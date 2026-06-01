// ******************* FILE INFO *******************
// File Name: job_listing_main.dart
// Created by: Amr Mesbah
// Purpose: Job Listing main page — hero + filter tabs + job cards grid
// UPDATED: Uses Firebase via JobListingCubit.loadJobs() — no static data
// UPDATED: Uses AppSearchTextField, customButtonWithImage, SVG assets
// FIXED: BlocListener handles JobListingSaved — pops edit page + reloads list
// FIXED: initState reloads on JobListingSaved state too
// FIXED: Card tap navigates to JobListingDetailPage with jobId
// FIXED: Filter button opens showJobListingFilterDialog + applies result

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/main_widgets/job_listing_filter_dialog.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../about_us/presentation/ui/pages/about_us_company_main.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../departments/presentation/ui/pages/department_main.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/job_listing_model.dart';
import '../../controller/job_listing_cubit.dart';
import '../../controller/job_listing_state.dart';
import 'job_listing_detail.dart';
import 'job_listing_edit.dart';

part '../widgets/job_listing_main/svg.dart';
part '../widgets/job_listing_main/job_card.dart';
part '../widgets/job_listing_main/company_logo.dart';

// ── SVG asset paths ──────────────────────────────────────────────────────────

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

  // ── Track advanced filter state ────────────────────────────────────────────
  JobListingFilterData? _advancedFilter;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<JobListingCubit>();
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

  // ── Open filter dialog ─────────────────────────────────────────────────────
  Future<void> _openFilterDialog() async {
    final result = await showJobListingFilterDialog(
      context,
      initial: _advancedFilter,
    );
    if (result != null) {
      setState(() => _advancedFilter = result);
      context.read<JobListingCubit>().applyAdvancedFilter(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobListingCubit, JobListingState>(
      listener: (context, state) {
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
              backgroundColor: ColorPick.background,
              body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
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
            backgroundColor: ColorPick.background,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel:    'Job Listing',
                      homePage:       CareersMainPageDashboard(),
                      webPage:        MainMainPage(),
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
                                      color: ColorPick.primary,
                                      image: 'assets/images/job_list/about.svg',
                                      widthImage: 16.w,
                                      heightImage: 16.h,
                                      colorBorder: ColorPick.primary,
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
                                      color: ColorPick.primary,
                                      image: 'assets/images/job_list/department.svg',
                                      widthImage: 16.w,
                                      heightImage: 16.h,
                                      colorBorder: ColorPick.primary,
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
                                  color: ColorPick.primary,
                                  image: 'assets/images/job_list/post_job.svg',
                                  widthImage: 16.w,
                                  heightImage: 16.h,
                                  colorBorder: ColorPick.primary,
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
                                          color: isActive ? ColorPick.primary : ColorPick.white,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          f,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: isActive ? Colors.white : AppColors.text,
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
                                // ── FIXED: Filter button now opens the dialog ──
                                customButton(
                                  title: 'Filter',
                                  function: _openFilterDialog,
                                  width: 100.w,
                                  height: 36.h,
                                  radius: 6,
                                  color: ColorPick.primary,
                                  textColor: Colors.white,
                                  textStyle: StyleText.fontSize13Weight600.copyWith(color: Colors.white),
                                ),
                              ],
                            ),

                            // ── Active advanced-filter chips ──────────
                            if (_advancedFilter != null && !_advancedFilter!.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 12.h),
                                child: _buildActiveFilterChips(),
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
                                  border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
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
                                          color: ColorPick.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: ColorPick.primary,
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
                                  child: CustomSvg(assetPath: "",width: 150.w,height: 150.h,fit: BoxFit.fill,)
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

  // ── Active filter chips (shows what's applied + clear all) ────────────────

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];
    final f = _advancedFilter!;

    if (f.department != null) {
      chips.add(_filterChip('Dept: ${f.department!}', () {
        setState(() => _advancedFilter = JobListingFilterData(
          location: f.location,
          employmentType: f.employmentType,
          yearsOfExperience: f.yearsOfExperience,
          date: f.date,
        ));
        context.read<JobListingCubit>().applyAdvancedFilter(_advancedFilter!);
      }));
    }
    if (f.location != null) {
      chips.add(_filterChip('Loc: ${f.location!}', () {
        setState(() => _advancedFilter = JobListingFilterData(
          department: f.department,
          employmentType: f.employmentType,
          yearsOfExperience: f.yearsOfExperience,
          date: f.date,
        ));
        context.read<JobListingCubit>().applyAdvancedFilter(_advancedFilter!);
      }));
    }
    if (f.employmentType != null) {
      chips.add(_filterChip('Type: ${f.employmentType!}', () {
        setState(() => _advancedFilter = JobListingFilterData(
          department: f.department,
          location: f.location,
          yearsOfExperience: f.yearsOfExperience,
          date: f.date,
        ));
        context.read<JobListingCubit>().applyAdvancedFilter(_advancedFilter!);
      }));
    }
    if (f.yearsOfExperience != null) {
      chips.add(_filterChip('Exp: ${f.yearsOfExperience!}', () {
        setState(() => _advancedFilter = JobListingFilterData(
          department: f.department,
          location: f.location,
          employmentType: f.employmentType,
          date: f.date,
        ));
        context.read<JobListingCubit>().applyAdvancedFilter(_advancedFilter!);
      }));
    }
    if (f.date != null) {
      final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      chips.add(_filterChip('Date: ${f.date!.day} ${m[f.date!.month - 1]} ${f.date!.year}', () {
        setState(() => _advancedFilter = JobListingFilterData(
          department: f.department,
          location: f.location,
          employmentType: f.employmentType,
          yearsOfExperience: f.yearsOfExperience,
        ));
        context.read<JobListingCubit>().applyAdvancedFilter(_advancedFilter!);
      }));
    }

    // Clear All chip
    chips.add(
      GestureDetector(
        onTap: () {
          setState(() => _advancedFilter = null);
          context.read<JobListingCubit>().clearAdvancedFilter();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            'Clear All',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ),
      ),
    );

    return Wrap(spacing: 8.w, runSpacing: 6.h, children: chips);
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorPick.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: ColorPick.primary,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.sp, color: ColorPick.primary),
          ),
        ],
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
            color: AppColors.text,
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
