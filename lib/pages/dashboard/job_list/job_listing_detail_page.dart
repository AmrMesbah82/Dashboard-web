// ******************* FILE INFO *******************
// File Name: job_listing_detail_page.dart
// Created by: Amr Mesbah
// Purpose: Job Post Details — 3 tabs: Job Details | Dashboard | Applicant Details
// UPDATED: Dashboard + Applicant Details use REAL Firebase data
//          Applications fetched from jobListings/{jobId}/applications subcollection
//          Applicant Details table refactored to use Table widget (ServiceTableWidget pattern)
//          Table Setting dialog controls column visibility for table + export

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:web_app_admin/controller/job_list/job_listing_cubit.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/calender_widget.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/job_list/job_listing_main_page.dart';

import '../../../core/widget/button.dart';
import '../../../widgets/job_listing_export_dialog.dart';
import 'job_listing_edit_page.dart';

// ── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
}

class _Ch {
  static const Color green      = Color(0xFF008037);
  static const Color darkGreen  = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color orange     = Color(0xFFFF9800);
  static const Color red        = Color(0xFFD32F2F);
  static const Color yellow     = Color(0xFFFFD452);
  static const Color grey       = Color(0xFFACACAC);
  static const Color poor       = Color(0xFFD32F2F);
  static const Color weak       = Color(0xFFFF7043);
  static const Color good       = Color(0xFFFFCA28);
  static const Color veryGood   = Color(0xFF66BB6A);
  static const Color excellent  = Color(0xFF1B5E20);
}

// ═════════════════════════════════════════════════════════════════════════════
//  COLUMN KEYS — single source of truth for table + export
// ═════════════════════════════════════════════════════════════════════════════

class ColumnKey {
  static const String firstName       = 'firstName';
  static const String lastName        = 'lastName';
  static const String email           = 'email';
  static const String code            = 'code';
  static const String phone           = 'phone';
  static const String source          = 'source';
  static const String location        = 'location';
  static const String resume          = 'resume';
  static const String coverLetter     = 'coverLetter';
  static const String status          = 'status';
  static const String stage           = 'stage';
  static const String score           = 'score';
  static const String tags            = 'tags';
  static const String appliedDate     = 'appliedDate';
  static const String interviewDate   = 'interviewDate';
  static const String lastUpdate      = 'lastUpdate';
  static const String yearOfGraduation = 'yearOfGraduation';

  static const List<String> all = [
    firstName, lastName, email, code, phone,
    source, location, resume, coverLetter,
    status, stage, score, tags,
    appliedDate, interviewDate, lastUpdate, yearOfGraduation,
  ];

  static const Map<String, String> labels = {
    firstName:       'First Name',
    lastName:        'Last Name',
    email:           'Email',
    code:            'Code',
    phone:           'Phone',
    source:          'Source',
    location:        'Location',
    resume:          'Resume',
    coverLetter:     'Cover Letter',
    status:          'Status',
    stage:           'Stage',
    score:           'Score',
    tags:            'Tags',
    appliedDate:     'Applied Date',
    interviewDate:   'Interview Date',
    lastUpdate:      'Last Update',
    yearOfGraduation:'Year Of Graduation',
  };

  static Map<String, bool> defaultVisibility() {
    return {
      firstName:       true,
      lastName:        true,
      email:           true,
      code:            true,
      phone:           true,
      source:          false,
      location:        true,
      resume:          true,
      coverLetter:     true,
      status:          true,
      stage:           true,
      score:           true,
      tags:            true,
      appliedDate:     true,
      interviewDate:   false,
      lastUpdate:      false,
      yearOfGraduation:true,
    };
  }

  static String valueFromApp(String key, ApplicationModel a) {
    final avgScore = (a.technicalSkills + a.communicationSkills +
        a.experienceBackground + a.cultureFit + a.leadershipPotential);
    final scoreText = avgScore > 0 ? (avgScore / 5).toStringAsFixed(1) : '';

    String fmtDate(DateTime? dt) {
      if (dt == null) return '';
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    }

    switch (key) {
      case ColumnKey.firstName:        return a.firstName;
      case ColumnKey.lastName:         return a.lastName;
      case ColumnKey.email:            return a.email;
      case ColumnKey.code:             return a.countryCode;
      case ColumnKey.phone:            return a.phone;
      case ColumnKey.source:           return a.source;
      case ColumnKey.location:         return a.jobLocation;
      case ColumnKey.resume:           return a.resumeUrl;
      case ColumnKey.coverLetter:      return a.coverLetterUrl;
      case ColumnKey.status:           return a.status.label;
      case ColumnKey.stage:            return a.status.stage;
      case ColumnKey.score:            return scoreText;
      case ColumnKey.tags:             return a.tag;
      case ColumnKey.appliedDate:      return fmtDate(a.applicationDate);
      case ColumnKey.interviewDate:    return fmtDate(a.interviewDate);
      case ColumnKey.lastUpdate:       return fmtDate(a.lastUpdate);
      case ColumnKey.yearOfGraduation: return a.yearOfGraduation;
      default:                         return '';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TABLE SETTING DIALOG — show function (top-level so it's easy to call)
// ═════════════════════════════════════════════════════════════════════════════

Future<Map<String, bool>?> showTableSettingDialog(
    BuildContext context,
    Map<String, bool> currentVisibility,
    ) {
  print('🟡 [TableSetting] showTableSettingDialog called');
  return showGeneralDialog<Map<String, bool>?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'TableSettingDialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim, secondaryAnim) {
      return _TableSettingDialogContent(
        columnVisibility: Map.from(currentVisibility),
      );
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        ),
      );
    },
  );
}

class _TableSettingDialogContent extends StatefulWidget {
  final Map<String, bool> columnVisibility;
  const _TableSettingDialogContent({required this.columnVisibility});

