// ******************* FILE INFO *******************
// File Name: about_preview_page.dart
// Screen 3 — About Us CMS: Preview with Desktop/Tablet/Mobile + ENG/AR toggle
// Preview UI inside the accordion is IDENTICAL to about_page.dart (no logic changes).
// Save button shows confirm dialog before persisting.

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
import 'package:web_app_admin/widgets/app_navbar.dart';

// ── Shared constants (same as about_page.dart) ────────────────────────────────
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kDivider    = Color(0xFFDDE8DD);

// ── Preview-page-only colours ─────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color hintText  = Color(0xFF797979);
  static const Color labelText = Color(0xFF1A1A1A);
}

enum _PreviewMode { desktop, tablet, mobile }
enum _PreviewLang { eng, ar }

// ═══════════════════════════════════════════════════════════════════════════════
// STATIC VALUES DATA — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

class _StaticValue {
  final String titleEn, titleAr, descEn, descAr, svgPath;
  const _StaticValue({
    required this.titleEn, required this.titleAr,
    required this.descEn,  required this.descAr,
    required this.svgPath,
  });
  String title(bool isRtl) => isRtl ? titleAr : titleEn;
  String desc(bool isRtl)  => isRtl ? descAr  : descEn;
}

const List<_StaticValue> _kStaticValues = [
  _StaticValue(
    titleEn: 'Focus On\nCustomer Needs',     titleAr: 'التركيز على\nاحتياجات العملاء',
    descEn: 'We put our customers at the heart of everything we do, ensuring every solution is tailored to their needs and delivers real value.',
    descAr: 'نضع عملاءنا في صميم كل ما نقوم به، مما يضمن أن كل حل مصمم لاحتياجاتهم ويقدم قيمة حقيقية.',
    svgPath: 'assets/images/about_us/about_values/foucs_on.svg',
  ),
  _StaticValue(
    titleEn: 'Continuously\nLearn & Improve', titleAr: 'التعلم المستمر\nوالتحسين',
    descEn: 'We embrace a culture of continuous learning, constantly evolving our skills and processes to deliver better outcomes.',
    descAr: 'نتبنى ثقافة التعلم المستمر، ونطور باستمرار مهاراتنا وعملياتنا لتحقيق نتائج أفضل.',
    svgPath: 'assets/images/about_us/about_values/Continuously learn & improve.svg',
  ),
  _StaticValue(
    titleEn: 'Ethical &\nSustainable',        titleAr: 'أخلاقي\nومستدام',
    descEn: 'Prioritize The Long-Term Health And Well-Being Of The Environment, Society, And The Economy.',
    descAr: 'إعطاء الأولوية للصحة والرفاهية على المدى الطويل للبيئة والمجتمع والاقتصاد.',
    svgPath: 'assets/images/about_us/about_values/Embrace innovation.svg',
  ),
  _StaticValue(
    titleEn: 'Prioritize Data\n& Analytics',  titleAr: 'إعطاء الأولوية\nللبيانات والتحليلات',
    descEn: 'We leverage data and analytics to drive informed decisions, optimize performance, and unlock new growth opportunities.',
    descAr: 'نستفيد من البيانات والتحليلات لاتخاذ قرارات مستنيرة وتحسين الأداء وفتح فرص نمو جديدة.',
    svgPath: 'assets/images/about_us/about_values/Prioritize data & analytics.svg',
  ),
  _StaticValue(
    titleEn: 'Embrace\nInnovation',            titleAr: 'تبني\nالابتكار',
    descEn: 'Innovation is at our core. We challenge conventions and explore new ideas to stay ahead in a rapidly changing world.',
    descAr: 'الابتكار في صميم عملنا. نتحدى الأعراف ونستكشف أفكاراً جديدة للبقاء في الصدارة.',
    svgPath: 'assets/images/about_us/about_values/Embrace innovation.svg',
  ),
  _StaticValue(
    titleEn: 'Foster A Positive\nCompany Culture', titleAr: 'تعزيز ثقافة\nإيجابية',
    descEn: 'We build an inclusive, collaborative and positive workplace where every team member can thrive and contribute.',
    descAr: 'نبني بيئة عمل شاملة وتعاونية وإيجابية حيث يمكن لكل عضو في الفريق الازدهار والمساهمة.',
    svgPath: 'assets/images/about_us/about_values/Foster a positive company culture.svg',
  ),
  _StaticValue(
    titleEn: 'Build Strong\nPartnerships',     titleAr: 'بناء شراكات\nقوية',
    descEn: 'We cultivate strong, trust-based partnerships with clients and stakeholders to achieve shared goals and lasting success.',
    descAr: 'نبني شراكات قوية قائمة على الثقة مع العملاء وأصحاب المصلحة لتحقيق الأهداف المشتركة.',
    svgPath: 'assets/images/about_us/about_values/Build strong partnerships.svg',
  ),
  _StaticValue(
    titleEn: 'Emphasize\nTransparency',        titleAr: 'التأكيد على\nالشفافية والمساءلة',
    descEn: 'We operate with full transparency and hold ourselves accountable to the highest standards in all our actions.',
    descAr: 'نعمل بشفافية تامة ونحاسب أنفسنا على أعلى المعايير في جميع أعمالنا.',
    svgPath: 'assets/images/about_us/about_values/Emphasize transparency & accountability.svg',
  ),
  _StaticValue(
    titleEn: 'Invest In Employee\nDevelopment', titleAr: 'الاستثمار في تطوير\nالموظفين',
    descEn: 'Our people are our greatest asset. We invest in their growth, skills, and well-being to build a stronger organization.',
    descAr: 'موظفونا هم أعظم أصولنا. نستثمر في نموهم ومهاراتهم ورفاهيتهم لبناء منظمة أقوى.',
    svgPath: 'assets/images/about_us/about_values/Invest in employee development.svg',
  ),
  _StaticValue(
    titleEn: 'Stay Agile &\nAdaptable',         titleAr: 'البقاء رشيقاً\nوقابلاً للتكيف',
    descEn: 'In a fast-moving world, we stay agile and adaptable — ready to pivot and respond to new challenges and opportunities.',
    descAr: 'في عالم سريع التغير، نبقى رشيقين وقابلين للتكيف — مستعدين للتحول والاستجابة للتحديات والفرص الجديدة.',
    svgPath: 'assets/images/about_us/about_values/Stay agile & adaptable.svg',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Widget _valueIcon(String svgPath, {required double size, required Color color}) {
  return SvgPicture.asset(
    svgPath, width: size, height: size, fit: BoxFit.contain,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

Widget _buildNetworkImage(
    String url, {
      double? width, double? height,
      BoxFit fit = BoxFit.cover,
      BorderRadius? borderRadius,
      Widget? errorWidget,
      ColorFilter? colorFilter,
    }) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();
  final String decodedUrl = Uri.decodeFull(url);
  final bool isSvg = decodedUrl.toLowerCase().contains('.svg') ||
      decodedUrl.contains('/svg?') || decodedUrl.contains('/svg/') ||
      decodedUrl.endsWith('/svg') || decodedUrl.contains('%2Fsvg?') ||
      decodedUrl.contains('%2Fsvg%2F');
  Widget img;
  if (isSvg) {
    img = SvgPicture.network(url,
        width: width, height: height, fit: fit, colorFilter: colorFilter);
  } else {
    img = FutureBuilder<Widget>(
      future: _tryLoadAsImage(url, width, height, fit),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return SizedBox(width: width, height: height);
        if (snap.hasData) return snap.data!;
        return errorWidget ??
            Icon(Icons.broken_image, size: width ?? height ?? 24, color: Colors.grey);
      },
    );
  }
  return borderRadius != null
      ? ClipRRect(borderRadius: borderRadius, child: img)
      : img;
}

Future<Widget> _tryLoadAsImage(String url, double? w, double? h, BoxFit fit) async {
  try {
    final res = await html.HttpRequest.request(url, method: 'HEAD');
    final ct  = res.getResponseHeader('content-type') ?? '';
    if (ct.contains('svg'))
      return SvgPicture.network(url, width: w, height: h, fit: fit);
  } catch (_) {}
  return Image.network(url, width: w, height: h, fit: fit,
      errorBuilder: (_, __, ___) =>
          SvgPicture.network(url, width: w, height: h, fit: fit));
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
  _PreviewMode _mode = _PreviewMode.desktop;
  _PreviewLang _lang = _PreviewLang.eng;
  bool _previewOpen  = true;

  bool get _isRtl => _lang == _PreviewLang.ar;

  void _onSave() async {
    final confirmed = await _showConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<AboutCubit>().save(
        model: widget.model,
        imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
      );
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: BlocListener<AboutCubit, AboutState>(
        listener: (context, state) {
          if (state is AboutSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About Us saved successfully!')));
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is AboutError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                AdminSubNavBar(activeIndex: 3),
                SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // ── Large green title ──────────────────────────────
                      Text('Preview About Us Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary, fontWeight: FontWeight.w700)),
                      SizedBox(height: 16.h),

                      // ── Mode tabs + ENG|AR toggle ──────────────────────
                      Row(children: [
                        ..._PreviewMode.values.map((m) {
                          final selected = m == _mode;
                          final label = switch (m) {
                            _PreviewMode.desktop => 'Desktop',
                            _PreviewMode.tablet  => 'Tablet',
                            _PreviewMode.mobile  => 'Mobile',
                          };
                          return GestureDetector(
                            onTap: () => setState(() => _mode = m),
                            child: Padding(
                              padding: EdgeInsets.only(right: 24.w),
                              child: Text(label,
                                  style: selected
                                      ? StyleText.fontSize14Weight600.copyWith(
                                      color: _C.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _C.primary)
                                      : StyleText.fontSize14Weight400
                                      .copyWith(color: _C.hintText)),
                            ),
                          );
                        }),
                        const Spacer(),
                        // ENG button
                        GestureDetector(
                          onTap: () => setState(() => _lang = _PreviewLang.eng),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                                color: _lang == _PreviewLang.eng
                                    ? _C.primary
                                    : _C.cardBg,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6.r),
                                    bottomLeft: Radius.circular(6.r)),
                                border: Border.all(color: _C.primary)),
                            child: Text('ENG',
                                style: StyleText.fontSize12Weight600.copyWith(
                                    color: _lang == _PreviewLang.eng
                                        ? Colors.white
                                        : _C.primary)),
                          ),
                        ),
                        // AR button
                        GestureDetector(
                          onTap: () => setState(() => _lang = _PreviewLang.ar),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                                color: _lang == _PreviewLang.ar
                                    ? _C.primary
                                    : _C.cardBg,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6.r),
                                    bottomRight: Radius.circular(6.r)),
                                border: Border.all(color: _C.primary)),
                            child: Text('AR',
                                style: StyleText.fontSize12Weight600.copyWith(
                                    color: _lang == _PreviewLang.ar
                                        ? Colors.white
                                        : _C.primary)),
                          ),
                        ),
                      ]),
                      SizedBox(height: 16.h),

                      // ── Single accordion wrapping the full about-page body ──
                      _previewAccordion(
                        title: 'About Us Section',
                        isOpen: _previewOpen,
                        onToggle: () =>
                            setState(() => _previewOpen = !_previewOpen),
                        child: _aboutBodyByMode(),
                      ),
                      SizedBox(height: 24.h),

                      // ── Back | Save ────────────────────────────────────
                      Row(children: [
                        Expanded(child: SizedBox(height: 44.h,
                            child: ElevatedButton(
                              onPressed: _onBack,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r))),
                              child: Text('Back',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
                            ))),
                        SizedBox(width: 12.w),
                        Expanded(child: SizedBox(height: 44.h,
                            child: ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r))),
                              child: Text('Save',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
                            ))),
                      ]),
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

  // ── Accordion wrapper ──────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String title, required bool isOpen,
    required VoidCallback onToggle, required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: _C.cardBg, borderRadius: BorderRadius.circular(6.r)),
      child: Column(children: [
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
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r)),
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
          Padding(padding: EdgeInsets.all(16.w), child: child),
      ]),
    );
  }

  // ── Route to the correct about_page body by mode ───────────────────────────
  Widget _aboutBodyByMode() {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: switch (_mode) {
        _PreviewMode.desktop => _AboutBodyDesktop(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary),
        _PreviewMode.tablet  => _AboutBodyTablet(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary),
        _PreviewMode.mobile  => _AboutBodyMobile(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY — exact copy from about_page.dart (_AboutBodyDesktop)
// ═══════════════════════════════════════════════════════════════════════════════

class _AboutBodyDesktop extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutBodyDesktop(
      {required this.model, required this.isRtl, required this.primaryColor});

  @override
  State<_AboutBodyDesktop> createState() => _AboutBodyDesktopState();
}

class _AboutBodyDesktopState extends State<_AboutBodyDesktop> {
  int _selectedTab = 0;

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية'  : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم'   : 'Values',
  };

  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl
        : '',
  };

  String _tabDesc(int i) {
    final desc = switch (i) {
      0 => _ab(widget.model.vision.description,  widget.isRtl),
      1 => _ab(widget.model.mission.description, widget.isRtl),
      _ => widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
          : '',
    };
    if (desc.length > 160) return '${desc.substring(0, 157)}…';
    return desc;
  }

  @override
  Widget build(BuildContext context) {
    const double gap   = 16.0;
    const double leftW = 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: tab list ──────────────────────────────────────
              SizedBox(
                width: leftW.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (i) {
                    final bool isLast = i == 2;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                      child: _DesktopTabItem(
                        label:        _tabLabel(i),
                        iconUrl:      _tabIconUrl(i),
                        selectedDesc: _selectedTab == i ? _tabDesc(i) : '',
                        isSelected:   _selectedTab == i,
                        primaryColor: widget.primaryColor,
                        onTap: () => setState(() => _selectedTab = i),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(width: gap.w),

              // ── Right: detail panel ─────────────────────────────────
              Expanded(
                child: _DesktopRightPanel(
                  model:        widget.model,
                  tabIndex:     _selectedTab,
                  isRtl:        widget.isRtl,
                  primaryColor: widget.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 36.h),
      ],
    );
  }
}

// ─── Desktop Tab Item — exact copy from about_page.dart ──────────────────────

class _DesktopTabItem extends StatefulWidget {
  final String label, iconUrl, selectedDesc;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _DesktopTabItem({
    required this.label, required this.iconUrl, required this.selectedDesc,
    required this.isSelected, required this.onTap, required this.primaryColor,
  });

  @override
  State<_DesktopTabItem> createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends State<_DesktopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? SvgPicture.network(widget.iconUrl,
        width: 20.sp, height: 20.sp, fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
            AppColors.textButton, BlendMode.srcIn))
        : Icon(Icons.image_outlined,
        size: 20.sp, color: AppColors.textButton);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  width: 42.w, height: 42.h,
                  decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(child: iconWidget),
                ),
                SizedBox(width: 12.w),
                Flexible(child: Text(widget.label,
                    style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 14.sp, fontWeight: FontWeight.w600,
                        color: widget.primaryColor))),
              ]),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(widget.selectedDesc,
                    maxLines: 5, overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: 11.sp, height: 1.65,
                        color: AppColors.secondaryBlack)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Desktop Right Panel — exact copy from about_page.dart ───────────────────

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor;

  const _DesktopRightPanel({
    required this.model, required this.tabIndex,
    required this.isRtl, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      return _ValuesGridDesktop(
          values: model.values, isRtl: isRtl, primaryColor: primaryColor);
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      width: double.infinity, height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(_ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                  fontSize: 13.sp, height: 1.75))),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _buildNetworkImage(section.svgUrl,
                width: 180.w, height: 180.h, fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID DESKTOP — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridDesktop extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor;
  const _ValuesGridDesktop(
      {required this.values, this.isRtl = false, required this.primaryColor});

  @override
  State<_ValuesGridDesktop> createState() => _ValuesGridDesktopState();
}

