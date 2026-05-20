// ═══════════════════════════════════════════════════════════════════
// department_detail.dart  (Detail / View Page)
// Path: lib/pages/dashboard/department/department_detail.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/navigator.dart';


import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../job/data/model/job_listing_model.dart';
import '../../../../job/presentation/controller/job_listing_cubit.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/model/department_model.dart';
import 'department_edit.dart';
//
// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
// }

class DepartmentDetailPage extends StatelessWidget {
  final DepartmentModel department;

  const DepartmentDetailPage({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final allJobs = context.read<JobListingCubit>().allJobs;

    final deptJobs = allJobs
        .where((j) =>
    j.department.toLowerCase() == department.nameEn.toLowerCase())
        .toList();

    final totalCount    = deptJobs.length;
    final activeCount   = deptJobs.where((j) => j.status == JobStatus.active).length;
    final inactiveCount = deptJobs.where((j) => j.status == JobStatus.inactive).length;

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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──
                      Text(
                        'Department Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: ColorPick.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Edit button ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => navigateTo(
                            context,
                            DepartmentEditPage(department: department),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),

                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Text(
                                  'Edit Department Info',
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(color: ColorPick.primary),
                                ),

                                SizedBox(width: 6.w),
                                CustomSvg(assetPath: "assets/edit.svg",width: 16.w,height: 16.h,fit: BoxFit.scaleDown,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Accordion card ──
                      _accordion(
                        title: 'Department Information',
                        child: _detailContent(context, department,
                            totalCount, activeCount, inactiveCount),
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
  }

  Widget _accordion({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(6.r),
                topRight: Radius.circular(6.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white)),
                ),
                Icon(Icons.keyboard_arrow_up_rounded,
                    color: Colors.white, size: 20.sp),
              ],
            ),
          ),
          // body
          Container(
            width: double.infinity,
            decoration: BoxDecoration(

              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(6.r),
                bottomRight: Radius.circular(6.r),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _detailContent(
      BuildContext context,
      DepartmentModel dept,
      int total,
      int active,
      int inactive,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        // ── Company logo / icon ──
        BlocBuilder<HomeCmsCubit, HomeCmsState>(
          builder: (context, state) {
            final String logoUrl = switch (state) {
              HomeCmsLoaded(:final data) => data.branding.logoUrl,
              HomeCmsSaved(:final data)  => data.branding.logoUrl,
              _                          => '',
            };
            return Container(
              width: 70.w,
              height: 70.h,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(70.w * 0.20), // 20% padding = 60% content
                  child: logoUrl.isNotEmpty
                      ? SvgPicture.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => Icon(
                      Icons.business_rounded,
                      size: 70.sp * 0.6,
                      color: ColorPick.primary,
                    ),
                  )
                      : Icon(
                    Icons.business_rounded,
                    size: 70.sp * 0.6,
                    color: ColorPick.primary,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20.h),

        // ── Names row ──
        Row(
          children: [
            Expanded(child: _readField('Department Name', dept.nameEn)),
            SizedBox(width: 15.w),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _readField('اسم القسم', dept.nameAr),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _readField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text)),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color:  Colors.white,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, int count, String svgPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            CustomSvg(
                assetPath: svgPath,
                width: 16.sp,
                height: 16.sp,
                fit: BoxFit.contain),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text)),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}