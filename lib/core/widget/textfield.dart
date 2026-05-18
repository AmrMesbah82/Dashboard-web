// ******************* FILE INFO *******************
// File Name: custom_textformfield.dart
// Description: this is custom Text field can reuse
// Created by: Amr Mesbah
// Last Update: 16/5/2026

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
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;

  /// Dynamic primary color from CMS branding (used for focused border,
  /// cursor, and text selection highlight).
  /// Falls back to AppColors.primary if not provided.
  final Color? primaryColor;

  /// Hard character cap (default 500)
  final int maxLength;

  // Kept for call-site compatibility — ignored internally
  final bool submitted;
  final bool isRequired;
  final int minLength;
  final String? Function(String?)? validator;

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
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.primaryColor,
    this.maxLength = 500,
    this.submitted = false,
    this.isRequired = false,
    this.minLength = 0,
    this.validator,
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

  @override
  Widget build(BuildContext context) {
    final Color resolvedPrimary = widget.primaryColor ?? const Color(0xFF008037);

    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool showCounter =
        widget.showCharCount && widget.controller.text.isNotEmpty;

    final Color resolvedFill = widget.fillColor ??
        (lightMode ? const Color(0xFFF1F2ED) : AppColors.background);

    final List<TextInputFormatter> formatters = [
      if (widget.onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];

    final int currentLen = widget.controller.text.characters.length;
    final borderRadius = BorderRadius.circular(4.r);

    EdgeInsetsGeometry contentPadding;
    if (widget.maxLines > 1) {
      contentPadding = EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w);
    } else {
      contentPadding = EdgeInsets.symmetric(
        vertical: (widget.height - 20).h / 2,
        horizontal: 12.w,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            textDirection: widget.textDirection,
            style: StyleText.fontSize12Weight600.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
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
            child: TextField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              textDirection: widget.textDirection,
              textAlign: widget.textAlign,
              cursorColor: resolvedPrimary,
              keyboardType:
              widget.onlyDigits ? TextInputType.number : TextInputType.text,
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
                hoverColor: Colors.transparent,
                hintText: widget.hint,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize12Weight400.copyWith(
                      color: lightMode
                          ? const Color(0xFF9E9E9E)
                          : ColorAppDark.titleKey,
                    ),
                filled: true,
                fillColor: resolvedFill,
                isDense: true,
                counterText: '',
                contentPadding: contentPadding,
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  const BorderSide(color: Colors.transparent, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  const BorderSide(color: Colors.transparent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: resolvedPrimary, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        if (showCounter)
          Align(
            alignment: widget.textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h, right: 4.w, left: 4.w),
              child: Text(
                widget.textDirection == TextDirection.rtl
                    ? "${_toArabicNum(currentLen)}/${_toArabicNum(widget.maxLength)}"
                    : "$currentLen/${widget.maxLength}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
      ],
    );
  }
}