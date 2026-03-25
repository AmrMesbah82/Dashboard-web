// ******************* FILE INFO *******************
// File Name: job_listing_preview_page.dart
// Created by: Amr Mesbah
// Purpose: Preview Job Post Details — Desktop/Tablet/Mobile + ENG/AR toggle
// UPDATED: Firebase-backed — fetches from cubit.allJobs or loads from Firestore
// UPDATED: UI matches Figma — green-tinted sections, bold key bullets, Benefits layout

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/job_list/job_listing_cubit.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';

class _C {
  static const Color primary      = Color(0xFF008037);
  static const Color back         = Color(0xFFF1F2ED);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color border       = Color(0xFFE0E0E0);
  static const Color labelText    = Color(0xFF333333);
  static const Color hintText     = Color(0xFF999999);
  static const Color sectionBg    = Color(0xFFF5FAF5); // light green tint for sections
  static const Color dividerColor = Color(0xFFE8E8E8);
}

class JobListingPreviewPage extends StatefulWidget {
  final String jobId;
  const JobListingPreviewPage({super.key, required this.jobId});

  @override
  State<JobListingPreviewPage> createState() => _JobListingPreviewPageState();
}

class _JobListingPreviewPageState extends State<JobListingPreviewPage> {
  String _viewMode = 'Desktop';
  String _lang = 'ENG';

