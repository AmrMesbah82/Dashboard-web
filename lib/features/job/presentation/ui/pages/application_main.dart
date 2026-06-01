// ═══════════════════════════════════════════════════════════════════
// FILE: application_main.dart
// Path: lib/features/job/presentation/ui/pages/application_main.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/search.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/main_widgets/application_filter_dialog.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/application_model.dart';
import '../../controller/application_cubit.dart';
import '../../controller/application_state.dart';
import 'application_detail.dart';
import 'job_listing_main.dart';

part '../widgets/application_main/app_card.dart';
part '../widgets/application_main/app_table.dart';

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
//   static const Color border    = Color(0xFFE0E0E0);
// }

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
                  color: ColorPick.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: ColorPick.primary, size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                '$name\ndownload file success',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPick.primary,
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
              backgroundColor: ColorPick.background,
              body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
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
            backgroundColor: ColorPick.background,
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel: 'Applications',
                      homePage: CareersMainPageDashboard(),
                      webPage: MainMainPage(),
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
                                color: ColorPick.primary,
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
                                  color: ColorPick.primary,
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
                                      ? ColorPick.primary.withValues(alpha: 0.85)
                                      : ColorPick.primary,
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
                                    color: ColorPick.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Total Application:  $totalCount',
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.text),
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
                                  color: ColorPick.primary,
                                  image: 'assets/images/export.svg',
                                  widthImage: 14.sp,
                                  heightImage: 14.sp,
                                  colorBorder: ColorPick.primary,
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
                                  color: _isGridView ? ColorPick.primary : ColorPick.white,
                                  image: 'assets/images/grid.svg',
                                  widthImage: 16.sp,
                                  heightImage: 16.sp,
                                  colorBorder: Colors.transparent,
                                  svgColor: _isGridView ? Colors.white : AppColors.secondaryText,
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
                                  color: !_isGridView ? ColorPick.primary : ColorPick.white,
                                  image: 'assets/images/table.svg',
                                  widthImage: 16.sp,
                                  heightImage: 16.sp,
                                  colorBorder: Colors.transparent,
                                  svgColor: !_isGridView ? Colors.white : AppColors.secondaryText,
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
                                  child: Text('No applications found', style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText)),
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
            color: isActive ? ColorPick.primary : ColorPick.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != 'All') ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withValues(alpha: 0.3) : ColorPick.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('$count', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.white)),
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.text),
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
        color: ColorPick.white,
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
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
                SizedBox(height: 4.h),
                Text(details, style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ═════════════════════════════════════════════════════════════════════════════
//  APPLICATION CARD
// ═════════════════════════════════════════════════════════════════════════════
