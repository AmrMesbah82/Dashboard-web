// ******************* FILE INFO *******************
// File Name: why_join_section_preview_page.dart
// Preview page for Why Join Our Team / Our Interns / Our Teams
//
// CHANGES (Figma sync — mirrors careers_preview_page.dart shell):
//   • Admin shell background matches _AC.back (0xFFF1F2ED)
//   • Page title style matches "Preview {Section} Details" green heading
//   • Device tabs use underline-pill style (same as careers_preview_page)
//   • Language toggle uses CustomSegmentedTabs (ENG / AR) to match shell
//   • Green "View" collapsible bar (_ViewBar widget) above browser chrome
//   • Preview content wrapped in browser chrome + scaled device frame
//   • Bottom row: "Discard" (grey) + wide spacer + "Save" (green)
//   • _SiteNavBar injected at top of every preview viewport
//   • alternating left/right SVG + description layout preserved

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/career/careers_section_cubit.dart';
import 'package:web_app_admin/controller/career/careers_section_state.dart';
import 'package:web_app_admin/model/careers_section_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/two_tab.dart';

// ── Admin-shell colors (identical to careers_preview_page.dart) ───────────────
class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color red       = Color(0xFFD32F2F);
}

// ── Preview-viewport palette ──────────────────────────────────────────────────
const Color _kGreen  = Color(0xFF008037);
const Color _kBodyBg = Color(0xFFF8F9FA);

// ── Device viewport constants ─────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1200.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  900.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _Device { desktop, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class CareersSectionPreviewPage extends StatefulWidget {
  final String sectionKey;
  final String sectionTitle;

  const CareersSectionPreviewPage({
    super.key,
    required this.sectionKey,
    required this.sectionTitle,
  });

  @override
  State<CareersSectionPreviewPage> createState() =>
      _CareersSectionPreviewPageState();
}

