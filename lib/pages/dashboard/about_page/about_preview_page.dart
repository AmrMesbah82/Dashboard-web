// ******************* FILE INFO *******************
// File Name: about_preview_page.dart
// Screen 3 — About Us CMS: Preview with Desktop/Tablet/Mobile + ENG/AR toggle
// UPDATED: Mirrors about_page.dart UI exactly inside scaled device frames
//          Same top-tab bar, sub-tab items, accordion, values grid, colors.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../core/two_tab.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import 'about_main_page_master.dart';

// ── Admin-shell colors ────────────────────────────────────────────────────────
class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
}

// ── User-app palette (mirrors about_page.dart constants) ─────────────────────
const Color _kDefaultGreen = Color(0xFF2D8C4E);
const Color _kGreenLight   = Color(0xFFE8F5EE);
const Color _kSurface      = Color(0xFFFFFFFF);
const Color _kDivider      = Color(0xFFDDE8DD);

// ── Device viewport constants ─────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

Color _hoverTint(Color c) => c.withOpacity(0.12);

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

// ── HtmlElementView image helper (matches overview_preview_page.dart) ─────────
Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final id =
      'ab-pv-${url.hashCode}-${width?.toInt()}-${height?.toInt()}-${fit.index}';
  ui_web.platformViewRegistry.registerViewFactory(id, (_) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });
  Widget inner = HtmlElementView(viewType: id);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE  (admin shell)
// ═══════════════════════════════════════════════════════════════════════════════
class AboutPreviewPageLast extends StatefulWidget {
  final AboutPageModel model;
  final Map<String, Uint8List> imageUploads;

  const AboutPreviewPageLast({
    super.key,
    required this.model,
    this.imageUploads = const {},
  });

  @override
  State<AboutPreviewPageLast> createState() => _AboutPreviewPageLastState();
}

class _AboutPreviewPageLastState extends State<AboutPreviewPageLast> {
  _PreviewDevice _device       = _PreviewDevice.desktop;
  bool           _isAr         = false;
  bool           _isPublishing = false;

  void _onBack() => Navigator.pop(context);

  void _onSave() {
    showPublishConfirmDialog(
      context: context,
      title: 'EDITING ABOUT US DETAILS',
      subtitle: 'Do you want to save the changes made to this About Us?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: () async {
        setState(() => _isPublishing = true);
        try {
          await context.read<AboutCubit>().save(
            model: widget.model,
            imageUploads:
            widget.imageUploads.isEmpty ? null : widget.imageUploads,
          );
        } finally {
          if (mounted) setState(() => _isPublishing = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AboutCubit, AboutState>(
      listener: (context, state) {
        if (state is AboutSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const AboutMainPageMasterDashboard()),
                    (route) => false,
              );
            }
          });
        }
        if (state is AboutError) {
          setState(() => _isPublishing = false);
          showConfirmDialog(
            context: context,
            title: 'Error',
            subtitle: state.message,
            confirmLabel: 'OK',
            cancelLabel: '',
            onConfirm: () {},
            iconWidget: Container(
              width: 60.r,
              height: 60.r,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle),
              child:
              Icon(Icons.error_outline, color: Colors.white, size: 36.r),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: _AC.back,
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 3),
                      SizedBox(height: 16.h),

                      Text(
                        'Preview About Us Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                            color: _AC.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16.h),

                      // ── Device tabs + Language toggle ──────────────
                      Row(
                        children: [
                          _tab('Desktop', _PreviewDevice.desktop),
                          SizedBox(width: 24.w),
                          _tab('Tablet',  _PreviewDevice.tablet),
                          SizedBox(width: 24.w),
                          _tab('Mobile',  _PreviewDevice.mobile),
                          const Spacer(),
                          SizedBox(
                            width: 95.w,
                            height: 36.h,
                            child: CustomSegmentedTabs(
                              tabs: const ['ENG', 'AR'],
                              selectedIndex: _isAr ? 1 : 0,
                              onTabSelected: (i) =>
                                  setState(() => _isAr = i == 1),
                              selectedColor: _AC.primary,
                              unselectedColor: Colors.white,
                              selectedTextColor: Colors.white,
                              unselectedTextColor: _AC.labelText,
                              equalWidth: false,
                              containerPadding: EdgeInsets.symmetric(
                                  horizontal: 8.sp, vertical: 4.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ── Scaled device frame ────────────────────────
                      LayoutBuilder(
                          builder: (ctx, box) =>
                              _buildFrame(box.maxWidth)),

                      SizedBox(height: 24.h),

                      // ── Back + Save ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _onBack,
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                    color: _AC.grey,
                                    borderRadius:
                                    BorderRadius.circular(6.r)),
                                child: Center(
                                  child: Text('Back',
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 300.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isPublishing ? null : _onSave,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 44.h,
                                decoration: BoxDecoration(
                                    color: _isPublishing
                                        ? _AC.primary.withOpacity(0.5)
                                        : _AC.primary,
                                    borderRadius:
                                    BorderRadius.circular(6.r)),
                                child: Center(
                                  child: _isPublishing
                                      ? SizedBox(
                                    width: 18.w,
                                    height: 18.h,
                                    child:
                                    const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                      : Text('Save',
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isPublishing)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                  child: CircularProgressIndicator(color: _AC.primary)),
            ),
        ],
      ),
    );
  }

  Widget _tab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _AC.primary : _AC.hintText,
                )),
          ),
          Container(
              height: 2,
              width: label.length * 8.0,
              color: active ? _AC.primary : Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW, model: widget.model, isAr: _isAr);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW, model: widget.model, isAr: _isAr);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW, model: widget.model, isAr: _isAr);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final AboutPageModel model;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth, required this.model, required this.isAr});
  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width: containerWidth,
      height: frameH + 28,
      color: _AC.back,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        isAr: isAr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final AboutPageModel model;
  final bool isAr;
  const _TabletFrame(
      {required this.containerWidth, required this.model, required this.isAr});
  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;
    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _AC.border, width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const _BrowserChrome(compact: true),
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kTabletW,
                  maxHeight: _kTabletH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kTabletW,
                      fakeHeight: _kTabletH,
                      model: model,
                      isAr: isAr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final AboutPageModel model;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth, required this.model, required this.isAr});
  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 24 + 12 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _AC.border, width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                      color: _AC.border,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kMobileW,
                  maxHeight: _kMobileH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kMobileW,
                      fakeHeight: _kMobileH,
                      model: model,
                      isAr: isAr,
                      isMobile: true,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _AC.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT — mirrors about_page.dart layout at native device resolution
