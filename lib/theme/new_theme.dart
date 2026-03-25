// legacy_theme_adapter.dart
// Drop this in place of old theme files
// It redirects old names to the new theme system


import 'package:flutter/material.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';

import 'app_theme.dart';

void updateButtonTextStyleContrast() {
  final isPrimaryDark = AppColors.primary.computeLuminance() < 0.5;
  final contrastColor = isPrimaryDark ? Colors.white : Colors.black;

  // ✅ Only override button-specific text color
}

// ===== Legacy Color Redirects (ColorAppLight, ColorAppDark) =====
abstract class ColorAppLight {
  static Color yellowColor = AppColors.yellow;
  static Color waitColor = AppColors.secondaryPrimary;
  static Color grayTextSla = AppColors.secondaryText;
  static Color masterGray = AppColors.secondaryText;
  static Color grayHead = AppColors.grey;
  static Color Grayy = AppColors.lighterGrey;
  static Color blueColor = AppColors.blue;
  static Color searchbar = AppColors.white;
  static Color lightGrayy = AppColors.lightGrey;
  static Color greenColor = AppColors.lightGreen;
  static Color lightRedColor = AppColors.crimson;
  static Color redColor = AppColors.red;
  static Color orangeColor = AppColors.orange;
  static Color greyButtonSaveLatter = AppColors.secondaryButton;
  static Color backGroundGray = AppColors.background;
  static Color blackButton = AppColors.blackButton;
  static Color get buttonTextColor =>
      AppColors.textButton; // 🔁 NEW: used only in buttons
  static Color naturalColorsBlack = AppColors.text;
  static Color get amberColor => AppColors.primary;
  static Color darkBlue = AppColors.header;
  static Color subTitleSubmit = AppColors.secondaryText;
  static Color grayNoButton = AppColors.secondaryButton;
  static Color whiteOp = AppColors.background;
  static Color whiteTable = AppColors.whiteDashboardTable;
  static Color black = AppColors.text;
  static Color whiteColor = AppColors.white;
}

abstract class ColorAppDark {
  static Color secondaryPrimary = AppColors.secondaryPrimary;
  static Color primary = AppColors.primary;
  static Color inputColor = AppColors.inputColor;
  static Color grey = AppColors.grey;
  static Color lightGrey = AppColors.lightGrey;
  static Color moreLightGrey = AppColors.moreLightGrey;
  static Color buttonTextColor = Colors.white; // 🔁 NEW: used only in buttons
  static Color mediumGrey = AppColors.mediumGrey;
  static Color darkGrey = AppColors.darkGrey;
  static Color blackShadow = AppColors.blackShadow;
  static Color green = AppColors.lightGreen;
  static Color greyDark = AppColors.greyDark;
  static Color red = AppColors.red;
  static Color blue = AppColors.blue;
  static Color field = AppColors.field;
  static Color text = AppColors.text;
  static Color darkRed = AppColors.darkRed;
  static Color base = AppColors.base;
  static Color inverseBase = AppColors.inverseBase;
  static Color dropShadow = AppColors.dropShadow;
  static Color borderCard = AppColors.borderCard;
  static Color message = AppColors.message;
  static Color messageText = AppColors.messageText;
  static Color border = AppColors.border;
  static Color get background => AppColors.background;
  static Color appBar = AppColors.appBar;
  static Color indicator = AppColors.indicator;
  static Color starredCard = AppColors.starredCard;
  static Color black = AppColors.black;
  static Color secondaryBlack = AppColors.secondaryBlack;
  static Color whiteShadow = AppColors.whiteShadow;
  static Color darkWhiteShadow = AppColors.darkWhiteShadow;
  static Color white = AppColors.white;
  static Color darkWhite = AppColors.darkWhite;
  static Color dialog = AppColors.dialog;
  static Color button = AppColors.button;
  static Color icon = AppColors.icon;
  static Color chatBackground = AppColors.chatBackground;
  static Color chatField = AppColors.chatField;
  static Color searchBar = AppColors.card;
  static Color searchBarText = AppColors.secondaryText;
  static Color searchBarIcon = AppColors.greyIcon;
  static Color buttonColorBlack = AppColors.blackButton;
  static Color cardColorDark = AppColors.card;
  static Color filterColorDark = AppColors.card;
  static Color unSelectFilterDark = AppColors.grey;
  static Color selectFilterDark = AppColors.white;
  static Color unselectFilterTextDark = AppColors.grey;
  static Color selectFilterTextDark = AppColors.black;
  static Color bottomNavigationBarColorDark = AppColors.card;
  static Color sideColor = AppColors.drawerColor;
  static Color titleKey = AppColors.grey;
  static Color labelColorDark = AppColors.white;
  static Color titleValue = AppColors.white;
}