  @override
  void initState() {
    super.initState();
    // If job is not in local cache, fetch from Firestore
    final cubit = context.read<JobListingCubit>();
    final hasLocal = cubit.allJobs.any((j) => j.id == widget.jobId);
    if (!hasLocal && widget.jobId != 'new') {
      cubit.loadJobDetail(widget.jobId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JobListingCubit>();

    // Try to find job from local cache first
    JobPostModel? job;
    final localList = cubit.allJobs.where((j) => j.id == widget.jobId).toList();
    if (localList.isNotEmpty) {
      job = localList.first;
    }

    // If not found locally, show loading or use BlocBuilder for async fetch
    if (job == null && widget.jobId != 'new') {
      return BlocBuilder<JobListingCubit, JobListingState>(
        builder: (context, state) {
          if (state is JobListingDetailLoaded) {
            return _buildPreviewContent(state.job);
          }
          if (state is JobListingError) {
            return Scaffold(
              backgroundColor: _C.back,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: const Color(0xFFE53935), size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(state.message, style: TextStyle(fontSize: 14.sp, color: _C.hintText)),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                        decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(8.r)),
                        child: Text('Back', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        },
      );
    }

    // Use empty model for 'new' preview (from edit page)
    job ??= JobPostModel.empty();
    return _buildPreviewContent(job);
  }

  Widget _buildPreviewContent(JobPostModel job) {
    final isAr = _lang == 'AR';

    double contentWidth;
    switch (_viewMode) {
      case 'Tablet':
        contentWidth = 700.w;
        break;
      case 'Mobile':
        contentWidth = 400.w;
        break;
      default:
        contentWidth = 1000.w;
    }

    return Scaffold(
      backgroundColor: _C.back,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 30.h),
              SizedBox(
                width: 1000.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ────────────────────────────────────
                    Text(
                      'Preview Digital Journy Details',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── View mode tabs + Language toggle ─────────
                    Row(
                      children: [
                        _viewModeTab('Desktop'),
                        SizedBox(width: 16.w),
                        _viewModeTab('Tablet'),
                        SizedBox(width: 16.w),
                        _viewModeTab('Mobile'),
                        const Spacer(),
                        _langToggle('ENG'),
                        SizedBox(width: 4.w),
                        _langToggle('AR'),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ── Preview content card ─────────────────────
                    Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _C.cardBg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: _C.border),
                          ),
                          child: Directionality(
                            textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Accordion header: View ───────
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: Colors.white,
                                        size: 22.sp,
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Accordion body ───────────────
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.w, vertical: 24.h),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Job title
                                      Text(
                                        isAr
                                            ? (job.title.ar.isEmpty
                                            ? 'UI and UX Designer'
                                            : job.title.ar)
                                            : (job.title.en.isEmpty
                                            ? 'UI and UX Designer'
                                            : job.title.en),
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _C.labelText,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Divider(
                                          color: _C.dividerColor,
                                          thickness: 1),
                                      SizedBox(height: 16.h),

                                      // ── Info grid ──────────────
                                      _infoRow(
                                        'Hire Date:',
                                        _formatDate(job.hiringStartDate),
                                        'Hire End Date:',
                                        _formatDate(job.hiringEndDate),
                                      ),
                                      SizedBox(height: 10.h),
                                      _infoRow(
                                        'Work Type:',
                                        job.workType.label,
                                        'Employment Type:',
                                        job.employmentDurationText.isEmpty
                                            ? '3 Weeks'
                                            : job.employmentDurationText,
                                      ),
                                      SizedBox(height: 10.h),
                                      _infoRow(
                                        'Employment Type:',
                                        job.employmentType.label,
                                        'Compensation Range',
                                        '${job.salaryMin.toInt()} - ${job.salaryMax.toInt()}',
                                      ),
                                      SizedBox(height: 10.h),
                                      _infoRow(
                                        'Experience Level:',
                                        job.experienceLevel.label,
                                        '',
                                        '',
                                      ),
                                      SizedBox(height: 10.h),
                                      _singleInfo(
                                        'Required Qualification:',
                                        isAr
                                            ? job.requiredQualification.ar
                                            : job.requiredQualification.en,
                                      ),
                                      SizedBox(height: 16.h),

                                      // ── Skills chips ───────────
                                      if (job.requiredSkills.isNotEmpty) ...[
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Skills:',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: _C.hintText,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Wrap(
                                                spacing: 8.w,
                                                runSpacing: 6.h,
                                                children: job.requiredSkills
                                                    .map((s) => Container(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                    horizontal: 14.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: const Color(
                                                        0xFFF5F5F5),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        6.r),
                                                    border: Border.all(
                                                        color: _C
                                                            .dividerColor),
                                                  ),
                                                  child: Text(
                                                    isAr
                                                        ? s.name.ar
                                                        : s.name.en,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: _C
                                                          .labelText,
                                                    ),
                                                  ),
                                                ))
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 24.h),
                                      ],

                                      // ── About This Position ────
                                      _sectionCard(
                                        title: 'About This Position',
                                        text: isAr
                                            ? job.aboutThisPosition.ar
                                            : job.aboutThisPosition.en,
                                      ),
                                      SizedBox(height: 16.h),

                                      // ── Requirements ───────────
                                      _sectionCard(
                                        title: 'Requirements',
                                        text: isAr
                                            ? job.requirements.ar
                                            : job.requirements.en,
                                      ),
                                      SizedBox(height: 16.h),

                                      // ── Preferred Skills ───────
                                      _sectionCard(
                                        title: 'Preferred Skills',
                                        text: isAr
                                            ? job.preferredSkills.ar
                                            : job.preferredSkills.en,
                                      ),
                                      SizedBox(height: 16.h),

                                      // ── Benefits ───────────────
                                      if (job.benefits.isNotEmpty)
                                        _benefitsCard(job, isAr),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // ── Bottom buttons ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 15.sp,
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
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  VIEW MODE TAB
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _viewModeTab(String mode) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Text(
        mode,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: isActive ? _C.labelText : _C.hintText,
          decoration:
          isActive ? TextDecoration.underline : TextDecoration.none,
          decorationColor: _C.labelText,
          decorationThickness: 2,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  LANGUAGE TOGGLE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _langToggle(String lang) {
    final isActive = _lang == lang;
    return GestureDetector(
      onTap: () => setState(() => _lang = lang),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? _C.primary : _C.cardBg,
          borderRadius: BorderRadius.circular(4.r),
          border:
          Border.all(color: isActive ? _C.primary : _C.dividerColor),
        ),
        child: Text(
          lang,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : _C.hintText,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  INFO ROW (two columns)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _infoRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        if (label1.isNotEmpty)
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label1 ',
                    style: TextStyle(
                        fontSize: 13.sp, color: _C.hintText, height: 1.6),
                  ),
                  TextSpan(
                    text: value1,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _C.primary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (label2.isNotEmpty)
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label2 ',
                    style: TextStyle(
                        fontSize: 13.sp, color: _C.hintText, height: 1.6),
                  ),
                  TextSpan(
                    text: value2,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _C.primary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _singleInfo(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style:
            TextStyle(fontSize: 13.sp, color: _C.hintText, height: 1.6),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _C.primary,
              decoration: TextDecoration.underline,
              decorationColor: _C.primary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SECTION CARD (green-tinted container with title + bullet list)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _sectionCard({required String title, required String text}) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _C.primary,
            ),
          ),
          SizedBox(height: 14.h),
          _bulletList(text),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  BENEFITS CARD
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _benefitsCard(JobPostModel job, bool isAr) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _C.primary,
            ),
          ),
          SizedBox(height: 16.h),
          ...job.benefits.asMap().entries.map((entry) {
            final i = entry.key;
            final b = entry.value;
            final title = isAr ? b.title.ar : b.title.en;
            final desc = isAr ? b.shortDescription.ar : b.shortDescription.en;

            return Column(
              children: [
                if (i > 0) SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Benefit title (left column)
                    SizedBox(
                      width: 200.w,
                      child: Text(
                        title.isEmpty ? 'Benefit' : title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _C.labelText,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),

                    // Benefit description (right column — bold key bullets)
                    Expanded(
                      child: desc.isNotEmpty
                          ? _richBulletList(desc)
                          : Text(
                        '-',
                        style: TextStyle(
                            fontSize: 13.sp, color: _C.hintText),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  BULLET LIST (plain)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _bulletList(String text) {
    final lines =
    text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Container(
                  width: 5.sp,
                  height: 5.sp,
                  decoration: const BoxDecoration(
                    color: _C.labelText,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  line.trim(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _C.labelText,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  RICH BULLET LIST (bold key: description) — for Benefits
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _richBulletList(String text) {
    final lines =
    text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();

        // Check if line has "Key: Value" pattern
        final colonIndex = trimmed.indexOf(':');
        Widget textWidget;

        if (colonIndex > 0 && colonIndex < trimmed.length - 1) {
          final key = trimmed.substring(0, colonIndex + 1);
          final value = trimmed.substring(colonIndex + 1).trim();
          textWidget = RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$key ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.labelText,
                    height: 1.6,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _C.labelText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        } else {
          textWidget = Text(
            trimmed,
            style: TextStyle(
              fontSize: 13.sp,
              color: _C.labelText,
              height: 1.6,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Container(
                  width: 5.sp,
                  height: 5.sp,
                  decoration: const BoxDecoration(
                    color: _C.labelText,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: textWidget),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  DATE FORMATTER
  // ═════════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}