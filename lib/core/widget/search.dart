import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../custom/2-custom_textfield.dart';
import '../theme/app_theme.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';

class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.fillColor,
    this.hintText,
  });

  final TextEditingController controller;
  final Color? fillColor;
  final dynamic Function(String)? onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        controller: controller,
        onChanged: (v) => onChanged?.call(v),
        hint: hintText ?? "search",
        maxLines: 1,
        height: 36,
        borderRadius: BorderRadius.circular(8.r),
        fillColor: fillColor ?? AppColors.card,
        hintStyle: AppTextStyles.font14SecondaryBlackCairo.copyWith(
          height: 1,
          color: AppTheme.isDark
              ? AppColors.lightGrey
              : AppColors.secondaryBlack,
        ),
        prefixIcon: SvgPicture.asset(
          "assets/images/search_icon.svg",
          width: 24.w,
          height: 24.h,
          fit: BoxFit.contain,
          color: AppTheme.isDark
              ? AppColors.lightGrey
              : AppColors.secondaryBlack,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 8.h,
        ),
      ),
    );
  }
}
