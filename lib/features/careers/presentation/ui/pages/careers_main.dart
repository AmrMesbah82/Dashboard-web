// ******************* FILE INFO *******************
// File Name: careers_main_page.dart
// Created by: Amr Mesbah
// Purpose: Careers CMS main page — Hero + Dashboard (10 charts, 2 per row)
// Pattern: Same as home_main.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/custom_svg.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/main_widgets/careers_stat_card.dart';
import '../../../../../core/main_widgets/funnel_chart_widget.dart';
import '../../../../../core/main_widgets/segmented_score_bar_widget.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/careers_model.dart';
import '../../controller/careers_cubit.dart';
import '../../controller/careers_state.dart';

part '../widget/careers_main/chart_colors.dart';
part '../widget/careers_main/legend_item.dart';
part '../widget/careers_main/pie_item.dart';
part '../widget/careers_main/careers_charts.dart';

// ── Chart color palette ──────────────────────────────────────────────────────

class CareersMainPageDashboard extends StatefulWidget {
  const CareersMainPageDashboard({super.key});

  @override
  State<CareersMainPageDashboard> createState() => _CareersMainPageDashboardState();
}

class _CareersMainPageDashboardState extends State<CareersMainPageDashboard> {
  bool _heroImageVisible = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CareersCmsCubit>();
    if (cubit.state is CareersCmsInitial) {
      cubit.loadRealData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersCmsCubit, CareersCmsState>(
      builder: (context, state) {
        if (state is CareersCmsInitial || state is CareersCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.white,
            body: Center(
              child: CircularProgressIndicator(color: ColorPick.primary),
            ),
          );
        }

        CareersCmsModel? data;
        if (state is CareersCmsLoaded) data = state.data;
        if (state is CareersCmsSaved) data = state.data;

        if (data == null) {
          return const Scaffold(
            backgroundColor: ColorPick.white,
            body: Center(
              child: CircularProgressIndicator(color: ColorPick.primary),
            ),
          );
        }

        final dash = data.dashboard;

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

                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Title Row with Hide / Collapse toggle ──
                          Row(
                            children: [
                              Text(
                                "Bayanatz Jobs",
                                style: StyleText.fontSize14Weight500.copyWith(
                                  fontSize: 44.sp,
                                  fontWeight: FontWeight.w700,
                                  color: ColorPick.primary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _heroImageVisible = !_heroImageVisible;
                                  });
                                },
                                child: IntrinsicWidth(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        _heroImageVisible ? "Hide" : "Collapse",
                                        style: StyleText.fontSize20Weight500.copyWith(
                                          color: const Color(0xFF1877F2),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Container(
                                        height: 1.5,
                                        color: const Color(0xFF1877F2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ── Hero SVG ──
                          if (_heroImageVisible) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSvg(
                                  assetPath: "assets/images/dashboard_image.svg",
                                  width: 300.w,
                                  height: 300.h,
                                  fit: BoxFit.fill,
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: 20.h),

                          // ── Dashboard Title ──
                          Center(
                            child: Text(
                              'Dashboard',
                              style: StyleText.fontSize18Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // ── Stat Cards Row ──
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
                            left:  _buildApplicationsReceivedChart(dash),
                            right: _buildJobPostingStatusChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 2: Hiring Stage (Funnel) | Job Status (Pie)
                          _chartRow(
                            left:  _buildHiringStageChart(dash),
                            right: _buildJobStatusChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 3: Candidate Quality | Jobs Performance
                          _chartRow(
                            left:  _buildCandidateQualityChart(dash),
                            right: _buildJobsPerformanceChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 4: Job Offer | Candidate Score Distribution
                          _chartRow(
                            left:  _buildJobOfferChart(dash),
                            right: _buildScoreDistributionChart(dash),
                          ),
                          SizedBox(height: 16.h),

                          // Row 5: Employment Types | Candidate Gender
                          _chartRow(
                            left:  _buildEmploymentTypesChart(dash),
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

}

// ── Internal helper classes ──────────────────────────────────────────────────
