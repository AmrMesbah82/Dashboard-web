// ═══════════════════════════════════════════════════════════════════
// FILE: application_detail_page.dart (Detail / Edit Page)
// Path: lib/pages/dashboard/application/application_detail_page.dart
// UPDATED: Single dynamic dropdown for status pipeline
// UPDATED: All fields use CustomValidatedTextFieldMaster
// UPDATED: All dropdowns use CustomDropdownFormFieldInvMaster
// FIXED: Removed stuck spinner on status change
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/application/application_cubit.dart';
import 'package:web_app_admin/controller/application/application_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

import '../../careers_main_dashboard.dart';
import '../main_page/home_main_page.dart';
import '../job_list/job_listing_main_page.dart';

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color back = Color(0xFFF1F2ED);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color red = Color(0xFFE53935);
}

// ── Tag dropdown items ────────────────────────────────────────────────────────
const List<Map<String, String>> _kTagItems = [
  {'key': 'Weak', 'value': 'Weak'},
  {'key': 'Adequate', 'value': 'Adequate'},
  {'key': 'Strong', 'value': 'Strong'},
];

const Map<String, Color> _kTagColors = {
  'Weak': Color(0xFFD32F2F),
  'Adequate': Color(0xFFF57F17),
  'Strong': Color(0xFF2E7D32),
};

class ApplicationDetailPage extends StatefulWidget {
  final String jobId;
  final String appId;
  const ApplicationDetailPage({
    super.key,
    required this.jobId,
    required this.appId,
  });

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  final _technicalCtrl = TextEditingController();
  final _communicationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _cultureFitCtrl = TextEditingController();
  final _leadershipCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  String? _selectedTag;
  bool _isSaving = false;
  bool _didLoad = false;

  ApplicationModel? _currentApp;

  @override
  void initState() {
    super.initState();
    context.read<ApplicationCubit>().loadDetail(widget.jobId, widget.appId);
  }

  void _seedControllers(ApplicationModel app) {
    if (_didLoad) return;
    _didLoad = true;
    _currentApp = app;
    _technicalCtrl.text = app.technicalSkills > 0
        ? app.technicalSkills.toString()
        : '';
    _communicationCtrl.text = app.communicationSkills > 0
        ? app.communicationSkills.toString()
        : '';
    _experienceCtrl.text = app.experienceBackground > 0
        ? app.experienceBackground.toString()
        : '';
    _cultureFitCtrl.text = app.cultureFit > 0 ? app.cultureFit.toString() : '';
    _leadershipCtrl.text = app.leadershipPotential > 0
        ? app.leadershipPotential.toString()
        : '';
    _commentsCtrl.text = app.comments;
    _selectedTag = app.tag.isNotEmpty ? app.tag : null;
  }