class _ValuesGridDesktopState extends State<_ValuesGridDesktop> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            widget.primaryColor.withOpacity(.06),
            widget.primaryColor.withOpacity(.25),
            widget.primaryColor.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Wrap(
              spacing: 8.w, runSpacing: 8.w,
              children: List.generate(_kStaticValues.length, (i) {
                final v   = _kStaticValues[i];
                final sel = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100.w, padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: sel ? widget.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: sel
                            ? [BoxShadow(
                            color: widget.primaryColor.withOpacity(0.28),
                            blurRadius: 10, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _valueIcon(v.svgPath, size: 22.sp,
                              color: sel ? Colors.white : widget.primaryColor),
                          SizedBox(height: 6.h),
                          Text(v.title(widget.isRtl),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : Colors.black87,
                                  height: 1.35)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
              value: _kStaticValues[_selectedIndex],
              isRtl: widget.isRtl, primaryColor: widget.primaryColor),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET BODY — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

class _AboutBodyTablet extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutBodyTablet(
      {required this.model, required this.isRtl, required this.primaryColor});

  @override
  State<_AboutBodyTablet> createState() => _AboutBodyTabletState();
}

class _AboutBodyTabletState extends State<_AboutBodyTablet> {
  int _selectedTab = 0;

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية'  : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم'   : 'Values',
  };

  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl
        : '',
  };

  @override
  Widget build(BuildContext context) {
    const double gap = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: List.generate(3, (i) {
          final bool isLast = i == 2;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: isLast ? 0 : gap.w),
              child: _TabletTabItem(
                label: _tabLabel(i), iconUrl: _tabIconUrl(i),
                isSelected: _selectedTab == i,
                primaryColor: widget.primaryColor,
                onTap: () => setState(() => _selectedTab = i),
              ),
            ),
          );
        })),
        SizedBox(height: 14.h),
        _TabletContentPanel(
            model: widget.model, tabIndex: _selectedTab,
            isRtl: widget.isRtl, primaryColor: widget.primaryColor),
        SizedBox(height: 30.h),
      ],
    );
  }
}

