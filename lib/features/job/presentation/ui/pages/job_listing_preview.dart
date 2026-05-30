// ******************* FILE INFO *******************
// File Name: job_listing_preview.dart
// Created by: Amr Mesbah
// Purpose: Preview Job Post Details — Desktop/Tablet/Mobile + ENG/AR toggle
// UPDATED: Firebase-backed — fetches from cubit.allJobs or loads from Firestore
// UPDATED: UI matches Figma — green-tinted sections, bold key bullets, Benefits layout

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../about_us/presentation/ui/pages/about_us_company_edit.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../data/models/job_listing_model.dart';
import '../../controller/job_listing_cubit.dart';
import '../../controller/job_listing_state.dart';
import 'job_listing_main.dart';

part '../widget/job_listing_preview/preview_helper_widgets.dart';
part '../widget/job_listing_preview/job_listing_preview_ui.dart';

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
              backgroundColor: ColorPick.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: const Color(0xFFE53935), size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(state.message, style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText)),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                        decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(8.r)),
                        child: Text('Back', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
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
      backgroundColor: ColorPick.background,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [

              AppAdminNavbar(
                activeLabel:    'Job Listing',
                homePage:       CareersMainPageDashboard(),
                webPage:        const AboutCompanyEditPage(),
                jobListingPage: JobListingMainPage(),
              ),

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
                        color: ColorPick.primary,
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
                        // const Spacer(),
                        // _langToggle('ENG'),
                        // SizedBox(width: 4.w),
                        // _langToggle('AR'),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ── Preview content card ─────────────────────
                    Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorPick.white,
                            borderRadius: BorderRadius.circular(12.r),
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
                                    color: ColorPick.primary,
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
                                          color: AppColors.text,
                                        ),
                                      ),
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
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.secondaryText,
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


                                                  ),
                                                  child: Text(
                                                    isAr
                                                        ? s.name.ar
                                                        : s.name.en,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: AppColors.text,
                                                          
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
                                color: Color(0xFF797979),
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
                                color: ColorPick.primary,
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

}