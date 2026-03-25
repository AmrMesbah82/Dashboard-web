// ******************* FILE INFO *******************
// File Name: careers_main_page.dart
// Created by: Amr Mesbah
// Purpose: Careers CMS main page — Hero + Dashboard (10 charts, 2 per row)
// Pattern: Same as home_main_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';

import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/pages/home_page.dart';

import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';
import 'package:web_app_admin/widgets/careers_stat_card.dart';
import 'package:web_app_admin/widgets/funnel_chart_widget.dart';
import 'package:web_app_admin/widgets/segmented_score_bar_widget.dart';

import 'dashboard/job_list/job_listing_main_page.dart';
import 'dashboard/main_page/home_main_page.dart';

// ── Local design tokens ──────────────────────────────────────────────────────

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

// ── Chart color palette ──────────────────────────────────────────────────────

class _ChartColors {
  static const Color green       = Color(0xFF008037);
  static const Color darkGreen   = Color(0xFF1B5E20);
  static const Color orange      = Color(0xFFFF9800);
  static const Color red         = Color(0xFFD32F2F);
  static const Color lightRed    = Color(0xFFF44336);
  static const Color yellow      = Color(0xFFFFD452);
  static const Color grey        = Color(0xFFACACAC);
  static const Color teal        = Color(0xFF00897B);
  static const Color pink        = Color(0xFFE91E63);
  static const Color scheduled   = Color(0xFFFFB300);
  static const Color draft       = Color(0xFF757575);
  static const Color active      = Color(0xFF2E7D32);
  static const Color closed      = Color(0xFFD32F2F);
}

// ═════════════════════════════════════════════════════════════════════════════
//  CAREERS MAIN PAGE
// ═════════════════════════════════════════════════════════════════════════════

class CareersMainPageDashboard extends StatefulWidget {
  const CareersMainPageDashboard({super.key});

  @override
  State<CareersMainPageDashboard> createState() => _CareersMainPageDashboardState();
}