  @override
  State<_TableSettingDialogContent> createState() => _TableSettingDialogContentState();
}

class _TableSettingDialogContentState extends State<_TableSettingDialogContent> {
  late Map<String, bool> _tempVisibility;

  static const _leftKeysTop = [
    ColumnKey.firstName,
    ColumnKey.lastName,
    ColumnKey.email,
    ColumnKey.code,
    ColumnKey.phone,
  ];

  static const _rightKeysTop = [
    ColumnKey.status,
    ColumnKey.stage,
    ColumnKey.score,
    ColumnKey.tags,
  ];

  static const _leftKeysBottom = [
    ColumnKey.source,
    ColumnKey.location,
    ColumnKey.resume,
    ColumnKey.coverLetter,
  ];

  static const _rightKeysBottom = [
    ColumnKey.appliedDate,
    ColumnKey.interviewDate,
    ColumnKey.lastUpdate,
    ColumnKey.yearOfGraduation,
  ];

  @override
  void initState() {
    super.initState();
    _tempVisibility = Map.from(widget.columnVisibility);
    print('🟢 [TableSetting] Dialog initState — keys: ${_tempVisibility.keys.length}');
  }

  void _reset() {
    setState(() {
      _tempVisibility = ColumnKey.defaultVisibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520.w,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    width: 32.sp,
                    height: 32.sp,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomSvg(assetPath: "assets/images/table_icon.svg",width: 20.w,height: 20.h,fit: BoxFit.scaleDown,)
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Table Setting',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _C.labelText),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _reset,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF666666)),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // ── Top group — two columns ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: _leftKeysTop.map((key) => _buildSwitchRow(key)).toList())),
                  SizedBox(width: 16.w),
                  Expanded(child: Column(children: _rightKeysTop.map((key) => _buildSwitchRow(key)).toList())),
                ],
              ),

              SizedBox(height: 8.h),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(height: 8.h),

              // ── Bottom group — two columns ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: _leftKeysBottom.map((key) => _buildSwitchRow(key)).toList())),
                  SizedBox(width: 16.w),
                  Expanded(child: Column(children: _rightKeysBottom.map((key) => _buildSwitchRow(key)).toList())),
                ],
              ),

              SizedBox(height: 16.h),

              // ── Bottom buttons — Back + Save ──
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        print('🔵 [TableSetting] Back pressed');
                        Navigator.of(context).pop(null);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text('Back', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF666666))),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        print('🟢 [TableSetting] Save pressed — visible: ${_tempVisibility.entries.where((e) => e.value).length}');
                        Navigator.of(context).pop(_tempVisibility);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Widget _buildSwitchRow(String key) {
    final label = ColumnKey.labels[key] ?? key;
    final value = _tempVisibility[key] ?? true;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: _C.labelText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          FlutterSwitch(
            width: 38.sp,
            height: 22.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 16.sp,
            activeColor: _C.primary,
            inactiveColor: Colors.grey.withOpacity(.16),
            value: value,
            onToggle: (v) {
              setState(() {
                _tempVisibility[key] = v;
              });
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PAGE
// ═════════════════════════════════════════════════════════════════════════════

class JobListingDetailPage extends StatefulWidget {
  final String jobId;
  const JobListingDetailPage({super.key, required this.jobId});

  @override
  State<JobListingDetailPage> createState() => _JobListingDetailPageState();
}

class _JobListingDetailPageState extends State<JobListingDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  JobPostModel? _job;

  List<ApplicationModel> _applications = [];
  bool _loadingApps = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJob();
    _loadApplications();
  }

  void _loadJob() {
    final cubit = context.read<JobListingCubit>();
    final matches = cubit.allJobs.where((j) => j.id == widget.jobId).toList();
    if (matches.isNotEmpty) setState(() => _job = matches.first);
  }

  Future<void> _loadApplications() async {
    try {
      print('🟡 [DetailPage] _loadApplications(${widget.jobId})');
      final snapshot = await FirebaseFirestore.instance
          .collection('jobListings')
          .doc(widget.jobId)
          .collection('applications')
          .orderBy('applicationDate', descending: true)
          .get(const GetOptions(source: Source.server));

      final apps = snapshot.docs.map((doc) {
        return ApplicationModel.fromMap(doc.id, {
          ...doc.data(),
          'jobId': widget.jobId,
        });
      }).toList();

      print('🟢 [DetailPage] _loadApplications() — got ${apps.length}');
      if (mounted) setState(() { _applications = apps; _loadingApps = false; });
    } catch (e) {
      print('🔴 [DetailPage] _loadApplications() ERROR: $e');
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('jobListings')
            .doc(widget.jobId)
            .collection('applications')
            .orderBy('applicationDate', descending: true)
            .get(const GetOptions(source: Source.cache));
        final apps = snapshot.docs.map((doc) {
          return ApplicationModel.fromMap(doc.id, {...doc.data(), 'jobId': widget.jobId});
        }).toList();
        if (mounted) setState(() { _applications = apps; _loadingApps = false; });
      } catch (_) {
        if (mounted) setState(() => _loadingApps = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobListingCubit, JobListingState>(
      listener: (context, state) {
        if (state is JobListingLoaded) {
          final matches = state.jobs.where((j) => j.id == widget.jobId).toList();
          if (matches.isNotEmpty) setState(() => _job = matches.first);
        }
        if (state is JobListingSaved && state.job.id == widget.jobId) {
          setState(() => _job = state.job);
        }
      },
      child: Scaffold(
        backgroundColor: _C.back,
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                AppAdminNavbar(
                  activeLabel: 'Job Listing',
                  homePage: CareersMainPageDashboard(),
                  webPage: HomeMainPage(),
                  jobListingPage: JobListingMainPage(),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Job Post Details',
                            style: StyleText.fontSize28Weight600.copyWith(
                                color: _C.primary, fontWeight: FontWeight.w700)),
                        SizedBox(height: 16.h),

                        Container(
                          child: Row(children: [
                            _buildTabBar(),
                            const Spacer(),
                            if (_job != null)
                              Text('Posted On ${_formatDate(_job!.postedDate)}',
                                  style: TextStyle(fontSize: 12.sp, color: _C.hintText)),
                            SizedBox(width: 16.w),
                            GestureDetector(
                              onTap: () => navigateTo(context, JobListingEditPage(jobId: widget.jobId)),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text('Edit Job Info', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                                  SizedBox(width: 6.w),
                                  Icon(Icons.edit_outlined, color: Colors.white, size: 14.sp),
                                ]),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(height: 20.h),

                        if (_job == null)
                          Center(child: Padding(
                            padding: EdgeInsets.all(40.sp),
                            child: const CircularProgressIndicator(color: _C.primary),
                          ))
                        else
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (_, __) {
                              switch (_tabController.index) {
                                case 0: return _JobDetailsTab(job: _job!);
                                case 1: return _DashboardTab(job: _job!, applications: _applications, loading: _loadingApps);
                                case 2: return _ApplicantDetailsTab(job: _job!, applications: _applications, loading: _loadingApps, onRefresh: _loadApplications);
                                default: return const SizedBox();
                              }
                            },
                          ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Job Details', 'Dashboard', 'Applicant Details'];
    return Row(children: List.generate(tabs.length, (i) {
      final isActive = _tabController.index == i;
      return Padding(
        padding: EdgeInsets.only(right: 24.w),
        child: GestureDetector(
          onTap: () => setState(() => _tabController.animateTo(i)),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _C.primary : _C.hintText,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: isActive ? _C.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TAB 1 — JOB DETAILS (read-only) — unchanged
// ═════════════════════════════════════════════════════════════════════════════

class _JobDetailsTab extends StatelessWidget {
  final JobPostModel job;
  const _JobDetailsTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionCard(title: 'Job Information', child: _jobInfoContent()),
      SizedBox(height: 10.h),
      _SectionCard(title: 'Job Details', child: _jobDetailsContent()),
      SizedBox(height: 10.h),
      if (job.benefits.isNotEmpty) ...[
        _SectionCard(title: 'Benefits', child: _benefitsContent()),
        SizedBox(height: 10.h),
      ],
      _SectionCard(title: 'Application Details', child: _appDetailsContent()),
    ]);
  }

  Widget _jobInfoContent() {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      _row(_infoField('Job Title', job.title.en), _infoFieldRtl('المسمى الوظيفي', job.title.ar)),
      const SizedBox(height: 12),
      _row(_infoField('Department', job.department.isEmpty ? '—' : job.department), _infoField('Work Type', job.workType.label)),
      const SizedBox(height: 12),
      _row(_infoField('Employment Type', job.employmentType.label),
          _infoField('Employment Duration', job.employmentDurationText.isNotEmpty ? '${job.employmentDurationText} ${job.employmentDurationType.label}' : job.employmentDurationType.label)),
      const SizedBox(height: 12),
      _row(_infoField('Experience Level', job.experienceLevel.label),
          _infoField('Salary Range', job.salaryMax > 0 ? '${job.salaryMin.toInt()} – ${job.salaryMax.toInt()} ${job.salaryCurrency}' : '—')),
      const SizedBox(height: 12),
      _row(_infoField('Required Qualification', job.requiredQualification.en), _infoFieldRtl('المؤهلات المطلوبة', job.requiredQualification.ar)),
      if (job.requiredSkills.isNotEmpty) ...[const SizedBox(height: 12), _skillsRow()],
    ]));
  }

  Widget _jobDetailsContent() {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      _infoField('About This Position', job.aboutThisPosition.en, multi: true),
      const SizedBox(height: 12),
      _infoField('Requirements', job.requirements.en, multi: true),
      const SizedBox(height: 12),
      _infoField('Preferred Skills', job.preferredSkills.en, multi: true),
    ]));
  }

  Widget _benefitsContent() {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      ...List.generate(job.benefits.length, (i) {
        final b = job.benefits[i];
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoField('Benefit ${i + 1} Title', b.title.en), const SizedBox(height: 6),
          _infoField('Description', b.shortDescription.en, multi: true),
          if (i < job.benefits.length - 1) ...[const SizedBox(height: 12), const Divider(color: Color(0xFFE8E8E8))],
        ]));
      }),
    ]));
  }

  Widget _appDetailsContent() {
    String fmtDate(DateTime? dt) {
      if (dt == null) return '—';
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    }
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      _row(_infoField('Hiring Start Date', fmtDate(job.hiringStartDate)), _infoField('Hiring End Date', fmtDate(job.hiringEndDate))),
      const SizedBox(height: 12),
      _row(_infoField('Max Applications', job.maxApplications > 0 ? job.maxApplications.toString() : '—'), const SizedBox()),
      if (job.requiredDocuments.isNotEmpty) ...[
        const SizedBox(height: 12),
        const Text('Required Documents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: job.requiredDocuments.map((d) => _chip('${d.name} (${d.docType.label})')).toList()),
      ],
    ]));
  }

  Widget _row(Widget left, Widget right) => Row(children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)]);

  Widget _skillsRow() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Required Skills', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 6, children: job.requiredSkills.map((s) => _chip(s.name.en)).toList()),
  ]);

  Widget _infoField(String label, String value, {bool multi = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (label.isNotEmpty) ...[Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF333333))), const SizedBox(height: 4)],
    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
        child: Text(value.isEmpty ? '—' : value, style: TextStyle(fontSize: 12, color: value.isEmpty ? const Color(0xFFAAAAAA) : const Color(0xFF333333)),
            maxLines: multi ? null : 1, overflow: multi ? null : TextOverflow.ellipsis)),
  ]);

  Widget _infoFieldRtl(String label, String value) => Directionality(textDirection: TextDirection.rtl, child: _infoField(label, value));

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFF008037).withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF008037).withOpacity(0.3))),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF008037))),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  TAB 2 — DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  final JobPostModel job;
  final List<ApplicationModel> applications;
  final bool loading;
  const _DashboardTab({required this.job, required this.applications, required this.loading});

  int get _total => applications.length;
  int get _qualified    => applications.where((a) => a.status == ApplicationStatus.qualified).length;
  int get _unqualified  => applications.where((a) => a.status == ApplicationStatus.unqualified).length;
  int get _applied      => applications.where((a) => a.status == ApplicationStatus.applied).length;
  int get _interviewPassed   => applications.where((a) => a.status == ApplicationStatus.interviewPassed).length;
  int get _interviewFailed   => applications.where((a) => a.status == ApplicationStatus.interviewFailed).length;
  int get _interviewWithdrew => applications.where((a) => a.status == ApplicationStatus.interviewWithdrew).length;
  int get _offerApproved => applications.where((a) => a.status == ApplicationStatus.offerApproved).length;
  int get _offerPending  => applications.where((a) => a.status == ApplicationStatus.offerPending).length;
  int get _offerRejected => applications.where((a) => a.status == ApplicationStatus.offerRejected).length;
  int get _hired => applications.where((a) => a.status == ApplicationStatus.hired).length;
  int get _appliedStage    => _applied + _qualified + _unqualified;
  int get _interviewStage  => _interviewPassed + _interviewFailed + _interviewWithdrew;
  int get _offerStage      => _offerApproved + _offerPending + _offerRejected;

  Map<int, int> get _appsByMonth {
    final map = <int, int>{};
    for (final a in applications) {
      if (a.applicationDate != null) {
        final month = a.applicationDate!.month;
        map[month] = (map[month] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get _scoreDistribution {
    int poor = 0, weak = 0, good = 0, veryGood = 0, excellent = 0;
    for (final a in applications) {
      final avg = (a.technicalSkills + a.communicationSkills + a.experienceBackground + a.cultureFit + a.leadershipPotential);
      if (avg == 0) continue;
      final score = avg / 5.0;
      if (score <= 1) poor++;
      else if (score <= 2) weak++;
      else if (score <= 3) good++;
      else if (score <= 4) veryGood++;
      else excellent++;
    }
    return {'Poor': poor, 'Weak': weak, 'Good': good, 'Very Good': veryGood, 'Excellent': excellent};
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: Padding(padding: EdgeInsets.all(40.sp), child: const CircularProgressIndicator(color: _C.primary)));
    if (applications.isEmpty) return Center(child: Padding(padding: EdgeInsets.all(40.sp), child: Text('No applications yet for this job.', style: TextStyle(fontSize: 14.sp, color: _C.hintText))));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartRow(left: _buildApplicationsReceived(), right: _buildCandidateClassification()),
      SizedBox(height: 16.h),
      _chartRow(left: _buildHiringStage(), right: _buildInterviewStage()),
      SizedBox(height: 16.h),
      _chartRow(left: _buildJobOffer(), right: _buildScoreDistributionChart()),
      SizedBox(height: 16.h),
    ]);
  }

  Widget _chartRow({required Widget left, required Widget right}) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: left), SizedBox(width: 16.w), Expanded(child: right)]);

  Widget _buildApplicationsReceived() {
    final labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final byMonth = _appsByMonth;
    final values = List.generate(12, (i) => (byMonth[i + 1] ?? 0).toDouble());
    final maxY = ((values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b)) + 10).toDouble();
    return _card(title: 'Applications Received', subtitle: 'Total: ${_fmtNum(_total)}', height: 280,
      child: Expanded(child: BarChart(BarChartData(maxY: maxY,
        barGroups: values.asMap().entries.map((e) => BarChartGroupData(x: e.key,
          barRods: [BarChartRodData(toY: e.value, width: 14.sp, color: _Ch.green, borderRadius: BorderRadius.circular(3.r))],
          showingTooltipIndicators: e.value > 0 ? [0] : [],
        )).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35.sp, interval: maxY > 50 ? (maxY / 5).ceilToDouble() : 10,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 9.sp, color: Colors.grey)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22.sp,
              getTitlesWidget: (v, _) { final i = v.toInt(); return i >= 0 && i < 12 ? Text(labels[i], style: TextStyle(fontSize: 8.sp, color: Colors.grey)) : const SizedBox.shrink(); })),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY > 50 ? (maxY / 5).ceilToDouble() : 10,
            getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEFF3F9), strokeWidth: 1)),
        barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(
          tooltipPadding: EdgeInsets.zero, tooltipMargin: 4, getTooltipColor: (_) => Colors.transparent, tooltipBorder: BorderSide.none,
          getTooltipItem: (group, _, rod, __) => BarTooltipItem(rod.toY.toInt().toString(), TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: _Ch.darkGreen)),
        )),
      ))),
    );
  }

  Widget _buildCandidateClassification() {
    final qualifiedCount = _qualified + _interviewPassed + _offerApproved + _offerPending + _hired;
    final unqualifiedCount = _unqualified + _interviewFailed + _interviewWithdrew + _offerRejected;
    final totalClassified = qualifiedCount + unqualifiedCount;
    final qPct = totalClassified > 0 ? (qualifiedCount / totalClassified * 100).round() : 0;
    final uPct = totalClassified > 0 ? 100 - qPct : 0;
    return _card(title: 'Candidate Classification', height: 280,
      child: Expanded(child: Row(children: [
        Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _legendRow(_Ch.green, '$qPct%', 'Qualified'), SizedBox(height: 12.h), _legendRow(_Ch.grey, '$uPct%', 'Unqualified'),
        ])),
        Expanded(flex: 3, child: Stack(alignment: Alignment.center, children: [
          PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 44.sp, sections: [
            PieChartSectionData(value: qualifiedCount.toDouble().clamp(0.1, double.infinity), color: _Ch.green, radius: 30.sp, title: ''),
            PieChartSectionData(value: unqualifiedCount.toDouble().clamp(0.1, double.infinity), color: _Ch.grey, radius: 30.sp, title: ''),
          ])),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Total\nApplication', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.sp, color: Colors.black54)),
            Text(_fmtNum(_total), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black)),
          ]),
        ])),
      ])),
    );
  }

  Widget _buildHiringStage() {
    final stages = [_FunnelItem('Applied', _appliedStage, _Ch.darkGreen), _FunnelItem('Interviewed', _interviewStage, const Color(0xFF2E7D32)), _FunnelItem('Offer Sent', _offerStage, _Ch.green), _FunnelItem('Hired', _hired, _Ch.lightGreen)];
    final maxVal = stages.map((s) => s.value).reduce((a, b) => a > b ? a : b).clamp(1, 999999);
    return _card(title: 'Hiring Stage', height: 280,
      child: Expanded(child: Row(children: [
        SizedBox(width: 90.w, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
          children: stages.map((s) => Padding(padding: EdgeInsets.only(bottom: 8.sp), child: Row(children: [
            Container(width: 10.sp, height: 10.sp, decoration: BoxDecoration(shape: BoxShape.circle, color: s.color)), SizedBox(width: 5.sp),
            Expanded(child: Text(s.label, style: TextStyle(fontSize: 10.sp, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]))).toList(),
        )),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: stages.map((s) {
            final frac = s.value / maxVal;
            return Padding(padding: EdgeInsets.only(bottom: 3.sp), child: LayoutBuilder(builder: (context, constraints) {
              final barWidth = constraints.maxWidth * frac;
              return Align(alignment: Alignment.centerLeft, child: Container(
                width: barWidth.clamp(30.0, constraints.maxWidth), height: 28.sp,
                decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2.r)),
                child: Center(child: Text(s.value.toString(), style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600))),
              ));
            }));
          }).toList(),
        )),
      ])),
    );
  }

  Widget _buildInterviewStage() {
    final passed = _interviewPassed; final failed = _interviewFailed; final withdrew = _interviewWithdrew;
    final total = passed + failed + withdrew;
    final pPct = total > 0 ? (passed / total * 100).round() : 0;
    final fPct = total > 0 ? (failed / total * 100).round() : 0;
    final wPct = total > 0 ? 100 - pPct - fPct : 0;
    return _card(title: 'Interview Stage', height: 280,
      child: Expanded(child: Row(children: [
        Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _legendRow(_Ch.green, '$pPct%', 'Passed'), SizedBox(height: 8.h), _legendRow(_Ch.lightGreen, '$fPct%', 'Failed'), SizedBox(height: 8.h), _legendRow(_Ch.grey, '$wPct%', 'Candidate Withdrew'),
        ])),
        Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 0, sections: [
          PieChartSectionData(value: passed.toDouble().clamp(0.1, double.infinity), color: _Ch.green, radius: 60.sp, title: ''),
          PieChartSectionData(value: failed.toDouble().clamp(0.1, double.infinity), color: _Ch.lightGreen, radius: 60.sp, title: ''),
          PieChartSectionData(value: withdrew.toDouble().clamp(0.1, double.infinity), color: _Ch.grey, radius: 60.sp, title: ''),
        ]))),
      ])),
    );
  }

  Widget _buildJobOffer() {
    final items = [_PieItem('Approved', _offerApproved.toDouble(), _Ch.green), _PieItem('Pending', _offerPending.toDouble(), _Ch.yellow), _PieItem('Rejected', _offerRejected.toDouble(), _Ch.red)];
    final sum = _offerApproved + _offerPending + _offerRejected;
    return _card(title: 'Job Offer', height: 280,
      child: Expanded(child: Row(children: [
        Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) => Padding(padding: EdgeInsets.only(bottom: 8.sp), child: Row(children: [
            Container(width: 10.sp, height: 10.sp, decoration: BoxDecoration(shape: BoxShape.circle, color: item.color)), SizedBox(width: 6.sp),
            Expanded(child: Text(item.label, style: TextStyle(fontSize: 11.sp, color: Colors.black87))),
            Text(_fmtNum(item.value.toInt()), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
          ]))).toList(),
        )),
        SizedBox(width: 8.w),
        Expanded(flex: 3, child: Stack(alignment: Alignment.center, children: [
          PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40.sp, sections: items.map((item) =>
              PieChartSectionData(value: item.value.clamp(0.1, double.infinity), color: item.color, radius: 28.sp, title: '')).toList())),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_fmtNum(sum), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black)),
            Text('Total', style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          ]),
        ])),
      ])),
    );
  }

  Widget _buildScoreDistributionChart() {
    final dist = _scoreDistribution;
    final segments = [_ScoreSegment('Poor', dist['Poor'] ?? 0, _Ch.poor), _ScoreSegment('Weak', dist['Weak'] ?? 0, _Ch.weak), _ScoreSegment('Good', dist['Good'] ?? 0, _Ch.good), _ScoreSegment('Very Good', dist['Very Good'] ?? 0, _Ch.veryGood), _ScoreSegment('Excellent', dist['Excellent'] ?? 0, _Ch.excellent)];
    final total = segments.fold<int>(0, (s, e) => s + e.value);
    return _card(title: 'Candidate Score Distribution', height: 280,
      child: Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: segments.map((s) => Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10.sp, height: 10.sp, decoration: BoxDecoration(shape: BoxShape.circle, color: s.color)), SizedBox(height: 4.sp),
          Text(s.label, style: TextStyle(fontSize: 9.sp, color: Colors.black54)),
          Text(_fmtNum(s.value), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        ])).toList()),
        SizedBox(height: 12.h),
        ClipRRect(borderRadius: BorderRadius.circular(4.r), child: Row(
          children: total > 0 ? segments.map((s) => Flexible(flex: s.value.clamp(1, 999999), child: Container(height: 20.sp, color: s.color))).toList()
              : [Expanded(child: Container(height: 20.sp, color: Colors.grey.shade200))],
        )),
      ])),
    );
  }

  Widget _card({required String title, required double height, required Widget child, String? subtitle}) {
    final innerChild = child is Expanded ? child.child : child;
    return Container(height: height.h, padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF333333))),
        if (subtitle != null) ...[SizedBox(height: 2.h), Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.black45))],
        SizedBox(height: 10.h), Expanded(child: innerChild),
      ]),
    );
  }

  Widget _legendRow(Color color, String percent, String label) => Row(children: [
    Container(width: 12.sp, height: 12.sp, decoration: BoxDecoration(shape: BoxShape.circle, color: color)), SizedBox(width: 6.sp),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(percent, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black)),
      Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
    ]),
  ]);

  String _fmtNum(int n) { final s = n.toString(); final buf = StringBuffer(); for (int i = 0; i < s.length; i++) { if (i > 0 && (s.length - i) % 3 == 0) buf.write(','); buf.write(s[i]); } return buf.toString(); }
}

