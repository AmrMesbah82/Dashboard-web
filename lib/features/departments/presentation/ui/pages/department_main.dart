// ═══════════════════════════════════════════════════════════════════
// FILE 6: department_main.dart (View Page)
// Path: lib/pages/dashboard/department/department_main.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/navigator.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../job/data/models/job_listing_model.dart';
import '../../../../job/presentation/controller/job_listing_cubit.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/department_model.dart';
import '../../controller/department_cubit.dart';
import '../../controller/department_state.dart';
import 'department_create.dart';
import 'department_detail.dart';   // ← NEW

part '../widget/department_main/department_card.dart';

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
// }

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
    final jobCubit = context.read<JobListingCubit>();
    if (jobCubit.allJobs.isEmpty) jobCubit.loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DepartmentCubit, DepartmentState>(
      listener: (context, state) {
        if (state is DepartmentCreated ||
            state is DepartmentUpdated ||
            state is DepartmentDeleted) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          context.read<DepartmentCubit>().loadDepartments();
        }
      },
      child: BlocBuilder<DepartmentCubit, DepartmentState>(
        builder: (context, state) {
          if (state is DepartmentInitial || state is DepartmentLoading) {
            return const Scaffold(
              backgroundColor: ColorPick.background,
              body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
            );
          }

          List<DepartmentModel> departments = [];
          if (state is DepartmentLoaded) departments = state.departments;
          if (state is DepartmentError && state.lastDepartments != null) {
            departments = state.lastDepartments!;
          }

          final allJobs = context.read<JobListingCubit>().allJobs;

          return Scaffold(
            backgroundColor: ColorPick.background,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Departments',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color:      ColorPick.primary,
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
                                    color:        ColorPick.primary,
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
                                  child: CustomSvg(
                                    assetPath: '',
                                    width:  150.w,
                                    height: 150.h,
                                    fit:    BoxFit.fill,
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
  Widget _buildGrid(
      List<DepartmentModel> depts, List<JobPostModel> allJobs) {
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
                if (i >= depts.length) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  child: Padding(
                    padding:
                    EdgeInsets.only(right: colIndex < 2 ? 12.w : 0),
                    child: _DepartmentCard(
                      department: depts[i],
                      allJobs:    allJobs,
                      // ── tap → detail page ──
                      onTap: () => navigateTo(
                        context,
                        DepartmentDetailPage(department: depts[i]),
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
//  DEPARTMENT CARD
// ═════════════════════════════════════════════════════════════════════════════