class _CareersMainPageDashboardState extends State<CareersMainPageDashboard> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CareersCmsCubit>();
    if (cubit.state is CareersCmsInitial) {
      cubit.loadRealData(); // ← was loadDemo()
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersCmsCubit, CareersCmsState>(
      builder: (context, state) {
        if (state is CareersCmsInitial || state is CareersCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        CareersCmsModel? data;
        if (state is CareersCmsLoaded) data = state.data;
        if (state is CareersCmsSaved) data = state.data;

        if (data == null) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final dash = data.dashboard;

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

                  // ── Content ─────────────────────────────────────
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 20.h),
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Hero Section ─────────────────────────

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomSvg(assetPath: "assets/images/dashboard_image.svg",width: 300.w,height: 300.h,fit: BoxFit.fill,),
                            ],
                          ),

                          // ── Dashboard Title ─────────────────────
                          Center(
                            child: Text(
                              'Dashboard',
                              style:
                              StyleText.fontSize18Weight500.copyWith(
                                color: _C.labelText,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // ── Stat Cards Row ──────────────────────
                          CareersStatCardsRow(
                            cards: dash.statCards
                                .map((c) => CareersStatCardData(
                              label: c.label,
                              value: c.value,
                              iconAsset: c.iconAsset,
                            ))
                                .toList(),
                          ),
                          SizedBox(height: 20.h),

                          // ══════════════════════════════════════════
                          //  DASHBOARD CHARTS — 2 per row
                          // ══════════════════════════════════════════

                          // Row 1: Applications Received | Job Posting Status
                          _chartRow(
                            left: _buildApplicationsReceivedChart(dash),
                            right: _buildJobPostingStatusChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 2: Hiring Stage (Funnel) | Job Status (Pie)
                          _chartRow(
                            left: _buildHiringStageChart(dash),
                            right: _buildJobStatusChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 3: Candidate Quality | Jobs Performance
                          _chartRow(
                            left: _buildCandidateQualityChart(dash),
                            right: _buildJobsPerformanceChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 4: Job Offer | Candidate Score Distribution
                          _chartRow(
                            left: _buildJobOfferChart(dash),
                            right: _buildScoreDistributionChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 5: Employment Types | Candidate Gender
                          _chartRow(
                            left: _buildEmploymentTypesChart(dash),
                            right: _buildCandidateGenderChart(dash),
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
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  HERO SECTION
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(CareersCmsModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Bayanatz Jobs',
                style: StyleText.fontSize24Weight600.copyWith(
                  color: _C.labelText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: Toggle careers visibility
                },
                child: Text(
                  'Hide',
                  style: StyleText.fontSize13Weight500.copyWith(
                    color: _C.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Illustration
          Center(
            child: SvgPicture.asset(
              'assets/images/dashboard_image.svg',
              width: 500.w,
              height: 250.h,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => SizedBox(
                height: 250.h,
                child: const Center(
                  child:
                  CircularProgressIndicator(color: _C.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  CHART ROW HELPER
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _chartRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 16.w),
        Expanded(child: right),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  1. APPLICATIONS RECEIVED — Vertical bar chart (monthly)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildApplicationsReceivedChart(CareersDashboardData dash) {
    return _chartCard(
      title: 'Applications Received',
      subtitle: 'Total: 1000',
      height: 280,
      child: Expanded(
        child: BarChart(
          BarChartData(
            maxY: _niceMax(dash.appReceivedValues),
            barGroups: dash.appReceivedValues.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    width: 18.sp,
                    color: _ChartColors.green,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ],
                showingTooltipIndicators: e.value > 0 ? [0] : [],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35.sp,
                  interval: _niceInterval(_niceMax(dash.appReceivedValues)),
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24.sp,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < dash.appReceivedLabels.length) {
                      return Text(
                        dash.appReceivedLabels[i],
                        style: TextStyle(
                            fontSize: 9.sp, color: Colors.grey),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval:
              _niceInterval(_niceMax(dash.appReceivedValues)),
              getDrawingHorizontalLine: (_) => FlLine(
                color: const Color(0xFFEFF3F9),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 4.sp,
                getTooltipColor: (_) => Colors.transparent,
                tooltipBorder: BorderSide.none,
                getTooltipItem: (group, _, rod, __) {
                  return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.labelText),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  2. JOB POSTING STATUS — Grouped vertical bar chart
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildJobPostingStatusChart(CareersDashboardData dash) {
    final legends = [
      _LegendItem('Active', _ChartColors.active),
      _LegendItem('Closed', _ChartColors.closed),
      _LegendItem('Scheduled', _ChartColors.scheduled),
      _LegendItem('Draft', _ChartColors.draft),
    ];

    final allValues = [
      ...dash.jobPostingActive,
      ...dash.jobPostingClosed,
      ...dash.jobPostingScheduled,
      ...dash.jobPostingDraft,
    ];
    final maxY = _niceMax(allValues);

    return _chartCard(
      title: 'Job Posting Status',
      height: 280,
      legendItems: legends,
      child: Expanded(
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(dash.jobPostingLabels.length, (i) {
              return BarChartGroupData(
                x: i,
                barsSpace: 3.sp,
                barRods: [
                  BarChartRodData(
                      toY: dash.jobPostingActive[i],
                      width: 10.sp,
                      color: _ChartColors.active,
                      borderRadius: BorderRadius.circular(2.r)),
                  BarChartRodData(
                      toY: dash.jobPostingClosed[i],
                      width: 10.sp,
                      color: _ChartColors.closed,
                      borderRadius: BorderRadius.circular(2.r)),
                  BarChartRodData(
                      toY: dash.jobPostingScheduled[i],
                      width: 10.sp,
                      color: _ChartColors.scheduled,
                      borderRadius: BorderRadius.circular(2.r)),
                  BarChartRodData(
                      toY: dash.jobPostingDraft[i],
                      width: 10.sp,
                      color: _ChartColors.draft,
                      borderRadius: BorderRadius.circular(2.r)),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35.sp,
                  interval: _niceInterval(maxY),
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24.sp,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < dash.jobPostingLabels.length) {
                      return Text(
                        dash.jobPostingLabels[i],
                        style: TextStyle(
                            fontSize: 9.sp, color: Colors.grey),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _niceInterval(maxY),
              getDrawingHorizontalLine: (_) => FlLine(
                color: const Color(0xFFEFF3F9),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(enabled: false),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  3. HIRING STAGE — Funnel chart
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildHiringStageChart(CareersDashboardData dash) {
    return SizedBox(
      height: 280.h,
      child: FunnelChartWidget(
        title: 'Hiring Stage',
        items: dash.hiringStages
            .map((s) => FunnelChartItem(label: s.label, value: s.value))
            .toList(),
        lightMode: true,
        height: 280,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  4. JOB STATUS — Donut/Pie chart
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildJobStatusChart(CareersDashboardData dash) {
    final statusColors = {
      'Active': _ChartColors.active,
      'Scheduled': _ChartColors.scheduled,
      'Closed': _ChartColors.closed,
      'Draft': _ChartColors.draft,
    };

    return _chartCard(
      title: 'Job Status',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // Legend
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dash.jobStatus.entries.map((e) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 12.sp,
                          height: 12.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColors[e.key] ?? Colors.grey,
                          ),
                        ),
                        SizedBox(width: 6.sp),
                        Text(
                          e.key,
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Pie chart
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40.sp,
                      sections: dash.jobStatus.entries.map((e) {
                        return PieChartSectionData(
                          value: e.value,
                          color: statusColors[e.key] ?? Colors.grey,
                          radius: 28.sp,
                          title: '',
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total\nDepartments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        dash.jobStatusTotal.toString(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  5. CANDIDATE QUALITY — Donut chart
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildCandidateQualityChart(CareersDashboardData dash) {
    return _chartCard(
      title: 'Candidate Quality',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // Legend
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _qualityLegendRow(
                    '${dash.qualifiedPercent.toInt()}%',
                    'Qualified',
                    _ChartColors.green,
                  ),
                  SizedBox(height: 8.sp),
                  _qualityLegendRow(
                    '${dash.unqualifiedPercent.toInt()}%',
                    'Unqualified',
                    _ChartColors.grey,
                  ),
                ],
              ),
            ),

            // Pie
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40.sp,
                      sections: [
                        PieChartSectionData(
                          value: dash.qualifiedPercent,
                          color: _ChartColors.green,
                          radius: 28.sp,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: dash.unqualifiedPercent,
                          color: _ChartColors.grey,
                          radius: 28.sp,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Applicants',
                        style: TextStyle(
                            fontSize: 9.sp, color: Colors.black54),
                      ),
                      Text(
                        _formatLargeNumber(dash.totalApplications),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qualityLegendRow(String percent, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.sp,
          height: 12.sp,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 6.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              percent,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  6. JOBS PERFORMANCE — Grouped vertical bar per role
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildJobsPerformanceChart(CareersDashboardData dash) {
    final legends = [
      _LegendItem('Applications', _ChartColors.green),
      _LegendItem('Interviews', _ChartColors.orange),
      _LegendItem('Hires', _ChartColors.teal),
    ];

    final allValues = [
      ...dash.performanceApplications,
      ...dash.performanceInterviews,
      ...dash.performanceHires,
    ];
    final maxY = _niceMax(allValues);

    return _chartCard(
      title: 'Jobs Performance',
      height: 280,
      legendItems: legends,
      child: Expanded(
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barGroups:
            List.generate(dash.performanceRoles.length, (i) {
              return BarChartGroupData(
                x: i,
                barsSpace: 3.sp,
                barRods: [
                  BarChartRodData(
                      toY: dash.performanceApplications[i],
                      width: 14.sp,
                      color: _ChartColors.green,
                      borderRadius: BorderRadius.circular(2.r)),
                  BarChartRodData(
                      toY: dash.performanceInterviews[i],
                      width: 14.sp,
                      color: _ChartColors.orange,
                      borderRadius: BorderRadius.circular(2.r)),
                  BarChartRodData(
                      toY: dash.performanceHires[i],
                      width: 14.sp,
                      color: _ChartColors.teal,
                      borderRadius: BorderRadius.circular(2.r)),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30.sp,
                  interval: _niceInterval(maxY),
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style:
                    TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36.sp,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < dash.performanceRoles.length) {
                      return SizedBox(
                        width: 70.sp,
                        child: Text(
                          dash.performanceRoles[i],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 8.sp, color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _niceInterval(maxY),
              getDrawingHorizontalLine: (_) => FlLine(
                color: const Color(0xFFEFF3F9),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(enabled: false),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  7. JOB OFFER — Donut chart with labels
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildJobOfferChart(CareersDashboardData dash) {
    final total = dash.jobOfferApproved +
        dash.jobOfferPending +
        dash.jobOfferRejected;

    final items = [
      _PieItem('Approved', dash.jobOfferApproved.toDouble(),
          _ChartColors.green),
      _PieItem('Pending', dash.jobOfferPending.toDouble(),
          _ChartColors.yellow),
      _PieItem('Rejected', dash.jobOfferRejected.toDouble(),
          _ChartColors.red),
    ];

    return _chartCard(
      title: 'Job Offer',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // Labels + values
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 12.sp,
                          height: 12.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.color,
                          ),
                        ),
                        SizedBox(width: 6.sp),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.black87),
                          ),
                        ),
                        Text(
                          _formatLargeNumber(item.value.toInt()),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.sp),

            // Pie
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40.sp,
                      sections: items
                          .map((item) => PieChartSectionData(
                        value: item.value,
                        color: item.color,
                        radius: 28.sp,
                        title: '',
                      ))
                          .toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatLargeNumber(total),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 10.sp, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  8. CANDIDATE SCORE DISTRIBUTION — Segmented bar
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildScoreDistributionChart(CareersDashboardData dash) {
    return SizedBox(
      height: 280.h,
      child: SegmentedScoreBarWidget(
        title: 'Candidate Score Distribution',
        segments: dash.scoreDistribution
            .map((s) => ScoreSegment(
          label: s.label,
          value: s.value,
          color: _hexToColor(s.colorHex),
        ))
            .toList(),
        lightMode: true,
        height: 280,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  9. EMPLOYMENT TYPES — Horizontal bar + Pie
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildEmploymentTypesChart(CareersDashboardData dash) {
    final entries = dash.employmentTypes.entries.toList();
    final total =
    entries.fold<double>(0, (sum, e) => sum + e.value);
    final typeColors = [
      _ChartColors.darkGreen,
      _ChartColors.green,
      const Color(0xFF81C784),
      const Color(0xFFC8E6C9),
    ];

    return _chartCard(
      title: 'Employment Types',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // Horizontal bars
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final percent =
                  total > 0 ? (e.value / total * 100) : 0.0;
                  final barColor =
                  i < typeColors.length ? typeColors[i] : typeColors.last;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40.sp,
                          child: Text(
                            '${percent.toInt()}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 14.sp,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius:
                                  BorderRadius.circular(4.r),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                (percent / 100).clamp(0.0, 1.0),
                                child: Container(
                                  height: 14.sp,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius:
                                    BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        SizedBox(
                          width: 70.sp,
                          child: Text(
                            e.key,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.sp),

            // Small pie
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: entries.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return PieChartSectionData(
                      value: e.value,
                      color: i < typeColors.length
                          ? typeColors[i]
                          : typeColors.last,
                      radius: 50.sp,
                      title: '',
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  10. CANDIDATE GENDER — Pie chart
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildCandidateGenderChart(CareersDashboardData dash) {
    return _chartCard(
      title: 'Candidate Gender',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // Legend
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _qualityLegendRow(
                    '${dash.malePercent.toInt()}%',
                    'Male',
                    _ChartColors.green,
                  ),
                  SizedBox(height: 8.sp),
                  _qualityLegendRow(
                    '${dash.femalePercent.toInt()}%',
                    'Female',
                    _ChartColors.grey,
                  ),
                ],
              ),
            ),

            // Pie
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                      value: dash.malePercent,
                      color: _ChartColors.green,
                      radius: 60.sp,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: dash.femalePercent,
                      color: _ChartColors.grey,
                      radius: 60.sp,
                      title: '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SHARED HELPERS
  // ═════════════════════════════════════════════════════════════════════════════

  /// Reusable chart card container
  Widget _chartCard({
    required String title,
    required double height,
    required Widget child,
    String? subtitle,
    List<_LegendItem>? legendItems,
  }) {
    return Container(
      height: height.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.labelText,
                  ),
                ),
              ),
              if (legendItems != null)
                Wrap(
                  spacing: 10.sp,
                  children: legendItems
                      .map((l) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.sp,
                        height: 8.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: l.color,
                        ),
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        l.label,
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black54),
                      ),
                    ],
                  ))
                      .toList(),
                ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.sp),
            Text(
              subtitle,
              style:
              TextStyle(fontSize: 11.sp, color: Colors.black45),
            ),
          ],
          SizedBox(height: 12.sp),
          child,
        ],
      ),
    );
  }

  /// Calculate nice max for Y axis
  double _niceMax(List<double> values) {
    if (values.isEmpty) return 10;
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    if (dataMax == 0) return 10;
    final intMax = dataMax.ceil();
    if (intMax <= 10) return 10;
    if (intMax <= 20) return 20;
    if (intMax <= 50) return ((intMax / 10).ceil() * 10).toDouble();
    if (intMax <= 100) return ((intMax / 20).ceil() * 20).toDouble();
    if (intMax <= 500) return ((intMax / 50).ceil() * 50).toDouble();
    return ((intMax / 100).ceil() * 100).toDouble();
  }

  /// Calculate nice interval for Y axis
  double _niceInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 200) return 50;
    if (maxY <= 500) return 100;
    return (maxY / 5).ceilToDouble();
  }

  /// Format large numbers: 114765 → "114,765"
  String _formatLargeNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  /// Parse hex color string to Color
  Color _hexToColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}

// ── Internal helper classes ──────────────────────────────────────────────────

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
}

class _PieItem {
  final String label;
  final double value;
  final Color color;
  const _PieItem(this.label, this.value, this.color);
}