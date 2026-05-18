// ******************* FILE INFO *******************
// File Name: admin_sub_navbar.dart
// Purpose: Shared sub-navbar used across ALL admin CMS pages.
//          Fix navigation in ONE place — no duplication.
//
// ✅ Logo: reads from HomeCmsCubit → branding.logoUrl (same as app_navbar).
//          Nothing shown until real URL arrives — no static placeholder flicker.
//
// Usage:
//   AdminSubNavBar(activeIndex: 0)
//
// Index map:
//   0 = Main  1 = Home  2 = Services  3 = About Us  4 = Contact Us  5 = Careers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/home_state.dart';
import '../../features/services/presentation/ui/pages/services_main/services_main.dart';
import '../theme/new_theme.dart';


class AdminSubNavBar extends StatelessWidget {
  final int activeIndex;
  final HomeCmsCubit? homeCubit;

  const AdminSubNavBar({
    super.key,
    required this.activeIndex,
    this.homeCubit,
  });

  static const Color _primary   = Color(0xFF008037);
  static const Color _cardBg    = Color(0xFFFFFFFF);
  static const Color _labelText = Color(0xFF333333);

  static const List<String> _labels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers',
  ];

  void _onTap(BuildContext context, int i) {
    if (i == activeIndex) return;

    // Services page is pushed via rootNavigator (outside GoRouter tree).
    // When navigating AWAY from Services, pop it first so it is cleanly
    // removed before GoRouter takes over, preventing the disposed-view crash.
    void goRoute(String location) {
      if (activeIndex == 2) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      context.go(location);
    }

    switch (i) {
      case 0: goRoute('/admin/dashboard');
      case 1: goRoute('/admin/home-page');
      case 2:
      // Services has no GoRouter route — push via rootNavigator and wrap
      // with InheritedGoRouter so context.go() works inside the pushed page.
        final router = GoRouter.of(context);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => _WithGoRouter(
              router: router,
              child: const ServicesMainPageMaster(),
            ),
          ),
        );
      case 3: goRoute('/admin/about-cms');
      case 4: goRoute('/admin/contact-cms');
      case 5: goRoute('/admin/careers-cms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000.w,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _AdminNavLogo(),
          SizedBox(width: 140.w),
          ...List.generate(_labels.length, (i) {
            final active = activeIndex == i;
            return GestureDetector(
              onTap: () => _onTap(context, i),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                child: Container(
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: active ? _primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _labels[i],
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: active ? Colors.white : _labelText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Re-injects the GoRouter instance into a subtree pushed outside the
//    GoRouter widget tree (via rootNavigator: true).
//
//    GoRouter.of(context) and context.go() both look for InheritedGoRouter
//    up the tree. Without it, they throw. Wrapping with InheritedGoRouter
//    (go_router's own exported InheritedWidget) restores that lookup so
//    all navigation calls inside ServicesMainPageMaster work normally.
class _WithGoRouter extends StatelessWidget {
  final GoRouter router;
  final Widget   child;

  const _WithGoRouter({required this.router, required this.child});

  @override
  Widget build(BuildContext context) {
    return InheritedGoRouter(goRouter: router, child: child);
  }
}

// ── Admin Nav Logo ─────────────────────────────────────────────────────────────
class _AdminNavLogo extends StatelessWidget {
  const _AdminNavLogo();

  @override
  Widget build(BuildContext context) {
    const double sz = 40;

    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _                          => '',
        };

        if (logoUrl.isEmpty) return SizedBox(width: sz.w, height: sz.w);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/admin/dashboard'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SvgPicture.network(
                  logoUrl,
                  width:  sz.w,
                  height: sz.w,
                  fit:    BoxFit.fill,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}