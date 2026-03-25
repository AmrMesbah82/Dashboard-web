/// ******************* FILE INFO *******************
/// File Name: custom_textformfield.dart
/// Description: this is custom Text field can reuse
/// Created by: Amr Mesbah
/// Last Update: 07/3/2026

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

  /// Dynamic primary color from CMS branding (used for focused border).
  /// Falls back to AppColors.primary if not provided.
  final Color? primaryColor;

  /// Hard character cap (default 500)
  final int maxLength;

  /// Minimum character requirement (default 0 = no minimum)
  final int minLength;

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
    this.maxLength = 800,
    this.minLength = 0,
  });

  @override
  State<CustomValidatedTextFieldMaster> createState() =>
      _CustomValidatedTextFieldMasterState();
}

class _CustomValidatedTextFieldMasterState
    extends State<CustomValidatedTextFieldMaster> {

  // ── Listen to controller so we rebuild on every keystroke ─────────────────
  // This is what makes validation text, char counter, AND primaryColor
  // always reflect the latest values.
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomValidatedTextFieldMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent swaps the controller, re-wire the listener.
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
    // Triggers a rebuild so validation errors, char counter, and border color
    // all update in real time.
    if (mounted) setState(() {});
  }

  // ── Arabic numeral helper ──────────────────────────────────────────────────
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
    // primaryColor is re-read every build — because the parent calls
    // setState when the color picker changes, this widget rebuilds and
    // picks up the new color immediately.
    final Color resolvedPrimary = widget.primaryColor ?? AppColors.primary;

    final bool isArabicField  = widget.textDirection == TextDirection.rtl;
    final bool isEnglishField = widget.textDirection == TextDirection.ltr;
    final String text         = widget.controller.text;

    final bool hasArabic   = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish  = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        widget.onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
    final bool isEmpty    = text.trim().isEmpty;
    final bool isTooShort =
        !isEmpty && widget.minLength > 0 && text.trim().length < widget.minLength;

    final bool showError = (widget.submitted && isEmpty) ||
        (widget.submitted && isTooShort) ||
        (!isEmpty &&
            ((isEnglishField && hasArabic) ||
                (isArabicField && hasEnglish) ||
                isNotDigits));

    String errorText = '';
    if (isEmpty) {
      errorText = widget.textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    } else if (isTooShort) {
      errorText = widget.textDirection == TextDirection.rtl
          ? "الحد الأدنى ${widget.minLength} حرف"
          : "Minimum ${widget.minLength} characters required.";
    } else if (isEnglishField && hasArabic) {
      errorText = "Please use English characters only.";
    } else if (isArabicField && hasEnglish) {
      errorText = "الرجاء استخدام الأحرف العربية فقط.";
    } else if (isNotDigits) {
      errorText = "Only numbers are allowed.";
    }

    final bool lightMode   = Theme.of(context).brightness == Brightness.light;
    final bool showCounter = widget.showCharCount && !showError;

    final Color resolvedFill = widget.fillColor ??
        (lightMode ? AppColors.card : AppColors.background);

    final List<TextInputFormatter> formatters = [
      if (widget.onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];

    final int currentLen = widget.controller.text.characters.length;

    final borderRadius = BorderRadius.circular(4.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (widget.label != null) ...[
          Text(
            widget.label!,
            textDirection: widget.textDirection,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
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
            ),
            child: TextFormField(
              controller:    widget.controller,
              maxLines:      widget.maxLines,
              enabled:       widget.enabled,
              textDirection: widget.textDirection,
              textAlign:     widget.textAlign,
              keyboardType:
              widget.onlyDigits ? TextInputType.number : TextInputType.text,
              style: widget.textStyle ??
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged: widget.onChanged,
              inputFormatters: formatters,
              maxLength: widget.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofillHints: const [],
              decoration: InputDecoration(
                hoverColor:  Colors.transparent,
                hintText:    widget.hint,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize12Weight400.copyWith(
                      color: lightMode
                          ? ColorAppLight.grayTextSla
                          : ColorAppDark.titleKey,
                    ),
                filled:      true,
                fillColor:   resolvedFill,
                isDense:     true,
                counterText: '',
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
                  // ← always the latest picked color
                  borderSide: BorderSide(color: resolvedPrimary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  BorderSide(color: ColorAppLight.redColor, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  BorderSide(color: ColorAppLight.redColor, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // Fixed-height lane: error OR counter OR nothing
        SizedBox(
          height: 18.h,
          child: showError
              ? Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize:   10.sp,
                fontWeight: FontWeight.w700,
                height:     1.1,
                color:      ColorAppLight.redColor,
              ),
            ),
          )
              : (showCounter
              ? Align(
            alignment: widget.textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.textDirection == TextDirection.rtl
                  ? "${_toArabicNum(currentLen)}/${_toArabicNum(widget.maxLength)}"
                  : "$currentLen/${widget.maxLength}",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          )
              : const SizedBox.shrink()),
        ),
      ],
    );
  }
}