// ═══════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatefulWidget {
  final double fakeWidth, fakeHeight;
  final AboutPageModel model;
  final bool isAr, isMobile;
  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isAr,
    this.isMobile = false,
  });
  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  int _topTab         = 0; // 0=About Us  1=Strategy  2=Terms  3=Privacy
  int _subTab         = 0; // Vision / Mission / Values
  int _mobileExpanded = 0; // accordion open index (-1=none)

  bool get _isDesktop  => widget.fakeWidth >= _kDesktopW;
  bool get _isTablet   => widget.fakeWidth >= 600 && !_isDesktop;
  bool get _isMobView  => widget.isMobile || widget.fakeWidth < 600;

  double get _hPad => _isDesktop ? 0 : (_isMobView ? 16 : 24);

  // branding stand-in
  Color get _primary   => _kDefaultGreen;
  Color get _secondary => _kGreenLight;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(widget.fakeWidth, widget.fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection:
        widget.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Material(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page heading ───────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _hPad,
                      vertical: _isDesktop ? 36 : 20),
                  child: Text(
                    _ab(widget.model.title, widget.isAr).isNotEmpty
                        ? _ab(widget.model.title, widget.isAr)
                        : (widget.isAr ? 'من نحن' : 'About Us'),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: _isDesktop ? 48 : 28,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),

                // // ── Top tab bar ────────────────────────────────────────
                // Padding(
                //   padding:
                //   EdgeInsets.symmetric(horizontal: _hPad),
                //   child: _isMobView
                //       ? SingleChildScrollView(
                //       scrollDirection: Axis.horizontal,
                //       child: Row(children: _buildTopTabs()))
                //       : Row(
                //       mainAxisAlignment:
                //       MainAxisAlignment.spaceEvenly,
                //       children: _buildTopTabs()),
                // ),
                // const SizedBox(height: 16),

                // ── Content ────────────────────────────────────────────
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: _hPad),
                  child: _buildContent(),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOP TABS  (mirrors _DesktopTopTabItem / _MobileTopTabItem)
  // ─────────────────────────────────────────────────────────────────────────
  List<Widget> _buildTopTabs() {
    final labels = widget.isAr
        ? ['من نحن', 'استراتيجيتنا', 'الشروط والأحكام', 'سياسة الخصوصية']
        : ['About Us', 'Our Strategy', 'Terms and Conditions', 'Privacy Policy'];

    final icons = [
      Icons.people_outline,
      Icons.account_tree_outlined,
      Icons.description_outlined,
      Icons.lock_outline,
    ];

    return List.generate(4, (i) {
      final bool sel = _topTab == i;
      return GestureDetector(
        onTap: () => setState(
                () { _topTab = i; _subTab = 0; _mobileExpanded = 0; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: _isMobView ? 8 : 0),
          padding: EdgeInsets.symmetric(
              horizontal: _isDesktop ? 12 : 10,
              vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isDesktop ? 48 : 38,
                height: _isDesktop ? 48 : 38,
                decoration: BoxDecoration(
                  color: sel ? _primary : _secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icons[i],
                      size: _isDesktop ? 24 : 20,
                      color: sel ? Colors.white : _primary),
                ),
              ),
              SizedBox(width: _isDesktop ? 10 : 6),
              Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: _isDesktop ? 13 : 11,
                  fontWeight:
                  sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? _primary : AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONTENT SWITCHER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (_topTab) {
      case 0:
        if (_isDesktop) return _buildDesktopAboutUs();
        if (_isMobView) return _buildMobileAboutUs();
        return _buildTabletAboutUs();
      case 1:
        return _buildPlaceholder(widget.isAr
            ? 'محتوى الاستراتيجية متاح في التطبيق'
            : 'Strategy content is available in the live app');
      case 2:
        return _buildPlaceholder(widget.isAr
            ? 'محتوى الشروط والأحكام متاح في التطبيق'
            : 'Terms & Conditions content is available in the live app');
      case 3:
        return _buildPlaceholder(widget.isAr
            ? 'محتوى سياسة الخصوصية متاح في التطبيق'
            : 'Privacy Policy content is available in the live app');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholder(String msg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12)),
    child: Center(
      child: Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: _isDesktop ? 14 : 12,
              color: Colors.grey[500])),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ABOUT US — DESKTOP (two-column: left sub-tabs + right panel)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDesktopAboutUs() {
    const double leftW = 280, gap = 16;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(bottom: i == 2 ? 0 : 8),
                child: _DesktopSubTab(
                  label:       _subTabLabel(i),
                  iconUrl:     _subTabIconUrl(i),
                  description: _subTab == i ? _subTabDesc(i) : '',
                  isSelected:  _subTab == i,
                  primary:     _primary,
                  secondary:   _secondary,
                  onTap: () => setState(() => _subTab = i),
                ),
              )),
            ),
          ),
          const SizedBox(width: gap),
          Expanded(child: _buildDesktopRightPanel()),
        ],
      ),
    );
  }

  Widget _buildDesktopRightPanel() {
    if (_subTab == 2) {
      final others = widget.model.values.length > 1
          ? widget.model.values.sublist(1) : <AboutValueItem>[];
      return _ValuesGrid(
          values: others, isRtl: widget.isAr,
          primary: _primary, secondary: _secondary, compact: false);
    }
    final s = _subTab == 0 ? widget.model.vision : widget.model.mission;
    return Container(
      width: double.infinity, height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(_ab(s.description, widget.isAr),
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: 13, height: 1.75, color: Color(0xFF444444))),
          ),
          if (s.svgUrl.isNotEmpty) ...[
            const SizedBox(width: 16),
            _netImg(url: s.svgUrl, width: 180, height: 180,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10)),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ABOUT US — TABLET (row of 3 tabs + content below)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTabletAboutUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
              child: _TabletSubTab(
                label: _subTabLabel(i), iconUrl: _subTabIconUrl(i),
                isSelected: _subTab == i,
                primary: _primary, secondary: _secondary,
                onTap: () => setState(() => _subTab = i),
              ),
            ),
          )),
        ),
        const SizedBox(height: 14),
        _buildTabletPanel(),
      ],
    );
  }

  Widget _buildTabletPanel() {
    if (_subTab == 2) {
      final others = widget.model.values.length > 1
          ? widget.model.values.sublist(1) : <AboutValueItem>[];
      return _ValuesGrid(
          values: others, isRtl: widget.isAr,
          primary: _primary, secondary: _secondary, compact: true);
    }
    final s = _subTab == 0 ? widget.model.vision : widget.model.mission;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (s.svgUrl.isNotEmpty) ...[
          Center(child: _netImg(url: s.svgUrl, width: 160, height: 160,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 12),
        ],
        Text(_ab(s.description, widget.isAr),
            style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 11, height: 1.75)),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ABOUT US — MOBILE (accordion)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileAboutUs() {
    return Column(
      children: List.generate(3, (i) {
        final bool open = _mobileExpanded == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MobileAccordion(
            label: _subTabLabel(i), iconUrl: _subTabIconUrl(i),
            isExpanded: open, primary: _primary, secondary: _secondary,
            onTap: () =>
                setState(() => _mobileExpanded = open ? -1 : i),
            child: _buildMobilePanel(i),
          ),
        );
      }),
    );
  }

  Widget _buildMobilePanel(int i) {
    if (i == 2) {
      final others = widget.model.values.length > 1
          ? widget.model.values.sublist(1) : <AboutValueItem>[];
      return _ValuesGrid(
          values: others, isRtl: widget.isAr,
          primary: _primary, secondary: _secondary, compact: true);
    }
    final s = i == 0 ? widget.model.vision : widget.model.mission;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (s.svgUrl.isNotEmpty) ...[
        Center(
          child: _netImg(
            url: s.svgUrl,
            width: 280,   // ✅ fixed mobile content width — no more Infinity
            height: 150,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
      ],
      Text(_ab(s.description, widget.isAr),
          style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 10, height: 1.7)),
    ]);
  }

  // ── Sub-tab helpers ────────────────────────────────────────────────────────
  String _subTabLabel(int i) => switch (i) {
    0 => widget.isAr ? 'الرؤية'  : 'Vision',
    1 => widget.isAr ? 'الرسالة' : 'Mission',
    _ => widget.isAr ? 'القيم'   : 'Values',
  };
  String _subTabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl : '',
  };
  String _subTabDesc(int i) {
    final raw = switch (i) {
      0 => _ab(widget.model.vision.subDescription, widget.isAr),
      1 => _ab(widget.model.mission.subDescription, widget.isAr),
      _ => widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isAr) : '',
    };
    return raw.length > 160 ? '${raw.substring(0, 157)}…' : raw;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP SUB-TAB ITEM  (mirrors _DesktopTabItem in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _DesktopSubTab extends StatefulWidget {
  final String label, iconUrl, description;
  final bool isSelected;
  final Color primary, secondary;
  final VoidCallback onTap;
  const _DesktopSubTab({
    required this.label, required this.iconUrl, required this.description,
    required this.isSelected, required this.primary, required this.secondary,
    required this.onTap,
  });
  @override State<_DesktopSubTab> createState() => _DesktopSubTabState();
}
class _DesktopSubTabState extends State<_DesktopSubTab> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final Color ico = widget.isSelected ? Colors.white : widget.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _kSurface
                : (_hov ? _hoverTint(widget.primary) : _kSurface),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: widget.isSelected ? widget.primary : widget.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: widget.iconUrl.isNotEmpty
                        ? _netImg(url: widget.iconUrl, width: 20, height: 20,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(ico, BlendMode.srcIn))
                        : Icon(Icons.image_outlined, size: 20, color: ico),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(child: Text(widget.label,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                        fontWeight: FontWeight.w600, color: widget.primary))),
              ]),
              if (widget.isSelected && widget.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(widget.description,
                    maxLines: 5, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                        height: 1.65, color: AppColors.secondaryBlack)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET SUB-TAB ITEM  (mirrors _TabletTabItem in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _TabletSubTab extends StatefulWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primary, secondary;
  final VoidCallback onTap;
  const _TabletSubTab({
    required this.label, required this.iconUrl, required this.isSelected,
    required this.primary, required this.secondary, required this.onTap,
  });
  @override State<_TabletSubTab> createState() => _TabletSubTabState();
}
class _TabletSubTabState extends State<_TabletSubTab> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primary
                : (_hov ? _hoverTint(widget.primary) : _kSurface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? widget.primary
                  : (_hov ? widget.primary.withOpacity(0.3) : _kDivider),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.iconUrl.isNotEmpty)
              _netImg(url: widget.iconUrl, width: 16, height: 16,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      widget.isSelected ? Colors.white : widget.primary,
                      BlendMode.srcIn))
            else
              Icon(Icons.image_outlined, size: 16,
                  color: widget.isSelected ? Colors.white : widget.primary),
            const SizedBox(width: 6),
            Flexible(child: Text(widget.label,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? Colors.white : widget.primary))),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE ACCORDION  (mirrors _MobileAccordionItem in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _MobileAccordion extends StatefulWidget {
  final String label, iconUrl;
  final bool isExpanded;
  final Color primary, secondary;
  final VoidCallback onTap;
  final Widget child;
  const _MobileAccordion({
    required this.label, required this.iconUrl, required this.isExpanded,
    required this.primary, required this.secondary,
    required this.onTap, required this.child,
  });
  @override State<_MobileAccordion> createState() => _MobileAccordionState();
}
class _MobileAccordionState extends State<_MobileAccordion> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? _kSurface : (_hov ? _hoverTint(widget.primary) : _kSurface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _hov && !widget.isExpanded
                ? widget.primary.withOpacity(0.25) : Colors.transparent),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hov = true),
          onExit:  (_) => setState(() => _hov = false),
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: widget.isExpanded ? widget.primary : widget.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: widget.iconUrl.isNotEmpty
                        ? _netImg(url: widget.iconUrl, width: 18, height: 18,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                            widget.isExpanded ? Colors.white : widget.primary,
                            BlendMode.srcIn))
                        : Icon(Icons.image_outlined, size: 16,
                        color: widget.isExpanded
                            ? Colors.white : widget.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.label,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                        fontWeight: FontWeight.w600, color: widget.primary))),
                if (widget.isExpanded)
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                        color: widget.primary,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.keyboard_arrow_up_rounded,
                        color: Colors.white, size: 16),
                  ),
              ]),
            ),
          ),
        ),
        if (widget.isExpanded)
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: widget.child),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID  (mirrors _ValuesGridDesktop / Tablet / Mobile in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _ValuesGrid extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl, compact;
  final Color primary, secondary;
  const _ValuesGrid({
    required this.values, required this.isRtl,
    required this.primary, required this.secondary, required this.compact,
  });
  @override State<_ValuesGrid> createState() => _ValuesGridState();
}
class _ValuesGridState extends State<_ValuesGrid> {
  int _sel = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _kSurface, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text('No additional values.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                color: Colors.grey[500]))),
      );

