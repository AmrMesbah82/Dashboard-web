// ******************* FILE INFO *******************
// File Name: careers_preview.dart
// Created by: Amr Mesbah
// Screen: 1.3 — Preview of Careers "Main" section (Desktop / Tablet / Mobile)
//               Mirrors about_us_preview.dart architecture exactly.
//               Publish confirm dialog → BlocListener navigates to CareersMainPageMaster.
//
// CHANGES (Figma sync):
//   • Added _SiteNavBar inside _PreviewContent (mirrors live site header)
//   • Added green "View" collapsible bar above browser chrome
//   • Hero section now renders rich description with bullet paragraphs
//   • Hero tagline + Apply Now button row at bottom of hero
//   • Stats rendered as number-headline cards (82%, 93%, 6, 75%, 1,200+, 6)
//   • Bottom action row: "Discard" (grey) + spacer + "Save" (green)

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/two_tab.dart';
import '../../../data/model/careers_model.dart';
import '../../controller/careers_cubit.dart';
import '../../controller/careers_state.dart';
import 'careers_main_page.dart'; // CareersMainPageMaster

// ── Admin-shell colors ────────────────────────────────────────────────────────
class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color red       = Color(0xFFD32F2F);
}

// ── User-app palette (mirrors live careers page) ──────────────────────────────
const Color _kGreen      = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kDivider    = Color(0xFFDDE8DD);
const Color _kBodyBg     = Color(0xFFF8F9FA);

// ── Device viewport constants ─────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1200.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  900.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

