// ******************* FILE INFO *******************
// File Name: job_listing_main_page.dart
// Created by: Amr Mesbah
// Purpose: Job Listing main page — hero + filter tabs + job cards grid
// UPDATED: Uses Firebase via JobListingCubit.loadJobs() — no static data
// UPDATED: Uses AppSearchTextField, customButtonWithImage, SVG assets
// FIXED: BlocListener handles JobListingSaved — pops edit page + reloads list
// FIXED: initState reloads on JobListingSaved state too
// FIXED: Card tap navigates to JobListingEditPage with jobId for editing

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/job_list/job_listing_cubit.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/pages/dashboard/about_company/about_company_main_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';
import 'package:web_app_admin/pages/home_page.dart';

import '../../department/department_main_page.dart';
import 'job_listing_detail_page.dart';
import 'job_listing_edit_page.dart';

// ── SVG asset paths ──────────────────────────────────────────────────────────
class _Svg {
  static const String _base     = 'assets/images/job_list';
  static const String calendar  = '$_base/calender.svg';
  static const String office    = '$_base/office.svg';
  static const String remote    = '$_base/remote.svg';
  static const String yearsExp  = '$_base/years_experince.svg';
  static const String posted    = '$_base/posted.svg';
  static const String endedOn   = '$_base/Ended_on.svg';
  static const String removed   = '$_base/Removed.svg';
  static const String scheduled = '$_base/Scheduled.svg';
  static const String started   = '$_base/Started.svg';
  static const String inactive  = '$_base/Inactive.svg';
}

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color tagGreen  = Color(0xFF008037);
}

class JobListingMainPage extends StatefulWidget {
  const JobListingMainPage({super.key});

  @override
  State<JobListingMainPage> createState() => _JobListingMainPageState();
}

