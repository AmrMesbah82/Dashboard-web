// ═══════════════════════════════════════════════════════════════════
// FILE: application_main_page.dart
// Path: lib/pages/dashboard/application/application_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web_app_admin/controller/application/application_cubit.dart';
import 'package:web_app_admin/controller/application/application_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  PDF DOWNLOAD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _downloadPdf(ApplicationModel app) async {
    try {
      final pdf = pw.Document();

      final dateStr = app.applicationDate != null
          ? '${app.applicationDate!.day}/${app.applicationDate!.month}/${app.applicationDate!.year}'
          : 'N/A';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) => [
            // ── Header ──
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#008037'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Application Details',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ── Personal Information ──
            _pdfSection('Personal Information', [
              _pdfRow('Full Name', app.fullName),
              _pdfRow('Email', app.email),
              _pdfRow('Phone', '${app.countryCode}${app.phone}'),
              _pdfRow('Year of Graduation', app.yearOfGraduation),
            ]),
            pw.SizedBox(height: 16),

            // ── Job Information ──
            _pdfSection('Job Information', [
              _pdfRow('Job Title', app.jobTitle),
              _pdfRow('Department', app.department),
              _pdfRow('Work Type', app.workType),
              _pdfRow('Employment Type', app.employmentType),
              _pdfRow('Employment Duration', app.employmentDuration),
              _pdfRow('Location', app.jobLocation),
              _pdfRow('Experience Level', app.experienceLevel),
              _pdfRow('Salary Range', app.salaryRange.isNotEmpty ? '${app.salaryRange} ${app.currency}' : 'N/A'),
            ]),
            pw.SizedBox(height: 16),

            // ── Requirements ──
            _pdfSection('Requirements', [
              _pdfRow('Required Qualification', app.requiredQualification),
              _pdfRow('Required Skills', app.requiredSkills),
            ]),
            pw.SizedBox(height: 16),

            // ── Application Status ──
            _pdfSection('Application Status', [
              _pdfRow('Status', app.status.label),
              _pdfRow('Tag', app.tag.isNotEmpty ? app.tag : 'N/A'),
              _pdfRow('Application Date', dateStr),
            ]),
            pw.SizedBox(height: 16),

            // ── Scoring (Interview) ──
            _pdfSection('Interview Scoring', [
              _pdfRow('Technical Skills', '${app.technicalSkills}/10'),
              _pdfRow('Communication Skills', '${app.communicationSkills}/10'),
              _pdfRow('Experience & Background', '${app.experienceBackground}/10'),
              _pdfRow('Culture Fit', '${app.cultureFit}/10'),
              _pdfRow('Leadership Potential', '${app.leadershipPotential}/10'),
              _pdfRow('Comments', app.comments.isNotEmpty ? app.comments : 'N/A'),
            ]),
            pw.SizedBox(height: 16),

            // ── Documents / Links ──
            _pdfSection('Documents', [
              _pdfRow('Resume', app.resumeUrl.isNotEmpty ? app.resumeUrl : 'Not uploaded'),
              _pdfRow('Resume File Name', app.resumeName.isNotEmpty ? app.resumeName : 'N/A'),
              _pdfRow('Cover Letter', app.coverLetterUrl.isNotEmpty ? app.coverLetterUrl : 'Not uploaded'),
              _pdfRow('Cover Letter File Name', app.coverLetterName.isNotEmpty ? app.coverLetterName : 'N/A'),
            ]),
          ],
        ),
      );

      final Uint8List bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${app.fullName.replaceAll(' ', '_')}_application.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      // Show success dialog
      if (mounted) {
        _showDownloadSuccessDialog(app.fullName);
      }
    } catch (e) {
      print('🔴 [ApplicationMainPage] _downloadPdf ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── PDF helper: Section ──
  pw.Widget _pdfSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#E8F5E9'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#008037'),
            ),
          ),
        ),
        ...rows,
      ],
    );
  }

  // ── PDF helper: Row ──
  pw.Widget _pdfRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? 'N/A' : value,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  // ── Success Dialog ──
  void _showDownloadSuccessDialog(String name) {
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
                width: 64.sp,
                height: 64.sp,
                decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: _C.primary, size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                '$name\ndownload file success',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _C.labelText,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
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
          String activeJobTitle = 'All';
          Map<String, int> jobTitleCounts = {};
          int totalCount = 0;
          int appliedQualified = 0, appliedUnqualified = 0;
          int interviewPassed = 0, interviewWithdrew = 0, interviewFailed = 0;
          int offerApproved = 0, offerPending = 0, offerRejected = 0;
          int hiredCompleted = 0;

          if (state is ApplicationLoaded) {
            apps = state.filteredApps;
            activeJobTitle = state.activeJobTitleFilter;
            jobTitleCounts = state.jobTitleCounts;
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

                            // ── Job Title filter tabs (was Department) ──
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterTab('All', apps.length, activeJobTitle == 'All', () => cubit.setJobTitleFilter('All')),
                                  ...jobTitleCounts.entries.map((e) =>
                                      _filterTab(e.key, e.value, activeJobTitle == e.key, () => cubit.setJobTitleFilter(e.key))),
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
                                      cubit.setFilter(result);
                                    }
                                  },
                                  width: 100.w,
                                  height: 36.h,
                                  radius: 6,
                                  color: _activeFilter != null && !_activeFilter!.isEmpty
                                      ? _C.primary.withOpacity(0.85)
                                      : _C.primary,
                                  textColor: Colors.white,
                                  textStyle: StyleText.fontSize13Weight600.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

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

                            // ── Summary cards with SVG icons ──
                            Row(
                              children: [
                                Expanded(child: _summaryCard(
                                  'Applied',
                                  'Qualified: $appliedQualified  Unqualified: $appliedUnqualified',
                                  'assets/images/job_list/applied.svg',
                                )),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard(
                                  'Interview',
                                  'Passed: $interviewPassed  Withdrew: $interviewWithdrew  Failed: $interviewFailed',
                                  'assets/images/job_list/interview.svg',
                                )),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard(
                                  'Offer',
                                  'Approved: $offerApproved  Pending: $offerPending  Rejected: $offerRejected',
                                  'assets/images/job_list/offer.svg',
                                )),
                                SizedBox(width: 10.w),
                                Expanded(child: _summaryCard(
                                  'Hired',
                                  'Completed: $hiredCompleted',
                                  'assets/images/job_list/hired.svg',
                                )),
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

  // ── Summary Card with SVG icon ─────────────────────────────────────────────
  Widget _summaryCard(String title, String details, String svgPath) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Color(0xFFF1F2ED),
              shape: BoxShape.circle
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 16.sp,
                height: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
                SizedBox(height: 4.h),
                Text(details, style: TextStyle(fontSize: 10.sp, color: _C.hintText)),
              ],
            ),
          ),
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
                      onDownload: () => _downloadPdf(apps[i]),
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
  Widget _buildTable(List<ApplicationModel> apps) {
    final headers = [
      'No', 'Candidate', 'Email', 'Phone', 'Department',
      'Job Title', 'Work Type', 'Location', 'Employment Type',
      'Experience Level', 'Salary Range', 'Application Date', 'Status', 'Download',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0:  FixedColumnWidth(50.sp),
      1:  FixedColumnWidth(140.sp),
      2:  FixedColumnWidth(200.sp),
      3:  FixedColumnWidth(150.sp),
      4:  FixedColumnWidth(120.sp),
      5:  FixedColumnWidth(150.sp),
      6:  FixedColumnWidth(100.sp),
      7:  FixedColumnWidth(120.sp),
      8:  FixedColumnWidth(130.sp),
      9:  FixedColumnWidth(120.sp),
      10: FixedColumnWidth(120.sp),
      11: FixedColumnWidth(110.sp),
      12: FixedColumnWidth(110.sp),
      13: FixedColumnWidth(90.sp),
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

                // ── Download cell ──
                cell(
                  InkWell(
                    onTap: () => _downloadPdf(a),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, size: 12.sp, color: Colors.white),
                          SizedBox(width: 2.w),
                          Text('PDF', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ];

              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: List.generate(cells.length, (ci) {
                  // Make all cells except Download clickable to navigate
                  if (ci < cells.length - 1) {
                    return InkWell(
                      onTap: () => navigateTo(context, ApplicationDetailPage(jobId: a.jobId, appId: a.id)),
                      child: cells[ci],
                    );
                  }
                  return cells[ci];
                }),
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
  final VoidCallback? onDownload;
  const _AppCard({required this.app, this.onTap, this.onDownload});

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
                  onTap: onDownload,
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

            // ── Job Title (was Department) ──
            Row(
              children: [
                BlocBuilder<HomeCmsCubit, HomeCmsState>(
                  builder: (context, cmsState) {
                    final String logoUrl = switch (cmsState) {
                      HomeCmsLoaded(:final data) => data.branding.logoUrl,
                      HomeCmsSaved(:final data)  => data.branding.logoUrl,
                      _                          => '',
                    };

                    if (logoUrl.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: SvgPicture.network(
                          logoUrl,
                          width: 18.sp,
                          height: 18.sp,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => Icon(
                            Icons.work_outline_rounded,
                            size: 18.sp,
                            color: _C.primary,
                          ),
                        ),
                      );
                    }

                    return Icon(
                      Icons.work_outline_rounded,
                      size: 18.sp,
                      color: _C.primary,
                    );
                  },
                ),                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle.isEmpty ? 'Untitled Job' : app.jobTitle,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _C.labelText),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Job Title', style: TextStyle(fontSize: 10.sp, color: _C.hintText)),
                    ],
                  ),
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