    final int idx = _sel.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    final double cardW  = widget.compact ? 88 : 100;
    final double iconSz = widget.compact ? 18 : 22;
    final double fontSz = widget.compact ? 8  : 9;
    final double pad    = widget.compact ? 9  : 10;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            widget.primary.withOpacity(.06),
            widget.primary.withOpacity(.25),
            widget.primary.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 8,
                children: List.generate(widget.values.length, (i) {
                  final v = widget.values[i];
                  return _ValueCard(
                    title: _ab(v.title, widget.isRtl),
                    iconUrl: v.iconUrl, isSelected: i == idx,
                    primary: widget.primary, width: cardW,
                    iconSize: iconSz, fontSize: fontSz, padding: pad,
                    onTap: () => setState(() => _sel = i),
                  );
                })),
            const SizedBox(height: 12),
            _ValueDetail(value: selected, isRtl: widget.isRtl,
                primary: widget.primary, secondary: widget.secondary),
          ]),
    );
  }
}

// ── Value card ────────────────────────────────────────────────────────────────
class _ValueCard extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primary;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  const _ValueCard({
    required this.title, required this.iconUrl, required this.isSelected,
    required this.primary, required this.width, required this.iconSize,
    required this.fontSize, required this.padding, required this.onTap,
  });
  @override State<_ValueCard> createState() => _ValueCardState();
}
class _ValueCardState extends State<_ValueCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Widget ico = widget.iconUrl.isNotEmpty
        ? _netImg(url: widget.iconUrl, width: widget.iconSize,
        height: widget.iconSize, fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
            sel ? Colors.white : widget.primary, BlendMode.srcIn))
        : Icon(Icons.star_outline, size: widget.iconSize,
        color: sel ? Colors.white : widget.primary);

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hov = true),
        onExit:  (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width, padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel ? widget.primary
                : (_hov ? _hoverTint(widget.primary) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            boxShadow: sel
                ? [BoxShadow(color: widget.primary.withOpacity(0.28),
                blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ico, const SizedBox(height: 6),
            Text(widget.title, textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Cairo', fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white
                        : (_hov ? widget.primary : Colors.black87),
                    height: 1.35)),
          ]),
        ),
      ),
    );
  }
}

// ── Value detail panel ────────────────────────────────────────────────────────
class _ValueDetail extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primary, secondary;
  const _ValueDetail({
    required this.value, required this.isRtl,
    required this.primary, required this.secondary,
  });
  @override
  Widget build(BuildContext context) {
    final String title     = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: secondary, borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: value.iconUrl.isNotEmpty
                ? _netImg(url: value.iconUrl, width: 30, height: 30,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn))
                : Icon(Icons.star_outline, size: 20, color: primary),
          ),
        ),
        const SizedBox(height: 10),
        if (title.isNotEmpty) ...[
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 8),
        ],
        if (shortDesc.isNotEmpty)
          Text(shortDesc, style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryBlack, height: 1.6)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({this.compact = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 22 : 28,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 4),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 4),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: compact ? 10 : 14,
              decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
  Widget _dot(Color c) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}