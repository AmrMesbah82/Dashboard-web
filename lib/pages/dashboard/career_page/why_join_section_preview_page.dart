// ******************* FILE INFO *******************
// File Name: why_join_section_preview_page.dart
// Preview page for Why Join Our Team / Our Interns / Our Teams
// UPDATED: _previewContent now mirrors the exact UI from careers_page.dart
//          — alternating left/right SVG + description layout for desktop/tablet
//          — stacked layout for mobile
//          — icon circle + title shown above each item row

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

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
}

enum _Device { desktop, tablet, mobile }

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

class _CareersSectionPreviewPageState extends State<CareersSectionPreviewPage> {
  _Device _device   = _Device.desktop;
  bool    _isAr     = false;
  bool    _isSaving = false;
  bool    _viewOpen = true;

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
            content: Text('${widget.sectionTitle} saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is CareersSectionError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CareersSectionCubit>();

        if (state is CareersSectionInitial ||
            state is CareersSectionLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        CareersSectionModel? data;
        if (state is CareersSectionLoaded) data = state.data;
        if (state is CareersSectionSaved)  data = state.data;

        return Scaffold(
          backgroundColor: _C.sectionBg,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 20.h),

                        // ── Page title ───────────────────────────────────────
                        Text(
                          'Preview ${widget.sectionTitle} Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color:      _C.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // ── Device tabs + ENG/AR ─────────────────────────────
                        Row(
                          children: [
                            _buildDeviceTabBar(),
                            const Spacer(),
                            _langChip('ENG',
                                active: !_isAr,
                                onTap: () => setState(() => _isAr = false)),
                            SizedBox(width: 4.w),
                            _langChip('ع',
                                active: _isAr,
                                onTap: () => setState(() => _isAr = true)),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── View accordion ───────────────────────────────────
                        _viewAccordion(data),
                        SizedBox(height: 24.h),

                        // ── Bottom buttons ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Center(
                                    child: Text('Discard',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: _isSaving ? null : () => _save(cubit),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
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
                                        width: 18.w, height: 18.h,
                                        child:
                                        const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                        : Text('Save',
                                        style: StyleText
                                            .fontSize14Weight600
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Device tab bar ─────────────────────────────────────────────────────────
  Widget _buildDeviceTabBar() {
    final tabs = [_Device.desktop, _Device.tablet, _Device.mobile];
    return Row(
      children: List.generate(tabs.length, (i) {
        final d        = tabs[i];
        final isActive = _device == d;
        final label    = d.name[0].toUpperCase() + d.name.substring(1);
        return Padding(
          padding: EdgeInsets.only(right: 24.w),
          child: GestureDetector(
            onTap: () => setState(() => _device = d),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize:   15.sp,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? _C.primary : _C.hintText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color:  isActive ? _C.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Language chip ──────────────────────────────────────────────────────────
  Widget _langChip(String label,
      {required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? _C.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: active ? Colors.white : _C.labelText,
          ),
        ),
      ),
    );
  }

  // ── View accordion ─────────────────────────────────────────────────────────
  Widget _viewAccordion(CareersSectionModel? data) {
    return Container(
      decoration: BoxDecoration(
        color:        _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // accordion header
          GestureDetector(
            onTap: () => setState(() => _viewOpen = !_viewOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _viewOpen
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('View',
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _viewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20.sp,
                  ),
                ],
              ),
            ),
          ),

          // accordion body
          if (_viewOpen)
            data == null || data.items.isEmpty
                ? Padding(
              padding: EdgeInsets.all(40.w),
              child: Center(
                child: Text(
                  'No items to preview.',
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: _C.hintText),
                ),
              ),
            )
                : _previewContent(data),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PREVIEW CONTENT — mirrors careers_page.dart layout exactly
  // ══════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════
  // PREVIEW CONTENT — matches Figma exactly
  // ══════════════════════════════════════════════════════════════════════════
  Widget _previewContent(CareersSectionModel data) {
    if (data.items.isEmpty) return const SizedBox();

    final bool isMobile = _device == _Device.mobile;
    final bool isTablet = _device == _Device.tablet;

    final double svgW   = isMobile ? 160.w : isTablet ? 160.w : 220.w;
    final double svgH   = isMobile ? 140.h : isTablet ? 140.h : 180.h;
    final double textFz = isMobile ? 11.sp  : isTablet ? 12.sp : 13.sp;
    final double gap    = isMobile ? 12.w   : isTablet ? 20.w  : 40.w;
    final double rowGap = isMobile ? 24.h   : isTablet ? 32.h  : 40.h;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      child: Directionality(
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.items.asMap().entries.map((entry) {
            final int    i      = entry.key;
            final item          = entry.value;
            final bool   imgLeft = i.isOdd; // odd → SVG left, even → SVG right

            final String desc = _isAr
                ? (item.description.ar.isNotEmpty
                ? item.description.ar
                : item.description.en)
                : item.description.en;

            // ── Mobile: stacked ──────────────────────────────────────────
            if (isMobile) {
              return Padding(
                padding: EdgeInsets.only(bottom: rowGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.svgUrl.isNotEmpty)
                      Center(
                        child: SvgPicture.network(
                          item.svgUrl,
                          width:  svgW,
                          height: svgH,
                          fit:    BoxFit.contain,
                          placeholderBuilder: (_) => Container(
                            width: svgW, height: svgH,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: svgW, height: svgH,
                        decoration: BoxDecoration(
                          color:        Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey, size: 32.sp),
                        ),
                      ),
                    SizedBox(height: 14.h),
                    Text(
                      desc,
                      textDirection:
                      _isAr ? TextDirection.rtl : TextDirection.ltr,
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

            // ── Desktop / Tablet: alternating left-right ─────────────────
            final Widget textWidget = Expanded(
              flex: 5,
              child: Text(
                desc,
                textDirection:
                _isAr ? TextDirection.rtl : TextDirection.ltr,
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
              child: item.svgUrl.isNotEmpty
                  ? SvgPicture.network(
                item.svgUrl,
                width:  svgW,
                height: svgH,
                fit:    BoxFit.contain,
                placeholderBuilder: (_) => Container(
                  width: svgW, height: svgH,
                  color: Colors.grey.shade100,
                ),
              )
                  : Container(
                height: svgH,
                decoration: BoxDecoration(
                  color:        Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(Icons.image_outlined,
                      color: Colors.grey, size: 40.sp),
                ),
              ),
            );

            // even (0,2,4…) → text | SVG
            // odd  (1,3,5…) → SVG | text
            final List<Widget> rowChildren = imgLeft
                ? [imageWidget, SizedBox(width: gap), textWidget]
                : [textWidget,  SizedBox(width: gap), imageWidget];

            return Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: rowChildren,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Icon circle + title row ────────────────────────────────────────────────────
class _IconTitleRow extends StatelessWidget {
  final String iconUrl;
  final String svgUrl;   // fallback if no icon
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
    // use iconUrl if available, otherwise fall back to svgUrl
    final String displayUrl =
    iconUrl.isNotEmpty ? iconUrl : svgUrl;

    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize:  MainAxisSize.min,
      children: [
        // circle icon
        Container(
          width:  iconSz + 8.w,
          height: iconSz + 8.w,
          decoration: const BoxDecoration(
            color: Color(0xFF008037),
            shape: BoxShape.circle,
          ),
          child: displayUrl.isNotEmpty
              ? ClipOval(
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: SvgPicture.network(
                displayUrl,
                fit:    BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
                placeholderBuilder: (_) => const SizedBox(),
              ),
            ),
          )
              : Icon(Icons.work_outline,
              color: Colors.white, size: iconSz * 0.6),
        ),
        SizedBox(width: 10.w),

        // title text
        Flexible(
          child: Text(
            title,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize:   14.sp,
              fontWeight: FontWeight.w600,
              color:      const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}