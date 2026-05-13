// ******************* FILE INFO *******************
// File Name: custom_textformfield.dart
// Description: this is custom Text field can reuse
// Created by: Amr Mesbah
// Last Update: 28/3/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';

class CustomValidatedTextFieldMaster extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;

  /// Dynamic primary color from CMS branding (used for focused border,
  /// cursor, and text selection highlight).
  /// Falls back to AppColors.primary if not provided.
  final Color? primaryColor;

  /// Hard character cap (default 500)
  final int maxLength;

  /// Minimum character requirement (default 0 = no minimum)
  final int minLength;

  /// Custom validator function (optional)
  final String? Function(String?)? validator;

  /// Whether this field is required
  final bool isRequired;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = 36,
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.primaryColor,
    this.maxLength = 500,
    this.minLength = 0,
    this.validator,
    this.isRequired = false,
  });

  @override
  State<CustomValidatedTextFieldMaster> createState() =>
      _CustomValidatedTextFieldMasterState();
}

class _CustomValidatedTextFieldMasterState
    extends State<CustomValidatedTextFieldMaster> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomValidatedTextFieldMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _toArabicNum(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  String? _getValidationError() {
    final String text = widget.controller.text;
    final bool isEmpty = text.trim().isEmpty;

    // Check custom validator first
    if (widget.validator != null) {
      final customError = widget.validator!(widget.controller.text);
      if (customError != null) return customError;
    }

    // Check if field is required and empty
    if (widget.isRequired && widget.submitted && isEmpty) {
      return widget.textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    }

    // Check min length
    if (widget.submitted && !isEmpty && widget.minLength > 0 && text.trim().length < widget.minLength) {
      return widget.textDirection == TextDirection.rtl
          ? "الحد الأدنى ${widget.minLength} حرف"
          : "Minimum ${widget.minLength} characters required.";
    }

    // Language validation for English fields
    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);

    if (widget.textDirection == TextDirection.ltr && hasArabic && text.isNotEmpty) {
      return "Please use English characters only.";
    }

    // Language validation for Arabic fields
    if (widget.textDirection == TextDirection.rtl && hasEnglish && text.isNotEmpty) {
      return "الرجاء استخدام الأحرف العربية فقط.";
    }

    // Digits only validation
    if (widget.onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text)) {
      return "Only numbers are allowed.";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedPrimary = widget.primaryColor ?? Color(0xFF008037);
    final String? errorText = _getValidationError();
    final bool showError = errorText != null;

    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool showCounter = widget.showCharCount && !showError && widget.controller.text.isNotEmpty;

    final Color resolvedFill = widget.fillColor ??
        (lightMode ? const Color(0xFFF1F2ED) : AppColors.background);

    final List<TextInputFormatter> formatters = [
      if (widget.onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];

    final int currentLen = widget.controller.text.characters.length;
    final borderRadius = BorderRadius.circular(4.r);

    // Calculate proper content padding
    EdgeInsetsGeometry contentPadding;
    if (widget.maxLines > 1) {
      // For multi-line fields, use fixed vertical padding
      contentPadding = EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w);
    } else {
      // For single line fields, center vertically
      contentPadding = EdgeInsets.symmetric(
        vertical: (widget.height - 20).h / 2,
        horizontal: 12.w,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                textDirection: widget.textDirection,
                style: StyleText.fontSize12Weight600.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
        ],

        SizedBox(
          height: widget.height.h,
          width: widget.width,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: resolvedPrimary,
                onSurface: AppColors.text,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: resolvedPrimary.withOpacity(0.3),
                selectionHandleColor: resolvedPrimary,
                cursorColor: resolvedPrimary,
              ),
            ),
            child: TextFormField(

              controller: widget.controller,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              textDirection: widget.textDirection,
              textAlign: widget.textAlign,
              cursorColor: resolvedPrimary,
              autovalidateMode: AutovalidateMode.always,
              validator: (_) => showError ? errorText : null,
              keyboardType: widget.onlyDigits ? TextInputType.number : TextInputType.text,
              style: widget.textStyle ??
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged: (value) {
                if (widget.onChanged != null) widget.onChanged!(value);
                if (mounted) setState(() {});
              },
              inputFormatters: formatters,
              maxLength: widget.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofillHints: const [],
              decoration: InputDecoration(
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                hoverColor: Colors.transparent,
                hintText: widget.hint,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize12Weight400.copyWith(
                      color: lightMode ? const Color(0xFF9E9E9E) : ColorAppDark.titleKey,
                    ),
                filled: true,
                fillColor: resolvedFill,
                isDense: true,
                counterText: '',
                contentPadding: contentPadding,
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: const BorderSide(color: Colors.transparent, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: const BorderSide(color: Colors.transparent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: resolvedPrimary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // // Fixed-height lane: error OR counter OR nothing
        // SizedBox(
        //   height: 20.h,
        //   child: showError
        //       ? Padding(
        //     padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w),
        //     child: Container(
        //       width: double.infinity,
        //       child: Text(
        //         errorText,
        //         textAlign: widget.textDirection == TextDirection.rtl
        //             ? TextAlign.right
        //             : TextAlign.left,
        //         textDirection: widget.textDirection,
        //         style: TextStyle(
        //           fontSize: 10.sp,
        //           fontWeight: FontWeight.w500,
        //           height: 1.1,
        //           color: Colors.red,
        //         ),
        //       ),
        //     ),
        //   )
        //       : (showCounter
        //       ? Align(
        //     alignment: widget.textDirection == TextDirection.rtl
        //         ? Alignment.centerLeft
        //         : Alignment.centerRight,
        //     child: Text(
        //       widget.textDirection == TextDirection.rtl
        //           ? "${_toArabicNum(currentLen)}/${_toArabicNum(widget.maxLength)}"
        //           : "$currentLen/${widget.maxLength}",
        //       style: TextStyle(
        //         fontSize: 10.sp,
        //         color: const Color(0xFF9E9E9E),
        //       ),
        //     ),
        //   )
        //       : const SizedBox.shrink()),
        // ),
      ],
    );
  }
}