class _FunnelItem { final String label; final int value; final Color color; const _FunnelItem(this.label, this.value, this.color); }
class _PieItem { final String label; final double value; final Color color; const _PieItem(this.label, this.value, this.color); }
class _ScoreSegment { final String label; final int value; final Color color; const _ScoreSegment(this.label, this.value, this.color); }

// ═════════════════════════════════════════════════════════════════════════════
//  TAB 3 — APPLICANT DETAILS (Table widget pattern + column visibility)
// ═════════════════════════════════════════════════════════════════════════════

class _ApplicantDetailsTab extends StatefulWidget {
  final JobPostModel job;
  final List<ApplicationModel> applications;
  final bool loading;
  final VoidCallback onRefresh;
  const _ApplicantDetailsTab({required this.job, required this.applications, required this.loading, required this.onRefresh});

  @override
  State<_ApplicantDetailsTab> createState() => _ApplicantDetailsTabState();
}

class _ApplicantDetailsTabState extends State<_ApplicantDetailsTab> {
  String? _stageFilter;
  String? _statusFilter;
  String? _calendarFilter;

  late Map<String, bool> _columnVisibility;

  @override
  void initState() {
    super.initState();
    _columnVisibility = ColumnKey.defaultVisibility();
  }

  bool _isVisible(String key) => _columnVisibility[key] ?? true;
  List<String> get _visibleColumnKeys => ColumnKey.all.where((k) => _isVisible(k)).toList();

