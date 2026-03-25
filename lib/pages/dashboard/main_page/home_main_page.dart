/// ******************* FILE INFO *******************
/// File Name: home_main_page.dart
/// Page 1 — "Main" read-only overview page (Figma screens 1 & 2)
/// UPDATED: "Edit Main" button now shows publish confirm dialog before
///          navigating. Saving overlay removed — dialog handles loading state.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/pages/home_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

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

class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});
  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage> {
  final Map<String, bool> _open = {
    'theme':  true,
    'header': true,
    'footer': true,
    'links':  true,
  };

  int _subNavIndex = 0;
  final List<String> _subNavItems = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  // ── Navigate to edit page ──────────────────────────────────────────────────
  void _goToEdit() => context.pushNamed('home_edit');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        HomePageModel? data;
        if (state is HomeCmsLoaded) data = state.data;
        if (state is HomeCmsSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [



                  AppAdminNavbar(
                    activeLabel:    'Home',
                    homePage:       CareersMainPageDashboard(),
                    webPage:        HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 0),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 20.h),
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title row ────────────────────────────────────
                          Row(
                            children: [
                              Text(
                                'Main',
                                style: StyleText.fontSize45Weight600.copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    context.pushNamed('home_preview'),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius:
                                    BorderRadius.circular(6.r),
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
                          SizedBox(height: 12.h),

                          // ── Last updated + Edit row ───────────────────────
                          Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  navigateTo(context, CareersMainPageDashboard());
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: _C.cardBg,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Last Updated On 12 Jul 2026',
                                    style: StyleText.fontSize13Weight500
                                        .copyWith(color: _C.primary),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // ── Edit Main button ────────────────────────
                              GestureDetector(
                                onTap: _goToEdit,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: _C.cardBg,
                                    borderRadius:
                                    BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Edit Main',
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(color: _C.primary),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(Icons.edit_outlined,
                                          size: 14.sp, color: _C.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Content ──────────────────────────────────────
                          if (data != null) ...[
                            _accordion(
                              key: 'theme',
                              title: 'Theme and Logo',
                              children: [_readOnlyLogoSection(data)],
                            ),
                            SizedBox(height: 10.h),

                            _accordion(
                              key: 'footer',
                              title: 'Footer',
                              children: [_readOnlyFooterSection(data)],
                            ),
                            SizedBox(height: 10.h),

                            _accordion(
                              key: 'links',
                              title: 'Links',
                              children: [_readOnlyLinksSection(data)],
                            ),
                          ] else ...[
                            const Center(
                                child: CircularProgressIndicator(
                                    color: _C.primary)),
                          ],

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

  // ── Read-only Logo / Theme section ─────────────────────────────────────────
  Widget _readOnlyLogoSection(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 15.h),
        Text('Logo',
            style: StyleText.fontSize12Weight500
                .copyWith(color: _C.labelText)),
        SizedBox(height: 8.h),
        Container(
          width: 70.w,
          height: 70.h,
          decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9), shape: BoxShape.circle),
          child: data.branding.logoUrl.isNotEmpty
              ? Center(
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: SvgPicture.network(
                  data.branding.logoUrl,
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) =>
                  const CircularProgressIndicator(
                      strokeWidth: 2),
                ),
              ),
            ),
          )
              : const Icon(Icons.image_outlined, color: Colors.grey),
        ),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(
              child: _colorReadField(
                  'Primary Color', data.branding.primaryColor)),
          SizedBox(width: 16.w),
          Expanded(
              child: _colorReadField(
                  'Secondary', data.branding.secondaryColor)),
        ]),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(
              child: _colorReadField('Background',
                  data.branding.backgroundColor.isNotEmpty
                      ? data.branding.backgroundColor
                      : '#D9D9D9')),
          SizedBox(width: 16.w),
          Expanded(
              child: _colorReadField('Header and Footer',
                  data.branding.headerFooterColor.isNotEmpty
                      ? data.branding.headerFooterColor
                      : '#D9D9D9')),
        ]),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(
              child: _readField(
                  'English Font',
                  data.branding.englishFont.isEmpty
                      ? 'Select Font'
                      : data.branding.englishFont)),
          SizedBox(width: 16.w),
          Expanded(
              child: _readField(
                  'Arabic Font',
                  data.branding.arabicFont.isEmpty
                      ? 'Select Font'
                      : data.branding.arabicFont)),
        ]),
      ],
    );
  }

  // ── Read-only Header section ───────────────────────────────────────────────
  Widget _readOnlyHeaderSection(HomePageModel data) {
    return Column(
      children: data.headerItems
          .map((item) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          children: [
            Icon(Icons.drag_indicator_rounded,
                size: 18.sp, color: _C.hintText),
            SizedBox(width: 8.w),
            Expanded(
                child: _readFieldWithStatus(
                    'Title', item.title.en, item.status)),
            SizedBox(width: 8.w),
            Expanded(
                child:
                _readFieldRtl('العنوان', item.title.ar)),
          ],
        ),
      ))
          .toList(),
    );
  }

  // ── Read-only Footer section ───────────────────────────────────────────────
  Widget _readOnlyFooterSection(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.footerColumns.asMap().entries.map((entry) {
        final i   = entry.key;
        final col = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),
            if (i > 0) ...[
              Divider(color: const Color(0xFFE8E8E8), height: 1),
              SizedBox(height: 12.h),
            ],
            Text(
              '${i + 1}${_ord(i + 1)} Column',
              style: StyleText.fontSize13Weight600
                  .copyWith(color: _C.labelText),
            ),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(
                  child: _readField('Group Title',
                      col.title.en.isEmpty ? 'Read Us' : col.title.en)),
              SizedBox(width: 16.w),
              Expanded(
                  child: _readFieldRtl(
                      'عنوان المجموعة', col.title.ar)),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(
                  child: _readField('Navigation',
                      col.route.isEmpty ? 'None' : col.route)),
              SizedBox(width: 10.w),
              const Expanded(child: SizedBox()),
            ]),
            SizedBox(height: 8.h),
            ...col.labels.map((lbl) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(children: [
                Expanded(
                    child: _readField(
                        'Navigation Label',
                        lbl.label.en.isEmpty
                            ? 'Text Here'
                            : lbl.label.en)),
                SizedBox(width: 8.w),
                Expanded(
                    child: _readFieldRtl(
                        'تسمية التنقل', lbl.label.ar)),
              ]),
            )),
            SizedBox(height: 8.h),
          ],
        );
      }).toList(),
    );
  }

  // ── Read-only Links section ────────────────────────────────────────────────
  Widget _readOnlyLinksSection(HomePageModel data) {
    final rows = (data.socialLinks.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child:
                  _readLinkItem(data.socialLinks[left], left)),
              SizedBox(width: 16.w),
              right < data.socialLinks.length
                  ? Expanded(
                  child: _readLinkItem(
                      data.socialLinks[right], right))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _readLinkItem(dynamic link, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        Text('Icon',
            style: StyleText.fontSize12Weight500
                .copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        Container(
          width: 60.w,
          height: 60.h,
          decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9), shape: BoxShape.circle),
          child: link.iconUrl.isNotEmpty
              ? Center(
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: SvgPicture.network(
                  link.iconUrl,
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) =>
                  const CircularProgressIndicator(
                      strokeWidth: 2),
                ),
              ),
            ),
          )
              : const Icon(Icons.add, color: Colors.grey, size: 20),
        ),
        SizedBox(height: 6.h),
        _readField('Insert Link',
            link.url.isEmpty ? 'Insert Links' : link.url),
      ],
    );
  }

  // ── Shared read-only field helpers ─────────────────────────────────────────
  Widget _readField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: StyleText.fontSize12Weight500
              .copyWith(color: _C.labelText)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: StyleText.fontSize12Weight400
              .copyWith(color: _C.hintText),
          overflow: TextOverflow.ellipsis,
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
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.centerRight,
          child: Text(
            value.isEmpty ? 'أدخل النص هنا' : value,
            style: StyleText.fontSize12Weight400
                .copyWith(color: _C.hintText),
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    ),
  );

  Widget _readFieldWithStatus(
      String label, String value, bool status) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: _C.labelText)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Status: ',
                    style: StyleText.fontSize11Weight400
                        .copyWith(color: _C.labelText)),
                Container(
                  width: 32.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: status
                        ? _C.primary
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Align(
                    alignment: status
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 14.w,
                      height: 14.h,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle),
                    ),
                  ),
                ),
              ]),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value.isEmpty ? 'Text Here' : value,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _colorReadField(String label, String hex) {
    Color color;
    try {
      final clean = hex.replaceAll('#', '');
      color = clean.length == 6
          ? Color(int.parse('FF$clean', radix: 16))
          : Colors.grey.shade300;
    } catch (_) {
      color = Colors.grey.shade300;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(children: [
            Container(
              width: 14.w,
              height: 14.h,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(
              hex.isEmpty ? '#D9D9D9' : hex,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText),
            ),
          ]),
        ),
      ],
    );
  }

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}