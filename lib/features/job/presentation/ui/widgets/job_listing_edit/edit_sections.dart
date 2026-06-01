// ******************* FILE INFO *******************
// Part of: job_listing_edit.dart
// Contains: _showConfirmDialog, _jobInfoSection, _jobDetailsSection,
//           _benefitsSection

part of '../../pages/job_listing_edit.dart';

extension _JobEditSections on _JobListingEditPageState {
  // ═══════════════════════════════════════════════════════════════════════════
  //  CONFIRM DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required String imagePath,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 450.w,
          padding: EdgeInsets.all(30.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(imagePath, height: 120.h, fit: BoxFit.contain),
              SizedBox(height: 20.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: ColorPick.primary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Text(
                            confirmLabel,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  1. JOB INFORMATION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _jobInfoSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _field('Job Title', 'Text Here', _titleEn)),
              SizedBox(width: 16.w),
              Expanded(
                child: _fieldRtl('المسمى الوظيفي', 'أدخل النص هنا', _titleAr),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Department',
                  hint: Text('Select Department',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                  selectedValue: _department,
                  items: _kDepartments,
                  primaryColor: _cmsPrimary(context),
                  widthIcon: 18,
                  heightIcon: 18,
                  height: 36,
                  dropdownColor: AppColors.background,
                  onChanged: (val) => setState(() => _department = val),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Work Type',
                  dropdownColor: AppColors.background,
                  hint: Text('Select Work Type',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                  selectedValue: _workType,
                  items: _kWorkTypes,
                  primaryColor: _cmsPrimary(context),
                  widthIcon: 18,
                  heightIcon: 18,
                  height: 36,
                  onChanged: (val) => setState(() => _workType = val),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Employment Type',
                  dropdownColor: AppColors.background,
                  hint: Text('Select Employment Type',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                  selectedValue: _employmentType,
                  items: _kEmploymentTypes,
                  widthIcon: 18,
                  primaryColor: _cmsPrimary(context),
                  heightIcon: 18,
                  height: 36,
                  onChanged: (val) => setState(() => _employmentType = val),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 15.sp),
                    Row(
                      children: [
                        Expanded(
                          child: _field('Employment Duration', 'Text Number', _durationText),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: 120.w,
                          child: CustomDropdownFormFieldInvMaster(
                            label: "",
                            hint: Text('Duration',
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.secondaryText)),
                            primaryColor: _cmsPrimary(context),
                            selectedValue: _durationType,
                            items: _kDurations,
                            dropdownColor: AppColors.background,
                            widthIcon: 18,
                            heightIcon: 18,
                            height: 36,
                            onChanged: (val) =>
                                setState(() => _durationType = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Experience Levels',
                  dropdownColor: AppColors.background,
                  hint: Text('Select Experience Level',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                  primaryColor: _cmsPrimary(context),
                  selectedValue: _experienceLevel,
                  items: _kExperienceLevels,
                  widthIcon: 18,
                  heightIcon: 18,
                  height: 36,
                  onChanged: (val) => setState(() => _experienceLevel = val),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _field('Salary Range', 'Min Salary', _salaryMin),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(child: _field('  ', 'Max Salary', _salaryMax)),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 90.w,
                      child: CustomDropdownFormFieldInvMaster(
                        hint: Text('Currency',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.secondaryText)),
                        selectedValue: _currency,
                        items: _kCurrencies,
                        widthIcon: 18,
                        primaryColor: _cmsPrimary(context),
                        heightIcon: 18,
                        height: 36,
                        dropdownColor: AppColors.background,
                        onChanged: (val) => setState(() => _currency = val),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: _field('Required Qualification', 'Text Here', _qualificationEn),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _fieldRtl('المؤهلات المطلوبة', 'أدخل النص هنا', _qualificationAr),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: _field('Required Skills', 'Text Here', TextEditingController()),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _fieldRtl('المهارات المطلوبة', 'أدخل النص هنا', TextEditingController()),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          ...List.generate(
            _skills.length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(child: _field('', 'Skill', _skills[i]['en']!)),
                  SizedBox(width: 8.w),
                  Expanded(child: _fieldRtl('', 'مهارة', _skills[i]['ar']!)),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() {
                      _skills[i]['en']!.dispose();
                      _skills[i]['ar']!.dispose();
                      _skills.removeAt(i);
                    }),
                    child: Container(
                      width: 24.sp,
                      height: 24.sp,
                      decoration: const BoxDecoration(
                        color: ColorPick.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () => setState(
              () => _skills.add({
                'en': TextEditingController(),
                'ar': TextEditingController(),
              }),
            ),
            child: _addButton('Skill'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  2. JOB DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _jobDetailsSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('About This Position', 'Text Here', _aboutEn, maxLines: 4, height: 100),
          SizedBox(height: 8.h),
          _fieldRtl('', 'أدخل النص هنا', _aboutAr, maxLines: 4, height: 100),
          SizedBox(height: 14.h),
          _field('Requirements', 'Text Here', _requirementsEn, maxLines: 4, height: 100),
          SizedBox(height: 8.h),
          _fieldRtl('', 'أدخل النص هنا', _requirementsAr, maxLines: 4, height: 100),
          SizedBox(height: 14.h),
          _field('Preferred Skills', 'Text Here', _prefSkillsEn, maxLines: 4, height: 100),
          SizedBox(height: 8.h),
          _fieldRtl('', 'أدخل النص هنا', _prefSkillsAr, maxLines: 4, height: 100),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  3. BENEFITS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _benefitsSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(_benefits.length, (i) {
            final b = _benefits[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Benefit ${i + 1}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        b.values.forEach((c) => c.dispose());
                        _benefits.removeAt(i);
                      }),
                      child: Container(
                        width: 24.sp,
                        height: 24.sp,
                        decoration: const BoxDecoration(
                          color: ColorPick.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _field('Title', 'Text Here', b['titleEn']!),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _fieldRtl('العنوان', 'أدخل النص هنا', b['titleAr']!),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _field('Short Description', 'Text Here', b['descEn']!, maxLines: 3, height: 80),
                SizedBox(height: 8.h),
                _fieldRtl('وصف مختصر', 'أدخل النص هنا', b['descAr']!, maxLines: 3, height: 80),
                SizedBox(height: 16.h),
                if (i < _benefits.length - 1)
                  const Divider(color: Color(0xFFE8E8E8)),
              ],
            );
          }),
          GestureDetector(
            onTap: () => setState(
              () => _benefits.add({
                'titleEn': TextEditingController(),
                'titleAr': TextEditingController(),
                'descEn': TextEditingController(),
                'descAr': TextEditingController(),
              }),
            ),
            child: _addButton('Benefits'),
          ),
        ],
      ),
    );
  }
}