  static final List<Map<String, String>> _stageItems = [
    {'key': 'Applied', 'value': 'Applied'}, {'key': 'Interview', 'value': 'Interview'},
    {'key': 'Offer', 'value': 'Offer'}, {'key': 'Hired', 'value': 'Hired'},
  ];

  static final List<Map<String, String>> _statusItems = [
    {'key': 'Applied', 'value': 'Applied'}, {'key': 'Qualified', 'value': 'Qualified'}, {'key': 'Unqualified', 'value': 'Unqualified'},
    {'key': 'Interview: Passed', 'value': 'Passed'}, {'key': 'Interview: Failed', 'value': 'Failed'}, {'key': 'Interview: Withdrew', 'value': 'Withdrew'},
    {'key': 'Offer: Approved', 'value': 'Approved'}, {'key': 'Offer: Pending', 'value': 'Pending'}, {'key': 'Offer: Rejected', 'value': 'Rejected'},
    {'key': 'Hired: Completed', 'value': 'Completed'},
  ];

  static final Map<String, Color> _stageColors = {
    'Applied': const Color(0xFF2196F3), 'Interview': const Color(0xFFFF9800),
    'Offer': const Color(0xFF9C27B0), 'Hired': const Color(0xFF2E7D32),
  };

  static final Map<String, Color> _statusColors = {
    'Applied': const Color(0xFF2196F3), 'Qualified': const Color(0xFF2E7D32), 'Unqualified': const Color(0xFFD32F2F),
    'Interview: Passed': const Color(0xFF2E7D32), 'Interview: Failed': const Color(0xFFD32F2F), 'Interview: Withdrew': const Color(0xFF757575),
    'Offer: Approved': const Color(0xFF2E7D32), 'Offer: Pending': const Color(0xFFFF9800), 'Offer: Rejected': const Color(0xFFD32F2F),
    'Hired: Completed': const Color(0xFF2E7D32),
  };

