import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:web_app_admin/core/theme/appcolors.dart';
import 'package:web_app_admin/core/theme/text.dart';




/// A customizable segmented tabs widget that can be reused throughout the app
///
/// Example usage:
/// ```dart
/// CustomSegmentedTabs(
///   tabs: ['المخطط', 'الجدول'],
///   selectedIndex: controller.selectedTabIndex,
///   onTabSelected: (index) {
///     controller.updateTabIndex(index);
///   },
/// )
/// ```
class CustomSegmentedTabs extends StatelessWidget {
  const CustomSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.containerPadding,
    this.containerColor,
    this.borderRadius,
    this.spacing,
    this.tabHorizontalPadding,
    this.tabVerticalPadding,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
    this.equalWidth = false,
  });

  /// List of tab titles
  final List<String> tabs;

  /// Currently selected tab index (0-based)
  final int selectedIndex;

  /// Callback when a tab is tapped, returns the index
  final ValueChanged<int> onTabSelected;

  /// Padding around the entire container
  final EdgeInsets? containerPadding;

  /// Background color of the container
  final Color? containerColor;

  /// Border radius of the container
  final double? borderRadius;

  /// Spacing between tabs
  final double? spacing;

  /// Horizontal padding for each tab
  final double? tabHorizontalPadding;

  /// Vertical padding for each tab
  final double? tabVerticalPadding;

  /// Background color for selected tab
  final Color? selectedColor;

  /// Background color for unselected tabs
  final Color? unselectedColor;

  /// Text color for selected tab
  final Color? selectedTextColor;

  /// Text color for unselected tabs
  final Color? unselectedTextColor;

  /// Custom text style (will be merged with color changes)
  final TextStyle? textStyle;

  /// If true, all tabs will have equal width
  final bool equalWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        color: containerColor ?? AppColors.field,
      ),
      padding: containerPadding ?? EdgeInsets.all(8.sp),
      child: Row(
        mainAxisSize: equalWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(tabs.length * 2 - 1, (index) {
          // Even indices are tabs, odd indices are spacers
          if (index.isOdd) {
            return SizedBox(width: spacing ?? 10.sp);
          }

          final tabIndex = index ~/ 2;
          final isSelected = tabIndex == selectedIndex;

          return equalWidth
              ? Expanded(
            child: _buildTab(
              title: tabs[tabIndex],
              isSelected: isSelected,
              onTap: () => onTabSelected(tabIndex),
            ),
          )
              : _buildTab(
            title: tabs[tabIndex],
            isSelected: isSelected,
            onTap: () => onTabSelected(tabIndex),
          );
        }),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isSelected
              ? (selectedColor ?? AppColors.primary)
              : (unselectedColor ?? AppColors.field),
        ),
        padding: EdgeInsets.symmetric(
          vertical: tabVerticalPadding ?? 6.sp,
          horizontal: tabHorizontalPadding ?? 6.sp,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              title.tr,
              style: (textStyle ?? AppTextStyles.font14BlackSemiBoldCairo).copyWith(
                height: 1,
                color: isSelected
                    ? (selectedTextColor ?? AppColors.textButton)
                    : (unselectedTextColor ?? AppColors.secondaryBlack),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Container(
// width: 130,
// height: 40,
// child: CustomSegmentedTabs(
// tabs: ['نشط', 'مكتمل'],
// selectedIndex: selectedIndex,
// onTabSelected: (index) => setState(() => selectedIndex = index),
// selectedColor: AppColors.secondaryPrimary,
// unselectedColor: AppColors.background,
// equalWidth: true,  // All tabs same width
// spacing: 15,
// ),
// ),