// ******************* FILE INFO *******************
// File Name: about_preview_page.dart
// Screen 3 — About Us CMS: Preview with Desktop/Tablet/Mobile + ENG/AR toggle
// UPDATED: Matches Figma design exactly — same pattern as services_main_preview_page.dart
// UPDATED: ENG/AR toggle using CustomSegmentedTabs
// UPDATED: Proper device frame sizing (desktop=full, tablet=768, mobile=375)
// UPDATED: Vision/Mission/Values as separate green accordions
// UPDATED: Confirm dialog with illustration matching Figma
// UPDATED: Responsive sizing for all device modes

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

// ── Shared constants ──────────────────────────────────────────────────────────
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color secondary = Color(0xFFE8F5EE);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color hintText = Color(0xFF797979);
  static const Color labelText = Color(0xFF1A1A1A);
  static const Color border = Color(0xFFE0E0E0);
}

Color _hoverTint(Color primary) => primary.withOpacity(0.12);

enum _PreviewDevice { desktop, tablet, mobile }

// ── Device preview widths ─────────────────────────────────────────────────────
const double _kMobilePreviewWidth = 375.0;
const double _kTabletPreviewWidth = 768.0;

// ═══════════════════════════════════════════════════════════════════════════════
// XHR IMAGE CACHE — CORS-safe for Firebase Storage
// ═══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header =
  String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();
  final bool hintSvg = _isSvgUrl(url);
  Widget inner = FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: hintSvg),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return placeholder ?? SizedBox(width: width, height: height);
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(bytes,
              width: width,
              height: height,
              fit: fit,
              colorFilter: colorFilter);
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return errorWidget ??
          Icon(Icons.broken_image,
              color: Colors.grey[400],
              size: (width ?? height ?? 24).toDouble());
    },
  );
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE
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
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isAr = false;
  bool _visionOpen = true;
  bool _missionOpen = true;
  bool _valuesOpen = true;

  bool get _isRtl => _isAr;

  void _onSave() {
    showPublishConfirmDialog(
      context: context,
      title: 'EDITING ABOUT US DETAILS',
      subtitle: 'Do you want to save the changes made to this About Us?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: () async {
        await context.read<AboutCubit>().save(
          model: widget.model,
          imageUploads:
          widget.imageUploads.isEmpty ? null : widget.imageUploads,
        );
      },
    );
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2ED),
      body: BlocListener<AboutCubit, AboutState>(
        listener: (context, state) {
          if (state is AboutSaved) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const AboutMainPageMasterDashboard(),
                  ),
                      (route) => false,
                );
              }
            });
          }
          if (state is AboutError) {
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
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child:
                Icon(Icons.error_outline, color: Colors.white, size: 36.r),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                AppAdminNavbar(
                  activeLabel: 'Web Page',
                  homePage: HomeMainPage(),
                  webPage: HomeMainPage(),
                  jobListingPage: HomeMainPage(),
                ),
                SizedBox(height: 20.h),
                AdminSubNavBar(activeIndex: 3),
                SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // ── Page title ─────────────────────────────────────
                      Text(
                        'Preview About Us Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // ── Top controls: Device tabs + Lang toggle ────────
                      _buildTopControls(),
                      SizedBox(height: 15.h),

                      // ── Vision Accordion ───────────────────────────────
                      _greenAccordion(
                        title: 'Vision',
                        isOpen: _visionOpen,
                        onToggle: () =>
                            setState(() => _visionOpen = !_visionOpen),
                        child: _visionContent(),
                      ),
                      SizedBox(height: 12.h),

                      // ── Mission Accordion ──────────────────────────────
                      _greenAccordion(
                        title: 'Mission',
                        isOpen: _missionOpen,
                        onToggle: () =>
                            setState(() => _missionOpen = !_missionOpen),
                        child: _missionContent(),
                      ),
                      SizedBox(height: 12.h),

                      // ── Values Accordion ───────────────────────────────
                      _greenAccordion(
                        title: 'Values',
                        isOpen: _valuesOpen,
                        onToggle: () =>
                            setState(() => _valuesOpen = !_valuesOpen),
                        child: _valuesContent(),
                      ),
                      SizedBox(height: 24.h),

                      // ── Back | Save ────────────────────────────────────
                      _buildActionButtons(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOP CONTROLS — Device tabs + ENG/AR toggle (same as services preview)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTopControls() {
    final langToggle = CustomSegmentedTabs(
      tabs: ['ENG', 'AR'],
      selectedIndex: _isAr ? 1 : 0,
      onTabSelected: (i) => setState(() => _isAr = i == 1),
      selectedColor: _C.primary,
      unselectedColor: Colors.transparent,
      selectedTextColor: Colors.white,
      unselectedTextColor: _C.labelText,
      containerColor: _C.border.withOpacity(0.45),
      equalWidth: false,
      containerPadding:
      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
    );

    return Row(
      children: [
        _buildDeviceTabBar(),
        const Spacer(),
        langToggle,
      ],
    );
  }

  Widget _buildDeviceTabBar() {
    final tabs = [
      (_PreviewDevice.desktop, 'Desktop'),
      (_PreviewDevice.tablet, 'Tablet'),
      (_PreviewDevice.mobile, 'Mobile'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tabs.map((entry) {
        final device = entry.$1;
        final label = entry.$2;
        final isActive = _device == device;
        return Padding(
          padding: EdgeInsets.only(right: 28.w),
          child: GestureDetector(
            onTap: () => setState(() => _device = device),
            child: IntrinsicWidth(
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
                        isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? _C.primary : _C.hintText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: isActive ? _C.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GREEN ACCORDION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _greenAccordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
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
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(child: _wrapInDeviceFrame(child)),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEVICE FRAME WRAPPER — sizes content to device width
  // ══════════════════════════════════════════════════════════════════════════

  Widget _wrapInDeviceFrame(Widget child) {
    final Widget dirChild = Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );

    if (_device == _PreviewDevice.mobile) {
      return Container(
        width: _kMobilePreviewWidth,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: dirChild,
      );
    }

    if (_device == _PreviewDevice.tablet) {
      return Container(
        width: _kTabletPreviewWidth,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: dirChild,
      );
    }

    // Desktop — full width
    return dirChild;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VISION CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _visionContent() {
    final section = widget.model.vision;
    final subDesc = _ab(section.subDescription, _isRtl);
    final desc = _ab(section.description, _isRtl);

    final double iconBoxSize = _device == _PreviewDevice.mobile ? 36.0 : 42.0;
    final double iconImgSize = _device == _PreviewDevice.mobile ? 18.0 : 20.0;
    final double titleFs = _device == _PreviewDevice.mobile ? 14.0 : 16.0;
    final double subDescFs = _device == _PreviewDevice.mobile ? 10.0 : 12.0;
    final double descFs = _device == _PreviewDevice.mobile ? 10.0 : 13.0;
    final double svgSize = _device == _PreviewDevice.mobile
        ? 120.0
        : (_device == _PreviewDevice.tablet ? 160.0 : 180.0);

    final bool isDesktop = _device == _PreviewDevice.desktop;

    // ── Tab header row (icon + title + sub desc)
    Widget tabHeader = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: section.iconUrl.isNotEmpty
                ? _netImg(
              url: section.iconUrl,
              width: iconImgSize,
              height: iconImgSize,
              fit: BoxFit.contain,
              colorFilter:
              ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
                : Icon(Icons.visibility_outlined,
                size: iconImgSize, color: Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRtl ? 'الرؤية' : 'Vision',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: titleFs,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                ),
              ),
              if (subDesc.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  subDesc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: subDescFs,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // ── Description + SVG
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: tab header
          SizedBox(
            width: 280,
            child: tabHeader,
          ),
          SizedBox(width: 16),
          // Right: description + SVG
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: descFs,
                        fontWeight: FontWeight.w400,
                        height: 1.75,
                      ),
                    ),
                  ),
                  if (section.svgUrl.isNotEmpty) ...[
                    SizedBox(width: 16),
                    _netImg(
                      url: section.svgUrl,
                      width: svgSize,
                      height: svgSize,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Tablet / Mobile — stacked layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tabHeader,
        SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.svgUrl.isNotEmpty) ...[
                Center(
                  child: _netImg(
                    url: section.svgUrl,
                    width: svgSize,
                    height: svgSize,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 12),
              ],
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: descFs,
                  fontWeight: FontWeight.w400,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MISSION CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _missionContent() {
    final section = widget.model.mission;
    final subDesc = _ab(section.subDescription, _isRtl);
    final desc = _ab(section.description, _isRtl);

    final double iconBoxSize = _device == _PreviewDevice.mobile ? 36.0 : 42.0;
    final double iconImgSize = _device == _PreviewDevice.mobile ? 18.0 : 20.0;
    final double titleFs = _device == _PreviewDevice.mobile ? 14.0 : 16.0;
    final double subDescFs = _device == _PreviewDevice.mobile ? 10.0 : 12.0;
    final double descFs = _device == _PreviewDevice.mobile ? 10.0 : 13.0;
    final double svgSize = _device == _PreviewDevice.mobile
        ? 120.0
        : (_device == _PreviewDevice.tablet ? 160.0 : 180.0);

    final bool isDesktop = _device == _PreviewDevice.desktop;

    Widget tabHeader = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: section.iconUrl.isNotEmpty
                ? _netImg(
              url: section.iconUrl,
              width: iconImgSize,
              height: iconImgSize,
              fit: BoxFit.contain,
              colorFilter:
              ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
                : Icon(Icons.flag_outlined,
                size: iconImgSize, color: Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRtl ? 'الرسالة' : 'Mission',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: titleFs,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                ),
              ),
              if (subDesc.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  subDesc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: subDescFs,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 280, child: tabHeader),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: descFs,
                        fontWeight: FontWeight.w400,
                        height: 1.75,
                      ),
                    ),
                  ),
                  if (section.svgUrl.isNotEmpty) ...[
                    SizedBox(width: 16),
                    _netImg(
                      url: section.svgUrl,
                      width: svgSize,
                      height: svgSize,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tabHeader,
        SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.svgUrl.isNotEmpty) ...[
                Center(
                  child: _netImg(
                    url: section.svgUrl,
                    width: svgSize,
                    height: svgSize,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 12),
              ],
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: descFs,
                  fontWeight: FontWeight.w400,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALUES CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _valuesContent() {
    final values = widget.model.values;
    if (values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    // First value goes in the left tab header, rest in the grid
    final firstValue = values.first;
    final otherValues = values.length > 1 ? values.sublist(1) : <AboutValueItem>[];

    final double iconBoxSize = _device == _PreviewDevice.mobile ? 36.0 : 42.0;
    final double iconImgSize = _device == _PreviewDevice.mobile ? 18.0 : 20.0;
    final double titleFs = _device == _PreviewDevice.mobile ? 14.0 : 16.0;
    final double subDescFs = _device == _PreviewDevice.mobile ? 10.0 : 12.0;

    final bool isDesktop = _device == _PreviewDevice.desktop;

    Widget tabHeader = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: firstValue.iconUrl.isNotEmpty
                ? _netImg(
              url: firstValue.iconUrl,
              width: iconImgSize,
              height: iconImgSize,
              fit: BoxFit.contain,
              colorFilter:
              ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
                : Icon(Icons.star_outline,
                size: iconImgSize, color: Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRtl ? 'القيم' : 'Values',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: titleFs,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                ),
              ),
              if (_ab(firstValue.shortDescription, _isRtl).isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  _ab(firstValue.shortDescription, _isRtl),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: subDescFs,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 280, child: tabHeader),
          SizedBox(width: 16),
          Expanded(
            child: _ValuesGridPreview(
              values: otherValues,
              isRtl: _isRtl,
              primaryColor: _C.primary,
              secondaryColor: _C.secondary,
              device: _device,
            ),
          ),
        ],
      );
    }

    // Tablet / Mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tabHeader,
        SizedBox(height: 14),
        _ValuesGridPreview(
          values: otherValues,
          isRtl: _isRtl,
          primaryColor: _C.primary,
          secondaryColor: _C.secondary,
          device: _device,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Back',
                style:
                StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Save',
                style:
                StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID PREVIEW — responsive card grid with detail panel
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridPreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final _PreviewDevice device;

  const _ValuesGridPreview({
    required this.values,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.device,
  });

  @override
  State<_ValuesGridPreview> createState() => _ValuesGridPreviewState();
}

class _ValuesGridPreviewState extends State<_ValuesGridPreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'No additional values.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    final bool isMobile = widget.device == _PreviewDevice.mobile;
    final double cardW = isMobile ? 140.0 : 100.0;
    final double iconSize = isMobile ? 16.0 : 22.0;
    final double fontSize = isMobile ? 8.0 : 9.0;
    final double cardPad = isMobile ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.primaryColor.withOpacity(.06),
            widget.primaryColor.withOpacity(.25),
            widget.primaryColor.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.values.length, (i) {
              final v = widget.values[i];
              return _ValueGridCard(
                title: _ab(v.title, widget.isRtl),
                iconUrl: v.iconUrl,
                isSelected: i == idx,
                primaryColor: widget.primaryColor,
                width: cardW,
                iconSize: iconSize,
                fontSize: fontSize,
                padding: cardPad,
                rowLayout: isMobile,
                onTap: () => setState(() => _selectedIndex = i),
              );
            }),
          ),
          SizedBox(height: 12),
          _ValueDetailPanel(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            device: widget.device,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUE GRID CARD — hover + selected states
// ═══════════════════════════════════════════════════════════════════════════════

class _ValueGridCard extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  final bool rowLayout;

  const _ValueGridCard({
    required this.title,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.width,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.onTap,
    this.rowLayout = false,
  });

  @override
  State<_ValueGridCard> createState() => _ValueGridCardState();
}

class _ValueGridCardState extends State<_ValueGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? _netImg(
      url: widget.iconUrl,
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        sel ? Colors.white : widget.primaryColor,
        BlendMode.srcIn,
      ),
    )
        : Icon(Icons.star_outline,
        size: widget.iconSize,
        color: sel ? Colors.white : widget.primaryColor);

    final Widget titleWidget = Text(
      widget.title,
      textAlign: widget.rowLayout ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        color: sel
            ? Colors.white
            : (_hovered ? widget.primaryColor : Colors.black87),
        height: 1.35,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.rowLayout ? null : widget.width,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color:
            sel ? widget.primaryColor : (_hovered ? hoverBg : Colors.white),
            borderRadius: BorderRadius.circular(10),
            boxShadow: sel
                ? [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          child: widget.rowLayout
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: 6),
              Expanded(child: titleWidget),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: 6),
              titleWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ═══════════════════════════════════════════════════════════════════════════════

class _ValueDetailPanel extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final _PreviewDevice device;

  const _ValueDetailPanel({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);

    final bool isMobile = device == _PreviewDevice.mobile;
    final double titleFs = isMobile ? 12.0 : 14.0;
    final double descFs = isMobile ? 10.0 : 12.0;
    final double iconBoxSize = isMobile ? 34.0 : 40.0;
    final double iconImgSize = isMobile ? 20.0 : 30.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
                  ? _netImg(
                url: value.iconUrl,
                width: iconImgSize,
                height: iconImgSize,
                fit: BoxFit.contain,
                colorFilter:
                ColorFilter.mode(primaryColor, BlendMode.srcIn),
              )
                  : Icon(Icons.star_outline, size: 20, color: primaryColor),
            ),
          ),
          SizedBox(height: 10),
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: titleFs,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
          ],
          if (shortDesc.isNotEmpty)
            Text(
              shortDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: descFs,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryBlack,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}