// ******************* FILE INFO *******************
// File Name: custom_field.dart
// Description: Project-adapted CustomTextField.
//   Border rule: NO border by default; red border only when [errorText] is set.
//   Default height 36 / radius 4. Adapted to web_app_admin theme.
//   ADDED: [labelTrailing] — widget pinned to the END of the label row
//          (used e.g. to align a Status/Visibility switch with the field end).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

/// Custom text field widget.
///
/// Border rule: NO border by default; red border only when [errorText] is set.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? hint;
  final String? label;

  /// Optional widget pinned to the END of the label row (same width as the
  /// field). Used e.g. to align a Status switch with the end of this field.
  final Widget? labelTrailing;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool required;

  // ── Call-site compatibility (mirrors the legacy field widget) ─────────────
  /// Alias for [required].
  final bool isRequired;

  /// Kept for call-site compatibility — ignored internally (borderless design).
  final Color? primaryColor;

  /// Kept for call-site compatibility — ignored internally.
  final int minLength;

  /// Alias for [valueStyle] (legacy name).
  final TextStyle? textStyle;

  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? valueStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? counterStyle;
  final double? width;
  final double? height;
  final bool submitted;
  final bool onlyDigits;
  final bool restrictByDirection;
  final bool autoCapitalize;
  final bool showCharCount;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hint,
    this.label,
    this.labelTrailing,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.isRequired = false,
    this.primaryColor,
    this.minLength = 0,
    this.textStyle,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onTap,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.valueStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.counterStyle,
    this.width,
    this.height = 36,
    this.submitted = false,
    this.onlyDigits = false,
    this.restrictByDirection = false,
    this.autoCapitalize = false,
    this.showCharCount = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _obscured = true;

  int _charCount = 0;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _focusNode.addListener(_onFocusChange);

    if (_needsTextListener) {
      _charCount = _controller.text.length;
      _controller.addListener(_onTextChange);
    }
  }

  void _onFocusChange() {
    setState(() {});
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() => _charCount = _controller.text.length);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_needsTextListener) _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _isMultiline => (widget.maxLines ?? 1) != 1 || widget.minLines != null;

  int? get _effectiveMaxLength =>
      widget.maxLength ?? (widget.showCharCount ? 500 : null);

  bool get _showCounter => widget.showCharCount || widget.maxLength != null;

  bool get _hasValidation =>
      widget.submitted || widget.onlyDigits || widget.restrictByDirection;

  bool get _needsTextListener => _showCounter || _hasValidation;

  String? get _resolvedError {
    final explicit = widget.errorText;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (!_hasValidation) return null;

    final text = _controller.text;
    final isEmpty = text.trim().isEmpty;
    final isRtl = widget.textDirection == TextDirection.rtl;
    final hasArabic = RegExp(r'[؀-ۿ]').hasMatch(text);

    if (widget.submitted && isEmpty) {
      return isRtl ? 'هذا الحقل مطلوب' : 'This field is required.';
    }
    if (!isEmpty && widget.restrictByDirection) {
      if (!isRtl && hasArabic) return 'Please use English characters only.';
      if (isRtl && !RegExp(r'^[؀-ۿ\s]+$').hasMatch(text)) {
        return 'الرجاء استخدام الأحرف العربية فقط.';
      }
    }
    if (widget.onlyDigits &&
        text.isNotEmpty &&
        !RegExp(r'^\d+$').hasMatch(text)) {
      return 'Only numbers are allowed.';
    }
    return null;
  }

  List<TextInputFormatter>? get _resolvedFormatters {
    final list = <TextInputFormatter>[];
    if (widget.autoCapitalize &&
        widget.textDirection != TextDirection.rtl &&
        !widget.onlyDigits) {
      list.add(_CapitalizeTextFormatter());
    }
    if (widget.restrictByDirection) {
      if (widget.textDirection == TextDirection.rtl) {
        list.add(_ArabicOnlyInputFormatter());
      } else if (!widget.onlyDigits) {
        list.add(_EnglishOnlyInputFormatter());
      }
    }
    if (widget.onlyDigits) {
      list.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.inputFormatters != null) list.addAll(widget.inputFormatters!);
    return list.isEmpty ? null : list;
  }

  bool get _effectiveObscure =>
      widget.obscureText && !_isMultiline && _obscured;

  @override
  Widget build(BuildContext context) {
    final resolvedError = _resolvedError;
    final hasError = resolvedError != null && resolvedError.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;

    Widget? resolvedSuffix = widget.suffixIcon;
    if (resolvedSuffix == null && widget.obscureText && !_isMultiline) {
      resolvedSuffix = GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Icon(
          _obscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: hasError
              ? AppColors.red
              : isDisabled
                  ? AppColors.text.withValues(alpha: 0.3)
                  : AppColors.text.withValues(alpha: 0.5),
        ),
      );
    }

    final effectivePadding = widget.contentPadding ??
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h);

    final Widget labelText = RichText(
      text: TextSpan(
        text: widget.label,
        style: widget.labelStyle ??
            StyleText.fontSize12Weight500.copyWith(
              color: hasError
                  ? AppColors.red
                  : isDisabled
                      ? AppColors.text.withValues(alpha: 0.4)
                      : AppColors.text,
            ),
        children: (widget.required || widget.isRequired)
            ? [
                TextSpan(
                  text: ' *',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.red),
                )
              ]
            : [],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label (+ optional trailing widget pinned to the field end) ──────
        if (widget.label != null) ...[
          widget.labelTrailing != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: labelText),
                    widget.labelTrailing!,
                  ],
                )
              : labelText,
          SizedBox(height: 6.h),
        ],

        // ── Field ───────────────────────────────────────────────────────────
        SizedBox(
          width: widget.width?.w,
          height: widget.height?.h,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _effectiveObscure,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: _effectiveMaxLength,
            keyboardType: _isMultiline
                ? TextInputType.multiline
                : (widget.keyboardType ??
                    (widget.onlyDigits ? TextInputType.number : null)),
            inputFormatters: _resolvedFormatters,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: widget.valueStyle ??
                widget.textStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: isDisabled
                      ? AppColors.text.withValues(alpha: 0.4)
                      : AppColors.text,
                ),
            buildCounter: _effectiveMaxLength != null
                ? (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink()
                : null,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: effectivePadding,
              filled: true,
              hoverColor: Colors.transparent,
              fillColor: isDisabled
                  ? (widget.fillColor ?? AppColors.card).withValues(alpha: 0.5)
                  : widget.fillColor ?? AppColors.card,
              border: OutlineInputBorder(
                borderRadius: radius,
                borderSide: hasError
                    ? BorderSide(color: AppColors.red, width: 1.5.w)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: hasError
                    ? BorderSide(color: AppColors.red, width: 1.5.w)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: hasError
                    ? BorderSide(color: AppColors.red, width: 1.5.w)
                    : BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
              ),
              hintText: widget.hint,
              hintStyle: widget.hintStyle ??
                  StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text.withValues(alpha: 0.4),
                  ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: resolvedSuffix != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 12.w),
                      child: resolvedSuffix,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(),
              errorText: null,
              helperText: null,
              counterText: '',
            ),
          ),
        ),

        // ── Error / Helper / Counter row ────────────────────────────────────
        if (hasError || widget.helperText != null || _showCounter) ...[
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: hasError
                    ? Text(
                        resolvedError,
                        style: widget.errorStyle ??
                            StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.red),
                      )
                    : widget.helperText != null
                        ? Text(
                            widget.helperText!,
                            style: widget.helperStyle ??
                                StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.text.withValues(alpha: 0.5),
                                ),
                          )
                        : const SizedBox.shrink(),
              ),
              if (_showCounter && _effectiveMaxLength != null) ...[
                SizedBox(width: 8.w),
                Text(
                  '$_charCount / ${_effectiveMaxLength}',
                  style: widget.counterStyle ??
                      StyleText.fontSize12Weight400.copyWith(
                        color: _charCount > _effectiveMaxLength!
                            ? AppColors.red
                            : AppColors.text.withValues(alpha: 0.4),
                      ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private input formatters (self-contained)
// ─────────────────────────────────────────────────────────────────────────────

class _ArabicOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final hasEnglishLetters = RegExp(r'[a-zA-Z]').hasMatch(newValue.text);
    if (hasEnglishLetters) return oldValue;
    return newValue;
  }
}

class _EnglishOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final hasArabicCharacters = RegExp(r'[؀-ۿ]').hasMatch(newValue.text);
    if (hasArabicCharacters) return oldValue;
    return newValue;
  }
}

class _CapitalizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final capitalizedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}
