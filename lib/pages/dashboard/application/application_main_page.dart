// ═══════════════════════════════════════════════════════════════════
// FILE 6: application_main_page.dart (View Page)
// Path: lib/pages/dashboard/application/application_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/application/application_cubit.dart';
import 'package:web_app_admin/controller/application/application_state.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/job_list/job_listing_main_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';
import 'package:web_app_admin/widgets/application_filter_dialog.dart';

import 'application_detail_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
}

class ApplicationMainPage extends StatefulWidget {
  const ApplicationMainPage({super.key});

  @override
  State<ApplicationMainPage> createState() => _ApplicationMainPageState();
}

class _ApplicationMainPageState extends State<ApplicationMainPage> {
  final _searchController = TextEditingController();
  bool _isGridView = true;
  ApplicationFilterData? _activeFilter;

  @override
  void initState() {
    super.initState();
    context.read<ApplicationCubit>().loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationUpdated) {
          context.read<ApplicationCubit>().loadApplications();
        }
      },
      child: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationInitial || state is ApplicationLoading) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          final cubit = context.read<ApplicationCubit>();
          List<ApplicationModel> apps = [];
          String activeDept = 'All';
          Map<String, int> deptCounts = {};
          int totalCount = 0;
          int appliedQualified = 0, appliedUnqualified = 0;
          int interviewPassed = 0, interviewWithdrew = 0, interviewFailed = 0;
          int offerApproved = 0, offerPending = 0, offerRejected = 0;
          int hiredCompleted = 0;

          if (state is ApplicationLoaded) {
            apps = state.filteredApps;
            activeDept = state.activeDeptFilter;
            deptCounts = state.departmentCounts;
            totalCount = state.totalCount;
            appliedQualified = state.appliedQualified;
            appliedUnqualified = state.appliedUnqualified;
            interviewPassed = state.interviewPassed;
            interviewWithdrew = state.interviewWithdrew;
            interviewFailed = state.interviewFailed;
            offerApproved = state.offerApproved;
            offerPending = state.offerPending;
            offerRejected = state.offerRejected;
            hiredCompleted = state.hiredCompleted;
          }

          if (state is ApplicationError && state.lastApps != null) {
            apps = state.lastApps!;
          }

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
                              'Applications',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Department filter tabs ──
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterTab('All', apps.length, activeDept == 'All', () => cubit.setDeptFilter('All')),
                                  ...deptCounts.entries.map((e) =>
                                      _filterTab(e.key, e.value, activeDept == e.key, () => cubit.setDeptFilter(e.key))),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Search + buttons row ──
                            Row(
                              children: [
                                AppSearchTextField(
                                  controller: _searchController,
                                  onChanged: (v) => cubit.setSearch(v),
                                  hintText: 'Search',
                                ),
                                SizedBox(width: 12.w),
                                customButton(
                                  title: 'Time Frame',
                                  function: () {},
                                  width: 110.w,
                                  height: 36.h,
                                  radius: 6,
                                  color: _C.primary,
                                  textColor: Colors.white,
                                  textStyle: StyleText.fontSize13Weight600.copyWith(color: Colors.white),
                                ),
                                SizedBox(width: 8.w),
                                customButton(
                                  title: 'Filter',
                                  function: () async {
                                    final result = await showApplicationFilterDialog(
                                      context,
                                      initial: _activeFilter,
                                    );
                                    if (result != null) {
                                      setState(() => _activeFilter = result);
                                      cubit.setFilter(result);   // 👇 add this method to cubit (Step 3)
                                    }
                                  },
                                  width: 100.w,
                                  height: 36.h,
                                  radius: 6,
                                  color: _activeFilter != null && !_activeFilter!.isEmpty
                                      ? _C.primary.withOpacity(0.85)   // tinted when filter is active
                                      : _C.primary,
                                  textColor: Colors.white,
                                  textStyle: StyleText.fontSize13Weight600.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            // ── Total + Export + Grid/List toggle ──
                            // ── Total + Export + Grid/List toggle ──
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: _C.cardBg,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Total Application:  $totalCount',
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText),
                                  ),
                                ),
                                const Spacer(),

                                // ── Export button ──
                                customButtonWithImage(
                                  title: 'Export',
                                  function: () {},
                                  textStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  height: 32.h,
                                  space: 4.w,
                                  radius: 6,
                                  color: _C.primary,
                                  image: 'assets/images/export.svg',
                                  widthImage: 14.sp,
                                  heightImage: 14.sp,
                                  colorBorder: _C.primary,
                                  svgColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                ),
                                SizedBox(width: 8.w),

                                // ── Grid toggle ──
                                customButtonWithImage(
                                  title: '',
                                  function: () => setState(() => _isGridView = true),
                                  textStyle: const TextStyle(),
                                  height: 32.sp,
                                  width: 32.sp,
                                  space: 0,
                                  radius: 6,
                                  color: _isGridView ? _C.primary : _C.cardBg,
                                  image: 'assets/images/grid.svg',
                                  widthImage: 16.sp,
                                  heightImage: 16.sp,
                                  colorBorder: Colors.transparent,
                                  svgColor: _isGridView ? Colors.white : _C.hintText,
                                ),
                                SizedBox(width: 4.w),

                                // ── List toggle ──
                                customButtonWithImage(
                                  title: '',
                                  function: () => setState(() => _isGridView = false),
                                  textStyle: const TextStyle(),
                                  height: 32.sp,
                                  width: 32.sp,
                                  space: 0,
                                  radius: 6,
                                  color: !_isGridView ? _C.primary : _C.cardBg,
                                  image: 'assets/images/table.svg',
                                  widthImage: 16.sp,
                                  heightImage: 16.sp,
                                  colorBorder: Colors.transparent,
                                  svgColor: !_isGridView ? Colors.white : _C.hintText,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Summary cards ──
                            Row(
                              children: [
                                Expanded(child: _summaryCard('Applied', 'Qualified: $appliedQualified  Unqualified: $appliedUnqualified')),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard('Interview', 'Passed: $interviewPassed  Withdrew: $interviewWithdrew  Failed: $interviewFailed')),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard('Offer', 'Approved: $offerApproved  Pending: $offerPending  Rejected: $offerRejected')),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard('Hired', 'Completed: $hiredCompleted')),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // ── Content ──
                            if (apps.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.sp),
                                  child: Text('No applications found', style: TextStyle(fontSize: 14.sp, color: _C.hintText)),
                                ),
                              )
                            else
                              _isGridView ? _buildGrid(apps) : _buildTable(apps),

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

  // ── Filter Tab ─────────────────────────────────────────────────────────────
  Widget _filterTab(String label, int count, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? _C.primary : _C.cardBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != 'All') ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.3) : _C.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('$count', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.white)),
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: isActive ? Colors.white : _C.labelText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────
  Widget _summaryCard(String title, String details) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
          SizedBox(height: 4.h),
          Text(details, style: TextStyle(fontSize: 10.sp, color: _C.hintText)),
        ],
      ),
    );
  }

  // ── Card Grid (3 columns) ─────────────────────────────────────────────────
  Widget _buildGrid(List<ApplicationModel> apps) {
    final rows = (apps.length / 3).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final start = rowIndex * 3;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(3, (colIndex) {
                final i = start + colIndex;
                if (i >= apps.length) return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < 2 ? 12.w : 0),
                    child: _AppCard(
                      app: apps[i],
                      onTap: () => navigateTo(context, ApplicationDetailPage(jobId: apps[i].jobId, appId: apps[i].id)),
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

  // ── Table View ─────────────────────────────────────────────────────────────
// ── Table View ─────────────────────────────────────────────────────────────
  Widget _buildTable(List<ApplicationModel> apps) {
    final headers = [
      'No', 'Candidate', 'Email', 'Phone', 'Department',
      'Job Title', 'Work Type', 'Location', 'Employment Type',
      'Experience Level', 'Salary Range', 'Application Date', 'Status',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0:  FixedColumnWidth(50.sp),
      1:  FixedColumnWidth(140.sp),
      2:  FixedColumnWidth(180.sp),
      3:  FixedColumnWidth(120.sp),
      4:  FixedColumnWidth(120.sp),
      5:  FixedColumnWidth(150.sp),
      6:  FixedColumnWidth(100.sp),
      7:  FixedColumnWidth(120.sp),
      8:  FixedColumnWidth(130.sp),
      9:  FixedColumnWidth(120.sp),
      10: FixedColumnWidth(120.sp),
      11: FixedColumnWidth(110.sp),
      12: FixedColumnWidth(110.sp),
    };

    TextStyle cellStyle = TextStyle(
      fontSize: 11.sp,
      color: _C.labelText,
    );

    Widget cell(Widget child) => Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: cellStyle, child: child),
    );

    Widget textCell(String text) => cell(
      Text(
        text.isEmpty ? '-' : text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    Color statusColor(ApplicationStatus status) {
      switch (status) {
        case ApplicationStatus.hired:
          return Colors.green.shade600;
        case ApplicationStatus.unqualified:
        case ApplicationStatus.interviewFailed:
        case ApplicationStatus.offerRejected:
          return Colors.red.shade600;
        case ApplicationStatus.interviewPassed:
        case ApplicationStatus.interviewWithdrew:
          return Colors.blue.shade600;
        case ApplicationStatus.offerApproved:
        case ApplicationStatus.offerPending:
          return Colors.orange.shade600;
        case ApplicationStatus.qualified:
          return Colors.teal.shade600;
        case ApplicationStatus.applied:
        default:
          return _C.primary;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [

            // ── Header Row ──
            TableRow(
              decoration: const BoxDecoration(color: _C.primary),
              children: headers.map((h) => Padding(
                padding: EdgeInsets.all(10.sp),
                child: Text(
                  h,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )).toList(),
            ),

            // ── Data Rows ──
            ...List.generate(apps.length, (index) {
              final a = apps[index];
              final isEven = index.isEven;
              final rowColor = isEven ? const Color(0xFFF7F8FA) : Colors.white;

              final dateStr = a.applicationDate != null
                  ? '${a.applicationDate!.day}/${a.applicationDate!.month}/${a.applicationDate!.year}'
                  : '-';

              final cells = [
                textCell('${index + 1}'),
                textCell(a.fullName),
                textCell(a.email),
                textCell('${a.countryCode}${a.phone}'),
                textCell(a.department),
                textCell(a.jobTitle),
                textCell(a.workType),
                textCell(a.jobLocation),
                textCell(a.employmentType),
                textCell(a.experienceLevel),
                textCell(a.salaryRange),
                textCell(dateStr),

                // ── Status cell (colored) ──
                cell(
                  Text(
                    a.status.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor(a.status),
                    ),
                  ),
                ),
              ];

              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells.map((c) => InkWell(
                  onTap: () => navigateTo(context, ApplicationDetailPage(jobId: a.jobId, appId: a.id)),
                  child: c,
                )).toList(),
              );
            }),

          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  APPLICATION CARD
// ═════════════════════════════════════════════════════════════════════════════

class _AppCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback? onTap;
  const _AppCard({required this.app, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = app.applicationDate != null
        ? '${app.applicationDate!.day} ${_month(app.applicationDate!.month)} ${app.applicationDate!.year}'
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tags row ──
            Row(
              children: [
                if (app.tag.isNotEmpty) _tag(app.tag, _C.primary),
                SizedBox(width: 6.w),
                _tag(app.status.label, _C.primary),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('Download Files', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Department ──
            Row(
              children: [
                Icon(Icons.business_rounded, size: 18.sp, color: _C.primary),
                SizedBox(width: 6.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.department.isEmpty ? 'Department' : app.department,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
                    Text('Department', style: TextStyle(fontSize: 10.sp, color: _C.hintText)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Info rows ──
            _infoRow('Candidate:', app.fullName),
            SizedBox(height: 4.h),
            _infoRow('Email:', app.email),
            SizedBox(height: 4.h),
            _infoRow('Phone Number:', '${app.countryCode}${app.phone}'),
            SizedBox(height: 4.h),
            _infoRow('Application Date:', dateStr),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _C.primary)),
        SizedBox(width: 4.w),
        Expanded(child: Text(value, style: TextStyle(fontSize: 11.sp, color: _C.labelText), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}