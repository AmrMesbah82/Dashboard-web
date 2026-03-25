/// ******************* FILE INFO *******************
/// File Name: home_preview_page.dart
/// Page 7 — "Preview Home Details" (Figma screen 7)
/// Desktop / Tablet / Mobile tabs + ENG/AR chips
/// "Home View" accordion with real HomePage content (hero + cards only, NO navbar/footer)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';
import 'package:web_app_admin/pages/home_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
}

enum _Device { desktop, tablet, mobile }

// ─────────────────────────────────────────────────────────────────────────────
class HomePreviewPageMaster extends StatefulWidget {
  const HomePreviewPageMaster({super.key});
  @override
  State<HomePreviewPageMaster> createState() => _HomePreviewPageMasterState();
}

class _HomePreviewPageMasterState extends State<HomePreviewPageMaster> {
  _Device _device   = _Device.desktop;
  bool    _isAr     = false;
  bool    _isSaving = false;
  bool    _homeViewOpen = true;

  Future<void> _publish(HomeCmsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save(publishStatus: 'published');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        if (state is HomeCmsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Published!',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is HomeCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final cubit = context.read<HomeCmsCubit>();

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
          backgroundColor: _C.sectionBg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                AdminSubNavBar(
                  activeIndex: 1,
                  homeCubit: context.read<HomeCmsCubit>(),
                ),
            
                // ── Scrollable content ──────────────────────────────────────
                Container(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page title ────────────────────────────────────────
                      Text('Preview Home Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary, fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 14.h),
                                  
                      // ── Device tabs + ENG/AR chips row ───────────────────
                      Row(
                        children: [
                          // Device tabs
                          ...[_Device.desktop, _Device.tablet, _Device.mobile].map((d) {
                            final active = _device == d;
                            final label  = d.name[0].toUpperCase() + d.name.substring(1);
                            return GestureDetector(
                              onTap: () => setState(() => _device = d),
                              child: Padding(
                                padding: EdgeInsets.only(right: 20.w),
                                child: Text(label,
                                  style: active
                                      ? StyleText.fontSize14Weight600.copyWith(
                                    color: _C.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _C.primary,
                                  )
                                      : StyleText.fontSize14Weight400.copyWith(color: _C.hintText),
                                ),
                              ),
                            );
                          }),
                          const Spacer(),
                          // ENG chip
                          _langChip('ENG', active: !_isAr, onTap: () => setState(() => _isAr = false)),
                          SizedBox(width: 6.w),
                          // AR chip
                          _langChip('AR',  active: _isAr,  onTap: () => setState(() => _isAr = true)),
                        ],
                      ),
                      SizedBox(height: 16.h),
                                  
                      // ── Home View accordion ───────────────────────────────
                      _homeViewAccordion(data),
                                  
                      SizedBox(height: 24.h),
                                  
                      // ── Bottom buttons ────────────────────────────────────
                      Row(children: [
                        // Back
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: Text('Back',
                                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Publish
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSaving ? null : () => _publish(cubit),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _isSaving ? _C.primary.withOpacity(0.5) : _C.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: _isSaving
                                    ? SizedBox(width: 18.w, height: 18.h,
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text('Publish',
                                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Language chip ──────────────────────────────────────────────────────────
  Widget _langChip(String label, {required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? _C.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: active ? _C.primary : _C.border),
        ),
        child: Text(label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: active ? Colors.white : _C.labelText,
          ),
        ),
      ),
    );
  }

  // ── Home View accordion ────────────────────────────────────────────────────
  Widget _homeViewAccordion(HomePageModel? data) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accordion header
          GestureDetector(
            onTap: () => setState(() => _homeViewOpen = !_homeViewOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _homeViewOpen
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(child: Text('Home View',
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
                )),
                Icon(
                  _homeViewOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp,
                ),
              ]),
            ),
          ),

          // Preview frame
          if (_homeViewOpen)
            _previewFrame(data),
        ],
      ),
    );
  }

  // ── Preview frame (scaled real widgets) ───────────────────────────────────
  Widget _previewFrame(HomePageModel? data) {
    // Virtual screen size the real widgets think they're on
    final double fakeW = switch (_device) {
      _Device.desktop => 1366,
      _Device.tablet  =>  1024,
      _Device.mobile  =>  375,
    };
    final double fakeH = switch (_device) {
      _Device.desktop => 768,
      _Device.tablet  => 768,
      _Device.mobile  => 812,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availW = constraints.maxWidth;
        final double scale  = availW / fakeW;
        final double scaledH = fakeH * scale;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _C.border),
              borderRadius: BorderRadius.circular(6.r),
            ),
            // Outer box is the SCALED size
            child: SizedBox(
              width:  availW,
              height: scaledH,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth:  fakeW,
                maxWidth:  fakeW,
                minHeight: fakeH,
                maxHeight: fakeH,
                child: Transform.scale(
                  scale:     scale,
                  alignment: Alignment.topLeft,
                  // ScreenUtilInit resets .w/.sp/.h relative to fakeW×fakeH
                  child: ScreenUtilInit(
                    designSize: Size(fakeW, fakeH),
                    minTextAdapt: true,
                    splitScreenMode: false,
                    builder: (_, __) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(fakeW, fakeH),
                      ),
                      child: SizedBox(
                        width:  fakeW,
                        height: fakeH,
                        child: BlocProvider<LanguageCubit>(
                          create: (_) {
                            final cubit = LanguageCubit();
                            // Set language to match _isAr
                            if (cubit.state.isArabic != _isAr) {
                              cubit.setLanguage(_isAr ? 'ar' : 'en');
                            }
                            return cubit;
                          },
                          child: Container(
                            color: AppColors.background,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Use the actual HomePage widget's body content
                                  // We'll render it directly here
                                  _buildActualHomeContent(data ?? _emptyHomePageModel()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper to create an empty model if needed
  HomePageModel _emptyHomePageModel() {
    return HomePageModel(
      title: BiText(en: '', ar: ''),
      shortDescription: BiText(en: '', ar: ''),
      branding: BrandingModel(
        logoUrl: '',
        primaryColor: '#008037',
      ),
      sections: [],
      navButtons: [],
      footerColumns: [],
      socialLinks: [],
    );
  }

  // Build the actual home page content (hero + cards)
  Widget _buildActualHomeContent(HomePageModel data) {
    return Builder(
      builder: (context) {
        final double w = MediaQuery.of(context).size.width;
        final isAr = context.read<LanguageCubit>().state.isArabic;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section - exact copy from home_page.dart
            _buildHeroSection(data, w, isAr),
            // Hero Cards Section - exact copy from home_page.dart
            _buildHeroCardsSection(data, w, isAr),
            SizedBox(height: 32.h),
          ],
        );
      },
    );
  }

  Widget _buildHeroSection(HomePageModel data, double w, bool isAr) {
    final Color primary = _hexColor(data.branding.primaryColor);
    final bool isMobile = w < 600.w;

    final String titleText = isAr
        ? (data.title.ar.isNotEmpty ? data.title.ar : data.title.en)
        : data.title.en;
    final String descText = isAr
        ? (data.shortDescription.ar.isNotEmpty ? data.shortDescription.ar : data.shortDescription.en)
        : data.shortDescription.en;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.w : 36.w,
        vertical: isMobile ? 20.h : 44.h,
      ),
      child: Column(
        children: [
          Text(
            titleText,
            style: TextStyle(
              fontSize: isMobile ? 28.sp : 48.sp,
              fontWeight: FontWeight.bold,
              color: primary,
              height: 1.1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            descText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12.sp : 20.sp,
              fontWeight: FontWeight.w400,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCardsSection(HomePageModel data, double w, bool isAr) {
    if (w >= 1024.w) return _buildDesktopCards(data, isAr);
    if (w >= 600.w) return _buildTabletCards(data, isAr);
    return _buildMobileCards(data, isAr);
  }

  Color _hexColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    } catch (_) {}
    return const Color(0xFF2D8C4E);
  }

  Widget _buildDesktopCards(HomePageModel data, bool isAr) {
    const Color sectionBg = Color(0xFFF2F6EF);
    final Color primary = _hexColor(data.branding.primaryColor);
    final double innerOffset = 36.h + 10.h + 90.h;
    final double btnOffset = innerOffset + 36.h + 10.h;
    final sec = data.sections;

    String secDesc(int i) => i < sec.length
        ? (isAr
        ? (sec[i].description.ar.isNotEmpty ? sec[i].description.ar : sec[i].description.en)
        : sec[i].description.en)
        : '';

    return Container(
      color: sectionBg,
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left outer card
          _buildOuterCard(
            iconUrl: sec.isNotEmpty ? sec[0].iconUrl : '',
            imageUrl: sec.isNotEmpty ? sec[0].imageUrl : '',
            text: secDesc(0),
            cardColor: primary,
            iconOnRight: !isAr,
          ),
          SizedBox(width: 10.w),

          // Inner column 1
          SizedBox(
            width: 160.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: innerOffset),
                _buildCircleIcon(sec.length > 1 ? sec[1].iconUrl : ''),
                SizedBox(height: 10.h),
                _buildSectionImage(
                  sec.length > 1 ? sec[1].imageUrl : '',
                  160.w,
                  180.h,
                ),
                SizedBox(height: 10.h),
                _buildGreenCard(
                  width: 160.w,
                  height: 120.h,
                  text: secDesc(1),
                  color: primary,
                  isRtl: isAr,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Center buttons
          SizedBox(
            width: 240.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: btnOffset),
                ...data.navButtons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final btn = entry.value;
                  final label = isAr
                      ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                      : btn.name.en;

                  final double btnWidth = index == 0
                      ? 240.w
                      : index == 1
                      ? 196.w
                      : index == 2
                      ? 172.w
                      : 160.w;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      width: btnWidth,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Inner column 2
          SizedBox(
            width: 160.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: innerOffset),
                _buildCircleIcon(sec.length > 2 ? sec[2].iconUrl : ''),
                SizedBox(height: 10.h),
                _buildSectionImage(
                  sec.length > 2 ? sec[2].imageUrl : '',
                  160.w,
                  180.h,
                ),
                SizedBox(height: 10.h),
                _buildGreenCard(
                  width: 160.w,
                  height: 120.h,
                  text: secDesc(2),
                  color: primary,
                  isRtl: isAr,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Right outer card
          _buildOuterCard(
            iconUrl: sec.length > 3 ? sec[3].iconUrl : '',
            imageUrl: sec.length > 3 ? sec[3].imageUrl : '',
            text: secDesc(3),
            cardColor: primary,
            iconOnRight: isAr,
          ),
        ],
      ),
    );
  }

  Widget _buildOuterCard({
    required String iconUrl,
    required String imageUrl,
    required String text,
    required Color cardColor,
    bool iconOnRight = false,
  }) {
    final double totalW = 212.w;
    final double iconSz = 36.w;
    final double imgW = 160.w;
    final double gap = 12.w;

    final Widget img = _buildSectionImage(imageUrl, imgW, 180.h, radius: 16.r);
    final Widget icn = Container(
      width: iconSz,
      height: iconSz,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: _smartImage(
          url: iconUrl,
          width: 18.w,
          height: 18.w,
          fit: BoxFit.scaleDown,
        ),
      ),
    );

    return SizedBox(
      width: totalW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: iconOnRight ? [img, SizedBox(width: gap), icn] : [icn, SizedBox(width: gap), img],
          ),
          SizedBox(height: 10.h),
          _buildGreenCard(width: totalW, height: 120.h, text: text, color: cardColor, isRtl: false),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(String iconUrl) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: _smartImage(
          url: iconUrl,
          width: 18.w,
          height: 18.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSectionImage(String imageUrl, double width, double height, {double? radius}) {
    final r = radius ?? 12.r;

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Container(
          width: width,
          height: height,
          color: AppColors.card,
          alignment: Alignment.center,
          child: SvgPicture.network(
            imageUrl,
            width: width * 0.75,
            height: height * 0.75,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => Icon(Icons.image, size: 48.sp, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }

  Widget _buildGreenCard({
    double? width,
    required double height,
    required String text,
    required Color color,
    double? fontSize,
    bool isRtl = false,
  }) {
    final double fSize = fontSize ?? 12.sp;
    const double lineHeight = 1.2;
    final double padding = 10.r * 2;
    final int maxLines = ((height - padding) / (fSize * lineHeight)).floor().clamp(1, 99);

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: lineHeight,
        ),
      ),
    );
  }

  Widget _smartImage({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (url.isEmpty) {
      return Icon(Icons.image_outlined, size: 16.sp, color: Colors.grey);
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => Icon(Icons.image_outlined, size: 16.sp, color: Colors.grey),
      );
    }

    return Icon(Icons.image_outlined, size: 16.sp, color: Colors.grey);
  }

  Widget _buildTabletCards(HomePageModel data, bool isAr) {
    const Color sectionBg = Color(0xFFF2F6EF);
    final Color primary = _hexColor(data.branding.primaryColor);
    final double cardW = 130.w;
    final double imageH = 150.h;
    final double textH = 110.h;
    final sec = data.sections;

    String secDesc(int i) => i < sec.length
        ? (isAr
        ? (sec[i].description.ar.isNotEmpty ? sec[i].description.ar : sec[i].description.en)
        : sec[i].description.en)
        : '';

    return Container(
      color: sectionBg,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: 2 cards with icons/images + center buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left card column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: cardW,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildCircleIcon(sec.isNotEmpty ? sec[0].iconUrl : ''),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _buildSectionImage(
                    sec.isNotEmpty ? sec[0].imageUrl : '',
                    cardW,
                    imageH,
                  ),
                ],
              ),
              SizedBox(width: 10.w),

              // Center buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 36.w + 6.h),
                    ...data.navButtons.take(2).toList().asMap().entries.map((e) {
                      final btn = e.value;
                      final label = isAr
                          ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                          : btn.name.en;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Right card column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: cardW,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildCircleIcon(sec.length > 3 ? sec[3].iconUrl : ''),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _buildSectionImage(
                    sec.length > 3 ? sec[3].imageUrl : '',
                    cardW,
                    imageH,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Bottom row: green cards + 2 middle columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left green card
              _buildGreenCard(
                width: cardW,
                height: textH,
                text: secDesc(0),
                color: primary,
                fontSize: 11.sp,
                isRtl: isAr,
              ),
              SizedBox(width: 10.w),

              // Middle column 1
              Expanded(
                child: Column(
                  children: [
                    _buildCircleIcon(sec.length > 1 ? sec[1].iconUrl : ''),
                    SizedBox(height: 6.h),
                    _buildSectionImage(
                      sec.length > 1 ? sec[1].imageUrl : '',
                      double.infinity,
                      imageH * 0.6,
                    ),
                    SizedBox(height: 6.h),
                    _buildGreenCard(
                      height: textH,
                      text: secDesc(1),
                      color: primary,
                      fontSize: 11.sp,
                      isRtl: isAr,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Middle column 2
              Expanded(
                child: Column(
                  children: [
                    _buildCircleIcon(sec.length > 2 ? sec[2].iconUrl : ''),
                    SizedBox(height: 6.h),
                    _buildSectionImage(
                      sec.length > 2 ? sec[2].imageUrl : '',
                      double.infinity,
                      imageH * 0.6,
                    ),
                    SizedBox(height: 6.h),
                    _buildGreenCard(
                      height: textH,
                      text: secDesc(2),
                      color: primary,
                      fontSize: 11.sp,
                      isRtl: isAr,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Right green card
              _buildGreenCard(
                width: cardW,
                height: textH,
                text: secDesc(3),
                color: primary,
                fontSize: 11.sp,
                isRtl: isAr,
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildMobileCards(HomePageModel data, bool isAr) {
    const Color sectionBg = Color(0xFFF2F6EF);
    final Color primary = _hexColor(data.branding.primaryColor);
    final sec = data.sections;

    String secDesc(int i) => i < sec.length
        ? (isAr
        ? (sec[i].description.ar.isNotEmpty ? sec[i].description.ar : sec[i].description.en)
        : sec[i].description.en)
        : '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sw = constraints.maxWidth;
        final double hPad = 16.w;
        final double gap = 8.w;
        final double col = (sw - hPad * 2 - gap) / 2;

        final double rowAH = col * 1.1;
        final double rowBH = col * 1.05;
        final double rowCH = col * 0.72;
        final double rowDH = col * 0.55;

        Widget imageBox(double w, double h, String url) =>
            _buildSectionImage(url, w, h, radius: 12.r);

        Widget green(double w, double h, String text, Color color) => Container(
          width: w,
          height: h,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        );

        Widget solidGreen(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );

        return Container(
          color: sectionBg,
          padding: EdgeInsets.fromLTRB(hPad, 0.h, hPad, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Buttons at top
              ...data.navButtons.take(2).toList().asMap().entries.map((e) {
                final btn = e.value;
                final label = isAr
                    ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                    : btn.name.en;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 6.h),

              // Row A: image | green
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageBox(col, rowAH, sec.isNotEmpty ? sec[0].imageUrl : ''),
                  SizedBox(width: gap),
                  green(col, rowAH, secDesc(0), primary),
                ],
              ),
              SizedBox(height: gap),

              // Row B: green | image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  green(col, rowBH, secDesc(1), primary),
                  SizedBox(width: gap),
                  imageBox(col, rowBH, sec.length > 1 ? sec[1].imageUrl : ''),
                ],
              ),
              SizedBox(height: gap),

              // Row C: image | solid green
              Row(
                children: [
                  imageBox(col, rowCH, sec.length > 2 ? sec[2].imageUrl : ''),
                  SizedBox(width: gap),
                  solidGreen(col, rowCH),
                ],
              ),
              SizedBox(height: gap),

              // Row D: full width green
              green(sw - hPad * 2, rowDH, secDesc(2), primary),
            ],
          ),
        );
      },
    );
  }
}