// ═══════════════════════════════════════════════════════════════════
// FILE 6: inquiry_main_page.dart (View Page)
// Path: lib/pages/dashboard/inquiry/inquiry_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/inquire/inquiry_cubit.dart';
import 'package:web_app_admin/controller/inquire/inquiry_state.dart';

import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';
import 'package:web_app_admin/model/inquiry_model.dart';
import 'package:web_app_admin/pages/careers_main_dashboard.dart';
import 'package:web_app_admin/pages/dashboard/inquire/inquiry_detail_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/job_list/job_listing_main_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

class _C {
  static const Color primary      = Color(0xFF008037);
  static const Color primaryLight = Color(0xFF4CAF7D);
  static const Color back         = Color(0xFFF1F2ED);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color labelText    = Color(0xFF333333);
  static const Color hintText     = Color(0xFFAAAAAA);
  static const Color border       = Color(0xFFE0E0E0);
  static const Color barLight     = Color(0xFFB2DFCC);
}

class InquiryMainPage extends StatefulWidget {
  const InquiryMainPage({super.key});

  @override
  State<InquiryMainPage> createState() => _InquiryMainPageState();
}

class _InquiryMainPageState extends State<InquiryMainPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InquiryCubit>().loadInquiries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiryCubit, InquiryState>(
      listener: (context, state) {
        if (state is InquiryUpdated) {
          context.read<InquiryCubit>().loadInquiries();
        }
      },
      child: BlocBuilder<InquiryCubit, InquiryState>(
        builder: (context, state) {
          if (state is InquiryInitial || state is InquiryLoading) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          final cubit = context.read<InquiryCubit>();
          List<InquiryModel> inquiries = [];
          int totalCount = 0, newCount = 0, repliedCount = 0, closedCount = 0;
          Map<String, int> entityTypeCounts   = {};
          Map<String, int> entitySizeCounts   = {};
          Map<String, int> locationCounts     = {};
          Map<int, int>    monthlySubmissions  = {};

          if (state is InquiryLoaded) {
            inquiries           = state.filtered;
            totalCount          = state.totalCount;
            newCount            = state.newCount;
            repliedCount        = state.repliedCount;
            closedCount         = state.closedCount;
            entityTypeCounts    = state.entityTypeCounts;
            entitySizeCounts    = state.entitySizeCounts;
            locationCounts      = state.locationCounts;
            monthlySubmissions  = state.monthlySubmissions;
          }

          if (state is InquiryError && state.lastInquiries != null) {
            inquiries = state.lastInquiries!;
          }

          // Derive interview-stage percentages from status counts
          final passedCount   = newCount;
          final failedCount   = repliedCount;
          final withdrewCount = closedCount;
          final stageTotal    = passedCount + failedCount + withdrewCount;
          final passedPct     = stageTotal > 0 ? (passedCount   / stageTotal * 100).round() : 72;
          final failedPct     = stageTotal > 0 ? (failedCount   / stageTotal * 100).round() : 28;
          final withdrewPct   = stageTotal > 0 ? (withdrewCount / stageTotal * 100).round() : 28;

          return Scaffold(
            backgroundColor: _C.back,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel: 'Inquires',
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
                            // Title
                            Text('Inquires',
                                style: StyleText.fontSize45Weight600.copyWith(
                                    color: _C.primary, fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // Search + Filter
                            Row(children: [
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
                                textStyle: StyleText.fontSize13Weight600
                                    .copyWith(color: Colors.white),
                              ),
                            ]),
                            SizedBox(height: 16.h),

                            // Summary cards
                            Row(children: [
                              Expanded(child: _summaryCard('Total Submission', totalCount, Colors.grey)),
                              SizedBox(width: 10.w),
                              Expanded(child: _summaryCard('New', newCount, _C.primary)),
                              SizedBox(width: 10.w),
                              Expanded(child: _summaryCard('Replied', repliedCount, const Color(0xFFFF9800))),
                              SizedBox(width: 10.w),
                              Expanded(child: _summaryCard('Closed', closedCount, const Color(0xFFE53935))),
                            ]),
                            SizedBox(height: 16.h),

                            // Filter dropdowns + Export
                            Row(children: [
                              _miniDropdown('Status'),
                              SizedBox(width: 8.w),
                              _miniDropdown('Entity Type'),
                              SizedBox(width: 8.w),
                              _miniDropdown('Location'),
                              SizedBox(width: 8.w),
                              _miniDropdown('Calendar'),
                              const Spacer(),
                              customButtonWithImage(
                                title: 'Export',
                                function: () {},
                                textStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
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
                            ]),
                            SizedBox(height: 16.h),

                            // Table
                            _buildTable(inquiries),
                            SizedBox(height: 40.h),

                            // Charts section title
                            Text('Inquires',
                                style: StyleText.fontSize24Weight600.copyWith(
                                    color: _C.primary, fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // Row 1: Submission Received | Entity Types
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: _chartCard(
                                  'Submission Received',
                                  'Total: $totalCount',
                                  _buildBarChart(monthlySubmissions),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _chartCard(
                                  'Entity Types',
                                  '',
                                  _buildEntityTypeChart(entityTypeCounts),
                                ),
                              ),
                            ]),
                            SizedBox(height: 16.h),

                            // Row 2: Entity Size Distribution | Interview Stage
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: _chartCard(
                                  'Entity Size Distribution',
                                  '',
                                  _buildSizeStackedBar(entitySizeCounts),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _chartCard(
                                  'Interview Stage',
                                  '',
                                  _buildInterviewStageChart(
                                    passedPct: passedPct,
                                    failedPct: failedPct,
                                    withdrewPct: withdrewPct,
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(height: 16.h),

                            // Row 3: Location Distribution (full width)
                            _chartCard(
                              'Location Distribution',
                              '',
                              _buildLocationChart(locationCounts),
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
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _summaryCard(String title, int count, Color topColor) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(children: [
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _C.labelText)),
              Text('$count',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.labelText)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Mini dropdown ─────────────────────────────────────────────────────────
  Widget _miniDropdown(String hint) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(hint, style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
        SizedBox(width: 4.w),
        Icon(Icons.keyboard_arrow_down, size: 14.sp, color: _C.hintText),
      ]),
    );
  }

  // ── Data table ───────────────────────────────────────────────────────────
  Widget _buildTable(List<InquiryModel> inquiries) {
    final columns = [
      'Submission Date', 'Preferred Language', 'First Name', 'Last Name',
      'Email', 'Country Code', 'Phone Number', 'Location', 'Entity Name',
      'Entity Type', 'Entity Size', 'Subject', 'Message', 'Note', 'Status',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(_C.primary),
        headingTextStyle: TextStyle(
            fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white),
        dataTextStyle: TextStyle(fontSize: 11.sp, color: _C.labelText),
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: inquiries.map((i) {
          final date = i.submissionDate != null
              ? '${i.submissionDate!.day}/${i.submissionDate!.month}/${i.submissionDate!.year}'
              : '';
          return DataRow(cells: [
            DataCell(Text(date)),
            DataCell(Text(i.preferredLanguage)),
            DataCell(Text(i.firstName)),
            DataCell(Text(i.lastName)),
            DataCell(Text(i.email)),
            DataCell(Text(i.countryCode)),
            DataCell(Text(i.phone)),
            DataCell(Text(i.location)),
            DataCell(Text(i.entityName)),
            DataCell(Text(i.entityType)),
            DataCell(Text(i.entitySize)),
            DataCell(Text(i.subject)),
            DataCell(Text(i.message, maxLines: 1, overflow: TextOverflow.ellipsis)),
            DataCell(Text(i.note,    maxLines: 1, overflow: TextOverflow.ellipsis)),
            DataCell(GestureDetector(
              onTap: () => navigateTo(context, InquiryDetailPage(inquiryId: i.id)),
              child: Text(i.status.label,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: i.status.color)),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ── Chart card wrapper ───────────────────────────────────────────────────
  Widget _chartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _C.primary)),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(fontSize: 11.sp, color: _C.labelText)),
        ],
        SizedBox(height: 12.h),
        chart,
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 1. Submission Received — vertical bar chart, value label inside bar
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildBarChart(Map<int, int> monthly) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    final maxVal   = monthly.values.fold(1, (a, b) => a > b ? a : b);
    const maxBarH  = 90.0;

    return SizedBox(
      height: 130.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final val  = monthly[i + 1] ?? 0;
          final h    = maxVal > 0 ? (val / maxVal) * maxBarH : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // bar
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: h.h,
                        decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      // value inside bar (rotated) when bar is tall enough
                      if (val > 0 && h > 16)
                        Positioned(
                          top: 3.h,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              '$val',
                              style: TextStyle(
                                  fontSize: 7.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // value above bar when bar is very short
                  if (val > 0 && h <= 16)
                    Text('$val',
                        style: TextStyle(fontSize: 7.sp, color: _C.labelText)),
                  SizedBox(height: 4.h),
                  Text(months[i],
                      style: TextStyle(fontSize: 8.sp, color: _C.hintText)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 2. Entity Types — two-column horizontal progress bars
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildEntityTypeChart(Map<String, int> counts) {
    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    final half    = (entries.length / 2).ceil();
    final left    = entries.take(half).toList();
    final right   = entries.skip(half).toList();
    final rows    = max(left.length, right.length);

    return Column(
      children: List.generate(rows, (idx) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (idx < left.length)
                Expanded(child: _entityTypeRow(left[idx], total))
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: 12.w),
              if (idx < right.length)
                Expanded(child: _entityTypeRow(right[idx], total))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _entityTypeRow(MapEntry<String, int> e, int total) {
    final pct = total > 0 ? (e.value / total * 100).round() : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(e.key,
                  style: TextStyle(fontSize: 10.sp, color: _C.labelText),
                  overflow: TextOverflow.ellipsis),
            ),
            Text('$pct%',
                style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.r)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (pct / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3. Entity Size Distribution — legend dots + stacked horizontal bar
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSizeStackedBar(Map<String, int> counts) {
    if (counts.isEmpty) return const SizedBox();

    final total  = counts.values.fold(0, (a, b) => a + b);
    final keys   = counts.keys.toList();
    final colors = _sizeColors(keys.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: List.generate(keys.length, (i) {
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 10.sp,
                  height: 10.sp,
                  decoration:
                  BoxDecoration(color: colors[i], shape: BoxShape.circle)),
              SizedBox(width: 4.w),
              Text(keys[i],
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: _C.labelText)),
              SizedBox(width: 4.w),
              Text('${counts[keys[i]]}',
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.labelText)),
            ]);
          }),
        ),
        SizedBox(height: 14.h),
        // Stacked horizontal bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: SizedBox(
            height: 22.h,
            child: Row(
              children: List.generate(keys.length, (i) {
                final val  = counts[keys[i]] ?? 0;
                final flex = total > 0 ? val : 1;
                return Flexible(
                  flex: flex,
                  child: Container(color: colors[i]),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _sizeColors(int count) {
    const palette = [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF388E3C),
      Color(0xFF66BB6A),
      Color(0xFFB2DFDB),
    ];
    return List.generate(count, (i) => palette[i % palette.length]);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 4. Interview Stage — stat list (left) + pie chart (right)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildInterviewStageChart({
    required int passedPct,
    required int failedPct,
    required int withdrewPct,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _interviewStatRow(_C.primary,      '$passedPct%',  'Passed'),
              SizedBox(height: 10.h),
              _interviewStatRow(_C.primaryLight, '$failedPct%',  'Failed'),
              SizedBox(height: 10.h),
              _interviewStatRow(const Color(0xFFB2DFCC), '$withdrewPct%', 'Candidate Withdrew'),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        // Pie
        SizedBox(
          width: 100.w,
          height: 100.w,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: [
                passedPct.toDouble(),
                failedPct.toDouble(),
                withdrewPct.toDouble(),
              ],
              colors: [
                _C.primary,
                _C.primaryLight,
                const Color(0xFFDCEDC8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _interviewStatRow(Color dotColor, String pct, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _C.back,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(children: [
        Container(
            width: 10.sp,
            height: 10.sp,
            decoration:
            BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        Text(pct,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _C.labelText)),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(label,
              style: TextStyle(fontSize: 10.sp, color: _C.hintText),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 5. Location Distribution — two-tone vertical bars
  //    Light background full height, dark primary fills from bottom up
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildLocationChart(Map<String, int> counts) {
    if (counts.isEmpty) return const SizedBox();

    final total = counts.values.fold(0, (a, b) => a + b);
    const fullBarH = 100.0; // logical bar height (in .h units applied below)

    return SizedBox(
      height: 150.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: counts.entries.map((e) {
          final pct   = total > 0 ? (e.value / total * 100).round() : 0;
          final fillH = (pct / 100) * fullBarH;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Two-tone bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: SizedBox(
                      height: fullBarH.h,
                      child: Column(
                        children: [
                          // light unused portion
                          Expanded(child: Container(color: _C.barLight)),
                          // dark filled portion (bottom)
                          Container(
                            height: fillH.h,
                            color: _C.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text('$pct%',
                      style:
                      TextStyle(fontSize: 8.sp, color: _C.labelText)),
                  SizedBox(height: 2.h),
                  Text(e.key,
                      style: TextStyle(fontSize: 8.sp, color: _C.hintText),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Custom pie chart painter
// ════════════════════════════════════════════════════════════════════════════
class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;

  const _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(
        rect, start, sweep, true,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill,
      );
      // White divider between slices
      canvas.drawArc(
        rect, start, sweep, true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.values != values || old.colors != colors;
}