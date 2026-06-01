part of '../../pages/add_intern.dart';

extension _AddInternWidgets on _AddInternPageState {
  Future<void> _pickDate() async {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    final result = await showCalendarDatePicker2Dialog(
      context: context,
      dialogBackgroundColor: Colors.white,
      barrierDismissible: true,
      value: [_joinedDate],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        currentDate: _joinedDate ?? DateTime.now(),
        calendarType: CalendarDatePicker2Type.single,
        centerAlignModePicker: true,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,
        dayBuilder: ({required DateTime date, BoxDecoration? decoration, bool? isDisabled, bool? isSelected, bool? isToday, TextStyle? textStyle}) {
          final isNow = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;
          return Center(
            child: Container(
              width: 28.sp, height: 28.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: isSelected == true ? ColorPick.primary : const Color(0xFFF5F5F5),
                border: Border.all(color: isNow ? ColorPick.primary : Colors.transparent, width: 1.5),
              ),
              child: Center(
                child: Text(date.day.toString(), style: TextStyle(
                  fontSize: 11.sp,
                  color: isSelected == true ? Colors.white : isDisabled == true ? AppColors.secondaryText : AppColors.text,
                  fontWeight: isSelected == true ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            ),
          );
        },
        okButton: Material(
          color: Colors.transparent,
          child: Container(
            height: 38.sp, width: isTablet ? 140.sp : 110.sp,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: ColorPick.primary),
            child: Center(child: Text('Set Date', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600))),
          ),
        ),
        cancelButton: Material(
          color: Colors.transparent,
          child: Container(
            height: 38.sp, width: isTablet ? 140.sp : 110.sp,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: const Color(0xFFE0E0E0)),
            child: Center(child: Text('Cancel', style: TextStyle(color: ColorPick.discard, fontSize: 13.sp, fontWeight: FontWeight.w600))),
          ),
        ),
        selectedDayHighlightColor: ColorPick.primary,
        selectedRangeHighlightColor: ColorPick.primary.withValues(alpha: 0.15),
        weekdayLabelTextStyle: TextStyle(color: ColorPick.primary, fontSize: 12.sp, fontWeight: FontWeight.w600),
        controlsTextStyle: TextStyle(color: ColorPick.primary, fontSize: 13.sp, fontWeight: FontWeight.w600),
        dayTextStyle: TextStyle(color: AppColors.text, fontSize: 11.sp),
        selectedDayTextStyle: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600),
        todayTextStyle: TextStyle(color: ColorPick.primary, fontSize: 11.sp),
        yearTextStyle: TextStyle(color: AppColors.text, fontSize: 12.sp),
        buttonPadding: EdgeInsets.symmetric(horizontal: isTablet ? 30.sp : 12.sp),
      ),
      dialogSize: isTablet ? Size(440.sp, 310.sp) : Size(320.w, 320.h),
      borderRadius: BorderRadius.circular(12),
      useSafeArea: true,
    );

    if (result != null && result.isNotEmpty && result.first != null && mounted) {
      setState(() => _joinedDate = result.first);
    }
  }

  Widget _photoPicker() {
    final hasPhoto = _photoBytes != null || _photoUrl.isNotEmpty;
    final hasError = _submitted && !_isEdit && !hasPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Photo', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
        ]),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: _pickPhoto,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70.w, height: 70.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0E0E0),
                  image: _photoBytes != null
                      ? DecorationImage(image: MemoryImage(_photoBytes!), fit: BoxFit.cover,
                          onError: (e, s) => debugPrint('Error loading photo: $e'))
                      : _photoUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(_photoUrl), fit: BoxFit.cover,
                              onError: (e, s) => debugPrint('Error loading photo URL: $e'))
                          : null,
                ),
                child: hasPhoto ? null : Center(
                  child: CustomSvg(color: Colors.grey, assetPath: 'assets/control/camera.svg', width: 30.w, height: 30.h, fit: BoxFit.fill),
                ),
              ),
              Positioned(
                bottom: 0, left: 45.w,
                child: Container(
                  width: 24.w, height: 24.h,
                  decoration: BoxDecoration(color: ColorPick.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: Center(child: CustomSvg(assetPath: 'assets/control/camera.svg', width: 11.w, height: 11.h, fit: BoxFit.scaleDown)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateField() {
    final label = _joinedDate != null ? DateFormat('dd MMM yyyy').format(_joinedDate!) : 'Select Date';
    final hasError = _submitted && _joinedDate == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Joined Date', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
          Text(' *', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ]),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity, height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: hasError ? Colors.red : Colors.transparent, width: hasError ? 1.5 : 0),
            ),
            child: Row(children: [
              Expanded(
                child: Text(label, style: StyleText.fontSize12Weight400.copyWith(
                    color: _joinedDate != null ? AppColors.text : AppColors.secondaryText)),
              ),
              CustomSvg(assetPath: "assets/control/Calendar.svg", width: 16.w, height: 16.h,
                  fit: BoxFit.scaleDown, color: hasError ? Colors.red : null),
            ]),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text('Joined date is required', style: TextStyle(fontSize: 11.sp, color: Colors.red)),
        ],
      ],
    );
  }
}
