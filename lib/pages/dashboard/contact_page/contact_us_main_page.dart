// ******************* FILE INFO *******************
// File Name: contact_us_main_page.dart
// Purpose: Read-only overview page for Contact Us CMS
// Navigation: Main | Home | Services | About Us | Contact Us (active) | Careers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_main_page_master.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../core/custom_svg.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONTACT US MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsMainPage extends StatefulWidget {
  const ContactUsMainPage({super.key});

  @override
  State<ContactUsMainPage> createState() => _ContactUsMainPageState();
}

class _ContactUsMainPageState extends State<ContactUsMainPage> {
  int _subNavIndex = 4; // Contact Us is index 4
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  final Map<String, bool> _open = {
    'info': true,
    'followUs': true,
    'offices': true,
    'confirm': true,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
      builder: (context, state) {
        if (state is ContactUsCmsInitial || state is ContactUsCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        ContactUsCmsModel? data;
        if (state is ContactUsCmsLoaded) data = state.data;
        if (state is ContactUsCmsSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        //      AppNavbar(currentRoute: '/contact'),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 4),
                  SizedBox(height: 20.h),
                  Container(
                    width: 1000.w,
                    child: data == null
                        ? const Center(child: CircularProgressIndicator(color: _C.primary))
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

  // ── Sub-navbar ─────────────────────────────────────────────────────────────
  Widget _subNavBar() => Container(
    width: 1000.w,
    decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.r)),
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
                context.go('/admin/dashboard');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HomeCmsCubit>(),
                      child: const HomeMainPageMaster(),
                    ),
                  ),
                );
                break;
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
                    builder: (_) => const AboutMainPageMasterDashboard(),
                  ),
                );
              case 4:
                break; // already here
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

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body(ContactUsCmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview Screen ─────────────────────────────────────────
        Row(
          children: [
            Text(
              'Contact Us',
              style: StyleText.fontSize45Weight600.copyWith(
                color: _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/admin/contact-cms/preview'), // ✅ Use push instead of go
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Preview Screen',
                  style: StyleText.fontSize14Weight500.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Last Updated + Edit ────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'Last Updated On 12 Jul 2026',
                style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/admin/contact-cms/edit'), // ✅ Use push instead of go
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

        // ── Info Section ───────────────────────────────────────────────────
        _accordion(
          key: 'info',
          title: 'Info',
          children: [
            SizedBox(height: 15.h),
            _readField('Sub description', data.subDescription.en),
            SizedBox(height: 10.h),
            _readFieldRtl('وصف فرعي', data.subDescription.ar),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _readField('Email', data.email)),
                SizedBox(width: 16.w),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Follow Us Section ──────────────────────────────────────────────
        _accordion(
          key: 'followUs',
          title: 'Follow Us',
          children: [
            SizedBox(height: 15.h),
            if (data.socialIcons.isEmpty)
              Text('No social icons added',
                  style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText))
            else
              _socialIconsGrid(data.socialIcons),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Office Locations ───────────────────────────────────────────────
        _accordion(
          key: 'offices',
          title: 'Office Locations',
          children: [
            SizedBox(height: 15.h),
            if (data.officeLocations.isEmpty)
              Text('No office locations added',
                  style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText))
            else
              ...data.officeLocations.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _officeLocationItem(e.value, e.key),
                );
              }),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Confirm Message ────────────────────────────────────────────────
        _accordion(
          key: 'confirm',
          title: 'Confirm Message',
          children: [
            SizedBox(height: 15.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SVG', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                    SizedBox(height: 6.h),
                    _imgCircle(data.confirmMessage.svgUrl, isSvg: true),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _readField('Title', data.confirmMessage.title.en)),
                SizedBox(width: 16.w),
                Expanded(child: _readFieldRtl('العنوان', data.confirmMessage.title.ar)),
              ],
            ),
            SizedBox(height: 10.h),
            _readField('Description', data.confirmMessage.description.en, height: 80),
            SizedBox(height: 10.h),
            _readFieldRtl('الوصف', data.confirmMessage.description.ar, height: 80),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Social Icons Grid (2 per row) ──────────────────────────────────────────
  Widget _socialIconsGrid(List<ContactSocialIcon> icons) {
    final rows = (icons.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final left = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _socialIconItem(icons[left])),
              SizedBox(width: 16.w),
              right < icons.length
                  ? Expanded(child: _socialIconItem(icons[right]))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _socialIconItem(ContactSocialIcon icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        _imgCircle(icon.iconUrl),
        SizedBox(height: 8.h),
        _readField('Insert Link', icon.link.isEmpty ? 'Insert Links' : icon.link),
      ],
    );
  }

  // ── Office Location Item ───────────────────────────────────────────────────
  Widget _officeLocationItem(ContactOfficeLocation office, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location ${index + 1}',
          style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                SizedBox(height: 6.h),
                _imgCircle(office.iconUrl),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _readField('Location Name', office.locationName.en)),
            SizedBox(width: 16.w),
            Expanded(child: _readFieldRtl('اسم الموقع', office.locationName.ar)),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: _readField('Text', office.text1.en)),
            SizedBox(width: 16.w),
            Expanded(child: _readFieldRtl('النص', office.text1.ar)),
          ],
        ),
      ],
    );
  }

  // ── Image Circle ───────────────────────────────────────────────────────────
  Widget _imgCircle(String url, {bool isSvg = false}) {
    return Container(
      width: 60.w,
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
        ),
      )
          : Center(
        child: Icon(
          isSvg ? Icons.description_outlined : Icons.image_outlined,
          color: Colors.grey,
          size: 20.sp,
        ),
      ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
              children: children,
            ),
        ],
      ),
    );
  }

  // ── Read Field ─────────────────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(label, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        height: height.h,
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: height > 36 ? 8.h : 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
        child: Text(
          value.isEmpty ? 'Text Here' : value,
          style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
          maxLines: height > 36 ? 4 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _readFieldRtl(String label, String value, {double height = 36}) => Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: height.h,
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: height > 36 ? 8.h : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: height > 36 ? Alignment.topRight : Alignment.centerRight,
          child: Text(
            value.isEmpty ? 'أكتب هنا' : value,
            style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
            textDirection: TextDirection.rtl,
            maxLines: height > 36 ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}