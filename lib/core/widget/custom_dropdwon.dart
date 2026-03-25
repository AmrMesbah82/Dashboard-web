import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';

class CustomDropdownFormFieldInvMaster extends StatefulWidget {
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
  final String? label;
  final String? iconPath;
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

  @override
  State<CustomDropdownFormFieldInvMaster> createState() =>
      _CustomDropdownFormFieldInvMasterState();
}

class _CustomDropdownFormFieldInvMasterState
    extends State<CustomDropdownFormFieldInvMaster> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dropdownKey.currentContext;
      if (ctx != null && mounted) {
        final box = ctx.findRenderObject() as RenderBox;
        setState(() => _popupWidth = box.size.width);
      }
    });
  }

  // ── Color helper ──────────────────────────────────────────────────────────
  Color? _getItemColor(Map<String, String> item) {
    if (widget.itemColors == null) return null;
    final key   = item['key']   ?? '';
    final value = item['value'] ?? '';
    return widget.itemColors![key] ?? widget.itemColors![value];
  }

  // ── Dropdown item builder ─────────────────────────────────────────────────
  Widget _buildDropdownItem(Map<String, String> item) {
    final Color? itemColor = _getItemColor(item);

    if (widget.showColorDots && itemColor != null) {
      return Row(
        children: [
          Container(
            width: 8.sp,
            height: 8.sp,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item['value'] ?? '',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      item['value'] ?? '',
      style: StyleText.fontSize12Weight400.copyWith(
        color: itemColor ?? AppColors.text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Arrow icon ────────────────────────────────────────────────────────────
  Widget _arrowIcon() => Icon(
    Icons.keyboard_arrow_down_rounded,
    size: (widget.widthIcon ?? 18).sp,
    color: AppColors.secondaryBlack,
  );

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = widget.height ?? 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ───────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
          ),
          SizedBox(height: widget.spaceHeight ?? 6.h),
        ],

        // ── Dropdown container ───────────────────────────────────────────────
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: fieldHeight.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            validator: widget.validator,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value: widget.items.any(
                          (e) => e['key'] == internalSelectedValue)
                      ? internalSelectedValue
                      : null,
                  onChanged: (value) {
                    setState(() {
                      internalSelectedValue = value;
                      field.didChange(value);
                    });
                    widget.onChanged(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: fieldHeight.h,
                    width: widget.width?.w,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor ?? AppColors.card,
                      borderRadius:
                      BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: widget.dropdownWidth ??
                        _popupWidth ??
                        widget.width ??
                        100.w,
                    maxHeight: 225.h,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                      BorderRadius.circular(widget.borderRadius.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(false),
                      trackVisibility: MaterialStateProperty.all(false),
                      thickness: MaterialStateProperty.all(0),
                      radius: Radius.zero,
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: fieldHeight.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    overlayColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return AppColors.primary.withOpacity(0.1);
                      }
                      return null;
                    }),
                  ),
                  iconStyleData: IconStyleData(icon: _arrowIcon()),
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  items: widget.items.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit['key'],
                      child: _buildDropdownItem(unit),
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