  static final List<Map<String, String>> _calendarItems = [
    {'key': '2026-01', 'value': 'January 2026'}, {'key': '2026-02', 'value': 'February 2026'},
    {'key': '2026-03', 'value': 'March 2026'}, {'key': '2025-12', 'value': 'December 2025'},
  ];

  List<ApplicationModel> get _filtered {
    var result = widget.applications;
    if (_stageFilter != null) result = result.where((a) => a.status.stage == _stageFilter).toList();
    if (_statusFilter != null) result = result.where((a) => a.status.label == _statusFilter).toList();
    if (_calendarFilter != null) {
      result = result.where((a) {
        if (a.applicationDate == null) return false;
        final ym = '${a.applicationDate!.year}-${a.applicationDate!.month.toString().padLeft(2, '0')}';
        return ym == _calendarFilter;
      }).toList();
    }
    return result;
  }

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() { _horizontalScrollController.dispose(); super.dispose(); }

  // ── Open table setting dialog — uses top-level showTableSettingDialog ──
  Future<void> _openTableSettingDialog() async {
    print('🟡 [Tab3] _openTableSettingDialog tapped');
    final result = await showTableSettingDialog(context, _columnVisibility);
    print('🟢 [Tab3] Dialog result: $result');
    if (result != null && mounted) {
      setState(() => _columnVisibility = result);
    }
  }

