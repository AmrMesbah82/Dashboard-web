// ******************* FILE INFO *******************
// File Name: terms_preview.dart
// Screen 3 of 3 — Terms of Service CMS: Preview
// UPDATED: Matches about_us_preview.dart pattern exactly:
//          Device frames (Desktop/Tablet/Mobile) + ENG/AR toggle
//          Scaled content inside browser chrome frames

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../../../../../core/custom_dialog.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../../core/two_tab.dart';
import '../../../../data/model/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';

// ── Admin-shell colors ────────────────────────────────────────────────────────
class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color cardBg    = Color(0xFFFFFFFF);
}

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

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class TermsPreviewPage extends StatefulWidget {
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final Map<String, DocUpload> docUploads;

  const TermsPreviewPage({
    super.key,
    required this.model,
    this.imageUploads = const {},
    this.docUploads   = const {},
  });

  @override
  State<TermsPreviewPage> createState() => _TermsPreviewPageState();
}

class _TermsPreviewPageState extends State<TermsPreviewPage> {
  _PreviewDevice _device       = _PreviewDevice.desktop;
  bool           _isAr         = false;
  bool           _isPublishing = false;

  void _onBack() => Navigator.pop(context);

  void _onSave() {
    showPublishConfirmDialog(
      context: context,
      title: 'EDITING TERMS OF SERVICE DETAILS',
      subtitle: 'Do you want to save the changes made to Terms of Service?',
      confirmLabel: 'Confirm',
      onConfirm: () async {
        setState(() => _isPublishing = true);
        try {
          await context.read<TermsCubit>().save(
            model:        widget.model,
            imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
            docUploads:   widget.docUploads.isEmpty   ? null : widget.docUploads,
          );
        } finally {
          if (mounted) setState(() => _isPublishing = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsCubit, TermsState>(
      listener: (context, state) {
        if (state is TermsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
          });
        }
        if (state is TermsError) {
          setState(() => _isPublishing = false);
          showConfirmDialog(
            context: context,
            title: 'Error',
            subtitle: state.message,
            confirmLabel: 'OK',
            cancelLabel: '',
            onConfirm: () {},
            iconWidget: Container(
              width: 60.r, height: 60.r,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle),
              child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
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
                        'Preview Terms of Service Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                            color: _AC.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16.h),

                      // ── Device tabs + Language toggle ──────────────────────
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

                      // ── Scaled device frame ────────────────────────────────
                      LayoutBuilder(
                        builder: (ctx, box) => _buildFrame(box.maxWidth),
                      ),

                      SizedBox(height: 24.h),

                      // ── Back + Save ────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _onBack,
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                    color: _AC.grey,
                                    borderRadius: BorderRadius.circular(6.r)),
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
                                    borderRadius: BorderRadius.circular(6.r)),
                                child: Center(
                                  child: _isPublishing
                                      ? SizedBox(
                                    width: 18.w, height: 18.h,
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

  // ── Device tab widget ─────────────────────────────────────────────────────
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
            color: active ? _AC.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame builder ─────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW,
            model: widget.model,
            imageUploads: widget.imageUploads,
            isAr: _isAr);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW,
            model: widget.model,
            imageUploads: widget.imageUploads,
            isAr: _isAr);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW,
            model: widget.model,
            imageUploads: widget.imageUploads,
            isAr: _isAr);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final bool isAr;
  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.imageUploads,
    required this.isAr,
  });
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
                      child: _TermsPreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        imageUploads: imageUploads,
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
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final bool isAr;
  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.imageUploads,
    required this.isAr,
  });
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
                    child: _TermsPreviewContent(
                      fakeWidth: _kTabletW,
                      fakeHeight: _kTabletH,
                      model: model,
                      imageUploads: imageUploads,
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
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final bool isAr;
  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.imageUploads,
    required this.isAr,
  });
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
                    child: _TermsPreviewContent(
                      fakeWidth: _kMobileW,
                      fakeHeight: _kMobileH,
                      model: model,
                      imageUploads: imageUploads,
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
// TERMS PREVIEW CONTENT — rendered at native device resolution inside frame
// ═══════════════════════════════════════════════════════════════════════════════
class _TermsPreviewContent extends StatefulWidget {
  final double fakeWidth, fakeHeight;
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final bool isAr, isMobile;

  const _TermsPreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.imageUploads,
    required this.isAr,
    this.isMobile = false,
  });

  @override
  State<_TermsPreviewContent> createState() => _TermsPreviewContentState();
}

class _TermsPreviewContentState extends State<_TermsPreviewContent> {
  bool _termsOpen   = true;
  bool _privacyOpen = true;

