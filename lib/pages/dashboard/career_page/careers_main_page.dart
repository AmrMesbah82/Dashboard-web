// ******************* FILE INFO *******************
// File Name: careers_main_page.dart
// Updated: AppNavbar now receives [onItemTap] so clicking a nav item in the
//          admin shell never routes to the public site.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_main_page_master.dart';
import 'package:web_app_admin/pages/dashboard/contact_page/contact_us_main_page.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../core/custom_svg.dart';

// ── Local palette ─────────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class CareersMainPageMaster extends StatefulWidget {
  const CareersMainPageMaster({super.key});

  @override
  State<CareersMainPageMaster> createState() => _CareersMainPageMasterState();
}

class _CareersMainPageMasterState extends State<CareersMainPageMaster> {
  // sub-nav — Careers is index 5
  int _subNavIndex = 5;
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  // accordion open/close state
  final Map<String, bool> _open = {
    'overview':   true,
    'statistics': true,
  };

  // tabs inside Careers sub-navigation
  int _careersTab = 0;
  final List<String> _careersTabLabels = [
    'Main', 'Why Join Our Team', 'Our Interns', 'Our Teams'
  ];



  // ── Admin-aware navbar tap handler ────────────────────────────────────────
  // The AppNavbar routes are public paths (/, /services, /careers …).
  // We intercept them here and navigate to the correct admin pages instead.
  void _onNavbarItemTap(String publicRoute) {
    switch (publicRoute) {
      case '/':
      // "Home" logo tap → go to admin dashboard root
        context.go('/admin/dashboard');
      case '/services':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ServicesMainPageMaster(),
          ),
        );
      case '/about':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AboutMainPageMasterDashboard(),
          ),
        );
      case '/contact':
        context.go('/admin/contact-cms');
      case '/careers':
      // Already here — do nothing
        break;
      default:
      // Fallback: just go to admin dashboard
        context.go('/admin/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersCmsCubit, CareersCmsState>(
      builder: (context, state) {
        if (state is CareersCmsInitial || state is CareersCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        CareersCmsModel? data;
        if (state is CareersCmsLoaded) data = state.data;
        if (state is CareersCmsSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _C.sectionBg,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 5),
                  SizedBox(height: 20.h),

                  // ── Careers sub-tabs (Main | Why Join …) ──────────────────
                  Container(
                    width: 1000.w,
                    decoration: BoxDecoration(
                   //   color:        _C.cardBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      children: List.generate(_careersTabLabels.length, (i) {
                        final active = _careersTab == i;
                        return GestureDetector(
                          onTap: () => setState(() => _careersTab = i),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: active
                                      ? _C.primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: Text(
                              _careersTabLabels[i],
                              style: StyleText.fontSize13Weight500.copyWith(
                                color:      active ? _C.primary : _C.labelText,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Main tab body ──────────────────────────────────────────
                  if (_careersTab == 0)
                    Container(
                      width: 1000.w,
                      child: data == null
                          ? const Center(
                          child: CircularProgressIndicator(
                              color: _C.primary))
                          : _mainBody(data),
                    ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Global sub-navbar (Main / Home / Services …) ──────────────────────────
  Widget _subNavBar() => Container(
    width: 1000.w,
    decoration: BoxDecoration(
        color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_subNavLabels.length, (i) {
        final active = _subNavIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => _subNavIndex = i);
            switch (i) {
              case 0:
                context.go('/admin/dashboard');
              case 1:
              // Already here — refresh
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HomeCmsCubit>(),
                      child: const HomeMainPageMaster(),
                    ),
                  ),
                );
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ServicesMainPageMaster()),
                );
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AboutCubit()..load(),
                      child: const AboutMainPageMasterDashboard(),
                    ),
                  ),
                );
              case 4:
                context.go('/admin/contact-cms');
              case 5:
                break; // already here
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:        active ? _C.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              _subNavLabels[i],
              style: StyleText.fontSize14Weight500.copyWith(
                color: active ? Colors.white : _C.labelText,
              ),
            ),
          ),
        );
      }),
    ),
  );

  // ── Main body ──────────────────────────────────────────────────────────────
  Widget _mainBody(CareersCmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Preview Screen
        Row(
          children: [
            Text(
              'Careers',
              style: StyleText.fontSize45Weight600.copyWith(
                color:      _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.pushNamed('careers-cms-preview'),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color:        _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Preview Screen',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Last updated + Edit Details
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:        _C.cardBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                data.lastUpdated != null
                    ? 'Last Updated On ${_formatDate(data.lastUpdated!)}'
                    : 'Last Updated On —',
                style: StyleText.fontSize13Weight500
                    .copyWith(color: _C.primary),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.pushNamed('careers-cms-edit'),
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

        // ── Careers Overview accordion ─────────────────────────────────────
        _accordion(
          key:   'overview',
          title: 'Careers Overview',
          children: [
            _readField('Description', data.overview.description.en,
                height: 80),
            SizedBox(height: 10.h),
            _readFieldRtl('الوصف', data.overview.description.ar,
                height: 80),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _readField(
                      'Action Button',
                      data.overview.actionButtonLabel.en.isEmpty
                          ? 'Text Here'
                          : data.overview.actionButtonLabel.en),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _readFieldRtl(
                      'زر الإجراء',
                      data.overview.actionButtonLabel.ar.isEmpty
                          ? 'أدخل النص'
                          : data.overview.actionButtonLabel.ar),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Career Statistics accordion ────────────────────────────────────
        _accordion(
          key:   'statistics',
          title: 'Career Statistics',
          children: [
            if (data.statistics.isEmpty)
              Text(
                'No statistics added yet.',
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.hintText),
              )
            else
              ...data.statistics.asMap().entries.map((e) {
                final i    = e.key;
                final stat = e.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i > 0) ...[
                      Divider(
                          color: const Color(0xFFE8E8E8), height: 1),
                      SizedBox(height: 12.h),
                    ],
                    Text(
                      '${_ordLabel(i + 1)} Statistics',
                      style: StyleText.fontSize13Weight600
                          .copyWith(color: _C.labelText),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                            child: _readField('Title', stat.title.en)),
                        SizedBox(width: 16.w),
                        Expanded(
                            child: _readFieldRtl(
                                'العنوان', stat.title.ar)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _readField('Short Description',
                        stat.shortDescription.en, height: 60),
                    SizedBox(height: 8.h),
                    _readFieldRtl('وصف مختصر',
                        stat.shortDescription.ar, height: 60),
                    SizedBox(height: 12.h),
                  ],
                );
              }),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
        color:        _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
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
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  // ── Read-only field helpers ─────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: _C.labelText)),
          SizedBox(height: 4.h),
          Container(
            width:  double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical:   height > 36 ? 8.h : 0,
            ),
            decoration: BoxDecoration(
              color:        AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment:
            height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              value.isEmpty ? 'Text Here' : value,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText),
              maxLines: height > 36 ? 5 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _readFieldRtl(String label, String value,
      {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 4.h),
            Container(
              width:  double.infinity,
              height: height.h,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical:   height > 36 ? 8.h : 0,
              ),
              decoration: BoxDecoration(
                color:        AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment: height > 36
                  ? Alignment.topRight
                  : Alignment.centerRight,
              child: Text(
                value.isEmpty ? 'أكتب هنا' : value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.hintText),
                textDirection: TextDirection.rtl,
                maxLines:      height > 36 ? 5 : 1,
                overflow:      TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _ordLabel(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_monthName(dt.month)} ${dt.year}';

  String _monthName(int m) => const [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}