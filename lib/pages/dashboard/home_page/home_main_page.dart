/// ******************* FILE INFO *******************
/// File Name: home_main_page_master.dart
/// Updated: AppNavbar now receives [onItemTap] so clicking a nav item in the
///          admin shell never routes to the public site.
/// Pages 1–3 — Read-only overview (Figma screens 1, 2, 3)
/// Sub-navbar: Main(active) | Home | Services | About Us | Contact Us | Careers
/// Status tabs: Published | Scheduled | Draft
/// Accordions: Headings, Navigation Button, Section 1-Left … Section 4-Right Corner

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_main_page_master.dart';
import 'package:web_app_admin/pages/dashboard/career_page/careers_main_page.dart';
import 'package:web_app_admin/pages/dashboard/contact_page/contact_us_main_page.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_preview_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../core/custom_svg.dart';
import '../../../repo/application/application_repo_imp.dart';
import '../../../repo/job_list/job_listing_repo_imp.dart';
import 'home_edit_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
}

// ─────────────────────────────────────────────────────────────────────────────
class HomeMainPageMaster extends StatefulWidget {
  const HomeMainPageMaster({super.key});
  @override
  State<HomeMainPageMaster> createState() => _HomeMainPageMasterState();
}

class _HomeMainPageMasterState extends State<HomeMainPageMaster> {
  int _subNavIndex = 1; // "Home" tab is active
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  int _statusIndex = 0;
  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  final Map<String, bool> _open = {
    'headings': true,
    'navBtn':   true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  Color _hexColor(String hex) {
    try {
      final c = hex.replaceAll('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  // ── Admin-aware navbar tap handler ────────────────────────────────────────
  // The AppNavbar routes are public paths (/, /services, /careers …).
  // We intercept them here and navigate to the correct admin pages instead.
  void _onNavbarItemTap(String publicRoute) {
    // 🔴 DEBUG
    print('🔴 _onNavbarItemTap called with: $publicRoute');

    switch (publicRoute) {
      case '/':
        context.go('/admin/dashboard');
      case '/services':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ServicesMainPageMaster()));
      case '/about':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (_) => AboutCubit()..load(),
                child: const AboutMainPageMasterDashboard())));
      case '/contact':
        context.go('/admin/contact-cms');
      case '/careers':
      // 🔴 DEBUG
        print('🔴 Navigating to CareersMainPage (admin)');
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (_) => CareersCmsCubit(
                  jobRepo: JobListingRepoImp(),
                  appRepo: ApplicationRepoImp(), // your application repo implementation
                )..load(),
                child: const CareersMainPageMaster())));
      default:
      // 🔴 DEBUG
        print('🔴 DEFAULT HIT — route was: $publicRoute');
        context.go('/admin/dashboard');
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }
        HomePageModel? data;
        if (state is HomeCmsLoaded) data = state.data;
        if (state is HomeCmsSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  AdminSubNavBar(
                    activeIndex: 1,
                    homeCubit: context.read<HomeCmsCubit>(),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 1000.w,
                    child: data == null
                        ? const Center(
                        child: CircularProgressIndicator(color: _C.primary))
                        : _body(data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
                break; // already here
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ServicesMainPageMaster()),
                );
              case 3:
                context.go('/admin/about-cms'); // ✅ use router — AboutCubit provided there
              case 4:
                context.go('/admin/contact-cms');
              case 5:
                context.go('/admin/careers-cms');
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  Widget _body(HomePageModel data) {
    final primary = _hexColor(data.branding.primaryColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview Screen button ────────────────────────────────────
        Row(
          children: [
            Text('Home',
              style: StyleText.fontSize45Weight600.copyWith(
                color: primary, fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomePreviewPageMaster()),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color:        primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Preview Screen',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Published / Scheduled / Draft tabs ──────────────────────────────
        Row(
          children: List.generate(_statusLabels.length, (i) {
            final active = _statusIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _statusIndex = i),
              child: Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: Text(_statusLabels[i],
                  style: active
                      ? StyleText.fontSize14Weight600.copyWith(
                    color:           primary,
                    decoration:      TextDecoration.underline,
                    decorationColor: primary,
                  )
                      : StyleText.fontSize14Weight400
                      .copyWith(color: _C.hintText),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 12.h),

        // ── Last Updated + Edit Home View ────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:        _C.cardBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text('Last Updated On 12 Jul 2026',
                style: StyleText.fontSize13Weight500.copyWith(color: primary),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomeEditPageMaster()),
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

        // // ── Headings ─────────────────────────────────────────────────────────
        // _accordion(key: 'headings', title: 'Headings', children: [
        //   Row(children: [
        //     Expanded(
        //       child: _readField('Title',
        //           data.title.en.isEmpty ? 'Text Here' : data.title.en),
        //     ),
        //     SizedBox(width: 16.w),
        //     Expanded(child: _readFieldRtl('العنوان', data.title.ar)),
        //   ]),
        //   SizedBox(height: 10.h),
        //   _readField('Short Description',
        //       data.shortDescription.en.isEmpty
        //           ? 'Text Here'
        //           : data.shortDescription.en,
        //       height: 72),
        //   SizedBox(height: 10.h),
        //   _readFieldRtl('وصف مختصر', data.shortDescription.ar, height: 72),
        // ]),
        // SizedBox(height: 10.h),

        // // ── Navigation Button ─────────────────────────────────────────────────
        // _accordion(key: 'navBtn', title: 'Navigation Button', children: [
        //   ...data.navButtons.asMap().entries.map((e) {
        //     final btn = e.value;
        //     return Padding(
        //       padding: EdgeInsets.only(bottom: 16.h),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text('${_ordinal(e.key + 1)} Button',
        //             style: StyleText.fontSize13Weight600
        //                 .copyWith(color: _C.labelText),
        //           ),
        //           SizedBox(height: 8.h),
        //           Row(children: [
        //             Expanded(
        //               child: _readField('Button Name',
        //                   btn.name.en.isEmpty ? 'Text Here' : btn.name.en),
        //             ),
        //             SizedBox(width: 16.w),
        //             Expanded(
        //                 child: _readFieldRtl('عنوان الزر', btn.name.ar)),
        //           ]),
        //           SizedBox(height: 8.h),
        //           _readField('Button Navigation',
        //               btn.route.isEmpty ? 'Services' : btn.route),
        //         ],
        //       ),
        //     );
        //   }),
        // ]),
        // SizedBox(height: 10.h),

        // ── Sections ─────────────────────────────────────────────────────────
        _accordion(
            key: 's1',
            title: 'Section 1 - Left',
            children: [

              SizedBox(height: 15.h),
              _sectionView(data, 0)]),
        SizedBox(height: 10.h),
        _accordion(
            key: 's2',
            title: 'Section 2 - Left Corner',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 1)]),
        SizedBox(height: 10.h),
        _accordion(
            key: 's3',
            title: 'Section 3 - Right',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 2)]),
        SizedBox(height: 10.h),
        _accordion(
            key: 's4',
            title: 'Section 4 - Right Corner',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 3)]),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _sectionView(HomePageModel data, int index) {
    final sec = index < data.sections.length ? data.sections[index] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Image',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgCircle(sec?.imageUrl ?? ''),
          ]),
          SizedBox(width: 24.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Icon',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgCircle(sec?.iconUrl ?? '', isAdd: true),
          ]),
        ]),
        SizedBox(height: 14.h),
        _readField('Description', sec?.description.en ?? 'Text Here',
            height: 80),
        SizedBox(height: 10.h),
        _readFieldRtl('الوصف', sec?.description.ar ?? '', height: 80),
      ],
    );
  }

  Widget _imgCircle(String url, {bool isAdd = false}) {
    return Container(
      width:  60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: url.isNotEmpty ? Colors.white : const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: url.isNotEmpty
          ? ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(
              url,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const SizedBox(),
            ),
          ))
          : Center(
          child: Icon(
            isAdd ? Icons.add : Icons.image_outlined,
            color: Colors.grey,
            size:  20.sp,
          )),
    );
  }

  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(

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
              child: Row(children: [
                Expanded(
                  child: Text(title,
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
              ]),
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

  Widget _readField(String label, String value,
      {double height = 36}) =>
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
              color:        AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment:
            height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(value,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText),
              maxLines: height > 36 ? 4 : 1,
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
                color:        AppColors.card,
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
                maxLines:      height > 36 ? 4 : 1,
                overflow:      TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}