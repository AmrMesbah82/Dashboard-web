// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing the app colors that are used in the app.

import 'package:flutter/material.dart';

import 'app_theme.dart';

abstract class AppColors {
  static Map<String, Color> currentThemeColors = AppTheme.lightThemeColors;


  // ----------------- Black & White Colors -----------------
  static Color get pending => currentThemeColors['pending']!;
  static Color get black => currentThemeColors['black']!;
  static Color get blackShadow => currentThemeColors['blackShadow']!;
  static Color get secondaryBlack => currentThemeColors['secondaryBlack']!;
  static Color get white => currentThemeColors['white']!;
  static Color get whiteShadow => currentThemeColors['whiteShadow']!;
  static Color get darkWhite => currentThemeColors['darkWhite']!;
  static Color get darkWhiteShadow => currentThemeColors['darkWhiteShadow']!;
  static Color get oddRowColor => currentThemeColors['oddRowColor']!;
  static Color get evenRowColor => currentThemeColors['evenRowColor']!;
  static Color get fullBlack => currentThemeColors['fullBlack']!;
  static Color get blackButton => currentThemeColors['blackButton']!;

  static Color get block => currentThemeColors['block']!;
  static Color get darkBackGround => currentThemeColors['darkBackGround']!;
  static Color get warning => currentThemeColors['warning']!;
  static Color get greyBack => currentThemeColors['greyBack']!;
  static Color get barrierColor => currentThemeColors['barrierColor']!;
  static Color get unBlock => currentThemeColors['unBlock']!;
  static Color get delete => currentThemeColors['delete']!;
  static Color get differentGrey => currentThemeColors['differentGrey']!;
  static Color get whiteDark => currentThemeColors['whiteDark']!;
  static Color get lightRed => currentThemeColors['lightRed']!;

  // ----------------- Primary Colors -----------------

  static Color get primary => currentThemeColors['primary']!;
  static Color get secondaryPrimary => currentThemeColors['secondaryPrimary']!;
  // ----------------- Components Colors -----------------
  static Color get header => currentThemeColors['header']!;
  static Color get text => currentThemeColors['text']!;
  static Color get inputColor => currentThemeColors['inputColor']!;
  static Color get button => currentThemeColors['button']!;
  static Color get textButton => AppTheme.contrastColor();
  static Color get secondaryPrimaryText => AppTheme.secondaryPrimaryText();
  static Color get icon => currentThemeColors['icon']!;
  static Color get card => currentThemeColors['card']!;
  static Color get field => currentThemeColors['field']!;
  static Color get appBar => currentThemeColors['appBar']!;
  static Color get dropShadow => currentThemeColors['dropShadow']!;
  static Color get borderCard => currentThemeColors['borderCard']!;
  static Color get message => currentThemeColors['message']!;
  static Color get messageText => currentThemeColors['messageText']!;
  static Color get background => currentThemeColors['background']!;
  static Color get switchOff => currentThemeColors['switchOff']!;

  static Color get indicator => currentThemeColors['indicator']!;
  static Color get starredCard => currentThemeColors['starredCard']!;
  static Color get border => currentThemeColors['border']!;
  static Color get navyBlue => currentThemeColors['navyBlue']!;

  static Color get dialog => currentThemeColors['dialog']!;
  static Color get chatBackground => currentThemeColors['chatBackground']!;
  static Color get chatField => currentThemeColors['chatField']!;
  static Color get fieldBorder => currentThemeColors['fieldBorder']!;
  static Color get totalBlack => currentThemeColors['totalBlack']!;
  static Color get greyDark => currentThemeColors['greyDark']!;

  // ----------------- Grey Colors -----------------
  static Color get grey => currentThemeColors['grey']!;
  static Color get lightGrey => currentThemeColors['lightGrey']!;
  static Color get moreLightGrey => currentThemeColors['moreLightGrey']!;
  static Color get mediumGrey => currentThemeColors['mediumGrey']!;
  static Color get darkGrey => currentThemeColors['darkGrey']!;
  static Color get lighterGrey => currentThemeColors['lighterGrey']!;
  static Color get darkerGrey => currentThemeColors['darkerGrey']!;
  static Color get greyIcon => currentThemeColors['greyIcon']!;
  static Color get drawerColor => currentThemeColors['drawerColor']!;
  static Color get lightPrimary => currentThemeColors['lightPrimary']!;

  // ----------------- Basic Colors -----------------
  static Color get base => currentThemeColors[
  'base']!; // *** anything white and converted to secondary black in dark mode ***
  static Color get inverseBase => currentThemeColors[
  'inverseBase']!; // *** anything secondary black and converted to white in dark mode ***

  // ----------------- Secondary Colors -----------------
  static Color get lightGreen => currentThemeColors['lightGreen']!;
  static Color get green => currentThemeColors['green']!;
  static Color get darkRed => currentThemeColors['darkRed']!;
  static Color get red => currentThemeColors['red']!;
  static Color get blue => currentThemeColors['blue']!;
  static Color get orange => currentThemeColors['orange']!;
  static Color get yellow => currentThemeColors['yellow']!;
  static Color get warming => currentThemeColors['warming']!;
  static Color get lightBlue => currentThemeColors['liteBlue']!;
  static Color get secondaryText => currentThemeColors['secondaryText']!;
  static Color get spanText => currentThemeColors['spanText']!;
  static Color get secondaryButton => currentThemeColors['secondaryButton']!;
  static Color get borderGrey => currentThemeColors['borderGrey']!;
  static Color get crimson => currentThemeColors['crimson']!;

  static Color get whiteDashboardTable =>
      currentThemeColors['whiteDashboardTable']!;
  static Color get darkDashboardTable =>
      currentThemeColors['darkDashboardTable']!;

  /// Create a list of colors to be used for the chart.
  static List<Color> colors = [
    AppColors.primary,
    AppColors.grey,
    AppColors.black,
    AppColors.secondaryPrimary,
  ];
}
