// ******************* FILE INFO *******************
// File Name: job_listing_edit_page.dart
// Created by: Amr Mesbah
// Purpose: Create / Edit Job Post — 4 accordion sections + publish dialogs
// Pattern: Same as home_edit_page.dart
// UPDATED: Firebase-backed via JobListingCubit.saveJob() — no static data
// FIXED: All dropdowns use CustomDropdownFormFieldInvMaster
// FIXED: All date pickers use CustomDropdownFormFieldCalender + DatePicker
// FIXED: BlocListener handles JobListingSaved — clears saving flag
// FIXED: _publish() and _saveDraft() no longer manually pop — main page handles it
// FIXED: Page title shows actual job title when editing

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web_app_admin/controller/job_list/job_listing_cubit.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/core/widget/calender_widget.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/date_pic.dart';
import 'package:web_app_admin/core/widget/date_picker.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/pages/dashboard/job_list/job_listing_main_page.dart';
import 'package:web_app_admin/pages/dashboard/job_list/job_listing_preview_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color remove    = Color(0xFFE53935);
}

const List<Map<String, String>> _kDepartments = [
  {'key': 'Design',      'value': 'Design'},
  {'key': 'Engineering', 'value': 'Engineering'},
  {'key': 'Marketing',   'value': 'Marketing'},
  {'key': 'HR',          'value': 'HR'},
  {'key': 'Finance',     'value': 'Finance'},
];

const List<Map<String, String>> _kWorkTypes = [
  {'key': 'On Site',  'value': 'On Site'},
  {'key': 'Remotely', 'value': 'Remotely'},
  {'key': 'Hybrid',   'value': 'Hybrid'},
];

const List<Map<String, String>> _kEmploymentTypes = [
  {'key': 'Full Time', 'value': 'Full Time'},
  {'key': 'Part Time', 'value': 'Part Time'},
];

const List<Map<String, String>> _kExperienceLevels = [
  {'key': 'Intern',     'value': 'Intern'},
  {'key': 'Junior',     'value': 'Junior'},
  {'key': 'Senior',     'value': 'Senior'},
  {'key': 'Leadership', 'value': 'Leadership'},
];

const List<Map<String, String>> _kDurations = [
  {'key': 'Open',  'value': 'Open'},
  {'key': 'Month', 'value': 'Month'},
  {'key': 'Week',  'value': 'Week'},
];

const List<Map<String, String>> _kCurrencies = [
  {'key': 'SAR', 'value': 'SAR'},
  {'key': 'USD', 'value': 'USD'},
  {'key': 'EUR', 'value': 'EUR'},
];

const List<Map<String, String>> _kDocTypes = [
  {'key': 'PDF',  'value': 'PDF'},
  {'key': 'Link', 'value': 'Link'},
];

class JobListingEditPage extends StatefulWidget {
  final String? jobId;
  const JobListingEditPage({super.key, this.jobId});

  @override
  State<JobListingEditPage> createState() => _JobListingEditPageState();
}

class _JobListingEditPageState extends State<JobListingEditPage> {
  bool _submitted = false;
  bool _isSaving  = false;
  bool _isActive  = true; // tracks active/inactive toggle

  final _titleEn         = TextEditingController();
  final _titleAr         = TextEditingController();
  String? _department;
  String? _workType;
  String? _employmentType;
  final _durationText    = TextEditingController();
  String? _durationType;
  String? _experienceLevel;
  final _salaryMin       = TextEditingController();
  final _salaryMax       = TextEditingController();
  String? _currency      = 'SAR';
  final _qualificationEn = TextEditingController();
  final _qualificationAr = TextEditingController();
  final List<Map<String, TextEditingController>> _skills = [];

  final _aboutEn        = TextEditingController();
  final _aboutAr        = TextEditingController();
  final _requirementsEn = TextEditingController();
  final _requirementsAr = TextEditingController();
  final _prefSkillsEn   = TextEditingController();
  final _prefSkillsAr   = TextEditingController();

  final List<Map<String, TextEditingController>> _benefits = [];

  DateTime? _hiringStart;
  DateTime? _hiringEnd;
  final _maxApps = TextEditingController();
  final List<Map<String, dynamic>> _requiredDocs = [];

  final Map<String, bool> _open = {
    'jobInfo': true, 'jobDetails': true, 'benefits': true, 'appDetails': true,
  };

  String? _editingJobId;

