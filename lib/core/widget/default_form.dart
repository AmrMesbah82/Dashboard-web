import 'package:web_app_admin/core/widget/arabic_format.dart';
import 'package:web_app_admin/core/widget/context.dart';
import 'package:web_app_admin/core/widget/format_helper.dart';
import 'package:web_app_admin/core/widget/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';




class DefaultFormField extends StatelessWidget {
  DefaultFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.showBorder,
    this.enabledBorder,
    this.textAlign,
    this.width,
    this.inputTextStyle,
    this.hintStyle,
    this.style,
    this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backGroundColor,
    this.onChanged,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.prefixIcon2,
    this.label,
    this.readOnly,
    this.enabled,
    this.onTap,
    this.top,
    this.bottom,
    this.maxLength,
    this.expands,
    this.keyboardType,
    this.autovalidateMode,
    this.height,
    this.labelText,
    this.minLines,
    this.maxLines,
    this.collapsed,
    this.errorHeight,
    this.textDirection,
    this.alignCounterTextLeft = false,
    this.showCounter = false,
    this.helperText,
    this.focusNode,
    this.radius,
    this.initialValue,
    this.inputFormatters, // Add this parameter
  });

  final TextAlign? textAlign;
  final int? maxLength;
  final double? errorHeight;
  final bool? collapsed;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle, style;
  final String? hintText;
  final bool? isObscureText, readOnly, enabled, showBorder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefixIcon2;
  final Widget? label;
  final Color? backGroundColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double? top, bottom;
  final double? height;
  final double? width;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onTap;
  final bool? expands;
  final TextInputType? keyboardType;
  final String? labelText;
  final int? minLines;
  final int? maxLines;
  final TextDirection? textDirection;
  final bool alignCounterTextLeft;
  final bool showCounter;
  final String? helperText;
  final FocusNode? focusNode;
  final double? radius;
  final List<TextInputFormatter>? inputFormatters; // Add this property
  bool isShowError = false;
  String? errorText = '';
  String? initialValue;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height?.h,
            child: TextFormField(
              initialValue: initialValue,
              inputFormatters: [
                // Combine custom formatters with the Arabic number formatter
                if (inputFormatters != null) ...inputFormatters!,
                if (context.isArabic && inputFormatters == null)
                  ArabicNumberFormatter(),
              ],
              buildCounter: (context,
                  {required currentLength,
                    required isFocused,
                    required maxLength}) =>
              const SizedBox.shrink(),
              focusNode: focusNode,
              textDirection: textDirection,
              textInputAction: TextInputAction.done,
              keyboardType: keyboardType,
              expands: expands ?? false,
              autovalidateMode:
              autovalidateMode ?? AutovalidateMode.onUserInteraction,
              onTap: onTap,
              controller: controller,
              onChanged: onChanged,
              minLines: minLines,
              maxLines: maxLines ?? 1,
              readOnly: readOnly ?? false,
              enabled: enabled,
              maxLength: maxLength,
              textAlignVertical: (height ?? 0) < 60.h
                  ? TextAlignVertical.center
                  : TextAlignVertical.top,
              textAlign: textAlign ?? TextAlign.start,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                helperText: helperText,
                counterStyle: GoogleFonts.cairo(
                  color: AppColors.lightGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: context.isTablett ? 13.sp : 10.sp,
                ),
                hoverColor: Colors.transparent,
                hintStyle:
                hintStyle ?? AppTextStyles.font12RegularSecondaryTextCairo,
                isCollapsed: collapsed ?? false,
                errorStyle: const TextStyle(fontSize: 0),
                labelText: labelText,
                prefixIcon: prefixIcon != null
                    ? Container(
                  height: 16.sp,
                  padding: EdgeInsets.symmetric(
                      vertical: 6.sp, horizontal: 0.sp),
                  child: prefixIcon,
                )
                    : null,
                label: label,
                contentPadding:   EdgeInsets.symmetric(horizontal: 8.w,vertical: 8.h),
                focusedBorder: focusedBorder ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius ?? 6.r),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: showBorder ?? false
                    ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide.none,
                )
                    : InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: const BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                hintText: hintText,
                suffixIcon: suffixIcon != null
                    ? Container(
                  height: 16.sp,
                  width: 16.sp,
                  padding: EdgeInsets.symmetric(
                      vertical: 8.r, horizontal: 8.r),
                  child: suffixIcon,
                )
                    : null,
                fillColor: backGroundColor ?? AppColors.card,
                filled: true,
              ),
              obscureText: isObscureText ?? false,
              style: style ??
                  AppTextStyles.font14BlackCairoRegular
                      .copyWith(locale: Get.locale),
              validator: (value) {
                var flag = validator?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isShowError = flag != null;
                    if (isShowError) {
                      errorText = flag;
                    } else {
                      flag = '';
                    }
                  });
                });
                return flag;
              },
            ),
          ),
          if (showCounter) ...[
            verticalSpace(4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection:
              alignCounterTextLeft ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (isShowError)
                  Text(
                    errorText!,
                    style: AppTextStyles.font12RedRegularCairo,
                  ),
                const Spacer(),
                Text(
                  alignCounterTextLeft
                      ? "${FormDateTimeHelper.formatInt(maxLength ?? 0).toArabicNumbers()}/${FormDateTimeHelper.formatInt(controller?.text.length ?? 0).toArabicNumbers()}"
                      : "${controller?.text.length}/$maxLength",
                  style: GoogleFonts.cairo(
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: context.isTablett ? 13.sp : 14.sp,
                  ),
                ),
              ],
            ),
          ],
          if (isShowError && showCounter == false) ...[
            verticalSpace(4),
            Text(
              errorText ?? '',
              style: AppTextStyles.font12RedRegularCairo,
            )
          ]
        ],
      ),
    );
  }
}