  // ── Styles ──
  TextStyle get _headerStyle => TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white);
  TextStyle get _cellStyle => TextStyle(fontSize: 12.sp, color: const Color(0xFF333333));

  Widget _cell(Widget child, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle, child: child),
    );
  }

  Widget _textCell(String text, {int maxLines = 1}) {
    return _cell(Text(
      text.isEmpty ? '—' : text, maxLines: maxLines, overflow: TextOverflow.ellipsis,
      style: _cellStyle.copyWith(color: text.isEmpty ? const Color(0xFFAAAAAA) : const Color(0xFF333333)),
    ));
  }

  Widget _rowTapWrapper(Widget child, VoidCallback onTap) => InkWell(onTap: onTap, child: child);

  Widget _statusBadgeCell(String status) {
    Color bg, fg;
    if (status.contains('Passed') || status.contains('Approved') || status.contains('Completed') || status == 'Qualified') { bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32); }
    else if (status.contains('Failed') || status.contains('Rejected') || status == 'Unqualified') { bg = const Color(0xFFFFEBEE); fg = const Color(0xFFD32F2F); }
    else if (status.contains('Pending')) { bg = const Color(0xFFFFF8E1); fg = const Color(0xFFF57F17); }
    else if (status.contains('Withdrew')) { bg = const Color(0xFFF5F5F5); fg = const Color(0xFF757575); }
    else { bg = const Color(0xFFE3F2FD); fg = const Color(0xFF1976D2); }
    return _cell(Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.r)),
      child: Text(status, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
    ));
  }

  Widget _stageCell(String stage) {
    Color color;
    switch (stage) { case 'Hired': color = const Color(0xFF2E7D32); break; case 'Interview': color = const Color(0xFFFF9800); break; case 'Offer': color = const Color(0xFF9C27B0); break; default: color = const Color(0xFF333333); }
    return _cell(Text(stage.isEmpty ? '—' : stage, style: _cellStyle.copyWith(color: color, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis));
  }

  Widget _tagCell(String tag) {
    if (tag.isEmpty) return _textCell('');
    Color bg, fg;
    switch (tag.toLowerCase()) { case 'strong': bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32); break; case 'adequate': bg = const Color(0xFFFFF8E1); fg = const Color(0xFFF57F17); break; case 'weak': bg = const Color(0xFFFFEBEE); fg = const Color(0xFFD32F2F); break; default: bg = const Color(0xFFF5F5F5); fg = const Color(0xFF757575); }
    return _cell(Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.r)),
      child: Text(tag, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
    ));
  }

  Widget _linkCell(String url) {
    if (url.isEmpty) return _textCell('');
    return _cell(GestureDetector(onTap: () {},
      child: Text(url, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1976D2), decoration: TextDecoration.underline, decorationColor: const Color(0xFF1976D2)), maxLines: 1, overflow: TextOverflow.ellipsis),
    ));
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  double _calcWidth(List<ApplicationModel> apps, String Function(ApplicationModel) getter, {double minW = 100, double maxW = 280}) {
    double maxLen = 0;
    for (var a in apps) { final val = getter(a); if (val.isNotEmpty) maxLen = math.max(maxLen, val.length.toDouble()); }
    if (maxLen == 0) return minW.sp;
    return math.max(math.min((maxLen * 8.sp) + 20.sp, maxW.sp), minW.sp);
  }

  String _headerLabel(String key) => ColumnKey.labels[key] ?? key;

  Widget _cellForKey(String key, ApplicationModel a) {
    final avgScore = (a.technicalSkills + a.communicationSkills + a.experienceBackground + a.cultureFit + a.leadershipPotential);
    final scoreText = avgScore > 0 ? (avgScore / 5).toStringAsFixed(1) : '';
    switch (key) {
      case ColumnKey.firstName:        return _textCell(a.firstName);
      case ColumnKey.lastName:         return _textCell(a.lastName);
      case ColumnKey.email:            return _textCell(a.email);
      case ColumnKey.code:             return _textCell(a.countryCode);
      case ColumnKey.phone:            return _textCell(a.phone);
      case ColumnKey.source:           return _textCell(a.source);
      case ColumnKey.location:         return _textCell(a.jobLocation);
      case ColumnKey.resume:           return _linkCell(a.resumeUrl);
      case ColumnKey.coverLetter:      return _linkCell(a.coverLetterUrl);
      case ColumnKey.status:           return _statusBadgeCell(a.status.label);
      case ColumnKey.stage:            return _stageCell(a.status.stage);
      case ColumnKey.score:            return _textCell(scoreText);
      case ColumnKey.tags:             return _tagCell(a.tag);
      case ColumnKey.appliedDate:      return _textCell(_fmtDate(a.applicationDate));
      case ColumnKey.interviewDate:    return _textCell(_fmtDate(a.interviewDate));
      case ColumnKey.lastUpdate:       return _textCell(_fmtDate(a.lastUpdate));
      case ColumnKey.yearOfGraduation: return _textCell(a.yearOfGraduation);
      default:                         return _textCell('');
    }
  }

  double _widthForKey(String key, List<ApplicationModel> rows) {
    switch (key) {
      case ColumnKey.firstName:        return _calcWidth(rows, (a) => a.firstName, minW: 100, maxW: 180);
      case ColumnKey.lastName:         return _calcWidth(rows, (a) => a.lastName, minW: 100, maxW: 180);
      case ColumnKey.email:            return _calcWidth(rows, (a) => a.email, minW: 160, maxW: 280);
      case ColumnKey.code:             return 70.sp;
      case ColumnKey.phone:            return _calcWidth(rows, (a) => a.phone, minW: 110, maxW: 180);
      case ColumnKey.source:           return 110.sp;
      case ColumnKey.location:         return _calcWidth(rows, (a) => a.jobLocation, minW: 110, maxW: 200);
      case ColumnKey.resume:           return 140.sp;
      case ColumnKey.coverLetter:      return 140.sp;
      case ColumnKey.status:           return 120.sp;
      case ColumnKey.stage:            return 100.sp;
      case ColumnKey.score:            return 70.sp;
      case ColumnKey.tags:             return 80.sp;
      case ColumnKey.appliedDate:      return 120.sp;
      case ColumnKey.interviewDate:    return 130.sp;
      case ColumnKey.lastUpdate:       return 120.sp;
      case ColumnKey.yearOfGraduation: return 130.sp;
      default:                         return 100.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return Center(child: Padding(padding: EdgeInsets.all(40.sp), child: const CircularProgressIndicator(color: _C.primary)));

    final rows = _filtered;
    final visibleKeys = _visibleColumnKeys;

    final columnWidths = <int, TableColumnWidth>{ 0: FixedColumnWidth(50.sp) };
    for (int i = 0; i < visibleKeys.length; i++) {
      columnWidths[i + 1] = FixedColumnWidth(_widthForKey(visibleKeys[i], rows));
    }
    final headerLabels = <String>['No', ...visibleKeys.map((k) => _headerLabel(k))];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Filter row ──
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        SizedBox(width: 160.w, child: CustomDropdownFormFieldInvMaster(
          selectedValue: _stageFilter, items: _stageItems, widthIcon: 18, heightIcon: 18, height: 36,
          hint: Text('Stage', style: TextStyle(fontSize: 12.sp, color: _C.hintText)),
          itemColors: _stageColors, showColorDots: true,
          onChanged: (v) => setState(() => _stageFilter = v),
        )),
        SizedBox(width: 12.w),
        SizedBox(width: 160.w, child: CustomDropdownFormFieldInvMaster(
          selectedValue: _statusFilter, items: _statusItems, widthIcon: 18, heightIcon: 18, height: 36,
          hint: Text('Status', style: TextStyle(fontSize: 12.sp, color: _C.hintText)),
          itemColors: _statusColors, showColorDots: true,
          onChanged: (v) => setState(() => _statusFilter = v),
        )),
        const Spacer(),
        SizedBox(width: 160.w, child: CustomDropdownFormFieldCalender(
          selectedValue: _calendarFilter, items: _calendarItems, widthIcon: 14, heightIcon: 14,
          dropdownColor: Colors.white, height: 36,
          hint: Text('Calendar', style: TextStyle(fontSize: 12.sp, color: _C.hintText)),
          onChanged: (v) => setState(() => _calendarFilter = v),
        )),
        SizedBox(width: 12.w),
        // ── TABLE SETTING BUTTON — uses Material InkWell for reliable tap on Web ──
        Material(
          color: _C.primary,
          borderRadius: BorderRadius.circular(6.r),
          child: InkWell(
            onTap: _openTableSettingDialog,
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(child: Text('Table Setting', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white))),
            ),
          ),
        ),
      ]),
      SizedBox(height: 10.h),

      Align(alignment: Alignment.centerRight, child: customButtonWithImage(
        title: 'Export', function: () => showJobListingExportDialog(
        context,
        job: widget.job,
        applications: _filtered,
      ),
        textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
        height: 36.h, width: 135.w, space: 6.w, radius: 6.r, color: _C.primary,
        image: 'assets/images/export.svg', widthImage: 16.sp, heightImage: 16.sp,
        colorBorder: Colors.transparent, svgColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16.w),
      )),
      SizedBox(height: 16.h),

      // ── TABLE ──
      Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                border: TableBorder.all(color: Colors.transparent, borderRadius: BorderRadius.circular(10.sp)),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: _C.primary),
                    children: headerLabels.map((name) => Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: Text(name, style: _headerStyle, maxLines: 1, textAlign: TextAlign.start),
                    )).toList(),
                  ),

                  if (rows.isEmpty)
                    TableRow(
                      decoration: const BoxDecoration(color: Colors.white),
                      children: [
                        _cell(Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.sp),
                          child: Text('No applicants match the selected filters.', style: TextStyle(fontSize: 13.sp, color: _C.hintText)),
                        )),
                        ...List.generate(headerLabels.length - 1, (_) => const SizedBox()),
                      ],
                    ),

                  ...List.generate(rows.length, (index) {
                    final a = rows[index];
                    final rowColor = index.isEven ? const Color(0xFFF7F8FA) : Colors.white;

                    VoidCallback goDetails = () {};

                    final cells = <Widget>[
                      _textCell('${index + 1}'),
                      ...visibleKeys.map((key) => _cellForKey(key, a)),
                    ];

                    return TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: cells.map((cell) => _rowTapWrapper(cell, goDetails)).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED — Section card (for Tab 1)
// ═════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatefulWidget {
  final String title; final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _open = true;
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => setState(() => _open = !_open),
          child: Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(color: _C.primary,
                borderRadius: _open ? BorderRadius.only(topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r)) : BorderRadius.circular(6.r)),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))),
              Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (_open) Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.r), bottomRight: Radius.circular(6.r))),
            child: widget.child),
      ]),
    );
  }
}