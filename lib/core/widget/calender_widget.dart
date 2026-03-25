/// ******************* FILE INFO *******************
/// File Name: custom_drop_down.dart
/// Description: this is custom calender dropdown can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025


import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web_app_admin/core/widget/format.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';



class CustomDropdownFormFieldCalender extends StatefulWidget {
  final String? selectedValue;
  final double? widthIcon;
  final Color? dropdownColor;
  final double? heightIcon;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  final String Function(String?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final double? dropdownWidth;
  final Widget? hint;
  final String? label; // ✅ NEW
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
    this.iconPath
  }) : super(key: key);

  @override
  _CustomDropdownFormFieldCalenderState createState() => _CustomDropdownFormFieldCalenderState();
}

class _CustomDropdownFormFieldCalenderState extends State<CustomDropdownFormFieldCalender> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _dropdownKey.currentContext;
      if (context != null && mounted) {
        final box = context.findRenderObject() as RenderBox;
        setState(() {
          _popupWidth = box.size.width;
        });
      }
    });
  }
//         'assets/calender.svg',
  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
              widget.label!,
              style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text
              )
          ),
          SizedBox(height: (widget.spaceHeight ?? 6.h)),
        ],
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: widget.height?.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value: internalSelectedValue,
                  onChanged: (value) {
                    setState(() {
                      internalSelectedValue = value;
                      field.didChange(value);
                    });
                    widget.onChanged(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: widget.height?.h,
                    width: widget.width,
                    padding: EdgeInsets.only(left: 8.sp,right: 8.sp),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor ??
                          (AppColors.background),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: widget.dropdownWidth ?? _popupWidth ?? 100.sp,
                    maxHeight: 230.sp,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: lightMode ? ColorAppLight.whiteColor : ColorAppDark.background,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(false),
                      trackVisibility: MaterialStateProperty.all(false),
                      thickness: MaterialStateProperty.all(0),
                      radius: Radius.zero,
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: widget.height!.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return AppColors.primary;
                        }
                        return Colors.white;
                      },
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Builder(
                      builder: (context) {
                        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                        return Padding(
                          padding: EdgeInsets.only(
                            right: isArabic ? 0 : 0.sp,
                            left: isArabic ? 0.sp : 0,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/images/calender.svg',
                              width: 14.w,
                              height: 14.h,
                              fit: BoxFit.fill,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode ? ColorAppLight.blackButton : ColorAppDark.titleValue,
                  ),
                  items: widget.items.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit["key"],
                      child: Text(
                        FormatHelper.capitalize(unit["value"] ?? '',),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: lightMode ? ColorAppLight.blackButton : ColorAppDark.titleValue,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

