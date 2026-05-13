// ******************* FILE INFO *******************
// File Name: admin_sub_navbar.dart
// Purpose: Shared sub-navbar used across ALL admin CMS pages.
//          Fix navigation in ONE place — no duplication.
//
// ✅ Logo: reads from HomeCmsCubit → branding.logoUrl (same as app_navbar).
//          Nothing shown until real URL arrives — no static placeholder flicker.
//
// Usage:
//   // Pages that HAVE HomeCmsCubit in their BlocProvider tree
//   AdminSubNavBar(activeIndex: 0, homeCubit: context.read<HomeCmsCubit>())
//
//   // Pages that do NOT have HomeCmsCubit
//   AdminSubNavBar(activeIndex: 3)
//
// Index map:
//   0 = Main  1 = Home  2 = Services  3 = About Us  4 = Contact Us  5 = Careers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/new_theme.dart';

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

    switch (i) {
      case 0: context.go('/admin/dashboard');
      case 1: context.go('/admin/home-page');
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServicesMainPageMaster()),
        );
      case 3: context.go('/admin/about-cms');
      case 4: context.go('/admin/contact-cms');
      case 5: context.go('/admin/careers-cms');
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
        mainAxisAlignment: MainAxisAlignment.start, // logo anchors to start
        children: [
          // ── Logo ──────────────────────────────────────────────────────────
          _AdminNavLogo(),

          SizedBox(width: 140.w),

          // ── Tab buttons ───────────────────────────────────────────────────
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

// ── Admin Nav Logo ─────────────────────────────────────────────────────────────
// Mirrors _BayanatzLogo from app_navbar.dart exactly:
//   • Reads logoUrl from HomeCmsCubit state.
//   • Shows an empty SizedBox (transparent) until the URL is available.
//   • No static asset placeholder — no flicker.

class _AdminNavLogo extends StatelessWidget {
  const _AdminNavLogo();

  @override
  Widget build(BuildContext context) {
    const double sz = 40; // fixed px — no ScreenUtil needed for a square logo

    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _                          => '',
        };

        // Nothing shown until we have a real URL — no static flicker.
        if (logoUrl.isEmpty) {
          return SizedBox(width: sz.w, height: sz.w);
        }

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
                  // No placeholderBuilder — renders nothing until SVG is ready.
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}