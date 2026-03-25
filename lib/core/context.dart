// Date: 4/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 8/8/2024
// Objectives: This file is responsible for providing extensions to several classes in the project.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


extension ContextExtension on BuildContext {
  // ScreenInfo
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  bool get isTablett => MediaQuery.of(this).size.shortestSide >= 600;

  bool get isTabletRange500To600 =>
      MediaQuery.of(this).size.width >= 500 &&
          MediaQuery.of(this).size.width <= 600;
  bool get isTabletVer =>
      MediaQuery.of(this).size.width >= 600 &&
          MediaQuery.of(this).size.width < 800;

  bool get isArabic => Get.locale.toString().toLowerCase().contains('ar');
}



/// Extension to provide additional functionality to the bool type.
extension BoolExtension on bool {
  /// Toggles the boolean value and returns the opposite.
  bool toggle() {
    return !this;
  }
}
