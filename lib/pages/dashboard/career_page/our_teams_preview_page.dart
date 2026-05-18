// ******************* FILE INFO *******************
// File Name: our_teams_preview_page.dart
// Preview page for "Our Teams" section.
// Figma: "Preview Our Teams Details"
// Features:
//   • Desktop / Tablet / Mobile device frame (mirrors about_preview_page.dart)
//   • ENG / AR language toggle
//   • Scaled device-frame preview of "Meet Our Teams" content
//   • Row sections (First Row, Second Row…) with card count badge
//   • + Row / Select Team controls (Figma "Fifths Row" section)
//   • Back + Save bottom buttons
// UPDATED: Full mockup-style preview matching Figma

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/career/our_teams_cubit.dart';
import 'package:web_app_admin/controller/career/our_teams_state.dart';
import 'package:web_app_admin/model/our_teams_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/two_tab.dart';

// ── Admin-shell colors ────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color discard   = Color(0xFF797979);
  static const Color preview   = Color(0xFF608570);
}

// ── Device viewport constants ─────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;
const int    _kPerRow   = 3;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

// ── HtmlElementView SVG/image helper (XHR/CORS workaround) ───────────────────
Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final id = 'ot-pv-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';
  ui_web.platformViewRegistry.registerViewFactory(id, (_) {
    final img = html.ImageElement()
      ..src = url
      ..style.width  = '100%'
      ..style.height = '100%'
      ..style.objectFit =
      fit == BoxFit.contain ? 'contain' : 'cover';
    return img;
  });
  Widget w = HtmlElementView(viewType: id);
  if (width != null || height != null)
    w = SizedBox(width: width, height: height, child: w);
  return w;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE  (admin shell)
// ═══════════════════════════════════════════════════════════════════════════════
class OurTeamsPreviewPage extends StatefulWidget {
  const OurTeamsPreviewPage({super.key});

  @override
  State<OurTeamsPreviewPage> createState() => _OurTeamsPreviewPageState();
}

