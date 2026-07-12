// ******************* FILE INFO *******************
// Part of: job_listing_edit.dart
// Contains: _applicationDetailsSection, _dateFieldCalendar, _docRow,
//           _bottomButtons, _actionButton, _accordion,
//           _field, _fieldRtl, _addButton

part of '../../pages/job_listing_edit.dart';

extension _JobEditFormHelpers on _JobListingEditPageState {
  // ═══════════════════════════════════════════════════════════════════════════
  //  4. APPLICATION DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _applicationDetailsSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _dateFieldCalendar(
                  label: 'Hiring Timeline (Start Date)',
                  date: _hiringStart,
                  onPicked: _setHiringStart,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _dateFieldCalendar(
                  label: 'Hiring Timeline (End Date)',
                  date: _hiringEnd,
                  onPicked: _setHiringEnd,
                  firstDate: _hiringStart,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Maximum Number of Applications for This Position',
                  'Text Here',
                  _maxApps,
                ),
              ),
              SizedBox(width: 16.w),
              const Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Required Documents',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          ...List.generate((_requiredDocs.length / 2).ceil(), (rowIndex) {
            final left = rowIndex * 2;
            final right = left + 1;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(child: _docRow(left)),
                  SizedBox(width: 16.w),
                  right < _requiredDocs.length
                      ? Expanded(child: _docRow(right))
                      : const Expanded(child: SizedBox()),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => setState(
              () => _requiredDocs.add({
                'name': TextEditingController(),
                'type': 'PDF',
              }),
            ),
            child: _addButton('Required Document'),
          ),
        ],
      ),
    );
  }

  Widget _dateFieldCalendar({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) {
    final displayValue =
        date != null ? DateFormat('dd/MM/yyyy').format(date) : null;
    final items = date != null
        ? [{'key': displayValue!, 'value': displayValue}]
        : <Map<String, String>>[];

    return GestureDetector(
      onTap: () => _pickDate(
        currentDate: date,
        onPicked: onPicked,
        firstDate: firstDate,
      ),
      child: AbsorbPointer(
        child: CustomDropdownFormFieldCalender(
          label: label,
          hint: Text(
            'Select Date',
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          selectedValue: displayValue,
          items: items,
          widthIcon: 18,
          heightIcon: 18,
          height: 36,
          dropdownColor: AppColors.background,
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _docRow(int i) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomTextField(
            controller: _requiredDocs[i]['name'] as TextEditingController,
            height: 36,
            valueStyle: TextStyle(fontSize: 12.sp),
            hint: 'Document Name',
            hintStyle:
                TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
            fillColor: AppColors.background,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 90.w,
          child: CustomDropdownFormFieldInvMaster(
            dropdownColor: AppColors.background,
            selectedValue: _requiredDocs[i]['type'] as String? ?? 'PDF',
            items: _kDocTypes,
            widthIcon: 16,
            heightIcon: 16,
            primaryColor: _cmsPrimary(context),
            height: 36,
            hint: Text(
              'Type',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            onChanged: (v) => setState(() => _requiredDocs[i]['type'] = v),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BOTTOM BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _bottomButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton('Preview', Colors.grey.shade400, () {
                navigateTo(
                  context,
                  JobListingPreviewPage(jobId: _editingJobId ?? 'new'),
                );
              }),
            ),
            SizedBox(width: 16.w),
            Expanded(
                child: _actionButton('Publish', ColorPick.primary, _publish)),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                'Discard',
                Colors.grey.shade300,
                () => context.pop(),
                textColor: AppColors.text,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _actionButton(
                'Save For Later',
                Colors.grey.shade600,
                _saveDraft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
    String label,
    Color bg,
    VoidCallback onTap, {
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ACCORDION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                        topLeft: Radius.circular(6.r),
                        topRight: Radius.circular(6.r),
                      )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              decoration: BoxDecoration(
                color: ColorPick.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FIELD HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl, {
    int maxLines = 1,
    double height = 36,
  }) {
    return CustomValidatedTextFieldMaster(
      label: label.isNotEmpty ? label : null,
      hint: hint,
      controller: ctrl,
      height: height,
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.start,
      showCharCount: false,
      maxLength: 500,
      minLength: 0,
      submitted: _submitted,
      primaryColor: _cmsPrimary(context),
      fillColor: AppColors.background,
      textStyle: TextStyle(fontSize: 12.sp, color: AppColors.text),
      hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
    );
  }

  Widget _fieldRtl(
    String label,
    String hint,
    TextEditingController ctrl, {
    int maxLines = 1,
    double height = 36,
  }) {
    return CustomValidatedTextFieldMaster(
      label: label.isNotEmpty ? label : null,
      hint: hint,
      controller: ctrl,
      height: height,
      maxLines: maxLines,
      textDirection: ui.TextDirection.rtl,
      textAlign: TextAlign.start,
      showCharCount: false,
      maxLength: 500,
      minLength: 0,
      submitted: _submitted,
      primaryColor: _cmsPrimary(context),
      fillColor: AppColors.background,
      textStyle: TextStyle(fontSize: 12.sp, color: AppColors.text),
      hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
    );
  }

  Widget _addButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFF797979),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
