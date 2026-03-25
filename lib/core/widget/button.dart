import 'dart:ui';


import 'package:web_app_admin/core/widget/svg_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:web_app_admin/theme/appcolors.dart';

Widget customButton({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  Color? textColor,
  Color? borderColor,
  TextStyle? textStyle,
})
{
  final isDark = Get.isDarkMode;

  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? (isDark ? Colors.white : Colors.black),
              ),
        ),
      ),
    ),
  );
}

Widget customButtonWithIcon({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  required double width,
  required double height,
  required double space,
  required double radius,
  required Color color,
  required IconData icon,
  required Color iconColor,
  required double iconSize,
})
{
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: space),
          Text(title, style: textStyle),
        ],
      ),
    ),
  );
}

Widget customButtonWithImage({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  required double height,
  required double space,
  required double radius,
  required Color color,
  required String image,
  required double widthImage,
  required double heightImage,
  required Color colorBorder,
  Color? svgColor,
  EdgeInsets? padding,
})
{
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: colorBorder),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: (title.trim().isEmpty && image.isNotEmpty)
          ? Center(
        child: CustomSvg(
          assetPath: image,
          height: heightImage,
          width: widthImage,
          color: svgColor ?? AppColors.textButton,
          fit: BoxFit.scaleDown,
        ),
      )
          : Padding(
        padding: padding ?? EdgeInsets.zero,
        child: (image.isNotEmpty)
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvg(
              assetPath: image,
              height: heightImage,
              width: widthImage,
              color: svgColor,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(width: space),
            Text(title, style: textStyle),
          ],
        )
            : Center( // ✅ Wrap text-only case with Center
          child: Text(title, style: textStyle),
        ),
      ),
    ),
  );
}