class _OurTeamsPreviewPageState extends State<OurTeamsPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool           _isAr   = false;
  bool           _isSaving = false;

  Future<void> _handleSave(OurTeamsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OurTeamsCubit, OurTeamsState>(
      builder: (context, state) {
        OurTeamsModel? data;
        if (state is OurTeamsLoaded) data = state.data;
        if (state is OurTeamsSaved)  data = state.data;

        final cubit = context.read<OurTeamsCubit>();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.sectionBg,
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

                        // ── Page title ──────────────────────────────────────
                        Text(
                          'Preview Our Teams Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color:      _C.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs + ENG/AR toggle ─────────────────────
                        Row(
                          children: [
                            _deviceTab('Desktop', _PreviewDevice.desktop),
                            SizedBox(width: 24.w),
                            _deviceTab('Tablet',  _PreviewDevice.tablet),
                            SizedBox(width: 24.w),
                            _deviceTab('Mobile',  _PreviewDevice.mobile),
                            const Spacer(),
                            SizedBox(
                              width:  95.w,
                              height: 36.h,
                              child: CustomSegmentedTabs(
                                tabs:               const ['ENG', 'AR'],
                                selectedIndex:      _isAr ? 1 : 0,
                                onTabSelected: (i) =>
                                    setState(() => _isAr = i == 1),
                                selectedColor:      _C.primary,
                                unselectedColor:    Colors.white,
                                selectedTextColor:  Colors.white,
                                unselectedTextColor: _C.labelText,
                                equalWidth: false,
                                containerPadding: EdgeInsets.symmetric(
                                    horizontal: 8.sp, vertical: 4.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Device frame ────────────────────────────────────
                        LayoutBuilder(
                          builder: (ctx, box) =>
                              _buildFrame(box.maxWidth, data),
                        ),

                        SizedBox(height: 24.h),

                        // ── Back + Save ─────────────────────────────────────
                        _bottomButtons(cubit),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Saving overlay ──────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: _C.primary),
                        SizedBox(height: 16.h),
                        Text('Saving…',
                            style: StyleText.fontSize14Weight600
                                .copyWith(color: _C.primary)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Device tab widget ───────────────────────────────────────────────────────
  Widget _deviceTab(String label, _PreviewDevice device) {
    final active = _device == device;
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
                color:      active ? _C.primary : _C.hintText,
              ),
            ),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? _C.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame switcher ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, OurTeamsModel? data) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
    }
  }

  // ── Bottom buttons ──────────────────────────────────────────────────────────
  Widget _bottomButtons(OurTeamsCubit cubit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color:        _C.discard,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
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
                onTap: _isSaving ? null : () => _handleSave(cubit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _isSaving
                        ? _C.primary.withOpacity(0.5)
                        : _C.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                      width:  18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text('Save',
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width:  containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset:     const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
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
                    width:  _kDesktopW,
                    height: _kDesktopH,
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
    );
  }
}

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _TabletFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW =
    (containerWidth * 0.55).clamp(280.0, 500.0);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;
    return Center(
      child: Container(
        width:           displayW + 4,
        height:          displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:        Colors.white,
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset:     const Offset(0, 4))
          ],
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
    );
  }
}

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW =
    (containerWidth * 0.35).clamp(200.0, 280.0);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    return Center(
      child: Container(
        width:  displayW + 4,
        height: displayH + 24 + 12 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color:        Colors.white,
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset:     const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Notch bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width:  displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                      color:        const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6)),
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
                      data:       data,
                      isAr:       isAr,
                      isMobile:   true,
                    ),
                  ),
                ),
              ),
            ),
            // Home indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width:  displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                      color:        const Color(0xFFE0E0E0),
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
// PREVIEW CONTENT — the scaled "Meet Our Teams" page rendered inside the frame
// ═══════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatefulWidget {
  final double fakeWidth, fakeHeight;
  final OurTeamsModel? data;
  final bool isAr, isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.data,
    required this.isAr,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  bool _accordionOpen = true;

  bool get _isDesktop => widget.fakeWidth >= _kDesktopW;
  bool get _isMob     => widget.isMobile || widget.fakeWidth < 600;

  static const Color _primary   = Color(0xFF008037);
  static const Color _sectionBg = Color(0xFFF1F2ED);
  static const Color _hintText  = Color(0xFFAAAAAA);
  static const Color _labelText = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final items = widget.data?.items ?? [];
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:       Size(widget.fakeWidth, widget.fakeHeight),
        padding:    EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection:
        widget.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Material(
          color: _sectionBg,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Green accordion header ──────────────────────────────
                GestureDetector(
                  onTap: () =>
                      setState(() => _accordionOpen = !_accordionOpen),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    color: _primary,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'View',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize:   14,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white,
                            ),
                          ),
                        ),
                        Icon(
                          _accordionOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size:  20,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_accordionOpen) ...[
                  const SizedBox(height: 20),

                  // ── "Meet Our Teams" heading ───────────────────────────
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.isAr ? 'تعرف على ' : 'Meet ',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize:   _isDesktop ? 28 : (_isMob ? 18 : 22),
                              fontWeight: FontWeight.w600,
                              color:      Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: widget.isAr ? 'فرقنا' : 'Our Teams',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize:   _isDesktop ? 28 : (_isMob ? 18 : 22),
                              fontWeight: FontWeight.w600,
                              color:      _primary,
                              fontStyle:  FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Team rows ──────────────────────────────────────────
                  if (items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          widget.isAr
                              ? 'لا توجد فرق بعد.'
                              : 'No teams added yet.',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize:   14,
                              color:      _hintText),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: _isDesktop ? 20 : (_isMob ? 12 : 16)),
                      child: Column(
                        children: _buildRows(items),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Chunk items into rows of 3 ──────────────────────────────────────────────
  List<Widget> _buildRows(List<OurTeamItem> items) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i += _kPerRow) {
      final rowIndex = i ~/ _kPerRow;
      final chunk =
      items.sublist(i, (i + _kPerRow).clamp(0, items.length));

      widgets.add(_RowSection(
        rowIndex:   rowIndex,
        items:      chunk,
        totalPerRow: _kPerRow,
        isAr:       widget.isAr,
        isMobile:   _isMob,
      ));
      if (i + _kPerRow < items.length)
        widgets.add(const SizedBox(height: 14));
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROW SECTION  — labeled row with cards
// ═══════════════════════════════════════════════════════════════════════════════
class _RowSection extends StatelessWidget {
  final int           rowIndex;
  final List<OurTeamItem> items;
  final int           totalPerRow;
  final bool          isAr, isMobile;

  const _RowSection({
    required this.rowIndex,
    required this.items,
    required this.totalPerRow,
    required this.isAr,
    required this.isMobile,
  });

  static const Color _primary   = Color(0xFF008037);
  static const Color _labelText = Color(0xFF333333);

  String get _rowLabel {
    const labels = [
      'First Row', 'Second Row', 'Third Row', 'Fourth Row',
      'Fifth Row', 'Sixth Row', 'Seventh Row',
    ];
    return rowIndex < labels.length
        ? labels[rowIndex]
        : '${rowIndex + 1}th Row';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row label bar ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.drag_handle_rounded,
                  color: _labelText, size: 16),
              const SizedBox(width: 6),
              Text(
                _rowLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      _labelText,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} Card',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   12,
                    color:      _labelText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Cards ──────────────────────────────────────────────────────
        isMobile
            ? Column(
          children: items
              .map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TeamCard(item: item, isAr: isAr),
          ))
              .toList(),
        )
            : IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...items.asMap().entries.expand((e) {
                final widgets = <Widget>[];
                if (e.key > 0)
                  widgets.add(const SizedBox(width: 14));
                widgets.add(
                  Expanded(
                      child: _TeamCard(
                          item: e.value, isAr: isAr)),
                );
                return widgets;
              }),
              // Fill remaining empty slots
              ...List.generate(
                totalPerRow - items.length,
                    (_) => const Expanded(child: SizedBox()),
              ).expand((w) => [const SizedBox(width: 14), w]),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEAM CARD  — matches Figma card design
