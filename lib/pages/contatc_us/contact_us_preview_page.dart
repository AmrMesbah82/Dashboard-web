// ******************* FILE INFO *******************
// File Name: contact_us_cms_preview_page.dart
// UPDATED: Matches about_preview_page.dart style —
//          Admin shell, Device frames (Desktop/Tablet/Mobile),
//          ENG/AR toggle, Back/Save buttons, StyleText throughout.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../core/two_tab.dart';
import '../../../widgets/app_admin_navbar.dart';

// ── Admin-shell colors (mirrors about_preview_page.dart _AC) ─────────────────
class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
}

// ── User-app palette ──────────────────────────────────────────────────────────
const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kDivider    = Color(0xFFDDE8DD);

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

// ── HtmlElementView image helper ──────────────────────────────────────────────
Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final id =
      'cu-pv-${url.hashCode}-${width?.toInt()}-${height?.toInt()}-${fit.index}';
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

// ── SVG via HtmlElementView ───────────────────────────────────────────────────
Widget _svgImg({
  required String url,
  double size = 20,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  return SvgPicture.network(
    url,
    width: size,
    height: size,
    fit: BoxFit.contain,
    placeholderBuilder: (_) =>
        Icon(Icons.link, size: size, color: _kGreen),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE  (admin shell — mirrors AboutPreviewPageLast)
// ═══════════════════════════════════════════════════════════════════════════════
class ContactUsCmsPreviewPage extends StatefulWidget {
  const ContactUsCmsPreviewPage({super.key});

  @override
  State<ContactUsCmsPreviewPage> createState() =>
      _ContactUsCmsPreviewPageState();
}

class _ContactUsCmsPreviewPageState extends State<ContactUsCmsPreviewPage> {
  _PreviewDevice    _device   = _PreviewDevice.desktop;
  bool              _isAr     = false;
  bool              _isSaving = false;
  ContactUsCmsModel? _loadedData; // cached so _onSave can always access it

  void _onBack() => Navigator.pop(context);

  void _onSave() {
    final data = _loadedData;
    if (data == null) return;

    showPublishConfirmDialog(
      context: context,
      title: 'EDITING CONTACT US DETAILS',
      subtitle:
      'Do you want to save the changes made to this Contact Us page?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: () async {
        setState(() => _isSaving = true);
        try {
          await context.read<ContactUsCmsCubit>().save(model: data);
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
      listener: (context, state) {
        if (state is ContactUsCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is ContactUsCmsError && _isSaving) {
          setState(() => _isSaving = false);
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
              child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
            ),
          );
        }
      },
      child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          if (state is ContactUsCmsLoading || state is ContactUsCmsInitial) {
            return const Scaffold(
              backgroundColor: _AC.back,
              body: Center(
                  child: CircularProgressIndicator(color: _AC.primary)),
            );
          }

          if (state is ContactUsCmsError && _loadedData == null) {
            return Scaffold(
              backgroundColor: _AC.back,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}',
                        style: StyleText.fontSize14Weight400
                            .copyWith(color: Colors.red)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ContactUsCmsCubit>().load(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _AC.primary),
                      child: Text('Retry',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ContactUsCmsLoaded) {
            _loadedData = state.data; // cache latest data
            return _buildShell(state.data);
          }

          if (state is ContactUsCmsSaved) {
            _loadedData = state.data; // keep data visible during nav transition
            return _buildShell(state.data);
          }

          // Fallback: if we already have data (e.g. error after load), keep showing it
          if (_loadedData != null) return _buildShell(_loadedData!);

          return const Scaffold(
              backgroundColor: _AC.back, body: SizedBox.shrink());
        },
      ),
    );
  }

  Widget _buildShell(ContactUsCmsModel data) {
    return Stack(
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

                    // ── Page title ──────────────────────────────────
                    Text(
                      'Preview Contact Us Details',
                      style: StyleText.fontSize45Weight600.copyWith(
                          color: _AC.primary,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 16.h),

                    // ── Device tabs + Language toggle ───────────────
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

                    // ── Scaled device frame ─────────────────────────
                    LayoutBuilder(
                        builder: (ctx, box) =>
                            _buildFrame(box.maxWidth, data)),

                    SizedBox(height: 24.h),

                    // ── Back + Save ─────────────────────────────────
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
                            onTap: _isSaving ? null : _onSave,
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 200),
                              height: 44.h,
                              decoration: BoxDecoration(
                                  color: _isSaving
                                      ? _AC.primary.withOpacity(0.5)
                                      : _AC.primary,
                                  borderRadius:
                                  BorderRadius.circular(6.r)),
                              child: Center(
                                child: _isSaving
                                    ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child:
                                  const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                                    : Text('Save',
                                    style:
                                    StyleText.fontSize14Weight600
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

        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: const Center(
                child: CircularProgressIndicator(color: _AC.primary)),
          ),
      ],
    );
  }

  // ── Tab widget ──────────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
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
                fontSize: 15.sp,
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _AC.primary : _AC.hintText,
              ),
            ),
          ),
          Container(
              height: 2,
              width: label.length * 8.0,
              color: active ? _AC.primary : Colors.transparent),
        ],
      ),
    );
  }

  // ── Frame builder ───────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, ContactUsCmsModel data) {
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES  (mirrors about_preview_page.dart exactly)
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final ContactUsCmsModel data;
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
    );
  }
}

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final ContactUsCmsModel data;
  final bool isAr;
  const _TabletFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

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
  final ContactUsCmsModel data;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

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
                      data: data,
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
// PREVIEW CONTENT  — renders the actual Contact Us page at native resolution
// ═══════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth, fakeHeight;
  final ContactUsCmsModel data;
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
  double get _hPad    => _isDesktop ? 0 : (_isMobView ? 16 : 24);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Material(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page title ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _hPad,
                      vertical: _isDesktop ? 40 : 24),
                  child: Text(
                    isAr ? 'اتصل بنا' : 'Contact us',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: _isDesktop ? 48 : (_isMobView ? 34 : 38),
                      fontWeight: FontWeight.w900,
                      color: _kGreen,
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _hPad),
                  child: _isMobView
                      ? _buildMobileLayout()
                      : _isDesktop
                      ? _buildDesktopLayout()
                      : _buildTabletLayout(),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop: Info Card + Form side-by-side ──────────────────────────────────
  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _InfoCard(data: data, isAr: isAr, compact: false)),
              const SizedBox(width: 28),
              Expanded(flex: 3, child: _FormPlaceholder(isAr: isAr, compact: false)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _OfficeLocationsSection(data: data, isAr: isAr, isMobile: false),
      ],
    );
  }

  // ── Tablet: stacked with moderate sizing ────────────────────────────────────
  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _InfoCard(data: data, isAr: isAr, compact: true)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _FormPlaceholder(isAr: isAr, compact: true)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _OfficeLocationsSection(data: data, isAr: isAr, isMobile: false),
      ],
    );
  }

  // ── Mobile: stacked vertically ──────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(data: data, isAr: isAr, compact: true),
        const SizedBox(height: 20),
        _FormPlaceholder(isAr: isAr, compact: true),
        const SizedBox(height: 32),
        _OfficeLocationsSection(data: data, isAr: isAr, isMobile: true),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final ContactUsCmsModel data;
  final bool isAr, compact;

  const _InfoCard(
      {required this.data, required this.isAr, required this.compact});

  @override
  Widget build(BuildContext context) {
    final double pad      = compact ? 20 : 28;
    final double rad      = compact ? 14 : 16;
    final double descSize = compact ? 12 : 15;
    final double lblSize  = compact ? 13 : 15;
    final double valSize  = compact ? 11 : 13;

    final String desc = isAr
        ? (data.subDescription.ar.isNotEmpty
        ? data.subDescription.ar
        : data.subDescription.en)
        : data.subDescription.en;
    final String emailLabel = isAr ? 'البريد الإلكتروني' : 'Email';
    final String followLabel = isAr ? 'تابعنا' : 'Follow Us';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(rad),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: descSize,
              height: 1.65,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: compact ? 22 : 32),

          Text(
            emailLabel,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: lblSize,
              fontWeight: FontWeight.w600,
              color: _kGreen,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            data.email,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: valSize,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: compact ? 20 : 28),

          Text(
            followLabel,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: lblSize,
              fontWeight: FontWeight.w600,
              color: _kGreen,
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.socialIcons
                .where((s) => s.iconUrl.isNotEmpty)
                .map((s) => _SocialIconBox(
                iconUrl: s.iconUrl, size: compact ? 34 : 38))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Social icon ───────────────────────────────────────────────────────────────
class _SocialIconBox extends StatelessWidget {
  final String iconUrl;
  final double size;
  const _SocialIconBox({required this.iconUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: _kGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SvgPicture.network(
          iconUrl,
          width: size * 0.5,
          height: size * 0.5,
          fit: BoxFit.contain,
          placeholderBuilder: (_) =>
              Icon(Icons.link, size: size * 0.5, color: _kGreen),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════════
class _FormPlaceholder extends StatelessWidget {
  final bool isAr, compact;
  const _FormPlaceholder({required this.isAr, required this.compact});

  @override
  Widget build(BuildContext context) {
    final double pad     = compact ? 20 : 28;
    final double rad     = compact ? 14 : 16;
    final double titleSz = compact ? 20 : 26;
    final double btnH    = compact ? 48 : 50;

    final String title     = isAr ? 'تواصل معنا'       : 'GET IN TOUCH';
    final String noticeMsg = isAr
        ? 'هذه معاينة. حقول النموذج غير نشطة.'
        : 'This is a preview. Form inputs are not functional.';
    final List<String> fields = isAr
        ? ['الاسم الكامل', 'البريد الإلكتروني', 'رقم الهاتف', 'الموضوع']
        : ['Full Name', 'Email', 'Phone Number', 'Subject'];
    final String msgLabel  = isAr ? 'الرسالة' : 'Message';
    final String btnLabel  = isAr ? 'إرسال'   : 'Send';

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(rad),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: titleSz,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.black,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),

          Text(
            noticeMsg,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.black45,
            ),
          ),
          SizedBox(height: compact ? 14 : 20),

          ...fields.map((f) => _placeholderField(f, compact)),
          _placeholderFieldLarge(msgLabel, compact),

          SizedBox(height: compact ? 6 : 8),

          SizedBox(
            width: double.infinity,
            height: btnH,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                btnLabel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderField(String label, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: compact ? 11 : 13,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _placeholderFieldLarge(String label, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: compact ? 11 : 13,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: compact ? 80 : 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OFFICE LOCATIONS SECTION
// ═══════════════════════════════════════════════════════════════════════════════
class _OfficeLocationsSection extends StatelessWidget {
  final ContactUsCmsModel data;
  final bool isAr, isMobile;

  const _OfficeLocationsSection(
      {required this.data, required this.isAr, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final String heading = isAr ? 'مواقع المكاتب' : 'Office Locations';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isMobile ? 22 : 30,
            fontWeight: FontWeight.w900,
            color: _kGreen,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),

        if (isMobile)
          Column(
            children: data.officeLocations
                .map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _OfficeCard(location: o, isAr: isAr),
            ))
                .toList(),
          )
        else
          Row(
            children: data.officeLocations.asMap().entries.map((e) {
              final bool isLast =
                  e.key == data.officeLocations.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 16),
                  child: _OfficeCard(location: e.value, isAr: isAr),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Office card ───────────────────────────────────────────────────────────────
class _OfficeCard extends StatelessWidget {
  final ContactOfficeLocation location;
  final bool isAr;

  const _OfficeCard({required this.location, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final String name = isAr
        ? (location.locationName.ar.isNotEmpty
        ? location.locationName.ar
        : location.locationName.en)
        : location.locationName.en;
    final String t1 = isAr
        ? (location.text1.ar.isNotEmpty ? location.text1.ar : location.text1.en)
        : location.text1.en;
    final String t2 = isAr
        ? (location.text2.ar.isNotEmpty ? location.text2.ar : location.text2.en)
        : location.text2.en;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (location.iconUrl.isNotEmpty)
            _netImg(
              url: location.iconUrl,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(8),
            )
          else
            const Icon(Icons.location_on, size: 100, color: _kGreen),
          const SizedBox(height: 16),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kGreen,
            ),
          ),
          const SizedBox(height: 6),

          if (t1.isNotEmpty)
            Text(
              t1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: Colors.black45),
            ),
          if (t2.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                t2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR  (identical to about_preview_page.dart)
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}