class _JobListingMainPageState extends State<JobListingMainPage> {
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Active', 'Inactive', 'Ended', 'Scheduled', 'Drafted', 'Removed',
  ];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<JobListingCubit>();
    // ── FIX: also reload when returning from a save ──────────────
    if (cubit.state is JobListingInitial || cubit.state is JobListingSaved) {
      cubit.loadJobs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getLogoUrl(BuildContext context) {
    try {
      final homeState = context.read<HomeCmsCubit>().state;
      if (homeState is HomeCmsLoaded) return homeState.data.branding.logoUrl;
      if (homeState is HomeCmsSaved) return homeState.data.branding.logoUrl;
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // ── FIX: BlocListener wraps BlocBuilder to handle post-save navigation ──
    return BlocListener<JobListingCubit, JobListingState>(
      listener: (context, state) {
        // ── After publish/draft save: pop edit page + reload ─────
        if (state is JobListingSaved) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          context.read<JobListingCubit>().loadJobs();
        }
      },
      child: BlocBuilder<JobListingCubit, JobListingState>(
        builder: (context, state) {
          if (state is JobListingInitial || state is JobListingLoading) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          final cubit = context.read<JobListingCubit>();
          List<JobPostModel> jobs = [];
          String activeFilter = 'All';

          if (state is JobListingLoaded) {
            jobs = state.filteredJobs;
            activeFilter = state.activeFilter;
          }

          if (state is JobListingError) {
            if (state.lastJobs != null && state.lastJobs!.isNotEmpty) {
              jobs = state.lastJobs!;
            }
          }

          final logoUrl = _getLogoUrl(context);

          return Scaffold(
            backgroundColor: _C.back,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel:    'Home',
                      homePage:       CareersMainPageDashboard(),
                      webPage:        HomeMainPage(),
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
                            // ── Hero ──────────────────────────────────
                            _buildHeroSection(),
                            SizedBox(height: 20.h),

                            // ── Action buttons row ────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    customButtonWithImage(
                                      title: 'About Company',
                                      function: () {
                                        navigateTo(context, AboutCompanyMainPage());
                                      },
                                      textStyle: StyleText.fontSize12Weight500.copyWith(color: Colors.white),
                                      height: 36.h,
                                      space: 6,
                                      radius: 6,
                                      width: 130.w,
                                      color: _C.primary,
                                      image: 'assets/images/job_list/about.svg',
                                      widthImage: 16.w,
                                      heightImage: 16.h,
                                      colorBorder: _C.primary,
                                      svgColor: Colors.white,
                                    ),
                                    SizedBox(height: 15.h),
                                    customButtonWithImage(
                                      title: 'Departments',
                                      function: () {
                                        navigateTo(context, DepartmentMainPage());
                                      },
                                      textStyle: StyleText.fontSize12Weight500.copyWith(color: Colors.white),
                                      height: 36.h,
                                      width: 120.w,
                                      space: 6,
                                      radius: 6,
                                      color: _C.primary,
                                      image: 'assets/images/job_list/department.svg',
                                      widthImage: 16.w,
                                      heightImage: 16.h,
                                      colorBorder: _C.primary,
                                      svgColor: Colors.white,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                customButtonWithImage(
                                  title: 'Post Job',
                                  function: () => navigateTo(context, const JobListingEditPage()),
                                  textStyle: StyleText.fontSize12Weight500.copyWith(color: Colors.white),
                                  height: 36.h,
                                  space: 6,
                                  radius: 6,
                                  color: _C.primary,
                                  image: 'assets/images/job_list/post_job.svg',
                                  widthImage: 16.w,
                                  heightImage: 16.h,
                                  colorBorder: _C.primary,
                                  svgColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // ── Filter tabs ───────────────────────────
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _filters.map((f) {
                                  final isActive = f == activeFilter;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: GestureDetector(
                                      onTap: () => cubit.setFilter(f),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: isActive ? _C.primary : _C.cardBg,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          f,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: isActive ? Colors.white : _C.labelText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Search + Filter button ────────────────
                            Row(
                              children: [
                                AppSearchTextField(
                                  controller: _searchController,
                                  onChanged: (v) => cubit.setSearch(v),
                                  hintText: 'Search',
                                ),
                                SizedBox(width: 12.w),
                                customButton(
                                  title: 'Filter',
                                  function: () {},
                                  width: 100.w,
                                  height: 36.h,
                                  radius: 6,
                                  color: _C.primary,
                                  textColor: Colors.white,
                                  textStyle: StyleText.fontSize13Weight600.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // ── Error banner ──────────────────────────
                            if (state is JobListingError)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 16.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: const Color(0xFFE53935), size: 18.sp),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        (state as JobListingError).message,
                                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFFE53935)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => cubit.loadJobs(),
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _C.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: _C.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Job cards grid ────────────────────────
                            if (jobs.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.sp),
                                  child: Text(
                                    'No jobs found',
                                    style: TextStyle(fontSize: 14.sp, color: _C.hintText),
                                  ),
                                ),
                              )
                            else
                              _buildJobGrid(jobs, logoUrl),
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

  // ── Hero Section ──────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bayanatz Jobs',
          style: StyleText.fontSize28Weight600.copyWith(
            color: _C.labelText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Job Cards Grid (3 columns) ────────────────────────────────────────────

  Widget _buildJobGrid(List<JobPostModel> jobs, String logoUrl) {
    final rows = (jobs.length / 3).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final start = rowIndex * 3;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          // ── IntrinsicHeight forces all cards in the row to the same height ──
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(3, (colIndex) {
                final i = start + colIndex;
                if (i >= jobs.length) return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < 2 ? 12.w : 0),
                    child: _JobCard(
                      job: jobs[i],
                      logoUrl: logoUrl,
                      onTap: () => navigateTo(
                        context,
                        JobListingDetailPage(jobId: jobs[i].id),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  JOB CARD WIDGET — uses SVG assets
// ═════════════════════════════════════════════════════════════════════════════

class _JobCard extends StatelessWidget {
  final JobPostModel job;
  final String logoUrl;
  final VoidCallback? onTap;

  const _JobCard({required this.job, required this.logoUrl, this.onTap});

  Color get _statusTextColor {
    switch (job.status) {
      case JobStatus.active:    return const Color(0xFF008037);
      case JobStatus.inactive:  return const Color(0xFFFF9800);
      case JobStatus.ended:     return const Color(0xFFD32F2F);
      case JobStatus.scheduled: return const Color(0xFFFF9800);
      case JobStatus.drafted:   return const Color(0xFF757575);
      case JobStatus.removed:   return const Color(0xFFD32F2F);
    }
  }

  Color get _bottomBarColor {
    switch (job.status) {
      case JobStatus.active:    return const Color(0xFF008037);
      case JobStatus.ended:     return const Color(0xFFD32F2F);
      case JobStatus.removed:   return const Color(0xFFD32F2F);
      case JobStatus.scheduled: return const Color(0xFF008037);
      case JobStatus.drafted:   return const Color(0xFF008037);
      case JobStatus.inactive:  return const Color(0xFF008037);
    }
  }

  String get _bottomSvg {
    switch (job.status) {
      case JobStatus.active:    return _Svg.posted;
      case JobStatus.ended:     return _Svg.endedOn;
      case JobStatus.removed:   return _Svg.removed;
      case JobStatus.scheduled: return _Svg.scheduled;
      case JobStatus.drafted:   return _Svg.started;
      case JobStatus.inactive:  return _Svg.inactive;
    }
  }

  String get _bottomText {
    switch (job.status) {
      case JobStatus.active:
        final days = DateTime.now().difference(job.postedDate ?? DateTime.now()).inDays;
        return 'Posted $days Days ago';
      case JobStatus.ended:
        return 'Ended On ${_formatDate(job.endedDate)}';
      case JobStatus.removed:
        return 'Removed Since ${_formatDate(job.endedDate)}';
      case JobStatus.scheduled:
        return 'Scheduled At ${_formatDate(job.postedDate)}';
      case JobStatus.drafted:
        return 'Draft — not published yet';
      case JobStatus.inactive:
        return 'Inactive Since ${_formatDate(job.endedDate)}';
    }
  }

  String get _bottomRightText {
    if (job.totalApplications > 0) return 'Total Application:${job.totalApplications}';
    return '';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _workTypeSvg() {
    switch (job.workType) {
      case WorkType.remote: return _Svg.remote;
      case WorkType.onSite: return _Svg.office;
      case WorkType.hybrid: return _Svg.office;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // ── height: double.infinity lets IntrinsicHeight in the grid drive height ──
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Stack(
          children: [
            // ── Column fills the full card height; Spacer pushes bar to bottom ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Logo + Title ──────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CompanyLogo(logoUrl: logoUrl),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          job.title.en.isEmpty ? 'Untitled' : job.title.en,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // ── Tags with SVG icons ───────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _svgTag(_Svg.calendar, 'Egypt'),
                      _svgTag(_workTypeSvg(), job.workType.label),
                      _svgTag(
                        _Svg.yearsExp,
                        job.employmentDurationText.isNotEmpty
                            ? job.employmentDurationText
                            : job.experienceLevel.label,
                      ),
                      if (job.salaryMax > 0)
                        _svgTag(
                          _Svg.calendar,
                          '${job.salaryMin.toInt()} - ${job.salaryMax.toInt()}',
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Requirements link ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12.sp, color: _C.labelText),
                      children: [
                        const TextSpan(text: 'Requirements.....'),
                        TextSpan(
                          text: 'View',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _C.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: _C.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Spacer pushes bottom bar to the bottom always ─
                const Spacer(),

                // ── Bottom bar with SVG icon ──────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _bottomBarColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        _bottomSvg,
                        width: 18.sp,
                        height: 18.sp,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _bottomText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_bottomRightText.isNotEmpty)
                        Text(
                          _bottomRightText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Status badge (top-right) ──────────────────────────
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: Text(
                    job.status.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _svgTag(String svgAsset, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _C.tagGreen,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 14.sp,
            height: 14.sp,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  COMPANY LOGO — from Firebase via HomeCmsCubit
// ═════════════════════════════════════════════════════════════════════════════

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;
  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final double sz = 30.sp;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: logoUrl.isNotEmpty
            ? SvgPicture.network(
          logoUrl,
          width: sz,
          height: sz,
          fit: BoxFit.scaleDown,
          placeholderBuilder: (_) => _fallbackIcon(sz),
        )
            : _fallbackIcon(sz),
      ),
    );
  }

  Widget _fallbackIcon(double sz) {
    return Container(
      width: sz,
      height: sz,
      color: const Color(0xFFF0F0F0),
      child: Icon(Icons.business_rounded, size: 20.sp, color: const Color(0xFFBBBBBB)),
    );
  }
}