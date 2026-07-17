// ******************* FILE INFO *******************
// File Name: job_listing_edit.dart
// Created by: Amr Mesbah
// Purpose: Create / Edit Job Post — 4 accordion sections + publish dialogs
// Pattern: Same as home_edit.dart
// UPDATED: Firebase-backed via JobListingCubit.saveJob() — no static data
// FIXED: All dropdowns use CustomDropdownFormFieldInvMaster
// FIXED: All date pickers use CustomDropdownFormFieldCalender + DatePicker
// FIXED: BlocListener handles JobListingSaved — clears saving flag
// FIXED: _publish() and _saveDraft() no longer manually pop — main page handles it
// FIXED: Page title shows actual job title when editing
// FIXED: Hire Start Date must be before Hire End Date — guards both directions

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/core/widget/calender_widget.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/date_pic.dart';
import 'package:web_app_admin/core/widget/date_picker.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom/2-custom_textfield.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../main/presentation/controller/main_cubit.dart';
import '../../../../main/presentation/controller/main_state.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/job_listing_model.dart';
import '../../controller/job_listing_cubit.dart';
import '../../controller/job_listing_state.dart';
import 'job_listing_main.dart';
import 'job_listing_preview.dart';

part '../widgets/job_listing_edit/edit_sections.dart';
part '../widgets/job_listing_edit/edit_form_helpers.dart';


Color _cmsHexColor(String hex) {
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return const Color(0xFF008037);
}



const List<Map<String, String>> _kDepartments = [
  {'key': 'Design', 'value': 'Design'},
  {'key': 'Engineering', 'value': 'Engineering'},
  {'key': 'Marketing', 'value': 'Marketing'},
  {'key': 'HR', 'value': 'HR'},
  {'key': 'Finance', 'value': 'Finance'},
];

const List<Map<String, String>> _kWorkTypes = [
  {'key': 'On Site', 'value': 'On Site'},
  {'key': 'Remotely', 'value': 'Remotely'},
  {'key': 'Hybrid', 'value': 'Hybrid'},
];

const List<Map<String, String>> _kEmploymentTypes = [
  {'key': 'Full Time', 'value': 'Full Time'},
  {'key': 'Part Time', 'value': 'Part Time'},
];

const List<Map<String, String>> _kExperienceLevels = [
  {'key': 'Intern', 'value': 'Intern'},
  {'key': 'Junior', 'value': 'Junior'},
  {'key': 'Senior', 'value': 'Senior'},
  {'key': 'Leadership', 'value': 'Leadership'},
];

const List<Map<String, String>> _kDurations = [
  {'key': 'Open', 'value': 'Open'},
  {'key': 'Month', 'value': 'Month'},
  {'key': 'Week', 'value': 'Week'},
];

const List<Map<String, String>> _kCurrencies = [
  {'key': 'SAR', 'value': 'SAR'},
  {'key': 'USD', 'value': 'USD'},
  {'key': 'EUR', 'value': 'EUR'},
];

