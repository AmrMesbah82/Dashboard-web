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
import '../../controller/department_cubit.dart';
import '../../controller/department_state.dart';
import 'department_create.dart';
import 'department_detail.dart';   // ← NEW

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
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          List<DepartmentModel> departments = [];
          if (state is DepartmentLoaded) departments = state.departments;
          if (state is DepartmentError && state.lastDepartments != null) {
            departments = state.lastDepartments!;
          }

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
                                color:      _C.primary,
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
                                    color:        _C.primary,
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

class _DepartmentCard extends StatefulWidget {
  final DepartmentModel    department;
  final List<JobPostModel> allJobs;
  final VoidCallback       onTap;

  const _DepartmentCard({
    required this.department,
    required this.allJobs,
    required this.onTap,
  });

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final deptJobs = widget.allJobs
        .where((j) =>
    j.department.toLowerCase() ==
        widget.department.nameEn.toLowerCase())
        .toList();

    final totalCount    = deptJobs.length;
    final activeCount   =
        deptJobs.where((j) => j.status == JobStatus.active).length;
    final inactiveCount =
        deptJobs.where((j) => j.status == JobStatus.inactive).length;

    final createdText = widget.department.createdAt != null
        ? 'Created At: ${widget.department.createdAt!.day} '
        '${_monthName(widget.department.createdAt!.month)} '
        '${widget.department.createdAt!.year}'
        : 'Created At: —';

    return MouseRegion(
      cursor:   SystemMouseCursors.click,
      onEnter:  (_) => setState(() => _hovered = true),
      onExit:   (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color:      _C.primary.withOpacity(0.15),
                blurRadius: 12,
                offset:     const Offset(0, 4),
              )
            ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: Row(
                  children: [
                    // ── Company logo ──
                    BlocBuilder<HomeCmsCubit, HomeCmsState>(
                      builder: (context, state) {
                        final String logoUrl = switch (state) {
                          HomeCmsLoaded(:final data) => data.branding.logoUrl,
                          HomeCmsSaved(:final data)  => data.branding.logoUrl,
                          _                          => '',
                        };
                        return Container(
                          width:  30.sp,
                          height: 30.sp,
                          decoration: BoxDecoration(
                            color:        const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: logoUrl.isNotEmpty
                                ? SvgPicture.network(
                              logoUrl,
                              width:  30.sp,
                              height: 30.sp,
                              fit:    BoxFit.fill,
                              placeholderBuilder: (_) => Icon(
                                Icons.business_rounded,
                                size:  18.sp,
                                color: _C.primary,
                              ),
                            )
                                : Icon(Icons.business_rounded,
                                size:  18.sp, color: _C.primary),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.department.nameEn.isEmpty
                            ? 'Department Name'
                            : widget.department.nameEn,
                        style: TextStyle(
                          fontSize:   15.sp,
                          fontWeight: FontWeight.w700,
                          color:      _C.labelText,
                        ),
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                      ),
                    ),
                    // ── Arrow indicator ──
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12.sp, color: _C.hintText),
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
                    _statRow('Total Job Post:', totalCount,
                        'assets/images/job_list/totoal_job.svg'),
                    SizedBox(height: 6.h),
                    _statRow('Active Job:', activeCount,
                        'assets/images/job_list/active_job.svg'),
                    SizedBox(height: 6.h),
                    _statRow('Inactive Job:', inactiveCount,
                        'assets/images/job_list/inactive_job.svg'),
                  ],
                ),
              ),

              const Spacer(),

              // ── Bottom bar ──
              Container(
                width:   double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                  ),
                ),
                child: Text(
                  createdText,
                  style: TextStyle(
                    fontSize:   12.sp,
                    color:      Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, int count, String svgPath) {
    return Row(
      children: [
        CustomSvg(
            assetPath: svgPath,
            width:     14.sp,
            height:    14.sp,
            fit:       BoxFit.contain),
        SizedBox(width: 8.w),
        Text('$label ',
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.text)),
        Text('$count',
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.secondaryText)),
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