  @override
  void initState() {
    super.initState();
    _editingJobId = widget.jobId;
    if (_editingJobId != null) {
      _seedFromExisting();
    } else {
      _requiredDocs.addAll([
        {'name': TextEditingController(text: 'Resume'),       'type': 'PDF'},
        {'name': TextEditingController(text: 'Cover Letter'), 'type': 'PDF'},
      ]);
    }
  }

  void _seedFromExisting() {
    final cubit = context.read<JobListingCubit>();
    final job = cubit.allJobs.firstWhere(
          (j) => j.id == _editingJobId,
      orElse: () => JobPostModel.empty(),
    );

    _titleEn.text = job.title.en;
    _titleAr.text = job.title.ar;
    _department      = job.department.isEmpty ? null : job.department;
    _workType        = job.workType.label;
    _employmentType  = job.employmentType.label;
    _durationText.text = job.employmentDurationText;
    _durationType    = job.employmentDurationType.label;
    _experienceLevel = job.experienceLevel.label;
    _salaryMin.text  = job.salaryMin > 0 ? job.salaryMin.toInt().toString() : '';
    _salaryMax.text  = job.salaryMax > 0 ? job.salaryMax.toInt().toString() : '';
    _currency        = job.salaryCurrency;
    _qualificationEn.text = job.requiredQualification.en;
    _qualificationAr.text = job.requiredQualification.ar;

    for (final s in job.requiredSkills) {
      _skills.add({
        'en': TextEditingController(text: s.name.en),
        'ar': TextEditingController(text: s.name.ar),
      });
    }

    _aboutEn.text        = job.aboutThisPosition.en;
    _aboutAr.text        = job.aboutThisPosition.ar;
    _requirementsEn.text = job.requirements.en;
    _requirementsAr.text = job.requirements.ar;
    _prefSkillsEn.text   = job.preferredSkills.en;
    _prefSkillsAr.text   = job.preferredSkills.ar;

    for (final b in job.benefits) {
      _benefits.add({
        'titleEn': TextEditingController(text: b.title.en),
        'titleAr': TextEditingController(text: b.title.ar),
        'descEn':  TextEditingController(text: b.shortDescription.en),
        'descAr':  TextEditingController(text: b.shortDescription.ar),
      });
    }

    _hiringStart = job.hiringStartDate;
    _hiringEnd   = job.hiringEndDate;
    _maxApps.text = job.maxApplications > 0 ? job.maxApplications.toString() : '';
    // ── Seed active/inactive toggle ─────────────────────────────
    _isActive = job.status == JobStatus.active || job.status == JobStatus.scheduled;

    for (final d in job.requiredDocuments) {
      _requiredDocs.add({
        'name': TextEditingController(text: d.name),
        'type': d.docType.label,
      });
    }

    if (_requiredDocs.isEmpty) {
      _requiredDocs.addAll([
        {'name': TextEditingController(text: 'Resume'),       'type': 'PDF'},
        {'name': TextEditingController(text: 'Cover Letter'), 'type': 'PDF'},
      ]);
    }
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _durationText.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    _qualificationEn.dispose();
    _qualificationAr.dispose();
    for (final s in _skills) { s['en']!.dispose(); s['ar']!.dispose(); }
    _aboutEn.dispose();
    _aboutAr.dispose();
    _requirementsEn.dispose();
    _requirementsAr.dispose();
    _prefSkillsEn.dispose();
    _prefSkillsAr.dispose();
    for (final b in _benefits) { b.values.forEach((c) => c.dispose()); }
    _maxApps.dispose();
    for (final d in _requiredDocs) { (d['name'] as TextEditingController).dispose(); }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TOGGLE ACTIVE / INACTIVE
  //  Only updates local UI state — does NOT save to Firestore.
  //  The actual save happens when the user taps Publish.
  // ═══════════════════════════════════════════════════════════════════════════

  void _toggleStatus(bool active) {
    setState(() => _isActive = active);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  REMOVE JOB
  // ═══════════════════════════════════════════════════════════════════════════

  void _confirmRemove() {
    _showConfirmDialog(
      title: 'REMOVE JOB POST',
      message: 'This will mark the job as removed and hide it from applicants. '
          'You can still find it under the "Removed" filter.\n\nAre you sure?',
      confirmLabel: 'Remove',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop();
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().removeJob(_editingJobId!);
        if (mounted) {
          setState(() => _isSaving = false);
          // Pop both edit page and detail page back to list
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );
  }

  JobPostModel _buildModel({String publishStatus = 'published'}) {
    // ── Resolve status from toggle ────────────────────────────────────────
    // Draft always → drafted.
    // Published → active or inactive based on the toggle the user set.
    final resolvedStatus = publishStatus == 'draft'
        ? JobStatus.drafted
        : (_isActive ? JobStatus.active : JobStatus.inactive);

    return JobPostModel(
      id: _editingJobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: BilingualTextJob(en: _titleEn.text, ar: _titleAr.text),
      department: _department ?? '',
      workType: WorkTypeExt.fromString(_workType ?? 'On Site'),
      employmentType: EmploymentTypeExt.fromString(_employmentType ?? 'Full Time'),
      employmentDurationText: _durationText.text,
      employmentDurationType: EmploymentDurationExt.fromString(_durationType ?? 'Open'),
      experienceLevel: ExperienceLevelExt.fromString(_experienceLevel ?? 'Junior'),
      salaryMin: double.tryParse(_salaryMin.text) ?? 0,
      salaryMax: double.tryParse(_salaryMax.text) ?? 0,
      salaryCurrency: _currency ?? 'SAR',
      requiredQualification: BilingualTextJob(en: _qualificationEn.text, ar: _qualificationAr.text),
      requiredSkills: _skills.map((s) => SkillItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: BilingualTextJob(en: s['en']!.text, ar: s['ar']!.text),
      )).toList(),
      aboutThisPosition: BilingualTextJob(en: _aboutEn.text, ar: _aboutAr.text),
      requirements: BilingualTextJob(en: _requirementsEn.text, ar: _requirementsAr.text),
      preferredSkills: BilingualTextJob(en: _prefSkillsEn.text, ar: _prefSkillsAr.text),
      benefits: _benefits.map((b) => BenefitItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: BilingualTextJob(en: b['titleEn']!.text, ar: b['titleAr']!.text),
        shortDescription: BilingualTextJob(en: b['descEn']!.text, ar: b['descAr']!.text),
      )).toList(),
      hiringStartDate: _hiringStart,
      hiringEndDate: _hiringEnd,
      maxApplications: int.tryParse(_maxApps.text) ?? 0,
      requiredDocuments: _requiredDocs.map((d) => RequiredDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: (d['name'] as TextEditingController).text,
        docType: DocTypeExt.fromString(d['type'] as String? ?? 'PDF'),
      )).toList(),
      status: resolvedStatus,       // ← carries active/inactive from toggle
      publishStatus: publishStatus,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PUBLISH
  //  NOTE: We do NOT call context.pop() here.
  //  JobListingMainPage's BlocListener catches JobListingSaved and pops for us,
  //  then calls loadJobs() so the list refreshes with the new entry.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _publish() async {
    if (_isSaving) return;
    _showConfirmDialog(
      title: 'NEW JOB POSTING',
      message: 'You are about to publish a new job opportunity. This action will '
          'make the post visible to applicants immediately. Please ensure all '
          'details are accurate before confirming.',
      confirmLabel: 'Submit',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop(); // close dialog only
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().saveJob(
          _buildModel(publishStatus: 'published'),
          publishStatus: 'published',
        );
        // ── Do NOT pop here — JobListingMainPage BlocListener handles it ──
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SAVE AS DRAFT
  //  Same pattern — no manual pop. BlocListener on main page handles it.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveDraft() async {
    if (_isSaving) return;
    _showConfirmDialog(
      title: 'SAVE JOB POST FOR LATER',
      message: 'Your job post will be saved as a draft. It will not be visible '
          'to applicants until you publish it.\nDo you want to continue?',
      confirmLabel: 'Draft',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop(); // close dialog only
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().saveJob(
          _buildModel(publishStatus: 'draft'),
          publishStatus: 'draft',
        );
        // ── Do NOT pop here — JobListingMainPage BlocListener handles it ──
      },
    );
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: _C.labelText),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: _C.hintText, height: 1.5),
              ),
              SizedBox(height: 24.h),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(child: Text(
                      'Back',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _C.labelText),
                    )),
                  ),
                )),
                SizedBox(width: 16.w),
                Expanded(child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(child: Text(
                      confirmLabel,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    )),
                  ),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  DATE PICKER HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickDate({
    required DateTime? currentDate,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) async {
    final result = await DatePicker().showDatePicker(
      context,
      currentDate != null ? [currentDate] : [],
      currentDate ?? DateTime.now(),
      CalendarDatePicker2Type.single,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
    );
    if (result != null && result.isNotEmpty && result.first != null) {
      onPicked(result.first!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isEdit = _editingJobId != null;

    return BlocListener<JobListingCubit, JobListingState>(
      listener: (context, state) {
        // ── Error: stop spinner + show snackbar ──────────────────
        if (state is JobListingError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: _C.remove),
          );
        }
        // ── Saved: stop spinner — main page listener handles pop ─
        if (state is JobListingSaved) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        backgroundColor: _C.back,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    AppAdminNavbar(
                      activeLabel: 'Job Listing',
                      homePage: CareersMainPageDashboard(),
                      webPage: HomeMainPage(),
                      jobListingPage: JobListingMainPage(),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Page title ────────────────────────────
                          Text(
                            isEdit
                                ? 'Editing Job Post Details'
                                : 'Create New Job Post',
                            style: StyleText.fontSize24Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Remove + Status toggle row (edit mode only) ──
                          if (isEdit) ...[
                            Row(
                              children: [
                                // Remove button
                                GestureDetector(
                                  onTap: () => _confirmRemove(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: _C.remove,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Job Status toggle
                                Text(
                                  'Job Status',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _C.labelText,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Transform.scale(
                                  scale: 0.85,
                                  child: FlutterSwitch(
                                    value: _isActive,
                                    activeColor: _C.primary,
                                    activeToggleColor: Colors.white,
                                    inactiveColor: Colors.grey.shade400,
                                    inactiveToggleColor: Colors.white,
                                    width: 46.0,
                                    height: 27.0,
                                    toggleSize: 21.0,
                                    borderRadius: 13.5,
                                    padding: 3.0,
                                    onToggle: (val) => _toggleStatus(val),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],

                          _accordion(key: 'jobInfo',    title: 'Job Information',    children: [_jobInfoSection()]),
                          SizedBox(height: 10.h),
                          _accordion(key: 'jobDetails', title: 'Job Details',        children: [_jobDetailsSection()]),
                          SizedBox(height: 10.h),
                          _accordion(key: 'benefits',   title: 'Benefits',           children: [_benefitsSection()]),
                          SizedBox(height: 10.h),
                          _accordion(key: 'appDetails', title: 'Application Details',children: [_applicationDetailsSection()]),
                          SizedBox(height: 24.h),

                          _bottomButtons(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Loading overlay ──────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                ),
              ),
          ],
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
          // Job Title
          Row(children: [
            Expanded(child: _field('Job Title', 'Text Here', _titleEn)),
            SizedBox(width: 16.w),
            Expanded(child: _fieldRtl('المسمى الوظيفي', 'أدخل النص هنا', _titleAr)),
          ]),
          SizedBox(height: 14.h),

          // Department + Work Type
          Row(children: [
            Expanded(child: CustomDropdownFormFieldInvMaster(
              label: 'Department',
              hint: Text('Select Department', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
              selectedValue: _department, items: _kDepartments,
              widthIcon: 18, heightIcon: 18, height: 36,
              dropdownColor: AppColors.background,
              onChanged: (val) => setState(() => _department = val),
            )),
            SizedBox(width: 16.w),
            Expanded(child: CustomDropdownFormFieldInvMaster(
              label: 'Work Type',
              dropdownColor: AppColors.background,
              hint: Text('Select Work Type', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
              selectedValue: _workType, items: _kWorkTypes,
              widthIcon: 18, heightIcon: 18, height: 36,
              onChanged: (val) => setState(() => _workType = val),
            )),
          ]),
          SizedBox(height: 14.h),

          // Employment Type + Duration
          Row(children: [
            Expanded(child: CustomDropdownFormFieldInvMaster(
              label: 'Employment Type',
              dropdownColor: AppColors.background,
              hint: Text('Select Employment Type', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
              selectedValue: _employmentType, items: _kEmploymentTypes,
              widthIcon: 18, heightIcon: 18, height: 36,
              onChanged: (val) => setState(() => _employmentType = val),
            )),
            SizedBox(width: 16.w),
            Expanded(child: Row(children: [
              Expanded(child: _field('Employment Duration', 'Text Number', _durationText)),
              SizedBox(width: 8.w),
              SizedBox(width: 120.w, child: CustomDropdownFormFieldInvMaster(
                hint: Text('Duration', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
                selectedValue: _durationType, items: _kDurations,
                dropdownColor: AppColors.background,
                widthIcon: 18, heightIcon: 18, height: 36,
                onChanged: (val) => setState(() => _durationType = val),
              )),
            ])),
          ]),
          SizedBox(height: 14.h),

          // Experience Level + Salary
          Row(children: [
            Expanded(child: CustomDropdownFormFieldInvMaster(
              label: 'Experience Levels',
              dropdownColor: AppColors.background,
              hint: Text('Select Experience Level', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
              selectedValue: _experienceLevel, items: _kExperienceLevels,
              widthIcon: 18, heightIcon: 18, height: 36,
              onChanged: (val) => setState(() => _experienceLevel = val),
            )),
            SizedBox(width: 16.w),
            Expanded(child: Row(children: [
              Expanded(child: _field('Salary Range', 'Min Salary', _salaryMin)),
              SizedBox(width: 8.w),
              Expanded(child: _field('', 'Max Salary', _salaryMax)),
              SizedBox(width: 8.w),
              SizedBox(width: 90.w, child: CustomDropdownFormFieldInvMaster(
                hint: Text('Currency', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
                selectedValue: _currency, items: _kCurrencies,
                widthIcon: 18, heightIcon: 18, height: 36,
                dropdownColor: AppColors.background,
                onChanged: (val) => setState(() => _currency = val),
              )),
            ])),
          ]),
          SizedBox(height: 14.h),

          // Required Qualification
          Row(children: [
            Expanded(child: _field('Required Qualification', 'Text Here', _qualificationEn)),
            SizedBox(width: 16.w),
            Expanded(child: _fieldRtl('المؤهلات المطلوبة', 'أدخل النص هنا', _qualificationAr)),
          ]),
          SizedBox(height: 14.h),

          // Required Skills header (display-only label row)
          Row(children: [
            Expanded(child: _field('Required Skills', 'Text Here', TextEditingController())),
            SizedBox(width: 16.w),
            Expanded(child: _fieldRtl('المهارات المطلوبة', 'أدخل النص هنا', TextEditingController())),
          ]),
          SizedBox(height: 8.h),

          // Dynamic skill rows
          ...List.generate(_skills.length, (i) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(children: [
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
                  width: 24.sp, height: 24.sp,
                  decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
                  child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                ),
              ),
            ]),
          )),

          GestureDetector(
            onTap: () => setState(() => _skills.add({
              'en': TextEditingController(),
              'ar': TextEditingController(),
            })),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  3. BENEFITS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _benefitsSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...List.generate(_benefits.length, (i) {
          final b = _benefits[i];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Benefit ${i + 1}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _C.labelText)),
              GestureDetector(
                onTap: () => setState(() {
                  b.values.forEach((c) => c.dispose());
                  _benefits.removeAt(i);
                }),
                child: Container(
                  width: 24.sp, height: 24.sp,
                  decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
                  child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                ),
              ),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(child: _field('Title', 'Text Here', b['titleEn']!)),
              SizedBox(width: 16.w),
              Expanded(child: _fieldRtl('العنوان', 'أدخل النص هنا', b['titleAr']!)),
            ]),
            SizedBox(height: 8.h),
            _field('Short Description', 'Text Here', b['descEn']!, maxLines: 3, height: 80),
            SizedBox(height: 8.h),
            _fieldRtl('وصف مختصر', 'أدخل النص هنا', b['descAr']!, maxLines: 3, height: 80),
            SizedBox(height: 16.h),
            if (i < _benefits.length - 1) const Divider(color: Color(0xFFE8E8E8)),
          ]);
        }),
        GestureDetector(
          onTap: () => setState(() => _benefits.add({
            'titleEn': TextEditingController(),
            'titleAr': TextEditingController(),
            'descEn':  TextEditingController(),
            'descAr':  TextEditingController(),
          })),
          child: _addButton('Benefits'),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  4. APPLICATION DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _applicationDetailsSection() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _dateFieldCalendar(
            label: 'Hiring Timeline (Start Date)',
            date: _hiringStart,
            onPicked: (d) => setState(() => _hiringStart = d),
          )),
          SizedBox(width: 16.w),
          Expanded(child: _dateFieldCalendar(
            label: 'Hiring Timeline (End Date)',
            date: _hiringEnd,
            onPicked: (d) => setState(() => _hiringEnd = d),
            firstDate: _hiringStart,
          )),
        ]),
        SizedBox(height: 14.h),
        Row(children: [
          Expanded(child: _field(
            'Maximum Number of Applications for This Position',
            'Text Here',
            _maxApps,
          )),
          SizedBox(width: 16.w),
          const Expanded(child: SizedBox()),
        ]),
        SizedBox(height: 14.h),
        Text('Required Documents',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText)),
        SizedBox(height: 8.h),
        ...List.generate((_requiredDocs.length / 2).ceil(), (rowIndex) {
          final left  = rowIndex * 2;
          final right = left + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(children: [
              Expanded(child: _docRow(left)),
              SizedBox(width: 16.w),
              right < _requiredDocs.length
                  ? Expanded(child: _docRow(right))
                  : const Expanded(child: SizedBox()),
            ]),
          );
        }),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => setState(() => _requiredDocs.add({
            'name': TextEditingController(),
            'type': 'PDF',
          })),
          child: _addButton('Required Document'),
        ),
      ]),
    );
  }

  Widget _dateFieldCalendar({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) {
    final displayValue = date != null ? DateFormat('dd/MM/yyyy').format(date) : null;
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
          hint: Text('Select Date', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
          selectedValue: displayValue,
          items: items,
          widthIcon: 18, heightIcon: 18, height: 36,
          dropdownColor: AppColors.background,
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _docRow(int i) {
    return Row(children: [
      Expanded(flex: 3, child: SizedBox(
        height: 36.h,
        child: TextFormField(
          controller: _requiredDocs[i]['name'] as TextEditingController,
          style: TextStyle(fontSize: 12.sp),
          decoration: InputDecoration(
            hintText: 'Document Name',
            hintStyle: TextStyle(fontSize: 12.sp, color: _C.hintText),
            filled: true, fillColor: AppColors.background, isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      )),
      SizedBox(width: 8.w),
      SizedBox(width: 90.w, child: CustomDropdownFormFieldInvMaster(
        dropdownColor: AppColors.background,
        selectedValue: _requiredDocs[i]['type'] as String? ?? 'PDF',
        items: _kDocTypes, widthIcon: 16, heightIcon: 16, height: 36,
        hint: Text('Type', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
        onChanged: (v) => setState(() => _requiredDocs[i]['type'] = v),
      )),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BOTTOM BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _bottomButtons() {
    return Column(children: [
      Row(children: [
        Expanded(child: _actionButton('Preview', Colors.grey.shade400, () {
          navigateTo(context, JobListingPreviewPage(jobId: _editingJobId ?? 'new'));
        })),
        SizedBox(width: 16.w),
        Expanded(child: _actionButton('Publish', _C.primary, _publish)),
      ]),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: _actionButton(
          'Discard',
          Colors.grey.shade300,
              () => context.pop(),
          textColor: _C.labelText,
        )),
        SizedBox(width: 16.w),
        Expanded(child: _actionButton('Save For Later', Colors.grey.shade600, _saveDraft)),
      ]),
    ]);
  }

  Widget _actionButton(String label, Color bg, VoidCallback onTap, {Color textColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r)),
        child: Center(child: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textColor),
        )),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                topLeft:  Radius.circular(6.r),
                topRight: Radius.circular(6.r),
              )
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(child: Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
              )),
              Icon(
                isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 20.sp,
              ),
            ]),
          ),
        ),
        if (isOpen)
          Container(
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(6.r),
                bottomRight: Radius.circular(6.r),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
      ]),
    );
  }

  Widget _field(
      String label,
      String hint,
      TextEditingController ctrl, {
        int maxLines = 1,
        double height = 36,
      }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText)),
        SizedBox(height: 5.h),
      ],
      SizedBox(
        height: height.h,
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: TextStyle(fontSize: 12.sp, color: _C.labelText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.sp, color: _C.hintText),
            filled: true, fillColor: AppColors.background, isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _fieldRtl(
      String label,
      String hint,
      TextEditingController ctrl, {
        int maxLines = 1,
        double height = 36,
      }) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: _field(label, hint, ctrl, maxLines: maxLines, height: height),
    );
  }

  Widget _addButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white)),
      ]),
    );
  }
}