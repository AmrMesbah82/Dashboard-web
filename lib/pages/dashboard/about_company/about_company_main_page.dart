// ═══════════════════════════════════════════════════════════════════
// FILE 6: about_company_main_page.dart  (View Page) — UPDATED
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/about_company/AboutCompanyCubit.dart';
import 'package:web_app_admin/controller/about_company/about_company_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/about_company_model.dart';
import 'package:web_app_admin/pages/dashboard/about_company/about_comany_edit_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

import '../../../core/custom_svg.dart';
import '../../careers_main_dashboard.dart';
import '../job_list/job_listing_main_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

class AboutCompanyMainPage extends StatefulWidget {
  const AboutCompanyMainPage({super.key});

  @override
  State<AboutCompanyMainPage> createState() => _AboutCompanyMainPageState();
}

class _AboutCompanyMainPageState extends State<AboutCompanyMainPage> {
  final Map<String, bool> _open = {
    'company_info': true,
  };

  @override
  void initState() {
    super.initState();
    context.read<AboutCompanyCubit>().loadAboutCompany();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCompanyCubit, AboutCompanyState>(
      builder: (context, state) {
        if (state is AboutCompanyInitial || state is AboutCompanyLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        AboutCompanyModel? data;
        if (state is AboutCompanyLoaded) data = state.data;
        if (state is AboutCompanySaved) data = state.data;
        if (state is AboutCompanyError) data = state.lastData;

        // Fallback
        data ??= AboutCompanyModel.empty();

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
                    webPage:        const AboutCompanyMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),

                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 20.h),
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title Row ──────────────────────────────
                          Row(
                            children: [
                              Text(
                                'About Company',
                                style:
                                StyleText.fontSize45Weight600.copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),

                              // ── Edit button ────────────────────────
                              GestureDetector(
                                onTap: () {
                                  navigateTo(
                                      context, const AboutCompanyEditPage());
                                },
                                child: Container(
                                  width: 130.w, height: 36.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Center(
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text('Edit Details',
                                          style: StyleText.fontSize14Weight500
                                              .copyWith(color: _C.primary)),
                                      SizedBox(width: 6.w),
                                      CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                                          width: 20.w, height: 20.h,
                                          fit: BoxFit.scaleDown, color: _C.primary),
                                    ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Company Information Accordion ──────────
                          _accordion(
                            key: 'company_info',
                            title: 'Company Information',
                            children: [
                              _readOnlyCompanyInfoSection(data)
                            ],
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

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  // ── Read-only Company Info ─────────────────────────────────────────────────
  Widget _readOnlyCompanyInfoSection(AboutCompanyModel data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(6.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          _readField(
            'About This Position',
            data.aboutEn.isEmpty ? 'Text Here' : data.aboutEn,
          ),
          SizedBox(height: 16.h),
          _readFieldRtl(
            'عن هذا المنصب',
            data.aboutAr.isEmpty ? 'ادخل النص هنا' : data.aboutAr,
          ),
        ],
      ),
    );
  }

  // ── Read-only helpers ──────────────────────────────────────────────────────
  Widget _readField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: StyleText.fontSize12Weight500
              .copyWith(color: _C.labelText)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        height: 80.h,
        padding:
        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.topLeft,
        child: Text(
          value,
          style: StyleText.fontSize12Weight400
              .copyWith(color: _C.hintText),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ),
    ],
  );

  Widget _readFieldRtl(String label, String value) => Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: 80.h,
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.topRight,
          child: Text(
            value,
            style: StyleText.fontSize12Weight400
                .copyWith(color: _C.hintText),
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    ),
  );
}