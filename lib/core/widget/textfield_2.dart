
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';


class ArabicOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Block English letters (a-z, A-Z)
    final hasEnglishLetters = RegExp(r'[a-zA-Z]').hasMatch(newValue.text);

    if (hasEnglishLetters) {
      return oldValue; // Reject if contains English letters
    }

    return newValue; // Allow everything else (Arabic, numbers, punctuation, spaces)
  }
}

class EnglishOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Block Arabic characters
    final hasArabicCharacters = RegExp(r'[\u0600-\u06FF]').hasMatch(newValue.text);

    if (hasArabicCharacters) {
      return oldValue; // Reject if contains Arabic
    }

    return newValue; // Allow everything else (English, numbers, punctuation, spaces)
  }
}

// ✅ NEW: Capitalize Text Formatter
// ✅ IMPROVED: Capitalize Text Formatter
class CapitalizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize first letter of each word
    String capitalizedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      // Handle cases where word might start with special characters
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}

class CustomValidatedTextFieldInv extends StatelessWidget {
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
  final Color? fillColor;
  final String? errorText;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;

  // SVG prefix icon parameters
  final String? prefixSvgAsset;
  final double? prefixIconWidth;
  final double? prefixIconHeight;
  final EdgeInsetsGeometry? prefixPadding;
  final VoidCallback? onPrefixTap;
  final BoxConstraints? prefixConstraints;

  final int? maxLength;

  // ✅ NEW: Additional input formatters
  final List<TextInputFormatter>? additionalInputFormatters;

  // ✅ NEW: Auto-capitalize option
  final bool autoCapitalize;

  const CustomValidatedTextFieldInv({
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
    this.fillColor,
    this.errorText,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
    this.prefixSvgAsset,
    this.prefixIconWidth,
    this.prefixIconHeight,
    this.prefixPadding,
    this.onPrefixTap,
    this.prefixConstraints,
    this.maxLength = 500,
    this.additionalInputFormatters,
    this.autoCapitalize = true, // ✅ Default to true for auto-capitalization
  });

  String _toArabicNum(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  TextInputType _getKeyboardType() {
    if (keyboardType != null) {
      return keyboardType!;
    }
    return onlyDigits ? TextInputType.number : TextInputType.text;
  }

  // ✅ UPDATED: Get appropriate input formatters based on text direction
  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];

    // Add length limiter
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    // ✅ Add capitalize formatter if enabled and not Arabic and not digits-only
    if (autoCapitalize && textDirection == TextDirection.ltr && !onlyDigits) {
      formatters.add(CapitalizeTextFormatter());
    }

    // Add language-specific formatter
    if (textDirection == TextDirection.rtl) {
      formatters.add(ArabicOnlyInputFormatter());
    } else if (textDirection == TextDirection.ltr && !onlyDigits) {
      formatters.add(EnglishOnlyInputFormatter());
    }

    // Add digits-only formatter if needed
    if (onlyDigits) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    // ✅ Add any additional formatters passed from outside
    if (additionalInputFormatters != null) {
      formatters.addAll(additionalInputFormatters!);
    }

    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicField = textDirection == TextDirection.rtl;
    final bool isEnglishField = textDirection == TextDirection.ltr;

    final String text = controller.text;

    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);

    final bool isEmpty = text.trim().isEmpty;

    String? displayErrorText;
    bool showError = false;

    if (errorText != null && errorText!.isNotEmpty) {
      displayErrorText = errorText;
      showError = true;
    } else {
      showError = (submitted && isEmpty) ||
          (!isEmpty &&
              ((isEnglishField && hasArabic) ||
                  (isArabicField && hasEnglish) ||
                  isNotDigits));

      if (showError) {
        if (isEmpty) {
          displayErrorText = textDirection == TextDirection.rtl
              ? "هذا الحقل مطلوب"
              : "This field is required.";
        } else if (isEnglishField && hasArabic) {
          displayErrorText = "Please use English characters only.";
        }
        else if (isArabicField && !RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text)) {
          displayErrorText = "الرجاء استخدام الأحرف العربية فقط.";
        }
        else if (isNotDigits) {
          displayErrorText = "Only numbers are allowed.";
        }
      }
    }

    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    Widget? buildPrefixIcon() {
      if (prefixSvgAsset == null || prefixSvgAsset!.isEmpty) return null;

      final svg = SvgPicture.asset(
        prefixSvgAsset!,
        width: (prefixIconWidth ?? 16).w,
        height: (prefixIconHeight ?? 16).h,
      );

      final padded = Padding(
        padding: prefixPadding ?? EdgeInsets.symmetric(horizontal: 8.w),
        child: svg,
      );

      if (onPrefixTap != null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPrefixTap,
          child: padded,
        );
      }
      return padded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            textDirection: textDirection,
            textAlign: textDirection == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text
            ),
          ),
          SizedBox(height: 6.h),
        ],
        SizedBox(
          width: width?.w,
          height: height.h,
          child: TextFormField(
            controller: controller,
            cursorColor: AppColors.primary,
            maxLines: maxLines,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType: _getKeyboardType(),
            // ✅ Use the updated method to get formatters
            inputFormatters: _getInputFormatters(),
            style: textStyle ??
                StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text
                ),
            onChanged: (val) {
              if (onChanged != null) onChanged!(val);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8.w),
              hoverColor: Colors.transparent,
              hintText: hint,
              hintStyle: StyleText.fontSize12Weight500.copyWith(
                color: lightMode ? ColorAppLight.grayTextSla : ColorAppDark.darkGrey,
              ),
              filled: true,
              fillColor: fillColor ?? AppColors.background,
              isDense: true,
              counterText: '',
              prefixIcon: buildPrefixIcon(),
              prefixIconConstraints: prefixConstraints ??
                  BoxConstraints(
                    minWidth: (prefixIconWidth ?? 16).w + 16.w,
                    minHeight: (prefixIconHeight ?? 16).h,
                  ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                    color: showError ? Colors.red : Colors.transparent,
                    width: 1
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(color: Colors.transparent, width: 1),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                    color: showError ? Colors.red : AppColors.primary,
                    width: 1
                ),
              ),
            ),
          ),
        ),

        if (showError || showCharCount)
          SizedBox(
            height: 15.h,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: [
                  if (showError && displayErrorText != null)
                    Expanded(
                      child: Text(
                        displayErrorText!,
                        textDirection: textDirection,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.red,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else if (!showError && showCharCount)
                    Expanded(
                      child: Align(
                        alignment: textDirection == TextDirection.rtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          textDirection == TextDirection.rtl
                              ? "${_toArabicNum(maxLength ?? 500)}/${_toArabicNum(controller.text.length)}"
                              : "${controller.text.length}/${maxLength ?? 500}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: controller.text.length >= (maxLength ?? 500)
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}