class _CareersSectionPreviewPageState
    extends State<CareersSectionPreviewPage> {
  _Device _device   = _Device.desktop;
  bool    _isAr     = false;
  bool    _isSaving = false;

  Future<void> _save(CareersSectionCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CareersSectionCubit, CareersSectionState>(
      listener: (context, state) {
        if (state is CareersSectionSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              '${widget.sectionTitle} saved!',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white),
            ),
            backgroundColor: _AC.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is CareersSectionError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Error: ${state.message}',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white),
            ),
            backgroundColor: _AC.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CareersSectionCubit>();

        if (state is CareersSectionInitial ||
            state is CareersSectionLoading) {
          return const Scaffold(
            backgroundColor: _AC.back,
            body: Center(
                child: CircularProgressIndicator(color: _AC.primary)),
          );
        }

        CareersSectionModel? data;
        if (state is CareersSectionLoaded) data = state.data;
        if (state is CareersSectionSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _AC.back,
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1000.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    AdminSubNavBar(activeIndex: 5),
                    SizedBox(height: 16.h),

                    // ── Page title ─────────────────────────────────────────
                    Text(
                      'Preview ${widget.sectionTitle} Details',
                      style: StyleText.fontSize45Weight600.copyWith(
                        color:      _AC.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Device tabs + ENG/AR toggle ────────────────────────
                    Row(
                      children: [
                        _deviceTab('Desktop', _Device.desktop),
                        SizedBox(width: 24.w),
                        _deviceTab('Tablet',  _Device.tablet),
                        SizedBox(width: 24.w),
                        _deviceTab('Mobile',  _Device.mobile),
                        const Spacer(),
                        SizedBox(
                          width:  95.w,
                          height: 36.h,
                          child: CustomSegmentedTabs(
                            tabs: const ['ENG', 'AR'],
                            selectedIndex: _isAr ? 1 : 0,
                            onTabSelected: (i) =>
                                setState(() => _isAr = i == 1),
                            selectedColor:       _AC.primary,
                            unselectedColor:     Colors.white,
                            selectedTextColor:   Colors.white,
                            unselectedTextColor: _AC.labelText,
                            equalWidth: false,
                            containerPadding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical:   4.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── Scaled device frame (View bar + browser) ───────────
                    LayoutBuilder(
                      builder: (ctx, box) =>
                          _buildFrame(box.maxWidth, data),
                    ),
                    SizedBox(height: 24.h),

                    // ── Discard + Save ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _AC.grey,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: Text(
                                  'Discard',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 300.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSaving ? null : () => _save(cubit),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _isSaving
                                    ? _AC.primary.withOpacity(0.5)
                                    : _AC.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: _isSaving
                                    ? SizedBox(
                                  width:  18.w,
                                  height: 18.h,
                                  child: const CircularProgressIndicator(
                                      color:       Colors.white,
                                      strokeWidth: 2),
                                )
                                    : Text(
                                  'Save',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white),
                                ),
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
        );
      },
    );
  }

  // ── Device tab pill ────────────────────────────────────────────────────────
  Widget _deviceTab(String label, _Device device) {
    final bool active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label,
              style: TextStyle(
                fontSize:   15.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color:      active ? _AC.primary : _AC.hintText,
              ),
            ),
          ),
          Container(
            height: 2,
            width:  label.length * 8.0,
            color:  active ? _AC.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame builder ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, CareersSectionModel? data) {
    switch (_device) {
      case _Device.desktop:
        return _DesktopFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _Device.tablet:
        return _TabletFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _Device.mobile:
        return _MobileFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

// ── Desktop ───────────────────────────────────────────────────────────────────
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final CareersSectionModel? data;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width: containerWidth,
      // color: _AC.back,
      child: Column(
        children: [
          const _ViewBar(),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Column(
              children: [
                const _BrowserChrome(),
                SizedBox(
                  width:  containerWidth,
                  height: frameH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kDesktopW,
                      maxHeight: _kDesktopH,
                      child: Transform.scale(
                        scale:     scale,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: _kDesktopW,
                          child: _PreviewContent(
                            fakeWidth:  _kDesktopW,
                            fakeHeight: _kDesktopH,
                            data: data,
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
        ],
      ),
    );
  }
}

// ── Tablet ────────────────────────────────────────────────────────────────────
class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final CareersSectionModel? data;
  final bool isAr;
  const _TabletFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;
    return Center(
      child: Column(
        children: [
          _ViewBar(width: displayW + 4),
          Container(
            width:  displayW + 4,
            height: displayH + 28 + 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft:  Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: _AC.border, width: 2),
              color:  Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _BrowserChrome(compact: true),
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kTabletW,
                      maxHeight: _kTabletH,
                      child: Transform.scale(
                        scale:     scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:  _kTabletW,
                          fakeHeight: _kTabletH,
                          data: data,
                          isAr: isAr,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────
class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final CareersSectionModel? data;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    return Center(
      child: Column(
        children: [
          _ViewBar(width: displayW + 4),
          Container(
            width:  displayW + 4,
            height: displayH + 24 + 12 + 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              border: Border.all(color: _AC.border, width: 2),
              color:  Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // top notch
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color:        _AC.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kMobileW,
                      maxHeight: _kMobileH,
                      child: Transform.scale(
                        scale:     scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:  _kMobileW,
                          fakeHeight: _kMobileH,
                          data:     data,
                          isAr:     isAr,
                          isMobile: true,
                        ),
                      ),
                    ),
                  ),
                ),
                // bottom home bar
                Container(
                  color:   Color(0xFFF1F2ED),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 4,
                      decoration: BoxDecoration(
                        color:        _AC.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GREEN "VIEW" BAR  (identical to careers_preview_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
class _ViewBar extends StatelessWidget {
  final double? width;
  const _ViewBar({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width ?? double.infinity,
      height: 36,
      decoration: const BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: const [
          Text(
            'View',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  compact ? 22 : 28,
      color:   const Color(0xFFF5F5F5),
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
                color:        const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width:  8,
    height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}



// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT — rendered at native resolution then scaled
// ═══════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth, fakeHeight;
  final CareersSectionModel? data;
  final bool isAr, isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.data,
    required this.isAr,
    this.isMobile = false,
  });

  bool get _isDesktop => fakeWidth >= _kDesktopW;
  bool get _isMobView => isMobile || fakeWidth < 600;
  double get _hPad    => _isDesktop ? 48 : (_isMobView ? 16 : 24);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(fakeWidth, fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Material(
          color: _kBodyBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Section content ──────────────────────────────────────
                if (data == null || data!.items.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'No items to preview.',
                        style: TextStyle(
                          fontSize: 14,
                          color:    const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  )
                else
                  _buildItems(data!),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(CareersSectionModel data) {
    final double svgW   = _isMobView ? 160 : (_isDesktop ? 220 : 160);
    final double svgH   = _isMobView ? 140 : (_isDesktop ? 180 : 140);
    final double textFz = _isMobView ? 11  : (_isDesktop ? 13  : 12);
    final double gap    = _isMobView ? 12  : (_isDesktop ? 40  : 20);
    final double rowGap = _isMobView ? 24  : (_isDesktop ? 40  : 32);

    return Container(
      color: Color(0xFFF1F2ED),
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.items.asMap().entries.map((entry) {
          final int   i       = entry.key;
          final item          = entry.value;
          final bool  imgLeft = i.isOdd;

          final String desc = isAr
              ? (item.description.ar.isNotEmpty
              ? item.description.ar
              : item.description.en)
              : item.description.en;

          // ── Mobile: stacked ────────────────────────────────────────────
          if (_isMobView) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _svgWidget(item.svgUrl, svgW, svgH, centered: true),
                  const SizedBox(height: 14),
                  Text(
                    desc,
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize:   textFz,
                      fontWeight: FontWeight.w400,
                      color:      const Color(0xFF555555),
                      height:     1.75,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Desktop / Tablet: alternating left / right ─────────────────
          final Widget textWidget = Expanded(
            flex: 5,
            child: Text(
              desc,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize:   textFz,
                fontWeight: FontWeight.w400,
                color:      const Color(0xFF555555),
                height:     1.75,
              ),
            ),
          );

          final Widget imageWidget = Expanded(
            flex: 4,
            child: _svgWidget(item.svgUrl, svgW, svgH),
          );

          // even (0,2,4…) → text | SVG   odd (1,3,5…) → SVG | text
          final List<Widget> row = imgLeft
              ? [imageWidget, SizedBox(width: gap), textWidget]
              : [textWidget,  SizedBox(width: gap), imageWidget];

          return Padding(
            padding: EdgeInsets.only(bottom: rowGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: row,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _svgWidget(String url, double w, double h,
      {bool centered = false}) {
    final Widget child = url.isNotEmpty
        ? SvgPicture.network(
      url,
      width:  w,
      height: h,
      fit:    BoxFit.contain,
      placeholderBuilder: (_) => Container(
        width:  w,
        height: h,
        color:  const Color(0xFFF0F0F0),
      ),
    )
        : Container(
      width:  w,
      height: h,
      decoration: BoxDecoration(
        color:        const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
      ),
    );

    return centered ? Center(child: child) : child;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON + TITLE ROW  (utility — kept for backward compat / other callers)
// ═══════════════════════════════════════════════════════════════════════════════
class _IconTitleRow extends StatelessWidget {
  final String iconUrl;
  final String svgUrl;
  final String title;
  final double iconSz;
  final bool   isAr;

  const _IconTitleRow({
    required this.iconUrl,
    required this.svgUrl,
    required this.title,
    required this.iconSz,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final String displayUrl = iconUrl.isNotEmpty ? iconUrl : svgUrl;

    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize:  MainAxisSize.min,
      children: [
        Container(
          width:  iconSz + 8,
          height: iconSz + 8,
          decoration: const BoxDecoration(
            color: Color(0xFF008037),
            shape: BoxShape.circle,
          ),
          child: displayUrl.isNotEmpty
              ? ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.network(
                displayUrl,
                fit:         BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
                placeholderBuilder: (_) => const SizedBox(),
              ),
            ),
          )
              : Icon(Icons.work_outline,
              color: Colors.white, size: iconSz * 0.6),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w600,
              color:      Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}