// ── Network image via HtmlElementView ────────────────────────────────────────
Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final id =
      'careers-pv-${url.hashCode}-${width?.toInt()}-${height?.toInt()}-${fit.index}';
  ui_web.platformViewRegistry.registerViewFactory(id, (_) {
    final img = html.ImageElement()
      ..src = url
      ..style.width  = '100%'
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
class CareersPreviewPage extends StatefulWidget {
  const CareersPreviewPage({super.key});
  @override
  State<CareersPreviewPage> createState() => _CareersPreviewPageState();
}

class _CareersPreviewPageState extends State<CareersPreviewPage> {
  _PreviewDevice _device       = _PreviewDevice.desktop;
  bool           _isAr         = false;
  bool           _isPublishing = false;

  void _onBack() => Navigator.pop(context);

  void _onSave(CareersCmsModel data) {
    showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH CAREERS PAGE',
      subtitle:
      'Do you want to publish the changes made to this Careers page?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: () async {
        if (!mounted) return;
        setState(() => _isPublishing = true);
        try {
          await context.read<CareersCmsCubit>().save(data);
        } finally {
          if (mounted) setState(() => _isPublishing = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CareersCmsCubit, CareersCmsState>(
      listener: (context, state) {
        if (state is CareersCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const CareersMainPageMaster()),
                    (route) => false,
              );
            }
          });
        }
        if (state is CareersCmsError) {
          if (mounted) setState(() => _isPublishing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _AC.red,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: _AC.back,
            body: BlocBuilder<CareersCmsCubit, CareersCmsState>(
              builder: (context, state) {
                CareersCmsModel? data;
                if (state is CareersCmsLoaded) data = state.data;
                if (state is CareersCmsSaved)  data = state.data;
                data ??= context.read<CareersCmsCubit>().current;

                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          AdminSubNavBar(activeIndex: 5),
                          SizedBox(height: 16.h),

                          // ── Page title ──────────────────────────────────
                          Text(
                            'Preview Main Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color:      ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
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
                                  selectedColor:       ColorPick.primary,
                                  unselectedColor:     Colors.white,
                                  selectedTextColor:   Colors.white,
                                  unselectedTextColor: AppColors.text,
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

                          // ── Scaled device frame ─────────────────────────
                          LayoutBuilder(
                            builder: (ctx, box) =>
                                _buildFrame(box.maxWidth, data!),
                          ),

                          SizedBox(height: 24.h),

                          // ── Discard + Save buttons ──────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _onBack,
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color:        ColorPick.discard,
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
                                  onTap: _isPublishing
                                      ? null
                                      : () => _onSave(data!),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _isPublishing
                                          ? ColorPick.primary.withOpacity(0.5)
                                          : ColorPick.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: _isPublishing
                                          ? SizedBox(
                                        width:  18.w,
                                        height: 18.h,
                                        child: const CircularProgressIndicator(
                                          color:       Colors.white,
                                          strokeWidth: 2,
                                        ),
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
                );
              },
            ),
          ),

          // ── Full-screen publishing overlay ─────────────────────────────
          if (_isPublishing)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(color: ColorPick.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ── Device tab pill ────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
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
                color:      active ? ColorPick.primary : AppColors.secondaryText,
              ),
            ),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? ColorPick.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame builder ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, CareersCmsModel data) {
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
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

// ── Desktop ───────────────────────────────────────────────────────────────────
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final CareersCmsModel data;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width:  containerWidth,
      color:  _AC.back,
      child: Column(
        children: [
          // Green "View" bar
          _ViewBar(),
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
  final CareersCmsModel data;
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
              border: Border.all(color: ColorPick.white, width: 2),
              color:  Colors.white,
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
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
        ],
      ),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────
class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final CareersCmsModel data;
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
              border: Border.all(color: ColorPick.white, width: 2),
              color:  Colors.white,
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // top notch bar
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color:        ColorPick.white,
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
                  color:   Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 4,
                      decoration: BoxDecoration(
                        color:        ColorPick.white,
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
// GREEN "VIEW" COLLAPSIBLE BAR  (Figma header above browser frame)
// ═══════════════════════════════════════════════════════════════════════════════
class _ViewBar extends StatelessWidget {
  final double? width;
  const _ViewBar({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width ?? double.infinity,
      height: 36,
      decoration:  BoxDecoration(
        color:        _kGreen,
        borderRadius: BorderRadius.circular(8.r)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Text(
            'View',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT  — rendered at native device resolution then scaled
// ═══════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth, fakeHeight;
  final CareersCmsModel data;
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


                // ── Hero / Overview section ────────────────────────────
                _buildOverviewSection(),

                // ── Statistics section ─────────────────────────────────
                if (data.statistics.isNotEmpty) _buildStatisticsSection(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Overview (hero) ────────────────────────────────────────────────────────
  Widget _buildOverviewSection() {
    final desc   = isAr
        ? data.overview.description.ar
        : data.overview.description.en;
    final btnLbl = isAr
        ? data.overview.actionButtonLabel.ar
        : data.overview.actionButtonLabel.en;

    final double titleFz   = _isDesktop ? 28 : (_isMobView ? 18 : 22);
    final double descFz    = _isDesktop ? 13 : (_isMobView ? 10 : 12);
    final double taglineFz = _isDesktop ? 12 : (_isMobView ? 10 : 11);
    final double btnFz     = _isDesktop ? 13 : (_isMobView ? 10 : 11);

    // Hero headline — either from CMS or Figma static fallback
    final String headline = isAr
        ? 'انضم إلى فريق يقود الابتكار ويقدّرك'
        : 'Join a Team That Drives Innovation and Values You';

    // Tagline
    final String tagline = isAr
        ? 'انضم إلى بيانات — حيث يبدأ مستقبلك'
        : 'Join Bayanatz—where your future begins';

    return Container(
      width:   double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 36),
      color:   _kBodyBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero headline
          Text(
            headline,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   titleFz,
              fontWeight: FontWeight.w700,
              color:      const Color(0xFF1A1A1A),
              height:     1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Bullet 1
          _BulletText(
            text: isAr
                ? 'في بيانات، نحن في طليعة الابتكار — نتحدى الوضع الراهن باستمرار. بانضمامك إلينا، ستساهم في مشاريع رائدة ذات أثر حقيقي.'
                : 'At Bayanatz, we are at the forefront of innovation—constantly pushing boundaries and challenging the status quo. By joining us, you\'ll contribute to groundbreaking projects that create meaningful impact across industries and society.',
            fontSize: descFz,
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 1
          Text(
            isAr
                ? 'نفخر ببيئة ديناميكية وشاملة تعترف بمواهبك وترعاها. ثقافتنا تعزز النمو المستمر والتطوير الشخصي والتميز المهني.'
                : 'We take pride in fostering a dynamic and inclusive environment where your talents are not only recognized, but also nurtured. Our culture promotes continuous growth, personal development, and professional excellence.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 2
          Text(
            isAr
                ? 'نؤمن بالتوازن. لهذا نولي أهمية لرفاهية الموظف، ونوفر بيئة عمل داعمة ومرنة تمكّنك من الازدهار مهنياً وشخصياً.'
                : 'We believe in balance. That\'s why we prioritize employee well-being, offering a supportive and flexible work environment that empowers you to thrive—both professionally and personally.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
          SizedBox(height: descFz * 0.8),

          // Bullet 2
          _BulletText(
            text: isAr
                ? 'التنوع والشمول في صميم كل ما نفعله. نحتفل بوجهات النظر والخلفيات والتجارب الفريدة لكل عضو في الفريق.'
                : 'At Bayanatz, diversity and inclusion are at the heart of everything we do. We celebrate the unique perspectives, backgrounds, and experiences each team member brings.',
            fontSize: descFz,
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 3
          Text(
            isAr
                ? 'كن جزءاً من بيئة عمل مبنية على الإبداع والتعاون والابتكار الجريء.'
                : 'Be a part of a workplace built on creativity, collaboration, and bold innovation.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),

          // Description from CMS (if any)
          if (desc.isNotEmpty) ...[
            SizedBox(height: descFz * 0.8),
            Text(
              desc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   descFz,
                height:     1.7,
                color:      const Color(0xFF444444),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Tagline + CTA row
          if (_isMobView) ...[
            Text(
              tagline,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   taglineFz,
                color:      const Color(0xFF555555),
                fontStyle:  FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            if (btnLbl.isNotEmpty) _buildActionButton(btnLbl, btnFz),
          ] else
            Row(
              children: [
                Text(
                  tagline,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   taglineFz,
                    color:      const Color(0xFF555555),
                    fontStyle:  FontStyle.italic,
                  ),
                ),
                const Spacer(),
                if (btnLbl.isNotEmpty) _buildActionButton(btnLbl, btnFz),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color:        _kGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize:   fontSize,
          fontWeight: FontWeight.w600,
          color:      Colors.white,
        ),
      ),
    );
  }

  // ── Statistics section ─────────────────────────────────────────────────────
  Widget _buildStatisticsSection() {
    return Container(
      width:   double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 24),
      color:   Colors.white,
      child: _isMobView
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.statistics
            .map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _StatCard(stat: s, isAr: isAr, compact: true),
        ))
            .toList(),
      )
          : Wrap(
        spacing:    14,
        runSpacing: 14,
        children: data.statistics
            .map((s) => SizedBox(
          width: _isDesktop ? 220 : 180,
          child: _StatCard(stat: s, isAr: isAr, compact: false),
        ))
            .toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SITE NAVBAR  (mirrors live Bayanatz careers page header)
// ═══════════════════════════════════════════════════════════════════════════════
class _SiteNavBar extends StatelessWidget {
  final bool isMobile, isAr;
  const _SiteNavBar({required this.isMobile, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final links = isAr
        ? ['الرئيسية', 'الوظائف', 'الطلبات', 'الاستفسارات']
        : ['Home', 'Job Listing', 'Applications', 'Inquiries'];
    final ctaLabel = isAr ? 'صفحة الويب' : 'Web Page';

    return Container(
      width:  double.infinity,
      height: isMobile ? 44 : 52,
      color:  Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
      child: Row(
        children: [
          // Logo
          Container(
            width:  isMobile ? 28 : 36,
            height: isMobile ? 28 : 36,
            decoration: BoxDecoration(
              color:        _kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   16,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            ...links.map(
                  (l) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  l,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   13,
                    color:      Color(0xFF333333),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // CTA button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 14,
              vertical:   isMobile ? 4  : 6,
            ),
            decoration: BoxDecoration(
              color:        _kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ctaLabel,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
                color:      Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BULLET TEXT helper
// ═══════════════════════════════════════════════════════════════════════════════
class _BulletText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _BulletText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.45, right: 6),
          child: Container(
            width:  fontSize * 0.4,
            height: fontSize * 0.4,
            decoration: const BoxDecoration(
              color: Color(0xFF444444),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   fontSize,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAT CARD  — number-headline style matching Figma stats grid
// ═══════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final CareerStatItem stat;
  final bool isAr, compact;

  const _StatCard({
    required this.stat,
    required this.isAr,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final String title     = isAr ? stat.title.ar     : stat.title.en;
    final String shortDesc = isAr
        ? stat.shortDescription.ar
        : stat.shortDescription.en;

    final double titleFz = compact ? 20 : 24;
    final double descFz  = compact ? 10 : 11;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        _kSurface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: _kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat number / title (e.g. "82%", "1,200+", "6")
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   titleFz,
                fontWeight: FontWeight.w700,
                color:      _kGreen,
                height:     1.1,
              ),
            ),
          if (shortDesc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              shortDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   descFz,
                height:     1.55,
                color:      const Color(0xFF555555),
              ),
            ),
          ],
          // Fallback icon if no image
          if (title.isEmpty && stat.iconUrl.isEmpty)
            Icon(Icons.bar_chart, size: compact ? 20 : 26, color: _kGreen),
          if (title.isEmpty && stat.iconUrl.isNotEmpty)
            _netImg(
              url:    stat.iconUrl,
              width:  compact ? 28 : 36,
              height: compact ? 28 : 36,
              fit:    BoxFit.contain,
            ),
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