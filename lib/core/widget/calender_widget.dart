/// ******************* FILE INFO *******************
/// File Name: calender_widget.dart
/// Description: DEPRECATED SHIM — CustomDropdownFormFieldCalender is now a
///              thin wrapper around the single shared dropdown in
///              lib/core/custom/1-custom_dropdwon.dart (calendar icon kept).
/// Created by: Amr Mesbah
/// Last Update: 12/7/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../custom/1-custom_dropdwon.dart' as custom;
import '../theme/appcolors.dart';
import '../theme/new_theme.dart';
import 'format.dart';

class CustomDropdownFormFieldCalender extends StatelessWidget {
  final String? selectedValue;
  final double? widthIcon; // kept for compatibility — ignored
  final Color? dropdownColor;
  final double? heightIcon; // kept for compatibility — ignored
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  final String Function(String?)? validator; // kept for compatibility
  final double? width;
  final double? height;
  final double? spaceHeight; // kept for compatibility — ignored
  final double? dropdownWidth; // kept for compatibility — ignored
  final Widget? hint;
  final String? label;
  final String? iconPath;

  const CustomDropdownFormFieldCalender({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.dropdownColor,
    this.label,
    this.iconPath,
  }) : super(key: key);

  String? get _hintText {
    final h = hint;
    if (h is Text) return h.data;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = height ?? 36;

    final dropdownItems = items.map((item) {
      return custom.DropdownItem<String>(
        value: item['key'] ?? '',
        label: FormatHelper.capitalize(item['value'] ?? ''),
      );
    }).toList();

    final hasSelection =
        items.any((e) => e['key'] == selectedValue) ? selectedValue : null;

    final dropdown = custom.CustomDropdown<String>(
      value: hasSelection,
      items: dropdownItems,
      onChanged: (v) => onChanged(v),
      hint: _hintText,
      label: label,
      labelStyle:
          StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      fillColor: dropdownColor ?? AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      triggerPadding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: ((fieldHeight - 20) / 2).h,
      ),
      itemHeight: fieldHeight.h,
      maxOverlayHeight: 230.sp,
      valueStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize12Weight400
          .copyWith(color: AppColors.text.withValues(alpha: 0.4)),
      suffixIcon: SvgPicture.asset(
        iconPath ?? 'assets/images/calender.svg',
        width: 14.w,
        height: 14.h,
        fit: BoxFit.fill,
        color: Colors.grey,
      ),
    );

    if (width == null) return dropdown;
    return SizedBox(width: width, child: dropdown);
  }
}