class _TabletTabItem extends StatelessWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _TabletTabItem({
    required this.label, required this.iconUrl,
    required this.isSelected, required this.onTap, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
            color: isSelected ? primaryColor : _kSurface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: isSelected ? primaryColor : _kDivider)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl.isNotEmpty)
              SvgPicture.network(iconUrl,
                  width: 16.sp, height: 16.sp, fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : primaryColor, BlendMode.srcIn))
            else
              Icon(Icons.image_outlined,
                  size: 16.sp,
                  color: isSelected ? Colors.white : primaryColor),
            SizedBox(width: 6.w),
            Flexible(child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : primaryColor))),
          ],
        ),
      ),
    );
  }
}

class _TabletContentPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor;

  const _TabletContentPanel({
    required this.model, required this.tabIndex,
    required this.isRtl, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      return _ValuesGridTablet(
          values: model.values, isRtl: isRtl, primaryColor: primaryColor);
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.svgUrl.isNotEmpty) ...[
            Center(child: _buildNetworkImage(section.svgUrl,
                width: 160.w, height: 160.h, fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r))),
            SizedBox(height: 12.h),
          ],
          Text(_ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                  fontSize: 11.sp, height: 1.75)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID TABLET — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridTablet extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor;
  const _ValuesGridTablet(
      {required this.values, this.isRtl = false, required this.primaryColor});

  @override
  State<_ValuesGridTablet> createState() => _ValuesGridTabletState();
}

