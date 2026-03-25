// ═══════════════════════════════════════════════════════════════════
// FILE 6: department_main_page.dart (View Page)
// Path: lib/pages/dashboard/department/department_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/department/department_cubit.dart';
import 'package:web_app_admin/controller/department/department_state.dart';
import 'package:web_app_admin/controller/job_list/job_listing_cubit.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/department_model.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

import '../dashboard/job_list/job_listing_main_page.dart';
import '../dashboard/main_page/home_main_page.dart';

import 'department_create_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
}

class DepartmentMainPage extends StatefulWidget {
  const DepartmentMainPage({super.key});

  @override
  State<DepartmentMainPage> createState() => _DepartmentMainPageState();
}

class _DepartmentMainPageState extends State<DepartmentMainPage> {
  @override
  void initState() {
    super.initState();
    context.read<DepartmentCubit>().loadDepartments();
    // Make sure jobs are loaded so we can compute counts
    final jobCubit = context.read<JobListingCubit>();
    if (jobCubit.allJobs.isEmpty) {
      jobCubit.loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DepartmentCubit, DepartmentState>(
      listener: (context, state) {
        if (state is DepartmentCreated) {
          // Refresh after coming back from create page
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          context.read<DepartmentCubit>().loadDepartments();
        }
      },
      child: BlocBuilder<DepartmentCubit, DepartmentState>(
        builder: (context, state) {
          if (state is DepartmentInitial || state is DepartmentLoading) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          List<DepartmentModel> departments = [];
          if (state is DepartmentLoaded) departments = state.departments;
          if (state is DepartmentError && state.lastDepartments != null) {
            departments = state.lastDepartments!;
          }

          // Get all jobs to compute counts
          final allJobs = context.read<JobListingCubit>().allJobs;

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
                            // ── Title ──
                            Text(
                              'Our Departments',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Create Department button ──
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => navigateTo(
                                    context, const DepartmentCreatePage()),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.settings_outlined,
                                          size: 16.sp, color: Colors.white),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Departments',
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // ── Department Grid ──
                            if (departments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.sp),
                                  child: Text(
                                    'No departments yet',
                                    style: TextStyle(
                                        fontSize: 14.sp, color: _C.hintText),
                                  ),
                                ),
                              )
                            else
                              _buildGrid(departments, allJobs),

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

  // ── Grid (3 columns) ──────────────────────────────────────────────────────
  Widget _buildGrid(List<DepartmentModel> depts, List<JobPostModel> allJobs) {
    final rows = (depts.length / 3).ceil();
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
                if (i >= depts.length) return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < 2 ? 12.w : 0),
                    child: _DepartmentCard(
                      department: depts[i],
                      allJobs: allJobs,
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
//  DEPARTMENT CARD
// ═════════════════════════════════════════════════════════════════════════════

class _DepartmentCard extends StatelessWidget {
  final DepartmentModel department;
  final List<JobPostModel> allJobs;

  const _DepartmentCard({
    required this.department,
    required this.allJobs,
  });

  @override
  Widget build(BuildContext context) {
    // Compute job counts for this department
    final deptJobs = allJobs
        .where((j) =>
    j.department.toLowerCase() == department.nameEn.toLowerCase())
        .toList();

    final totalCount = deptJobs.length;
    final activeCount =
        deptJobs.where((j) => j.status == JobStatus.active).length;
    final inactiveCount =
        deptJobs.where((j) => j.status == JobStatus.inactive).length;

    final createdText = department.createdAt != null
        ? 'Created At: ${department.createdAt!.day} ${_monthName(department.createdAt!.month)} ${department.createdAt!.year}'
        : 'Created At: —';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                // ── Department icon ──
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.business_rounded,
                      size: 18.sp, color: _C.primary),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    department.nameEn.isEmpty
                        ? 'Department Name'
                        : department.nameEn,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.labelText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── Stats ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow('Total Job Post:', totalCount),
                SizedBox(height: 6.h),
                _statRow('Active Job:', activeCount),
                SizedBox(height: 6.h),
                _statRow('Inactive Job:', inactiveCount),
              ],
            ),
          ),

          const Spacer(),

          // ── Bottom bar ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
            ),
            child: Text(
              createdText,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, int count) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6.sp, color: _C.primary),
        SizedBox(width: 8.w),
        Text(
          '$label ',
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: _C.labelText),
        ),
        Text(
          '$count',
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _C.labelText),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}