// ═══════════════════════════════════════════════════════════════════════════════
class _TeamCard extends StatelessWidget {
  final OurTeamItem item;
  final bool isAr;
  const _TeamCard({required this.item, required this.isAr});

  static const Color _primary  = Color(0xFF008037);
  static const Color _hintText = Color(0xFFAAAAAA);

  String _t(BilingualText b) {
    final v = isAr ? b.ar : b.en;
    return v.isNotEmpty ? v : b.en;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset:     const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Remove / drag icon row ──────────────────────────────────
          Row(
            children: [
              Container(
                width:  24,
                height: 24,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.remove,
                    color: Colors.white, size: 14),
              ),
              const Spacer(),
              const Icon(Icons.drag_indicator_rounded,
                  color: _hintText, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // ── Icon circle ─────────────────────────────────────────────
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color: item.iconUrl.isNotEmpty
                  ? Colors.white
                  : const Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _netImg(
                    url:    item.iconUrl,
                    width:  28,
                    height: 28,
                    fit:    BoxFit.contain),
              ),
            )
                : const Center(
                child: Icon(Icons.groups_rounded,
                    color: _primary, size: 26)),
          ),
          const SizedBox(height: 12),

          // ── Title badge ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:        _primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _t(item.title).isEmpty
                    ? 'Strategy & Planning Team'
                    : _t(item.title),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Description ─────────────────────────────────────────────
          Text(
            _t(item.description).isEmpty
                ? 'Conduct market analysis, establish KPIs, and set '
                'timelines for deliverables. Ensure every project '
                'is mapped to measurable business outcomes.'
                : _t(item.description),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize:   11,
              color:      Colors.black54,
              height:     1.5,
            ),
            maxLines:  5,
            overflow:  TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // ── Deliverables ─────────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isAr ? 'المخرجات:' : 'Deliverables:',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize:   11,
                fontWeight: FontWeight.w700,
                color:      Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing:    4,
            runSpacing: 4,
            children: item.deliverableItems.isNotEmpty
                ? item.deliverableItems
                .map((d) => _chip(_t(d.label), inactive: false))
                .toList()
                : List.generate(
                8, (_) => _chip('Inactive', inactive: true)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {required bool inactive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: inactive
            ? const Color(0xFFF5F5F5)
            : _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.isEmpty ? 'Inactive' : text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize:   10,
          fontWeight: FontWeight.w700,
          color:      inactive ? _hintText : _primary,
        ),
      ),
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
                  borderRadius: BorderRadius.circular(4)),
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
      decoration:
      BoxDecoration(color: c, shape: BoxShape.circle));
}