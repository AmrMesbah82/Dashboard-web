// ******************* FILE INFO *******************
// File Name: custom_dropdwon.dart
// Description: DEPRECATED SHIM — CustomDropdownFormFieldInvMaster is now a
//              thin wrapper around the single shared dropdown in
//              lib/core/custom/1-custom_dropdwon.dart. Keeps the legacy
//              Map<String,String> items API while delegating ALL
//              rendering/behaviour to the shared widget.
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../custom/1-custom_dropdwon.dart' as custom;
import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

class CustomDropdownFormFieldInvMaster extends StatelessWidget {
  final String? selectedValue;
  final double? widthIcon; // kept for compatibility — ignored
  final Color? primaryColor; // kept for compatibility — ignored
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
  final String? iconPath; // kept for compatibility — ignored
  final Map<String, Color>? itemColors;
  final bool showColorDots;
  final double borderRadius;

  const CustomDropdownFormFieldInvMaster({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.primaryColor,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.dropdownColor,
    this.label,
    this.iconPath,
    this.itemColors,
    this.showColorDots = false,
    this.borderRadius = 8.0,
  }) : super(key: key);

  Color? _getItemColor(Map<String, String> item) {
    if (itemColors == null) return null;
    final key = item['key'] ?? '';
    final value = item['value'] ?? '';
    return itemColors![key] ?? itemColors![value];
  }

  String? get _hintText {
    final h = hint;
    if (h is Text) return h.data;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = height ?? 36;

    final dropdownItems = items.map((item) {
      final Color? itemColor = _getItemColor(item);
      return custom.DropdownItem<String>(
        value: item['key'] ?? '',
        label: item['value'] ?? '',
        leading: (showColorDots && itemColor != null)
            ? Container(
                width: 8.sp,
                height: 8.sp,
                decoration:
                    BoxDecoration(color: itemColor, shape: BoxShape.circle),
              )
            : null,
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
      fillColor: dropdownColor ?? const Color(0xFFF1F2ED),
      borderRadius: BorderRadius.circular(borderRadius.r),
      triggerPadding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: ((fieldHeight - 20) / 2).h,
      ),
      itemHeight: fieldHeight.h,
      maxOverlayHeight: 225.h,
      valueStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize12Weight400
          .copyWith(color: AppColors.text.withValues(alpha: 0.4)),
    );

    if (width == null) return dropdown;
    return SizedBox(width: width, child: dropdown);
  }
}
