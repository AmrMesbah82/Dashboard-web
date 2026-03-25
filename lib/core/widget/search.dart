/// ************************* FILE INFO *************************
/// File Name: app_search_text_field.dart
/// purpose: app custom search text field
/// Created by: Mohamed Elrashidy
/// Created on: 5/5/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:web_app_admin/core/widget/default_form.dart';
import 'package:web_app_admin/theme/app_theme.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';






class AppSearchTextField extends StatelessWidget {
  AppSearchTextField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.fillColor,
    this.hintText, // ✅ Added optional hint parameter
  });

  final TextEditingController controller;
  final Color? fillColor;
  final dynamic Function(String)? onChanged;
  final String? hintText; // ✅ Optional hint text
  // final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultFormField(
        height: 36,
        hintText: hintText ?? "search", // ✅ Use custom hint or default to search
        maxLines: 1,
        radius: 8.r,
        backGroundColor: fillColor ?? AppColors.card,
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
          color: AppTheme.isDark
              ? AppColors.lightGrey
              : AppColors.secondaryBlack,
        ),
        showBorder: true,
        collapsed: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 0.sp,
          vertical: 11.h,
        ),
        controller: controller,
        onChanged: onChanged,
        onTap: () {
          // hapticController.triggerHapticFeedback(
          //   vibration: VibrateType.lightImpact,
          //   hapticFeedback: HapticFeedback.lightImpact,
          // );
        },
      ),
    );
  }
}