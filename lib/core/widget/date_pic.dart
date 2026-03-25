import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';


class DatePicker {
  Future<List<DateTime?>?> showDatePicker(
      BuildContext context,
      List<DateTime?> rangeDatePickerValueWithDefaultValue,
      DateTime? currentDate,
      CalendarDatePicker2Type? calendarType,
      {DateTime? firstDate}) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return showCalendarDatePicker2Dialog(
        context: context,
        dialogBackgroundColor: AppColors.card,
        barrierDismissible: true,
        value: rangeDatePickerValueWithDefaultValue,
        config: CalendarDatePicker2WithActionButtonsConfig(
          firstDate: firstDate ?? DateTime(1900),
          lastDate: DateTime(2100),

          dayBuilder: ({
            required DateTime date,
            BoxDecoration? decoration,
            bool? isDisabled,
            bool? isSelected,
            bool? isToday,
            TextStyle? textStyle,
          }) {
            return Center(
              child: Container(
                  width: 25.sp,
                  height: 25.sp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: isSelected == true
                          ? AppColors.secondaryPrimary
                          : AppColors.field,
                      border: Border.all(
                        color: date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year
                            ? AppColors.secondaryPrimary
                            : Colors.transparent,
                      )),
                  child: Center(
                      child: Text(
                        date.day.toString(),
                        style: AppTextStyles.font14BlackCairoRegular.copyWith(
                          color: isSelected == true
                              ? AppColors.textButton
                              : AppColors.text,
                        ),
                      ))),
            );
          },
          calendarViewMode: CalendarDatePicker2Mode.day,
          closeDialogOnCancelTapped: true,
          closeDialogOnOkTapped: true,
          currentDate: currentDate, //widget.dateTimeNow ?? DateTime.now(),
          centerAlignModePicker: true,
          dayBorderRadius: BorderRadius.circular(8),

          customModePickerIcon: SvgPicture.asset(
            'assets/images/downArrow.svg',
            fit: BoxFit.fitHeight,
            color: AppColors.secondaryPrimary,
            height: isTablet ? 16.sp : null,
          ),

          okButton: Material(
            color: Colors.transparent,
            child: GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(bottom: 0.sp),
                child: Container(
                  height: 38.sp,
                  width: isTablet ? 150.sp : 120.sp,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.secondaryPrimary,

                  ),
                  child: Center(
                    child: Text(
                      'Set Date'.tr,
                      style: AppTextStyles.font14BlackCairoRegular
                          .copyWith(color: AppColors.textButton),
                    ),
                  ),
                ),
              ),
            ),
          ),

          cancelButton: Material(
            color: Colors.transparent,
            child: GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(bottom: 0.sp),
                child: Container(
                  height: 38.sp,
                  width: isTablet ? 150.sp : 120.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.secondaryButton,
                  ),
                  child: Center(
                    child: Text(
                      'Cancel'.tr,
                      style: AppTextStyles.font14BlackCairoRegular.copyWith(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          lastMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 0 : 3.14,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.secondaryPrimary,
            ),
          ),
          nextMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 3.14 : 0,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.secondaryPrimary,
            ),
          ),
          weekdayLabelTextStyle: AppTextStyles.font16BlackRegularCairo
              .copyWith(color: AppColors.secondaryPrimary),

          controlsTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.secondaryPrimary),
          selectedYearTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.secondaryPrimary),
          selectedDayHighlightColor: AppColors.secondaryPrimary,
          dayTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.textButton),
          selectedDayTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.textButton),

          yearTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.text),
          todayTextStyle: AppTextStyles.font14BlackCairoRegular
              .copyWith(color: AppColors.text),
          buttonPadding:
          EdgeInsets.symmetric(horizontal: isTablet ? 35.sp : 14.sp),
          selectedRangeHighlightColor: AppColors.primary,
          calendarType: calendarType, //CalendarDatePicker2Type.range,
        ),
        dialogSize: isTablet ? Size(460.sp, 320.sp) : Size(320.w, 320.h),
        borderRadius: BorderRadius.circular(10),
        useSafeArea: true);
  }
}
