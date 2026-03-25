// ******************* FILE INFO *******************
// File Name: about_main_page_master.dart
// Screen 1 — About Us CMS: Main view page
// Sub-tabs: About Us | Our Strategy | Terms of Service

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_preview_page.dart';
import 'package:web_app_admin/pages/dashboard/about_page/terms_page/terms_main_page.dart';
import 'package:web_app_admin/pages/dashboard/about_page/terms_page/terms_preview_page.dart';
import 'package:web_app_admin/pages/dashboard/career_page/careers_main_page.dart';
import 'package:web_app_admin/pages/dashboard/contact_page/contact_us_main_page.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../core/widget/svg_image.dart';
import '../../../repo/application/application_repo_imp.dart';
import '../../../repo/job_list/job_listing_repo_imp.dart';
import 'strategy_page/strategy_main_page.dart';
import 'strategy_page/strategy_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
}

// ─────────────────────────────────────────────────────────────────────────────
class AboutMainPageMasterDashboard extends StatefulWidget {
  const AboutMainPageMasterDashboard({super.key});

  @override
  State<AboutMainPageMasterDashboard> createState() =>
      _AboutMainPageMasterDashboardState();
}

class _AboutMainPageMasterDashboardState
    extends State<AboutMainPageMasterDashboard> {

  int _subNavIndex = 3;
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  int _tabIndex = 0;
  final List<String> _tabLabels = [
    'About Us',
    'Our Strategy',
    'Terms of Service',
  ];

  final Map<String, bool> _open = {
    'headings':        true,
    'navigationLabel': true,
    'vision':          true,
    'mission':         true,
    'values':          true,
  };

  // ── URL → bytes cache (avoids re-fetching on every rebuild) ──
  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  // ── Lifted cubits so Preview button can access them from any tab ──
  late final StrategyCubit _strategyCubit;
  late final TermsCubit    _termsCubit;

  @override
  void initState() {
    super.initState();
    _strategyCubit = StrategyCubit();
    _termsCubit    = TermsCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AboutCubit>().load();
    });
  }

  @override
  void dispose() {
    _strategyCubit.close();
    _termsCubit.close();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // XHR loaders
  // ══════════════════════════════════════════════════════════════════════════

  Future<Uint8List> _cachedLoad(String url, {bool isSvg = false}) {
    return _urlBytesCache.putIfAbsent(
      url,
          () => isSvg ? _loadSvg(url) : _loadImageBytes(url),
    );
  }

  Future<Uint8List> _loadImageBytes(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url, method: 'GET', responseType: 'arraybuffer',
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  Future<Uint8List> _loadSvg(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url, method: 'GET', responseType: 'arraybuffer',
        mimeType: 'image/svg+xml',
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  // ── Detect SVG from raw bytes ──
  bool _isSvgBytes(Uint8List b) {
    if (b.length < 5) return false;
    final header = String.fromCharCodes(
        b.sublist(0, b.length.clamp(0, 100))).trimLeft();
    return header.startsWith('<svg') || header.startsWith('<?xml');
  }

  // ── Render bytes auto-detecting SVG vs raster ──
  Widget _renderBytes(Uint8List b, {bool isSvg = false, BoxFit fit = BoxFit.cover}) {
    if (isSvg || _isSvgBytes(b)) {
      return SvgPicture.memory(b, fit: fit);
    }
    return Image.memory(b, fit: fit);
  }

  // ── Universal XHR image widget ─────────────────────────────────────────────
  Widget _networkImage({
    required String url,
    bool isSvg = false,
    BoxFit fit = BoxFit.cover,
    double iconSize = 24,
  }) {
    if (url.isEmpty) {
      return Icon(
        isSvg ? Icons.description_outlined : Icons.image_outlined,
        color: Colors.grey[500], size: iconSize.sp,
      );
    }

    return FutureBuilder<Uint8List>(
      future: _cachedLoad(url, isSvg: isSvg),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _C.primary),
            ),
          );
        }
        if (snapshot.hasData) {
          return _renderBytes(snapshot.data!, isSvg: isSvg, fit: fit);
        }
        // error fallback
        return Icon(
          isSvg ? Icons.description_outlined : Icons.broken_image,
          color: isSvg ? Colors.grey[400] : Colors.red[300],
          size: iconSize.sp,
        );
      },
    );
  }

  // ── Admin-aware navbar tap handler ────────────────────────────────────────
  void _onNavbarItemTap(String publicRoute) {
    switch (publicRoute) {
      case '/':
        context.go('/admin/dashboard');
      case '/services':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const ServicesMainPageMaster(),
        ));
      case '/about':
        break;
      case '/contact':
        context.go('/admin/contact-cms');
      case '/careers':
        context.go('/admin/careers-cms');
      default:
        context.go('/admin/dashboard');
    }
  }

  // ── Preview button handler — respects active tab ──────────────────────────
  void _onPreviewTap(AboutPageModel aboutModel) {
    switch (_tabIndex) {
    // ── Tab 0: About Us ──
      case 0:
        final cubit = context.read<AboutCubit>();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: AboutPreviewPageLast(model: aboutModel, imageUploads: const {}),
          ),
        ));

    // ── Tab 1: Our Strategy ──
      case 1:
        final strategyState = _strategyCubit.state;
        final OurStrategyModel? sm = switch (strategyState) {
          StrategyLoaded s => s.data,
          StrategySaved  s => s.data,
          _                => null,
        };
        if (sm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Strategy data not loaded yet.')),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _strategyCubit,
            child: StrategyPreviewPage(model: sm, imageUploads: const {}),
          ),
        ));

    // ── Tab 2: Terms of Service ──
      case 2:
        final termsState = _termsCubit.state;
        final TermsOfServiceModel? tm = switch (termsState) {
          TermsLoaded s => s.data,
          TermsSaved  s => s.data,
          _             => null,
        };
        if (tm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terms data not loaded yet.')),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _termsCubit,
            child: TermsPreviewPage(model: tm, imageUploads: const {}),
          ),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        if (state is AboutLoading || state is AboutInitial) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final AboutPageModel? model = switch (state) {
          AboutLoaded s => s.data,
          AboutSaved  s => s.data,
          _             => null,
        };

        if (model == null) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: Text('No data found')),
          );
        }

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 3),
                  SizedBox(height: 20.h),
                  SizedBox(width: 1000.w, child: _body(model)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Global sub-navbar ──────────────────────────────────────────────────────
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
              case 0: context.go('/admin/dashboard');
              case 1:
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<HomeCmsCubit>(),
                    child: const HomeMainPageMaster(),
                  ),
                ));
              case 2: break;
              case 3:
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => AboutCubit()..load(),
                    child: const AboutMainPageMasterDashboard(),
                  ),
                ));
              case 4: context.go('/admin/contact-cms');
              case 5:
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CareersCmsCubit(
            jobRepo: JobListingRepoImp(),
            appRepo: ApplicationRepoImp(), // your application repo implementation
            )..load(),
                    child: const CareersMainPageMaster(),
                  ),
                ));
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: active ? _C.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(_subNavLabels[i],
              style: StyleText.fontSize14Weight500.copyWith(
                color: active ? Colors.white : _C.labelText,
              ),
            ),
          ),
        );
      }),
    ),
  );

  // ── Page body ──────────────────────────────────────────────────────────────
  Widget _body(AboutPageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('About Us',
              style: StyleText.fontSize45Weight600.copyWith(
                  color: _C.primary, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => _onPreviewTap(model),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(6.r)),
              child: Text('Preview Screen',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: Colors.white)),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        // Sub-tabs
        Row(
          children: List.generate(_tabLabels.length, (i) {
            final active = _tabIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Padding(
                padding: EdgeInsets.only(right: 28.w),
                child: Text(_tabLabels[i],
                    style: active
                        ? StyleText.fontSize16Weight600.copyWith(
                        color: _C.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: _C.primary)
                        : StyleText.fontSize16Weight400
                        .copyWith(color: _C.hintText)),
              ),
            );
          }),
        ),
        SizedBox(height: 12.h),

        if (_tabIndex == 0) _aboutUsTab(model),
        if (_tabIndex == 1)
          BlocProvider.value(
            value: _strategyCubit,
            child: const StrategyMainView(),
          ),
        if (_tabIndex == 2)
          BlocProvider.value(
            value: _termsCubit,
            child: const TermsMainView(),
          ),

        SizedBox(height: 40.h),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0 — About Us
  // ══════════════════════════════════════════════════════════════════════════
  Widget _aboutUsTab(AboutPageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lastUpdatedRow(onEdit: () => navigateTo(context, AboutEditPageMaster())),
        SizedBox(height: 16.h),

        // ① Headings
        _accordion(
          key: 'headings',
          title: 'Headings',
          children: [

            SizedBox(height: 16.h),
            Row(children: [
              Expanded(child: _readField('Title',
                  model.title.en.isEmpty ? 'Text Here' : model.title.en)),
              SizedBox(width: 16.w),
              Expanded(child: _readFieldRtl('العنوان', model.title.ar)),
            ]),
          ],
        ),
        SizedBox(height: 12.h),



        // ③ Vision
        _accordion(
          key: 'vision',
          title: 'Vision',
          children: [
            _sectionReadView(
              iconUrl:   model.vision.iconUrl,
              svgUrl:    model.vision.svgUrl,
              subDescEn: model.vision.subDescription.en,
              subDescAr: model.vision.subDescription.ar,
              descEn:    model.vision.description.en,
              descAr:    model.vision.description.ar,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ④ Mission
        _accordion(
          key: 'mission',
          title: 'Mission',
          children: [
            _sectionReadView(
              iconUrl:   model.mission.iconUrl,
              svgUrl:    model.mission.svgUrl,
              subDescEn: model.mission.subDescription.en,
              subDescAr: model.mission.subDescription.ar,
              descEn:    model.mission.description.en,
              descAr:    model.mission.description.ar,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ⑤ Values
        _accordion(
          key: 'values',
          title: 'Values',
          children: [
            if (model.values.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text('No values yet.',
                      style: StyleText.fontSize13Weight400
                          .copyWith(color: _C.hintText)),
                ),
              )
            else
              _valuesGrid(model.values),
          ],
        ),
      ],
    );
  }

  // ── Section read view (Vision / Mission) ──────────────────────────────────
  Widget _sectionReadView({
    required String iconUrl, required String svgUrl,
    required String subDescEn, required String subDescAr,
    required String descEn,    required String descAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 16.h),

        Row(children: [
          _iconPreviewCircle(label: 'Icon', url: iconUrl),
          SizedBox(width: 24.w),
          _iconPreviewCircle(label: 'SVG', url: svgUrl, isSvg: true),
        ]),
        SizedBox(height: 16.h),
        _readField('Sub Description',
            subDescEn.isEmpty ? 'Text Here' : subDescEn, height: 80),
        SizedBox(height: 8.h),
        _readFieldRtl('وصف فرعي', subDescAr, height: 80),
        SizedBox(height: 10.h),
        _readField('Description', descEn.isEmpty ? 'Text Here' : descEn,
            height: 80),
        SizedBox(height: 8.h),
        _readFieldRtl('الوصف', descAr, height: 80),
      ],
    );
  }

  // ── Icon preview circle — now uses XHR loader ─────────────────────────────
  Widget _iconPreviewCircle({
    required String label,
    required String url,
    bool isSvg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        Container(
          width: 56.w, height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEEEEEE),

          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: _networkImage(
                url: url,
                isSvg: isSvg,
                fit: BoxFit.contain,
                iconSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Values grid (4 per row) ────────────────────────────────────────────────
  Widget _valuesGrid(List<AboutValueItem> items) {
    final rows = <List<AboutValueItem>>[];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }
    return Column(
      children: rows.map((row) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...row.map((item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _valueMiniCard(item),
              ),
            )),
            ...List.generate(
                4 - row.length, (_) => const Expanded(child: SizedBox())),
          ],
        ),
      )).toList(),
    );
  }

  // ── Value mini card — now uses XHR loader ─────────────────────────────────
  Widget _valueMiniCard(AboutValueItem item) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
          color: _C.sectionBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w, height: 28.w,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(6.r)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: _networkImage(
                url: item.iconUrl,
                isSvg: false,
                fit: BoxFit.contain,
                iconSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: StyleText.fontSize12Weight600
                .copyWith(color: const Color(0xFF1A1A1A)),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            item.shortDescription.en.isNotEmpty
                ? item.shortDescription.en
                : 'Short Description',
            style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryBlack, height: 1.5),
            maxLines: 3, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Last Updated + Edit Details ────────────────────────────────────────────
  Widget _lastUpdatedRow({required VoidCallback onEdit}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
          child: Text('Last Updated On 12 Jul 2026',
              style: StyleText.fontSize13Weight500.copyWith(color: _C.primary)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
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
          borderRadius: BorderRadius.circular(6.r)),
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
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp),
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

  // ── Read-only LTR ──────────────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity, height: height.h,
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r)),
            alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(value,
                style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
                maxLines: height > 36 ? 5 : 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // ── Read-only RTL ──────────────────────────────────────────────────────────
  Widget _readFieldRtl(String label, String value, {double height = 36}) =>
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
              width: double.infinity, height: height.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4.r)),
              alignment:
              height > 36 ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                  value.isEmpty ? 'أكتب هنا' : value,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText),
                  textDirection: TextDirection.rtl,
                  maxLines: height > 36 ? 5 : 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}