import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/theme/app_theme.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';

const Color _kWebGreen = Color(0xFF2D8C4E);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(children: [
          AppNavbar(currentRoute: '/about'),
          _Placeholder(title: 'About Us'),
          const AppFooter(),
        ]),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(children: [
          AppNavbar(currentRoute: '/contact'),
          _Placeholder(title: 'Contact Us'),
          const AppFooter(),
        ]),
      ),
    );
  }
}

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(children: [
          AppNavbar(currentRoute: '/careers'),
          _Placeholder(title: 'Careers'),
          const AppFooter(),
        ]),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      padding: EdgeInsets.all(48.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
              fontSize: 40.sp,
              color: _kWebGreen,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Send the Figma design for this page and it will be built to match exactly.',
            style: AppTextStyles.font14BlackRegularCairo.copyWith(
              color: AppColors.secondaryBlack,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}