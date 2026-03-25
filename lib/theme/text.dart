// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing the app text styles that are used in the app.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';



abstract class AppTextStyles {
  static final _storage = GetStorage();

  // ✅ CHANGED: Made font families getters that read from storage
  static String get englishFontFamily => _storage.read('font') ?? 'Cairo';
  static String get arabicFontFamily => _storage.read('font_arabic') ?? 'CairoArabic';

  // Helper method to apply font family based on locale
  static TextStyle _withFontFamily(TextStyle style) {
    return style.copyWith(
      fontFamily: Get.locale?.languageCode == 'en'
          ? englishFontFamily
          : arabicFontFamily,
    );
  }

  // --------------------- REGULAR Text Styles - w400 ---------------------
  static TextStyle get font10LightGreyRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.lightGrey,
      fontSize: 10.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font26BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 26.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font20BlackCairoSemiBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get redFont12CairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.red,
      fontWeight: AppFontWeights.regular,
    ),
  );
  static TextStyle get font16SecondaryBlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font10RegularMonserrat => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font10BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font10FullBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font16FullBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font10BlackRegularInter => _withFontFamily(
    GoogleFonts.inter(
      color: AppColors.text,
      fontSize: 10.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12PrimaryColorRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12LightGreyRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12SecondaryBlackMontserratRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12MediumGreyRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.mediumGrey,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font15MediumInverseBaseRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 15.sp,
      color: AppColors.inverseBase,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12RedRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.red,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );  static TextStyle get font12BlackCairoBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.bold,
    ),
  );

  static TextStyle get font12BlackCairoSemiBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font12FullBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );
  static TextStyle get font11FullBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 11.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12FullBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12SecondaryBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font10SecondaryBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12BlueCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.blue,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14BlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12darkWhiteShadowRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.darkWhiteShadow,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font16inverseBaseRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.inverseBase,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14FullBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14FullBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.fullBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font14SecondaryBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14SecondaryBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16LightGreyRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font16PrimaryColorRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.primary,
      fontSize: 16.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font16BlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 16.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font16WhiteRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: Colors.white,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font18SecondaryBlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font19WhiteRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 19.sp,
      color: Colors.white,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font19BlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 19.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font19BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 19.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font19LightGreyRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 19.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font20BlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 20.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font23BlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 23.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font12SpanTextCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.spanText,
      fontSize: 12.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );
  static TextStyle get font11SpanTextCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.spanText,
      fontSize: 11.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14SpanTextCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.spanText,
      fontSize: 12.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font10SpanTextCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.spanText,
      fontSize: 10.sp,
      fontWeight: AppFontWeights.regular,
    ),
  );

  // --------------------- MEDIUM Text Styles - w500 ---------------------
  static TextStyle get font8SecondaryBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 8.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font8SecondaryBlackRegularCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 8.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font10BlueCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: AppColors.blue,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12PrimaryColorMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font10BlackCairoMediam => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: Color(0xff797979),
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12InputColorCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.inputColor,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12BlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12LighterGreyMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.lighterGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font10LighterGreyMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: AppColors.lighterGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12ButtonCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.textButton,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12SecondaryBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16TextMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12secondaryPrimaryCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12WhiteCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.background,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font13SecondaryBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 13.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12SecondaryBlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.secondaryBlack,
      fontSize: 12.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font14SecondaryBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font14BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font14BlueCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.lightBlue,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16whiteCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.white,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font14TextButtonCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.textButton,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16MediumMonserrat => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16BlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.inputColor,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16SecondaryPrimaryCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16SecondaryBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16SecondaryYelloCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16ButtonMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.textButton,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16MediumDarkGreyCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.darkGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16MediumInverseBaseCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.inverseBase,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16MediumSecondaryTextCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryText,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font12RegularSecondaryTextCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.secondaryText,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font14MediumSecondaryTextCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.secondaryText,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font20MediumSecondaryTextCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.secondaryText,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16LightGreyMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16InputColorCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.inputColor,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16SecondaryBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font16PrimaryColorMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 18.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18ButtonMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.textButton,
      fontSize: 18.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18SecondaryPrimaryCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18secondaryPrimaryMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18SecondaryBlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font18SecondaryBlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font19DarkGreyMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.darkGrey,
      fontSize: 19.sp,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font20BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font20BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font23MediumDarkGreyCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 23.sp,
      color: AppColors.darkGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font23LightGreyMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 23.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font23MediumBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 23.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font28BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 28.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font45BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 45.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );


  static TextStyle get font36BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 36.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font21BlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 21.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font36MediumBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 36.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font24MediumBlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 24.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  // --------------------- SEMI-BOLD Text Styles - w600 -------------------
  static TextStyle get font10WhiteSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 10.sp,
      color: Colors.white,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font12GrayCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.grey,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font12DarkGrayCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.darkGrey,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font14DarkGrayCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.darkGrey,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font14BlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font18BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 18.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font20BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font20SecondaryBlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font26BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 26.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font28BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 28.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font14BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font16BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font16SecondaryPrimarySemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font19SecondaryPrimarySemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 19.sp,
      color: AppColors.secondaryPrimary,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font14MontserratNumber => _withFontFamily(
    GoogleFonts.montserrat(
      fontSize: 14.sp,
      color: const Color(0xB31A1A1A),
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  // --------------------- BOLD Text Styles - w700 -----------------------
  static TextStyle get font12LightGreyBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 12.sp,
      color: AppColors.lightGrey,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font16WhiteBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: Colors.white,
      fontWeight: AppFontWeights.bold,
    ),
  );

  static TextStyle get font16PrimaryColorBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 16.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.bold,
    ),
  );

  static TextStyle get font14PrimaryColorSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 14.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font23PrimaryColorBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 23.sp,
      color: AppColors.primary,
      fontWeight: AppFontWeights.bold,
    ),
  );

  static TextStyle get font23WhiteBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 23.sp,
      color: Colors.white,
      fontWeight: AppFontWeights.bold,
    ),
  );

  static TextStyle get font20BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font15BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 15.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font25BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 25.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font26BlackCairoRegular => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 26.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.regular,
    ),
  );

  static TextStyle get font23BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      color: AppColors.text,
      fontSize: 23.sp,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font30BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 30.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font30BlackCairoSemiBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 30.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font35BlackCairoSemiBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 35.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font22BlackCairoMedium => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 22.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font22BlackCairoSemiBold => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 22.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font20SecondaryBlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 20.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font30SecondaryBlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 30.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font25SecondaryBlackMediumCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 25.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.medium,
    ),
  );

  static TextStyle get font25SecondaryBlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 25.sp,
      color: AppColors.secondaryBlack,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font30BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 30.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font25BlackSemiBoldCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 25.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );

  static TextStyle get font26BlackCairo => _withFontFamily(
    GoogleFonts.cairo(
      fontSize: 26.sp,
      color: AppColors.text,
      fontWeight: AppFontWeights.semiBold,
    ),
  );
}