const List<Map<String, String>> _kDocTypes = [
  {'key': 'PDF', 'value': 'PDF'},
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
  bool _isSaving = false;
  bool _isActive = true; // tracks active/inactive toggle

  final _titleEn = TextEditingController();
  final _titleAr = TextEditingController();
  String? _department;
  String? _workType;
  String? _employmentType;
  final _durationText = TextEditingController();
  String? _durationType;
  String? _experienceLevel;
  final _salaryMin = TextEditingController();
  final _salaryMax = TextEditingController();
  String? _currency = 'SAR';
  final _qualificationEn = TextEditingController();
  final _qualificationAr = TextEditingController();
  final List<Map<String, TextEditingController>> _skills = [];

  final _aboutEn = TextEditingController();
  final _aboutAr = TextEditingController();
  final _requirementsEn = TextEditingController();
  final _requirementsAr = TextEditingController();
  final _prefSkillsEn = TextEditingController();
  final _prefSkillsAr = TextEditingController();

  final List<Map<String, TextEditingController>> _benefits = [];

  DateTime? _hiringStart;
  DateTime? _hiringEnd;
  final _maxApps = TextEditingController();
  final List<Map<String, dynamic>> _requiredDocs = [];

  final Map<String, bool> _open = {
    'jobInfo': true,
    'jobDetails': true,
    'benefits': true,
    'appDetails': true,
  };

  String? _editingJobId;

  Color _cmsPrimary(BuildContext context) {
    final state = context.read<MainCmsCubit>().state;
    return switch (state) {
      MainCmsLoaded(:final data) => _cmsHexColor(data.branding.primaryColor),
      MainCmsSaved(:final data)  => _cmsHexColor(data.branding.primaryColor),
      _                          => const Color(0xFF008037),
    };
  }

  @override
  void initState() {
    super.initState();
    _editingJobId = widget.jobId;
    if (_editingJobId != null) {
      _seedFromExisting();
    } else {
      _requiredDocs.addAll([
        {'name': TextEditingController(text: 'Resume'), 'type': 'PDF'},
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
    _department = job.department.isEmpty ? null : job.department;
    _workType = job.workType.label;
    _employmentType = job.employmentType.label;
    _durationText.text = job.employmentDurationText;
    _durationType = job.employmentDurationType.label;
    _experienceLevel = job.experienceLevel.label;
    _salaryMin.text = job.salaryMin > 0 ? job.salaryMin.toInt().toString() : '';
    _salaryMax.text = job.salaryMax > 0 ? job.salaryMax.toInt().toString() : '';
    _currency = job.salaryCurrency;
    _qualificationEn.text = job.requiredQualification.en;
    _qualificationAr.text = job.requiredQualification.ar;

    for (final s in job.requiredSkills) {
      _skills.add({
        'en': TextEditingController(text: s.name.en),
        'ar': TextEditingController(text: s.name.ar),
      });
    }

    _aboutEn.text = job.aboutThisPosition.en;
    _aboutAr.text = job.aboutThisPosition.ar;
    _requirementsEn.text = job.requirements.en;
    _requirementsAr.text = job.requirements.ar;
    _prefSkillsEn.text = job.preferredSkills.en;
    _prefSkillsAr.text = job.preferredSkills.ar;

    for (final b in job.benefits) {
      _benefits.add({
        'titleEn': TextEditingController(text: b.title.en),
        'titleAr': TextEditingController(text: b.title.ar),
        'descEn': TextEditingController(text: b.shortDescription.en),
        'descAr': TextEditingController(text: b.shortDescription.ar),
      });
    }

    _hiringStart = job.hiringStartDate;
    _hiringEnd = job.hiringEndDate;
    _maxApps.text = job.maxApplications > 0
        ? job.maxApplications.toString()
        : '';
    // ── Seed active/inactive toggle ─────────────────────────────
    _isActive =
        job.status == JobStatus.active || job.status == JobStatus.scheduled;

    for (final d in job.requiredDocuments) {
      _requiredDocs.add({
        'name': TextEditingController(text: d.name),
        'type': d.docType.label,
      });
    }

    if (_requiredDocs.isEmpty) {
      _requiredDocs.addAll([
        {'name': TextEditingController(text: 'Resume'), 'type': 'PDF'},
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
    for (final s in _skills) {
      s['en']!.dispose();
      s['ar']!.dispose();
    }
    _aboutEn.dispose();
    _aboutAr.dispose();
    _requirementsEn.dispose();
    _requirementsAr.dispose();
    _prefSkillsEn.dispose();
    _prefSkillsAr.dispose();
    for (final b in _benefits) {
      b.values.forEach((c) => c.dispose());
    }
    _maxApps.dispose();
    for (final d in _requiredDocs) {
      (d['name'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TOGGLE ACTIVE / INACTIVE
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
      message:
      'This will mark the job as removed and hide it from applicants. '
          'You can still find it under the "Removed" filter.\n\nAre you sure?',
      confirmLabel: 'Remove',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop();
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().removeJob(_editingJobId!);
        if (mounted) {
          setState(() => _isSaving = false);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );
  }

  JobPostModel _buildModel({String publishStatus = 'published'}) {
    final resolvedStatus = publishStatus == 'draft'
        ? JobStatus.drafted
        : (_isActive ? JobStatus.active : JobStatus.inactive);

    return JobPostModel(
      id: _editingJobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: BilingualTextJob(en: _titleEn.text, ar: _titleAr.text),
      department: _department ?? '',
      workType: WorkTypeExt.fromString(_workType ?? 'On Site'),
      employmentType: EmploymentTypeExt.fromString(
        _employmentType ?? 'Full Time',
      ),
      employmentDurationText: _durationText.text,
      employmentDurationType: EmploymentDurationExt.fromString(
        _durationType ?? 'Open',
      ),
      experienceLevel: ExperienceLevelExt.fromString(
        _experienceLevel ?? 'Junior',
      ),
      salaryMin: double.tryParse(_salaryMin.text) ?? 0,
      salaryMax: double.tryParse(_salaryMax.text) ?? 0,
      salaryCurrency: _currency ?? 'SAR',
      requiredQualification: BilingualTextJob(
        en: _qualificationEn.text,
        ar: _qualificationAr.text,
      ),
      requiredSkills: _skills
          .map(
            (s) => SkillItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: BilingualTextJob(en: s['en']!.text, ar: s['ar']!.text),
        ),
      )
          .toList(),
      aboutThisPosition: BilingualTextJob(en: _aboutEn.text, ar: _aboutAr.text),
      requirements: BilingualTextJob(
        en: _requirementsEn.text,
        ar: _requirementsAr.text,
      ),
      preferredSkills: BilingualTextJob(
        en: _prefSkillsEn.text,
        ar: _prefSkillsAr.text,
      ),
      benefits: _benefits
          .map(
            (b) => BenefitItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: BilingualTextJob(
            en: b['titleEn']!.text,
            ar: b['titleAr']!.text,
          ),
          shortDescription: BilingualTextJob(
            en: b['descEn']!.text,
            ar: b['descAr']!.text,
          ),
        ),
      )
          .toList(),
      hiringStartDate: _hiringStart,
      hiringEndDate: _hiringEnd,
      maxApplications: int.tryParse(_maxApps.text) ?? 0,
      requiredDocuments: _requiredDocs
          .map(
            (d) => RequiredDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: (d['name'] as TextEditingController).text,
          docType: DocTypeExt.fromString(d['type'] as String? ?? 'PDF'),
        ),
      )
          .toList(),
      status: resolvedStatus,
      publishStatus: publishStatus,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PUBLISH
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _publish() async {
    if (_isSaving) return;
    _showConfirmDialog(
      title: 'NEW JOB POSTING',
      message:
      'You are about to publish a new job opportunity. This action will '
          'make the post visible to applicants immediately. Please ensure all '
          'details are accurate before confirming.',
      confirmLabel: 'Submit',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop();
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().saveJob(
          _buildModel(publishStatus: 'published'),
          publishStatus: 'published',
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SAVE AS DRAFT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveDraft() async {
    if (_isSaving) return;
    _showConfirmDialog(
      title: 'SAVE JOB POST FOR LATER',
      message:
      'Your job post will be saved as a draft. It will not be visible '
          'to applicants until you publish it.\nDo you want to continue?',
      confirmLabel: 'Draft',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop();
        setState(() => _isSaving = true);
        await context.read<JobListingCubit>().saveJob(
          _buildModel(publishStatus: 'draft'),
          publishStatus: 'draft',
        );
      },
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
      firstDate:
      firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
    );
    if (result != null && result.isNotEmpty && result.first != null) {
      onPicked(result.first!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HIRE DATE SETTERS — with cross-validation guards
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sets the hiring start date.
  /// If the new start date is after the current end date, clears the end date.
  void _setHiringStart(DateTime picked) {
    setState(() {
      _hiringStart = picked;
      // ── Guard: if end date is now before the new start, reset it ──
      if (_hiringEnd != null && _hiringEnd!.isBefore(picked)) {
        _hiringEnd = null;
      }
    });
  }

  /// Sets the hiring end date.
  /// The date picker already restricts selection to dates >= start date,
  /// but we add an extra programmatic guard just in case.
  void _setHiringEnd(DateTime picked) {
    if (_hiringStart != null && picked.isBefore(_hiringStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('End date cannot be before start date'),
          backgroundColor: ColorPick.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _hiringEnd = picked;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isEdit = _editingJobId != null;

    return BlocListener<JobListingCubit, JobListingState>(
      listener: (context, state) {
        if (state is JobListingError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: ColorPick.red),
          );
        }
        if (state is JobListingSaved) {
          setState(() => _isSaving = false);
        }
      },
      child: Scaffold(
        backgroundColor: ColorPick.background,
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
                      webPage: MainMainPage(),
                      jobListingPage: JobListingMainPage(),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? 'Editing Job Post Details'
                                : 'Create New Job Post',
                            style: StyleText.fontSize24Weight600.copyWith(
                              color: ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          if (isEdit) ...[
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _confirmRemove(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorPick.red,
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
                                Text(
                                  'Job Status',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Transform.scale(
                                  scale: 0.85,
                                  child: FlutterSwitch(
                                    value: _isActive,
                                    activeColor: ColorPick.primary,
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

                          _accordion(
                            key: 'jobInfo',
                            title: 'Job Information',
                            children: [_jobInfoSection()],
                          ),
                          SizedBox(height: 10.h),
                          _accordion(
                            key: 'jobDetails',
                            title: 'Job Details',
                            children: [_jobDetailsSection()],
                          ),
                          SizedBox(height: 10.h),
                          _accordion(
                            key: 'benefits',
                            title: 'Benefits',
                            children: [_benefitsSection()],
                          ),
                          SizedBox(height: 10.h),
                          _accordion(
                            key: 'appDetails',
                            title: 'Application Details',
                            children: [_applicationDetailsSection()],
                          ),
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

            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: ColorPick.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

}