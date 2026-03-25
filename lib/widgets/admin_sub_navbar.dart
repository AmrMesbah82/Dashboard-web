// ******************* FILE INFO *******************
// File Name: admin_sub_navbar.dart
// Purpose: Shared sub-navbar used across ALL admin CMS pages.
//          Fix navigation in ONE place — no duplication.
//
// Usage:
//   // Pages that HAVE HomeCmsCubit in their BlocProvider tree
//   // (home_main_page.dart, home_main_page_master.dart):
//   AdminSubNavBar(
//     activeIndex: 0,
//     homeCubit: context.read<HomeCmsCubit>(),
//   )
//
//   // Pages that do NOT have HomeCmsCubit
//   // (about, contact, careers pages):
//   AdminSubNavBar(activeIndex: 3)
//   // → tapping "Home" from these pages goes to /admin/dashboard first,
//   //   from which the "Home" tab works correctly.
//
// Index map:
//   0 = Main
//   1 = Home
//   2 = Services
//   3 = About Us
//   4 = Contact Us
//   5 = Careers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/new_theme.dart';

class AdminSubNavBar extends StatelessWidget {
  final int activeIndex;

  /// Pass this from any page that already has [HomeCmsCubit] in its
  /// BlocProvider tree (e.g. home_main_page, home_main_page_master).
  /// Leave null from pages that don't (about, contact, careers) — tapping
  /// "Home" will fall back to /admin/dashboard where the cubit is available.
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
    if (i == activeIndex) return; // already here

    switch (i) {
      case 0:
        context.go('/admin/dashboard');

      case 1:
        context.go('/admin/home-page');


      case 2:
      // Services has no GoRouter entry yet — keep as Navigator push.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ServicesMainPageMaster(),
          ),
        );

      case 3:
        context.go('/admin/about-cms');

      case 4:
        context.go('/admin/contact-cms');

      case 5:
        context.go('/admin/careers-cms');
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_labels.length, (i) {
          final active = activeIndex == i;
          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 12.h,horizontal: 12.w),
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
      ),
    );
  }
}