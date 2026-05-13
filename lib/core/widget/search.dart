import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
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
    this.hintText,
  });

  final TextEditingController controller;
  final Color? fillColor;
  final dynamic Function(String)? onChanged;
  final String? hintText;

  Color _cmsHexColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {}
    return AppColors.primary;
  }

  Color _primaryFromState(HomeCmsState state) {
    return switch (state) {
      HomeCmsLoaded(:final data) => _cmsHexColor(data.branding.primaryColor),
      HomeCmsSaved(:final data)  => _cmsHexColor(data.branding.primaryColor),
      _                          => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color primary = _primaryFromState(cmsState);

        return Expanded(
          child: DefaultFormField(
            height: 36,
            hintText: hintText ?? "search",
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
              fit: BoxFit.contain,
              color: AppTheme.isDark
                  ? AppColors.lightGrey
                  : AppColors.secondaryBlack,
            ),
            // ── CMS-driven focused border ──
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
            showBorder: true,
            collapsed: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 0.sp,
              vertical: 11.h,
            ),
            controller: controller,
            onChanged: onChanged,
            onTap: () {},
          ),
        );
      },
    );
  }
}