  @override
  void dispose() {
    _technicalCtrl.dispose();
    _communicationCtrl.dispose();
    _experienceCtrl.dispose();
    _cultureFitCtrl.dispose();
    _leadershipCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  // ── Status change with confirm dialog ──────────────────────────────────────
  void _onStatusChange(ApplicationModel app, ApplicationStatus newStatus) {
    showDialog(
      context: context,
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
              SvgPicture.asset(
                'assets/images/dashboard_image.svg',
                height: 120.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              Text(
                'CHANGE STATUS',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: _C.labelText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to change this Submissions status from ${app.status.label} to ${newStatus.label}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _C.hintText,
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
                              color: _C.labelText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.read<ApplicationCubit>().updateStatus(
                          app.jobId,
                          app.id,
                          newStatus,
                        );
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
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

  // ── Save scoring ───────────────────────────────────────────────────────────
  Future<void> _saveScoring() async {
    if (_currentApp == null) return;
    setState(() => _isSaving = true);

    final updated = _currentApp!.copyWith(
      tag: _selectedTag ?? '',
      technicalSkills: int.tryParse(_technicalCtrl.text) ?? 0,
      communicationSkills: int.tryParse(_communicationCtrl.text) ?? 0,
      experienceBackground: int.tryParse(_experienceCtrl.text) ?? 0,
      cultureFit: int.tryParse(_cultureFitCtrl.text) ?? 0,
      leadershipPotential: int.tryParse(_leadershipCtrl.text) ?? 0,
      comments: _commentsCtrl.text,
    );

    await context.read<ApplicationCubit>().updateScoring(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scoring saved successfully')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  DYNAMIC STATUS DROPDOWN HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  int _getStageIndex(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
      case ApplicationStatus.qualified:
      case ApplicationStatus.unqualified:
        return 0;
      case ApplicationStatus.interviewPassed:
      case ApplicationStatus.interviewFailed:
      case ApplicationStatus.interviewWithdrew:
        return 1;
      case ApplicationStatus.offerApproved:
      case ApplicationStatus.offerPending:
      case ApplicationStatus.offerRejected:
        return 2;
      case ApplicationStatus.hired:
        return 3;
    }
  }

  bool _isStoppedStatus(ApplicationStatus status) {
    return status == ApplicationStatus.unqualified ||
        status == ApplicationStatus.interviewFailed ||
        status == ApplicationStatus.interviewWithdrew ||
        status == ApplicationStatus.offerRejected;
  }

  List<Map<String, String>> _getDropdownItems(ApplicationStatus status) {
    if (_isStoppedStatus(status) || status == ApplicationStatus.hired) {
      return [];
    }

    switch (status) {
      case ApplicationStatus.applied:
        return [
          {'key': 'qualified', 'value': 'Qualified'},
          {'key': 'unqualified', 'value': 'Unqualified'},
        ];
      case ApplicationStatus.qualified:
        return [
          {'key': 'passed', 'value': 'Passed'},
          {'key': 'failed', 'value': 'Failed'},
          {'key': 'withdrew', 'value': 'Withdrew'},
        ];
      case ApplicationStatus.interviewPassed:
        return [
          {'key': 'approved', 'value': 'Approved'},
          {'key': 'rejected', 'value': 'Rejected'},
        ];
      case ApplicationStatus.offerApproved:
      case ApplicationStatus.offerPending:
        return [
          {'key': 'completed', 'value': 'Completed'},
        ];
      default:
        return [];
    }
  }

  ApplicationStatus? _mapKeyToStatus(String key) {
    switch (key) {
      case 'qualified':
        return ApplicationStatus.qualified;
      case 'unqualified':
        return ApplicationStatus.unqualified;
      case 'passed':
        return ApplicationStatus.interviewPassed;
      case 'failed':
        return ApplicationStatus.interviewFailed;
      case 'withdrew':
        return ApplicationStatus.interviewWithdrew;
      case 'approved':
        return ApplicationStatus.offerApproved;
      case 'rejected':
        return ApplicationStatus.offerRejected;
      case 'completed':
        return ApplicationStatus.hired;
      default:
        return null;
    }
  }

  String _getDropdownHint(ApplicationStatus status) {
    if (_isStoppedStatus(status) || status == ApplicationStatus.hired) {
      return status.label;
    }
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.qualified:
        return 'Interview';
      case ApplicationStatus.interviewPassed:
        return 'Offer';
      case ApplicationStatus.offerApproved:
      case ApplicationStatus.offerPending:
        return 'Hired';
      default:
        return 'Select';
    }
  }

  List<Widget> _buildCompletedStageChips(ApplicationStatus status) {
    final List<Widget> chips = [];
    final int currentStage = _getStageIndex(status);
    final bool isStopped = _isStoppedStatus(status);

    if (currentStage > 0) {
      chips.add(_completedChip('Applied: Qualified'));
      chips.add(SizedBox(width: 8.w));
    }
    if (currentStage > 1) {
      chips.add(_completedChip('Interview: Passed'));
      chips.add(SizedBox(width: 8.w));
    }
    if (currentStage > 2) {
      chips.add(_completedChip('Offer: Approved'));
      chips.add(SizedBox(width: 8.w));
    }

    if (isStopped) {
      String stoppedLabel = '';
      switch (status) {
        case ApplicationStatus.unqualified:
          stoppedLabel = 'Applied: Unqualified';
          break;
        case ApplicationStatus.interviewFailed:
          stoppedLabel = 'Interview: Failed';
          break;
        case ApplicationStatus.interviewWithdrew:
          stoppedLabel = 'Interview: Withdrew';
          break;
        case ApplicationStatus.offerRejected:
          stoppedLabel = 'Offer: Rejected';
          break;
        default:
          break;
      }
      if (stoppedLabel.isNotEmpty) {
        chips.add(_stoppedChip(stoppedLabel));
        chips.add(SizedBox(width: 8.w));
      }
    }

    if (status == ApplicationStatus.hired) {
      chips.add(_completedChip('Hired: Completed'));
      chips.add(SizedBox(width: 8.w));
    }

    return chips;
  }

  Widget _completedChip(String label) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: _C.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14.sp, color: _C.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _C.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stoppedChip(String label) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: _C.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: _C.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, size: 14.sp, color: _C.red),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _C.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── BlocListener: reset _didLoad when status updates so UI re-seeds ──
    return BlocListener<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationUpdated) {
          _didLoad = false;
          _currentApp = state.application;
        }
      },
      child: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          ApplicationModel? app;
          if (state is ApplicationDetailLoaded) app = state.application;
          if (state is ApplicationUpdated) app = state.application;

          // ── Fallback: keep using cached app while cubit is in loading/intermediate state ──
          if (app == null && _currentApp != null) {
            app = _currentApp;
          }

          if (app == null) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(
                child: CircularProgressIndicator(color: _C.primary),
              ),
            );
          }

          _seedControllers(app);
          _currentApp = app;

          final dropdownItems = _getDropdownItems(app.status);
          final completedChips = _buildCompletedStageChips(app.status);
          final bool hasNextOptions = dropdownItems.isNotEmpty;

          return Scaffold(
            backgroundColor: _C.back,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel: 'Applications',
                      homePage: CareersMainPageDashboard(),
                      webPage: HomeMainPage(),
                      jobListingPage: JobListingMainPage(),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Title ──
                            Text(
                              'Applications',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ══════════════════════════════════════════════
                            // ── STATUS PIPELINE ──
                            // ══════════════════════════════════════════════
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...completedChips,

                                  if (completedChips.isNotEmpty &&
                                      hasNextOptions) ...[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right,
                                        size: 18.sp,
                                        color: _C.hintText,
                                      ),
                                    ),
                                  ],

                                  if (hasNextOptions)
                                    SizedBox(
                                      width: 200.w,
                                      child: CustomDropdownFormFieldInvMaster(
                                        selectedValue: null,
                                        items: dropdownItems,
                                        widthIcon: 18,
                                        heightIcon: 18,
                                        height: 36,
                                        dropdownColor: Colors.white,
                                        hint: Text(
                                          _getDropdownHint(app!.status),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: _C.labelText,
                                          ),
                                        ),
                                        onChanged: (selectedKey) {
                                          if (selectedKey == null) return;
                                          final newStatus =
                                          _mapKeyToStatus(selectedKey);
                                          if (newStatus != null) {
                                            _onStatusChange(app!, newStatus);
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Personal Information Card ──
                            _buildPersonalInfoCard(app),
                            SizedBox(height: 24.h),

                            // ── Tags + Scoring Card ──
                            _buildTagsScoringCard(app),
                            SizedBox(height: 24.h),

                            // ── Save button ──
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _isSaving ? null : _saveScoring,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: _isSaving
                                      ? SizedBox(
                                    width: 16.sp,
                                    height: 16.sp,
                                    child:
                                    const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    'Save Scoring',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PERSONAL INFORMATION + PROFILE INFORMATION CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPersonalInfoCard(ApplicationModel app) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Information'),
          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _readOnlyField('First Name', app.firstName)),
              SizedBox(width: 16.w),
              Expanded(child: _readOnlyField('Last Name', app.lastName)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _readOnlyField('Email', app.email)),
              SizedBox(width: 16.w),
              Expanded(
                child: _readOnlyField(
                  'Phone',
                  '${app.countryCode} ${app.phone}',
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _readOnlyField(
                  'Year Of Graduation',
                  app.yearOfGraduation,
                ),
              ),
              SizedBox(width: 16.w),
              const Expanded(child: SizedBox()),
            ],
          ),

          SizedBox(height: 20.h),

          _sectionTitle('Profile Information'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _fileCard('Resume*', app.resumeName, app.resumeUrl),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _fileCard(
                  'Cover Letter*',
                  app.coverLetterName,
                  app.coverLetterUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TAGS + SCORING INTERVIEW CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTagsScoringCard(ApplicationModel app) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Information'),
          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200.w,
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Tags',
                  selectedValue: _selectedTag,
                  items: _kTagItems,
                  widthIcon: 18,
                  heightIcon: 18,
                  height: 36,
                  dropdownColor: Color(0xFFF1F2ED),
                  itemColors: _kTagColors,
                  showColorDots: true,
                  hint: Text(
                    'Select Tag',
                    style: TextStyle(fontSize: 12.sp, color: _C.hintText),
                  ),
                  onChanged: (v) => setState(() => _selectedTag = v),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          _sectionTitle('Scoring Interview'),
          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Technical Skills',
                  hint: 'Text Here, 1-5 Scoring',
                  controller: _technicalCtrl,
                  height: 36,
                  onlyDigits: true,
                  submitted: false,
                  primaryColor: _C.primary,
                  fillColor: Color(0xFFF1F2ED),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Communication Skills',
                  hint: 'Text Here, 1-5 Scoring',
                  controller: _communicationCtrl,
                  height: 36,
                  onlyDigits: true,
                  submitted: false,
                  primaryColor: _C.primary,
                  fillColor: Color(0xFFF1F2ED),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Experience & Background',
                  hint: 'Text Here, 1-5 Scoring',
                  controller: _experienceCtrl,
                  height: 36,
                  onlyDigits: true,
                  submitted: false,
                  primaryColor: _C.primary,
                  fillColor: Color(0xFFF1F2ED),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Culture Fit',
                  hint: 'Text Here, 1-5 Scoring',
                  controller: _cultureFitCtrl,
                  height: 36,
                  onlyDigits: true,
                  submitted: false,
                  primaryColor: _C.primary,
                  fillColor: Color(0xFFF1F2ED),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Leadership Potential',
                  hint: 'Text Here, 1-5 Scoring',
                  controller: _leadershipCtrl,
                  height: 36,
                  onlyDigits: true,
                  submitted: false,
                  primaryColor: _C.primary,
                  fillColor: Color(0xFFF1F2ED),
                ),
              ),
              SizedBox(width: 16.w),
              const Expanded(child: SizedBox()),
            ],
          ),

          CustomValidatedTextFieldMaster(
            label: 'Comments',
            hint: 'Text Here',
            controller: _commentsCtrl,
            height: 100,
            maxLines: 5,
            submitted: false,
            primaryColor: _C.primary,
            fillColor: Color(0xFFF1F2ED),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: _C.primary,
    ),
  );

  Widget _readOnlyField(String label, String value) {
    return CustomValidatedTextFieldMaster(
      label: label,
      hint: 'Text Here',
      controller: TextEditingController(text: value),
      height: 36,
      enabled: false,
      submitted: false,
      primaryColor: _C.primary,
      fillColor: const Color(0xFFF1F2ED),
    );
  }

  Widget _fileCard(String label, String fileName, String fileUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: _C.labelText,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            children: [
              CustomSvg(
                assetPath: "assets/images/pdf 1.svg",
                width: 30.w,
                height: 30.h,
                fit: BoxFit.fill,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName.isEmpty ? 'No file' : fileName,
                      style: TextStyle(fontSize: 11.sp, color: _C.labelText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileName.isNotEmpty)
                      Text(
                        '62 KB',
                        style: TextStyle(fontSize: 9.sp, color: _C.hintText),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}