// ===== Legacy TextStyle Redirects (StyleText) =====
abstract class StyleText {
  static TextStyle get fontSize8Weight400 =>
      AppTextStyles.font8SecondaryBlackRegularCairo;
  static TextStyle get fontSize10Weight400 =>
      AppTextStyles.font10BlackCairoRegular;
  static TextStyle get fontSize10Weight500 =>
      AppTextStyles.font10BlackCairoMediam;
  static TextStyle get fontSize10Weight700 =>
      AppTextStyles.font10WhiteSemiBoldCairo;
  static TextStyle get fontSize11Weight400 =>
      AppTextStyles.font10SecondaryBlackCairoRegular;
  static TextStyle get fontSize11Weight600 =>
      AppTextStyles.font12BlackCairoSemiBold;
  static TextStyle get fontSize12Weight400 =>
      AppTextStyles.font12BlackCairoRegular;
  static TextStyle get fontSize12Weight500 =>
      AppTextStyles.font12BlackMediumCairo;
  static TextStyle get fontSize12Weight600 =>
      AppTextStyles.font12SecondaryBlackCairoMedium;
  static TextStyle get fontSize13Weight400 =>
      AppTextStyles.font13SecondaryBlackCairo;
  static TextStyle get fontSize13Weight500 =>
      AppTextStyles.font13SecondaryBlackCairo;
  static TextStyle get fontSize13Weight600 =>
      AppTextStyles.font13SecondaryBlackCairo;
  static TextStyle get fontSize14Weight400 =>
      AppTextStyles.font14BlackCairoRegular;
  static TextStyle get fontSize14Weight500 =>
      AppTextStyles.font14BlackCairoMedium;
  static TextStyle get fontSize14Weight600 =>
      AppTextStyles.font14BlackSemiBoldCairo;
  static TextStyle get fontSize14Weight700 =>
      AppTextStyles.font14BlackSemiBoldCairo;
  static TextStyle get fontSize15Weight400 =>
      AppTextStyles.font15BlackCairoRegular;
  static TextStyle get fontSize15Weight500 =>
      AppTextStyles.font15BlackCairoRegular;
  static TextStyle get fontSize15Weight600 =>
      AppTextStyles.font15BlackCairoRegular;
  static TextStyle get fontSize16Weight400 =>
      AppTextStyles.font16BlackRegularCairo;
  static TextStyle get fontSize16Weight500 =>
      AppTextStyles.font16BlackMediumCairo;
  static TextStyle get fontSize16Weight600 =>
      AppTextStyles.font16BlackSemiBoldCairo;
  static TextStyle get fontSize16Weight700 =>
      AppTextStyles.font16BlackSemiBoldCairo;
  static TextStyle get fontSize18Weight500 =>
      AppTextStyles.font18BlackMediumCairo;
  static TextStyle get fontSize20Weight500 =>
      AppTextStyles.font20BlackCairoMedium;
  static TextStyle get fontSize20Weight600 =>
      AppTextStyles.font20BlackSemiBoldCairo;
  static TextStyle get fontSize22Weight700 =>
      AppTextStyles.font22BlackCairoSemiBold;
  static TextStyle get fontSize24Weight600 =>
      AppTextStyles.font24MediumBlackCairo;
  static TextStyle get fontSize28Weight600 =>
      AppTextStyles.font28BlackMediumCairo;
  static TextStyle get fontSize45Weight600 =>
      AppTextStyles.font28BlackMediumCairo;
}

// ===== Legacy ThemeData Redirects =====
ThemeData get lightTheme => AppTheme.lightTheme;
ThemeData get darkTheme => AppTheme.darkTheme;