// ******************* FILE INFO *******************
// File Name: strategy_preview_page.dart
// Screen 3 of 3 — Our Strategy CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)

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

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color hintText = Color(0xFF797979);
  static const Color back = Color(0xFFF1F2ED);
}

enum _PreviewMode { desktop, tablet, mobile }

enum _PreviewLang { eng, ar }

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyPreviewPage extends StatefulWidget {
  final OurStrategyModel model;
  final Map<String, Uint8List> imageUploads;

  const StrategyPreviewPage({
    super.key,
    required this.model,
    this.imageUploads = const {},
  });

  @override
  State<StrategyPreviewPage> createState() => _StrategyPreviewPageState();
}

class _StrategyPreviewPageState extends State<StrategyPreviewPage> {
  _PreviewMode _mode = _PreviewMode.desktop;
  _PreviewLang _lang = _PreviewLang.eng;
  bool _previewOpen = true;

  bool get _isRtl => _lang == _PreviewLang.ar;

  // Returns in-memory bytes if user just picked a new file, else null
  Uint8List? get _visionSvgBytes =>
      widget.imageUploads['strategy_cms/vision/svg'];

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() async {
    final ok = await _confirm(context);
    if (ok == true && mounted) {
      context.read<StrategyCubit>().save(
        model: widget.model,
        imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<StrategyCubit, StrategyState>(
        listener: (context, state) {
          if (state is StrategySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Our Strategy saved!')),
            );
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is StrategyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 1000.w,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 3),
                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25.h),

                            Text(
                              'Preview Our Strategy Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Mode tabs + ENG|AR ─────────────────────────────────
                            Row(
                              children: [
                                ..._PreviewMode.values.map((m) {
                                  final sel = m == _mode;
                                  final label = switch (m) {
                                    _PreviewMode.desktop => 'Desktop',
                                    _PreviewMode.tablet => 'Tablet',
                                    _PreviewMode.mobile => 'Mobile',
                                  };
                                  return GestureDetector(
                                    onTap: () => setState(() => _mode = m),
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 24.w),
                                      child: Text(
                                        label,
                                        style: sel
                                            ? StyleText.fontSize14Weight600
                                                  .copyWith(
                                                    color: _C.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor: _C.primary,
                                                  )
                                            : StyleText.fontSize14Weight400
                                                  .copyWith(color: _C.hintText),
                                      ),
                                    ),
                                  );
                                }),
                                const Spacer(),
                                _langBtn('ENG', _PreviewLang.eng, isLeft: true),
                                _langBtn('AR', _PreviewLang.ar, isLeft: false),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Vision accordion ───────────────────────────────────
                            _previewAccordion(
                              title: 'Vision',
                              isOpen: _previewOpen,
                              onToggle: () =>
                                  setState(() => _previewOpen = !_previewOpen),
                              child: _previewBody(),
                            ),
                            SizedBox(height: 24.h),

                            // ── Back | Save ────────────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44.h,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: SizedBox(
                                    height: 44.h,
                                    child: ElevatedButton(
                                      onPressed: _onSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Save',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Language button ───────────────────────────────────────────────────────
  Widget _langBtn(String label, _PreviewLang lang, {required bool isLeft}) {
    final active = _lang == lang;
    return GestureDetector(
      onTap: () => setState(() => _lang = lang),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? _C.primary : _C.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 6.r : 0),
            bottomLeft: Radius.circular(isLeft ? 6.r : 0),
            topRight: Radius.circular(isLeft ? 0 : 6.r),
            bottomRight: Radius.circular(isLeft ? 0 : 6.r),
          ),
          border: Border.all(color: _C.primary),
        ),
        child: Text(
          label,
          style: StyleText.fontSize12Weight600.copyWith(
            color: active ? Colors.white : _C.primary,
          ),
        ),
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(

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
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
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
            child,
        ],
      ),
    );
  }

  // ── Preview body — passes BOTH bytes and url ──────────────────────────────
  Widget _previewBody() {
    final desc = _isRtl
        ? widget.model.vision.description.ar
        : widget.model.vision.description.en;
    final svgUrl = widget.model.vision.svgUrl;
    final svgBytes = _visionSvgBytes; // in-memory bytes from file picker

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: switch (_mode) {
        _PreviewMode.desktop => _StrategyDesktopPreview(
          desc: desc,
          svgUrl: svgUrl,
          svgBytes: svgBytes,
        ),
        _PreviewMode.tablet => _StrategyTabletPreview(
          desc: desc,
          svgUrl: svgUrl,
          svgBytes: svgBytes,
        ),
        _PreviewMode.mobile => _StrategyMobilePreview(
          desc: desc,
          svgUrl: svgUrl,
          svgBytes: svgBytes,
        ),
      },
    );
  }
}

// ── Shared SVG renderer — bytes take priority over url ────────────────────────
Widget _svgWidget({
  required Uint8List? bytes,
  required String url,
  required double width,
  required double height,
}) {
  if (bytes != null && bytes.isNotEmpty) {
    // Render from in-memory bytes (newly picked file, not yet uploaded)
    return SvgPicture.memory(
      bytes,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
  if (url.isNotEmpty) {
    // Render from Firebase Storage URL (existing saved file)
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF008037),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
  // Nothing to render
  return SizedBox(
    width: width,
    height: height,
    child: Icon(
      Icons.image_outlined,
      color: Colors.grey[400],
      size: width * 0.4,
    ),
  );
}

// ─── Desktop ──────────────────────────────────────────────────────────────────
class _StrategyDesktopPreview extends StatelessWidget {
  final String desc;
  final String svgUrl;
  final Uint8List? svgBytes;

  const _StrategyDesktopPreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              desc.isEmpty ? 'Description text here…' : desc,
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13.sp,
                height: 1.75,
              ),
            ),
          ),
          if (hasSvg) ...[
            SizedBox(width: 24.w),
            _svgWidget(
              bytes: svgBytes,
              url: svgUrl,
              width: 200.w,
              height: 200.h,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────────────────────
class _StrategyTabletPreview extends StatelessWidget {
  final String desc;
  final String svgUrl;
  final Uint8List? svgBytes;

  const _StrategyTabletPreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          if (hasSvg) ...[
            Center(
              child: _svgWidget(
                bytes: svgBytes,
                url: svgUrl,
                width: 160.w,
                height: 160.h,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(
            desc.isEmpty ? 'Description text here…' : desc,
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 12.sp,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────
class _StrategyMobilePreview extends StatelessWidget {
  final String desc;
  final String svgUrl;
  final Uint8List? svgBytes;

  const _StrategyMobilePreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          if (hasSvg) ...[
            Center(
              child: _svgWidget(
                bytes: svgBytes,
                url: svgUrl,
                width: 120.w,
                height: 120.h,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          Text(
            desc.isEmpty ? 'Description text here…' : desc,
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 11.sp,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm Dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    contentPadding: EdgeInsets.all(24.r),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(
            Icons.edit_note,
            size: 40.sp,
            color: const Color(0xFF008037),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'EDITING OUR STRATEGY DETAILS',
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight600.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Do you want to save the changes made to this Our Strategy?',
          textAlign: TextAlign.center,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: StyleText.fontSize13Weight500.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: StyleText.fontSize13Weight500.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