class _ValuesGridTabletState extends State<_ValuesGridTablet> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    const double gap = 8.0;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
                color: _kGreenLight,
                borderRadius: BorderRadius.circular(10.r)),
            child: Wrap(
              spacing: gap, runSpacing: gap,
              children: List.generate(_kStaticValues.length, (i) {
                final v   = _kStaticValues[i];
                final sel = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 88.w, padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                      color: sel ? widget.primaryColor : _kSurface,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                          color: sel ? widget.primaryColor : _kDivider),
                      boxShadow: sel
                          ? [BoxShadow(
                          color: widget.primaryColor.withOpacity(0.28),
                          blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _valueIcon(v.svgPath, size: 18.sp,
                            color: sel ? Colors.white : widget.primaryColor),
                        SizedBox(height: 5.h),
                        Text(v.title(widget.isRtl),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : Colors.black87,
                                height: 1.3)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
              value: _kStaticValues[_selectedIndex],
              isRtl: widget.isRtl, primaryColor: widget.primaryColor),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY — exact copy from about_page.dart (_AboutBodyMobile)
// ═══════════════════════════════════════════════════════════════════════════════

class _AboutBodyMobile extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutBodyMobile(
      {required this.model, required this.isRtl, required this.primaryColor});

  @override
  State<_AboutBodyMobile> createState() => _AboutBodyMobileState();
}

class _AboutBodyMobileState extends State<_AboutBodyMobile> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _MobileTabData(
          label: widget.isRtl ? 'الرؤية'  : 'Vision',
          iconUrl: widget.model.vision.iconUrl,
          svgUrl:  widget.model.vision.svgUrl,
          fullText: _ab(widget.model.vision.description, widget.isRtl),
          tabIndex: 0),
      _MobileTabData(
          label: widget.isRtl ? 'الرسالة' : 'Mission',
          iconUrl: widget.model.mission.iconUrl,
          svgUrl:  widget.model.mission.svgUrl,
          fullText: _ab(widget.model.mission.description, widget.isRtl),
          tabIndex: 1),
      _MobileTabData(
          label: widget.isRtl ? 'القيم' : 'Values',
          iconUrl: '', svgUrl: '', fullText: '', tabIndex: 2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14.h),
        ...tabs.asMap().entries.map((entry) {
          final tab    = entry.value;
          final isOpen = _expanded == tab.tabIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _MobileAccordionItem(
              tab: tab, values: widget.model.values,
              isExpanded: isOpen, isRtl: widget.isRtl,
              primaryColor: widget.primaryColor,
              onTap: () =>
                  setState(() => _expanded = isOpen ? -1 : tab.tabIndex),
            ),
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _MobileTabData {
  final String label, iconUrl, svgUrl, fullText;
  final int tabIndex;
  const _MobileTabData({
    required this.label, required this.iconUrl, required this.svgUrl,
    required this.fullText, required this.tabIndex,
  });
}

class _MobileAccordionItem extends StatelessWidget {
  final _MobileTabData tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor;
  final VoidCallback onTap;

  const _MobileAccordionItem({
    required this.tab, required this.values, required this.isExpanded,
    required this.onTap, this.isRtl = false, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap, behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(children: [
                Container(
                  width: 38.w, height: 38.h,
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: tab.iconUrl.isNotEmpty
                        ? SvgPicture.network(tab.iconUrl,
                        width: 18.sp, height: 18.sp, fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                            AppColors.textButton, BlendMode.srcIn))
                        : Icon(Icons.image_outlined,
                        size: 16.sp, color: AppColors.textButton),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Text(tab.label,
                    style: StyleText.fontSize16Weight600.copyWith(
                        fontSize: 12.sp, color: primaryColor))),
                if (isExpanded)
                  Container(
                    width: 26.w, height: 26.h,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6.r)),
                    child: Icon(Icons.keyboard_arrow_up_rounded,
                        color: Colors.white, size: 16.sp),
                  ),
              ]),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tab.tabIndex != 2 && tab.svgUrl.isNotEmpty) ...[
                    Center(child: _buildNetworkImage(tab.svgUrl,
                        width: MediaQuery.of(context).size.width -
                            16.w * 2 - 12.w * 2,
                        height: 150.h, fit: BoxFit.contain)),
                    SizedBox(height: 10.h),
                  ],
                  if (tab.tabIndex != 2)
                    Text(tab.fullText,
                        style: StyleText.fontSize13Weight400.copyWith(
                            fontSize: 10.sp, height: 1.7)),
                  if (tab.tabIndex == 2)
                    _ValuesGridMobile(
                        values: values, isRtl: isRtl,
                        primaryColor: primaryColor),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID MOBILE — exact copy from about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridMobile extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor;
  const _ValuesGridMobile(
      {required this.values, this.isRtl = false, required this.primaryColor});

  @override
  State<_ValuesGridMobile> createState() => _ValuesGridMobileState();
}

class _ValuesGridMobileState extends State<_ValuesGridMobile> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final double innerW =
        MediaQuery.of(context).size.width - 16.w * 2 - 12.w * 2;
    final double gap   = 7.w;
    final double cardW = (innerW - gap) / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: gap, runSpacing: gap,
          children: List.generate(_kStaticValues.length, (i) {
            final v   = _kStaticValues[i];
            final sel = i == _selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: cardW, padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : _kSurface,
                  borderRadius: BorderRadius.circular(9.r),
                  border:
                  Border.all(color: sel ? widget.primaryColor : _kDivider),
                  boxShadow: sel
                      ? [BoxShadow(
                      color: widget.primaryColor.withOpacity(0.28),
                      blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _valueIcon(v.svgPath, size: 16.sp,
                        color: sel ? Colors.white : widget.primaryColor),
                    SizedBox(width: 6.w),
                    Expanded(child: Text(v.title(widget.isRtl),
                        style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : Colors.black87,
                            height: 1.35))),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 10.h),
        _ValueDetailPanel(
            value: _kStaticValues[_selectedIndex],
            isRtl: widget.isRtl, primaryColor: widget.primaryColor),
      ],
    );
  }
}

