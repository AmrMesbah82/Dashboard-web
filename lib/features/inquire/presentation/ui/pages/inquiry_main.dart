// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_main.dart (View Page)
// Path: lib/pages/dashboard/inquiry/inquiry_main.dart
// UPDATED: Charts enhanced to match Figma design exactly
// ═══════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/model/inquiry_model.dart';
import '../../controller/inquiry_cubit.dart';
import '../../controller/inquiry_state.dart';
import 'inquiry_details.dart';


class _C {
  static const Color primary      = Color(0xFF008037);
  static const Color primaryLight = Color(0xFF4CAF7D);
  static const Color back         = Color(0xFFF1F2ED);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color labelText    = Color(0xFF333333);
  static const Color hintText     = Color(0xFFAAAAAA);
  static const Color border       = Color(0xFFE0E0E0);
  static const Color barLight     = Color(0xFFB2DFCC);   // light green bg for location bars
  static const Color barLighter   = Color(0xFFDCEFE5);   // even lighter for entity size
}

// ── Month name helper ────────────────────────────────────────────────────────
const List<String> _kMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

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

  // ═══════════════════════════════════════════════════════════════════════════
  //  CSV EXPORT
  // ═══════════════════════════════════════════════════════════════════════════

  String _escapeCsvValue(String value) {
    if (value.isEmpty) return '';
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatDateForExport(DateTime? date) {
    if (date == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showExportDialog(List<InquiryModel> inquiries) {
    final fileNameCtrl = TextEditingController();
    bool isExporting = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            child: Container(
              width: 400.w,
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.primary),
                        child: Icon(Icons.file_download_outlined, size: 16.sp, color: Colors.white),
                      ),
                      SizedBox(width: 8.sp),
                      Text('Export', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: _C.labelText)),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  CustomValidatedTextFieldMaster(
                    label: 'File Name',
                    hint: 'Enter file name',
                    controller: fileNameCtrl,
                    height: 36,
                    submitted: false,
                    primaryColor: _C.primary,
                    fillColor: const Color(0xFFF1F2ED),
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isExporting ? null : () => Navigator.of(ctx).pop(),
                          child: Container(
                            height: 38.h,
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8.r)),
                            child: Center(child: Text('Discard', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: _C.labelText))),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      Expanded(
                        child: GestureDetector(
                          onTap: isExporting
                              ? null
                              : () {
                            final fileName = fileNameCtrl.text.trim();
                            if (fileName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a file name'), backgroundColor: Colors.orange));
                              return;
                            }
                            if (inquiries.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No inquiries to export'), backgroundColor: Colors.orange));
                              return;
                            }
                            setDialogState(() => isExporting = true);
                            _performExport(inquiries, fileName);
                            Navigator.of(ctx).pop();
                            _showExportSuccessDialog(fileName);
                          },
                          child: Container(
                            height: 38.h,
                            decoration: BoxDecoration(color: isExporting ? Colors.grey : _C.primary, borderRadius: BorderRadius.circular(8.r)),
                            child: Center(
                              child: isExporting
                                  ? SizedBox(width: 16.sp, height: 16.sp, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Download', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _performExport(List<InquiryModel> inquiries, String fileName) {
    try {
      final csvBuffer = StringBuffer();
      csvBuffer.writeln(['No', 'Submission Date', 'Preferred Language', 'First Name', 'Last Name', 'Email', 'Country Code', 'Phone Number', 'Location', 'Entity Name', 'Entity Type', 'Entity Size', 'Subject', 'Message', 'Note', 'Status'].map(_escapeCsvValue).join(','));
      for (int i = 0; i < inquiries.length; i++) {
        final inq = inquiries[i];
        csvBuffer.writeln(['${i + 1}', _formatDateForExport(inq.submissionDate), inq.preferredLanguage, inq.firstName, inq.lastName, inq.email, inq.countryCode, inq.phone, inq.location, inq.entityName, inq.entityType, inq.entitySize, inq.subject, inq.message, inq.note, inq.status.label].map(_escapeCsvValue).join(','));
      }
      final bytes = utf8.encode(csvBuffer.toString());
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final finalFileName = fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)..setAttribute('download', finalFileName)..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e'), backgroundColor: Colors.red));
    }
  }

  void _showExportSuccessDialog(String fileName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.sp, height: 64.sp,
                decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle, color: _C.primary, size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text('Export Successful', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
              SizedBox(height: 8.h),
              Text('$fileName\ndownloaded successfully', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: _C.hintText, height: 1.4)),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: _C.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)), padding: EdgeInsets.symmetric(vertical: 12.h)),
                  child: Text('OK', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiryCubit, InquiryState>(
      listener: (context, state) {
        if (state is InquiryUpdated) context.read<InquiryCubit>().loadInquiries();
      },
      child: BlocBuilder<InquiryCubit, InquiryState>(
        builder: (context, state) {
          if (state is InquiryInitial || state is InquiryLoading) {
            return const Scaffold(backgroundColor: _C.back, body: Center(child: CircularProgressIndicator(color: _C.primary)));
          }

          final cubit = context.read<InquiryCubit>();
          List<InquiryModel> inquiries = [];
          int totalCount = 0, newCount = 0, repliedCount = 0, closedCount = 0;
          Map<String, int> entityTypeCounts  = {};
          Map<String, int> entitySizeCounts  = {};
          Map<String, int> locationCounts    = {};
          Map<int, int>    monthlySubmissions = {};
          List<String> uniqueStatuses    = [];
          List<String> uniqueEntityTypes = [];
          List<String> uniqueLocations   = [];
          List<int>    uniqueMonths      = [];
          String? activeStatusFilter;
          String? activeEntityTypeFilter;
          String? activeLocationFilter;
          int?    activeMonthFilter;

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
            uniqueStatuses      = state.uniqueStatuses;
            uniqueEntityTypes   = state.uniqueEntityTypes;
            uniqueLocations     = state.uniqueLocations;
            uniqueMonths        = state.uniqueMonths;
            activeStatusFilter     = state.statusFilter;
            activeEntityTypeFilter = state.entityTypeFilter;
            activeLocationFilter   = state.locationFilter;
            activeMonthFilter      = state.monthFilter;
          }
          if (state is InquiryError && state.lastInquiries != null) inquiries = state.lastInquiries!;

          final passedCount   = newCount;
          final failedCount   = repliedCount;
          final withdrewCount = closedCount;
          final stageTotal    = passedCount + failedCount + withdrewCount;
          final passedPct     = stageTotal > 0 ? (passedCount   / stageTotal * 100).round() : 0;
          final failedPct     = stageTotal > 0 ? (failedCount   / stageTotal * 100).round() : 0;
          final withdrewPct   = stageTotal > 0 ? (withdrewCount / stageTotal * 100).round() : 0;

          final statusItems     = uniqueStatuses.map((s)    => {'key': s, 'value': s}).toList();
          final entityTypeItems = uniqueEntityTypes.map((s) => {'key': s, 'value': s}).toList();
          final locationItems   = uniqueLocations.map((s)   => {'key': s, 'value': s}).toList();
          final monthItems      = uniqueMonths.map((m)      => {'key': m.toString(), 'value': m >= 1 && m <= 12 ? _kMonthNames[m - 1] : m.toString()}).toList();

          final bool hasActiveFilters = activeStatusFilter != null || activeEntityTypeFilter != null || activeLocationFilter != null || activeMonthFilter != null;

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
                            Text('Inquires', style: StyleText.fontSize45Weight600.copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),
                            Row(children: [AppSearchTextField(controller: _searchController, onChanged: (v) => cubit.setSearch(v), hintText: 'Search')]),
                            SizedBox(height: 16.h),

                            // ── Summary cards ──
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

                            // ── Filters ──
                            Row(children: [
                              SizedBox(width: 130.w, child: CustomDropdownFormFieldInvMaster(selectedValue: activeStatusFilter, items: statusItems, widthIcon: 14, heightIcon: 14, height: 32, dropdownColor: _C.cardBg, primaryColor: _C.primary, hint: Text('Status', style: TextStyle(fontSize: 11.sp, color: _C.hintText)), onChanged: (v) => cubit.setStatusFilter(v))),
                              SizedBox(width: 8.w),
                              SizedBox(width: 150.w, child: CustomDropdownFormFieldInvMaster(selectedValue: activeEntityTypeFilter, items: entityTypeItems, widthIcon: 14, heightIcon: 14, height: 32, dropdownColor: _C.cardBg, primaryColor: _C.primary, hint: Text('Entity Type', style: TextStyle(fontSize: 11.sp, color: _C.hintText)), onChanged: (v) => cubit.setEntityTypeFilter(v))),
                              SizedBox(width: 8.w),
                              SizedBox(width: 140.w, child: CustomDropdownFormFieldInvMaster(selectedValue: activeLocationFilter, items: locationItems, widthIcon: 14, heightIcon: 14, height: 32, dropdownColor: _C.cardBg, primaryColor: _C.primary, hint: Text('Location', style: TextStyle(fontSize: 11.sp, color: _C.hintText)), onChanged: (v) => cubit.setLocationFilter(v))),
                              SizedBox(width: 8.w),
                              SizedBox(width: 120.w, child: CustomDropdownFormFieldInvMaster(selectedValue: activeMonthFilter?.toString(), items: monthItems, widthIcon: 14, heightIcon: 14, height: 32, dropdownColor: _C.cardBg, primaryColor: _C.primary, hint: Text('Calendar', style: TextStyle(fontSize: 11.sp, color: _C.hintText)), onChanged: (v) { if (v != null) { cubit.setMonthFilter(int.tryParse(v)); } else { cubit.setMonthFilter(null); } })),
                              SizedBox(width: 8.w),
                              if (hasActiveFilters)
                                GestureDetector(
                                  onTap: () { cubit.clearAllFilters(); _searchController.clear(); },
                                  child: Container(
                                    height: 32.h, padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(4.r), border: Border.all(color: _C.border)),
                                    child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.clear, size: 12.sp, color: _C.hintText), SizedBox(width: 4.w), Text('Clear', style: TextStyle(fontSize: 11.sp, color: _C.hintText))])),
                                  ),
                                ),
                              const Spacer(),
                              customButtonWithImage(title: 'Export', function: () => _showExportDialog(inquiries), textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white), height: 32.h, space: 4.w, radius: 6, color: _C.primary, image: 'assets/images/export.svg', widthImage: 14.sp, heightImage: 14.sp, colorBorder: _C.primary, svgColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10.w)),
                            ]),
                            SizedBox(height: 16.h),

                            // ── Table ──
                            _buildTable(inquiries),
                            SizedBox(height: 40.h),

                            // ── Charts title ──
                            Text('Dashboard', style: StyleText.fontSize24Weight600.copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // Row 1 — Bar chart + Entity Types
                            IntrinsicHeight(
                              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                Expanded(child: _chartCard('Submission Received', 'Total: $totalCount', _buildBarChart(monthlySubmissions))),
                                SizedBox(width: 16.w),
                                Expanded(child: _chartCard('Entity Types', '', _buildEntityTypeChart(entityTypeCounts))),
                              ]),
                            ),
                            SizedBox(height: 16.h),

                            // Row 2 — Entity Size + Interview Stage
                            IntrinsicHeight(
                              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                Expanded(child: _chartCard('Entity Size Distribution', '', _buildSizeStackedBar(entitySizeCounts))),
                                SizedBox(width: 16.w),
                                Expanded(child: _chartCard('Interview Stage', '', _buildInterviewStageChart(passedPct: passedPct, failedPct: failedPct, withdrewPct: withdrewPct))),
                              ]),
                            ),
                            SizedBox(height: 16.h),

                            // Row 3 — Location
                            _chartCard('Location Distribution', '', _buildLocationChart(locationCounts)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _summaryCard(String title, int count, Color topColor) {
    return Container(
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(children: [
        Container(height: 4.h, decoration: BoxDecoration(color: topColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r)))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText)),
            Text('$count', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TABLE
  // ═══════════════════════════════════════════════════════════════════════════

  final _headers = const [
    'No', 'Submission Date', 'Preferred Language', 'First Name', 'Last Name',
    'Email', 'Country Code', 'Phone Number', 'Location', 'Entity Name',
    'Entity Type', 'Entity Size', 'Subject', 'Message', 'Note', 'Status',
  ];

  final _columnWidths = <int, TableColumnWidth>{
    0: FixedColumnWidth(50), 1: FixedColumnWidth(120), 2: FixedColumnWidth(130),
    3: FixedColumnWidth(120), 4: FixedColumnWidth(120), 5: FixedColumnWidth(180),
    6: FixedColumnWidth(100), 7: FixedColumnWidth(120), 8: FixedColumnWidth(120),
    9: FixedColumnWidth(140), 10: FixedColumnWidth(120), 11: FixedColumnWidth(100),
    12: FixedColumnWidth(150), 13: FixedColumnWidth(180), 14: FixedColumnWidth(150),
    15: FixedColumnWidth(100),
  };

  TextStyle get _cellStyle => TextStyle(fontSize: 11.sp, color: _C.labelText);
  Widget _cell(Widget child) => Container(padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp), child: DefaultTextStyle.merge(style: _cellStyle, child: child));
  Widget _textCell(String text, {int maxLines = 2}) => _cell(Text(text.isEmpty ? '-' : text, maxLines: maxLines, overflow: TextOverflow.ellipsis));

  Widget _buildTable(List<InquiryModel> inquiries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: _columnWidths.map((k, v) => MapEntry(k, FixedColumnWidth((v as FixedColumnWidth).value.sp))),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _C.primary),
              children: _headers.map((h) => Padding(padding: EdgeInsets.all(10.sp), child: Text(h, maxLines: 1, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white)))).toList(),
            ),
            ...List.generate(inquiries.length, (index) {
              final i = inquiries[index];
              final rowColor = index.isEven ? const Color(0xFFF7F8FA) : Colors.white;
              final dateStr = i.submissionDate != null ? '${i.submissionDate!.day}/${i.submissionDate!.month}/${i.submissionDate!.year}' : '-';
              final cells = [
                _textCell('${index + 1}', maxLines: 1), _textCell(dateStr, maxLines: 1),
                _textCell(i.preferredLanguage, maxLines: 1), _textCell(i.firstName),
                _textCell(i.lastName), _textCell(i.email), _textCell(i.countryCode, maxLines: 1),
                _textCell(i.phone), _textCell(i.location), _textCell(i.entityName),
                _textCell(i.entityType), _textCell(i.entitySize, maxLines: 1),
                _textCell(i.subject), _textCell(i.message, maxLines: 1), _textCell(i.note, maxLines: 1),
                _cell(Text(i.status.label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: i.status.color))),
              ];
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells.map((cell) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<InquiryCubit>(), child: InquiryDetailPage(inquiryId: i.id)))), child: cell)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CHART CARD WRAPPER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _chartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,        // ← shrink to content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.primary)),
          if (subtitle.isNotEmpty) ...[SizedBox(height: 4.h), Text(subtitle, style: TextStyle(fontSize: 11.sp, color: _C.labelText))],
          SizedBox(height: 12.h),
          chart,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BAR CHART — values rotated inside bars (Figma style)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBarChart(Map<int, int> monthly) {
    final maxVal = monthly.values.fold(1, (a, b) => a > b ? a : b);
    const maxBarH = 130.0;
    const labelH  = 16.0; // reserved height above every bar for the label

    return SizedBox(
      height: 175.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final val  = monthly[i + 1] ?? 0;
          final barH = maxVal > 0 ? (val / maxVal) * maxBarH : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // value label always above bar (empty string when 0 so space is consistent)
                  SizedBox(
                    height: labelH.h,
                    child: val > 0
                        ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        '$val',
                        style: TextStyle(
                          fontSize: 7.sp,
                          color: _C.labelText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ),
                  // bar itself
                  Container(
                    height: barH.h,
                    decoration: BoxDecoration(
                      color: val > 0 ? _C.primary : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft:  Radius.circular(3.r),
                        topRight: Radius.circular(3.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(_kMonthNames[i], style: TextStyle(fontSize: 8.sp, color: _C.hintText)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ENTITY TYPES — 2-col grid, label left + % right, green progress bar
  //  Matches Figma: name | pct% on one line, bar underneath, divider between rows
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEntityTypeChart(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    final half = (entries.length / 2).ceil();
    final left  = entries.take(half).toList();
    final right = entries.skip(half).toList();
    final rows  = max(left.length, right.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (idx) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (idx < left.length)  Expanded(child: _entityTypeItem(left[idx],  total))
              else                    const Expanded(child: SizedBox()),
              SizedBox(width: 16.w),
              if (idx < right.length) Expanded(child: _entityTypeItem(right[idx], total))
              else                    const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _entityTypeItem(MapEntry<String, int> e, int total) {
    final pct = total > 0 ? (e.value / total * 100).round() : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label + percentage on same row (like Figma)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                e.key,
                style: TextStyle(fontSize: 10.sp, color: _C.labelText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(fontSize: 10.sp, color: _C.hintText),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        // progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: Container(
            height: 7.h,
            color: _C.back,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (pct / 100).clamp(0.0, 1.0),
              child: Container(color: _C.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ENTITY SIZE — legend row with dot + label + bold count, stacked bar
  //  Matches Figma: dots in a row, then one stacked horizontal bar below
  // ═══════════════════════════════════════════════════════════════════════════

  // All possible entity size categories in display order
  static const List<String> _kAllEntitySizes = [
    '1 to 50',
    '51 to 150',
    '151 to 500',
    '501 to 750',
    '+750',
  ];

  Widget _buildSizeStackedBar(Map<String, int> counts) {
    // Merge with all predefined sizes so zeros show up
    final allCounts = <String, int>{
      for (final size in _kAllEntitySizes) size: counts[size] ?? 0,
      // also keep any extra keys not in predefined list
      for (final e in counts.entries)
        if (!_kAllEntitySizes.contains(e.key)) e.key: e.value,
    };

    final keys   = allCounts.keys.toList();
    final colors = _sizeColors(keys.length);
    final total  = allCounts.values.fold(0, (a, b) => a + b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend row
        Wrap(
          spacing: 20.w,
          runSpacing: 10.h,
          children: List.generate(keys.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10.sp, height: 10.sp,
                  decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
                ),
                SizedBox(width: 5.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(keys[i],                   style: TextStyle(fontSize: 9.sp,  color: _C.labelText, fontWeight: FontWeight.w400)),
                    Text('${allCounts[keys[i]]}',   style: TextStyle(fontSize: 12.sp, color: _C.labelText, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 16.h),
        // Stacked horizontal bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: SizedBox(
            height: 24.h,
            child: Row(
              children: List.generate(keys.length, (i) {
                // if all zeros give each equal flex so bar still renders
                final flex = total > 0 ? (allCounts[keys[i]] ?? 0) : 1;
                return Flexible(
                  flex: flex == 0 ? 0 : flex,
                  child: flex == 0
                      ? const SizedBox()
                      : Container(color: colors[i]),
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
      Color(0xFF388E3C),
      Color(0xFF66BB6A),
      Color(0xFFB2DFDB),
      Color(0xFFDCEDC8),
    ];
    return List.generate(count, (i) => palette[i % palette.length]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  INTERVIEW STAGE — stat rows (dot + bold% + label below) + pie chart
  //  Matches Figma exactly: percentage is large & bold, label smaller below it
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInterviewStageChart({
    required int passedPct,
    required int failedPct,
    required int withdrewPct,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // left — stat rows
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _interviewStatRow(_C.primary,      '$passedPct%',   'Passed'),
              SizedBox(height: 10.h),
              _interviewStatRow(_C.primaryLight, '$failedPct%',   'Failed'),
              SizedBox(height: 10.h),
              _interviewStatRow(const Color(0xFFB2DFCC), '$withdrewPct%', 'Candidate Withdrew'),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        // right — pie chart
        SizedBox(
          width: 110.w,
          height: 110.w,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: [passedPct.toDouble(), failedPct.toDouble(), withdrewPct.toDouble()],
              colors: [_C.primary, _C.primaryLight, const Color(0xFFDCEDC8)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _interviewStatRow(Color dotColor, String pct, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(color: _C.back, borderRadius: BorderRadius.circular(6.r)),
      child: Row(
        children: [
          Container(
            width: 10.sp, height: 10.sp,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pct,   style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
              Text(label, style: TextStyle(fontSize: 9.sp,  fontWeight: FontWeight.w400, color: _C.hintText)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LOCATION DISTRIBUTION — dual-tone vertical bars (Figma style)
  //  Full-height light bg, dark green fills from bottom proportionally
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLocationChart(Map<String, int> counts) {
    if (counts.isEmpty) return const SizedBox();
    final total    = counts.values.fold(0, (a, b) => a + b);
    const barH     = 120.0; // total bar height in logical pixels

    return SizedBox(
      height: 160.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: counts.entries.map((e) {
          final pct    = total > 0 ? (e.value / total * 100).round() : 0;
          final fillH  = (pct / 100) * barH;
          final emptyH = barH - fillH;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // full bar = light top + dark bottom
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // light (empty) portion on top
                        Container(height: emptyH.h, color: _C.barLight),
                        // dark (filled) portion on bottom
                        Container(height: fillH.h,  color: _C.primary),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text('$pct%', style: TextStyle(fontSize: 8.sp, color: _C.labelText, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2.h),
                  Text(e.key, style: TextStyle(fontSize: 7.sp, color: _C.hintText), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIE CHART PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  const _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
      // white divider lines between slices
      canvas.drawArc(rect, start, sweep, true, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.values != values || old.colors != colors;
}