  bool get _isDesktop => widget.fakeWidth >= _kDesktopW;
  bool get _isMobView => widget.isMobile || widget.fakeWidth < 600;

  double get _hPad => _isDesktop ? 0 : (_isMobView ? 16 : 24);

  static const Color _primary = Color(0xFF2D8C4E);

  // ── SVG resolver — bytes win over URL ─────────────────────────────────────
  Uint8List? _bytes(String key) => widget.imageUploads[key];

  Widget _svgWidget({
    required String     storageKey,
    required String     fallbackUrl,
    required double     width,
    required double     height,
  }) {
    final bytes = _bytes(storageKey);
    if (bytes != null && bytes.isNotEmpty) {
      return SvgPicture.memory(bytes,
          width: width, height: height, fit: BoxFit.contain);
    }
    if (fallbackUrl.isNotEmpty) {
      return SvgPicture.network(
        fallbackUrl,
        width: width, height: height, fit: BoxFit.contain,
        placeholderBuilder: (_) => SizedBox(
          width: width, height: height,
          child: const Center(child: CircularProgressIndicator(
              color: _primary, strokeWidth: 2)),
        ),
      );
    }
    return SizedBox(
      width: width, height: height,
      child: Icon(Icons.image_outlined,
          color: Colors.grey[400], size: width * 0.4),
    );
  }

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
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _hPad, vertical: _isDesktop ? 36 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page title ───────────────────────────────────────
                  Text(
                    widget.isAr ? 'الشروط والسياسات' : 'Terms & Policies',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: _isDesktop ? 38 : (_isMobView ? 22 : 28),
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                  SizedBox(height: _isDesktop ? 32 : 20),

                  // ── Terms and Conditions accordion ───────────────────
                  _accordion(
                    title: widget.isAr
                        ? 'الشروط والأحكام'
                        : 'Terms and Conditions',
                    isOpen: _termsOpen,
                    onToggle: () =>
                        setState(() => _termsOpen = !_termsOpen),
                    child: _sectionContent(
                      section: widget.model.termsAndConditions,
                      svgKey: 'terms_cms/terms/svg',
                    ),
                  ),
                  SizedBox(height: _isDesktop ? 16 : 12),

                  // ── Privacy Policy accordion ─────────────────────────
                  _accordion(
                    title: widget.isAr
                        ? 'سياسة الخصوصية'
                        : 'Privacy Policy',
                    isOpen: _privacyOpen,
                    onToggle: () =>
                        setState(() => _privacyOpen = !_privacyOpen),
                    child: _sectionContent(
                      section: widget.model.privacyPolicy,
                      svgKey: 'terms_cms/privacy/svg',
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: _isDesktop ? 24 : 16,
                  vertical: _isDesktop ? 18 : 14),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: _isDesktop ? 16 : (_isMobView ? 13 : 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: _isDesktop ? 24 : 20,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.symmetric( horizontal:  _isDesktop ? 0 : 16 , vertical: 16.h),
              child: child,
            ),
        ],
      ),
    );
  }

  // ── Section content — Desktop: row, Tablet/Mobile: column ─────────────────
  Widget _sectionContent({
    required TermsSection section,
    required String       svgKey,
  }) {
    final desc    = widget.isAr
        ? section.description.ar
        : section.description.en;
    final svgUrl  = section.svgUrl;
    final hasSvg  = _bytes(svgKey) != null || svgUrl.isNotEmpty;

    final double svgSize = _isDesktop ? 180 : (_isMobView ? 100 : 130);
    final double fontSize = _isDesktop ? 14 : (_isMobView ? 11 : 12);

    final Widget svgW = hasSvg
        ? _svgWidget(
      storageKey:  svgKey,
      fallbackUrl: svgUrl,
      width:       svgSize,
      height:      svgSize,
    )
        : const SizedBox.shrink();

    final Widget textW = Text(
      desc.isEmpty
          ? (widget.isAr ? 'وصف القسم…' : 'Section description…')
          : desc,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: fontSize,
        height: 1.75,
        color: const Color(0xFF444444),
      ),
    );

    if (_isDesktop) {
      // Desktop: text left, SVG right (or reversed for RTL)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: textW),
          if (hasSvg) ...[
            const SizedBox(width: 32),
            svgW,
          ],
        ],
      );
    } else {
      // Tablet / Mobile: SVG top, text below
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSvg) ...[
            Center(child: svgW),
            SizedBox(height: _isMobView ? 12 : 16),
          ],
          textW,
        ],
      );
    }
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