// ─── Value Detail Panel — exact copy from about_page.dart ────────────────────

class _ValueDetailPanel extends StatelessWidget {
  final _StaticValue value;
  final bool isRtl;
  final Color primaryColor;
  const _ValueDetailPanel(
      {required this.value, required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r)),
            child: Center(child: _valueIcon(value.svgPath,
                size: 20.sp, color: primaryColor)),
          ),
          SizedBox(height: 14.w),
          Text(value.title(isRtl).replaceAll('\n', ' '),
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 14.sp,
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          SizedBox(height: 6.h),
          Text(value.desc(isRtl),
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryBlack, height: 1.65)),
        ],
      ),
    );
  }
}

// ── Confirm Dialog ─────────────────────────────────────────────────────────────
Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.r),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w, height: 80.w,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(40.r)),
            child: Icon(Icons.edit_note,
                size: 40.sp, color: const Color(0xFF008037)),
          ),
          SizedBox(height: 16.h),
          Text('EDITING ABOUT US DETAILS', textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight600
                  .copyWith(color: const Color(0xFF1A1A1A))),
          SizedBox(height: 8.h),
          Text(
              'Do you want to save the changes made to this About Us?',
              textAlign: TextAlign.center,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryBlack)),
          SizedBox(height: 20.h),
          Row(children: [
            Expanded(child: SizedBox(height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E9E9E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r))),
                  child: Text('Back',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ))),
            SizedBox(width: 12.w),
            Expanded(child: SizedBox(height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008037),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r))),
                  child: Text('Confirm',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ))),
          ]),
        ],
      ),
    ),
  );
}