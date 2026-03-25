// ******************* FILE INFO *******************
// File Name: terms_preview_page.dart
// Screen 3 of 3 — Terms of Service CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/model/about_us.dart';       // DocUpload lives here
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color hintText  = Color(0xFF797979);
}

enum _PreviewMode { desktop, tablet, mobile }
enum _PreviewLang { eng, ar }

// ═══════════════════════════════════════════════════════════════════════════════

class TermsPreviewPage extends StatefulWidget {
  final TermsOfServiceModel      model;
  final Map<String, Uint8List>   imageUploads;
  final Map<String, DocUpload>   docUploads;

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
  _PreviewMode _mode        = _PreviewMode.desktop;
  _PreviewLang _lang        = _PreviewLang.eng;
  bool         _termsOpen   = true;
  bool         _privacyOpen = true;

  bool get _isRtl => _lang == _PreviewLang.ar;

  // Convenience getters for in-memory bytes
  Uint8List? get _termsSvgBytes    => widget.imageUploads['terms_cms/terms/svg'];
  Uint8List? get _privacySvgBytes  => widget.imageUploads['terms_cms/privacy/svg'];

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() async {
    final ok = await _confirm(context);
    if (ok == true && mounted) {
      context.read<TermsCubit>().save(
        model:        widget.model,
        imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
        docUploads:   widget.docUploads.isEmpty   ? null : widget.docUploads,
      );
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: BlocListener<TermsCubit, TermsState>(
        listener: (context, state) {
          if (state is TermsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service saved!')));
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is TermsError) {
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
                Container(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AdminSubNavBar(activeIndex: 3),
                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),

                            Text('Preview Terms of Service Details',
                                style: StyleText.fontSize45Weight600.copyWith(
                                    color: _C.primary,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // ── Mode tabs + ENG|AR toggle ──────────────────────────
                            Row(children: [
                              ..._PreviewMode.values.map((m) {
                                final sel   = m == _mode;
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
                                        style: sel
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
                              _langBtn('ENG', _PreviewLang.eng, isLeft: true),
                              _langBtn('AR',  _PreviewLang.ar,  isLeft: false),
                            ]),
                            SizedBox(height: 16.h),

                            // ── Terms and Conditions accordion ─────────────────────
                            _previewAccordion(
                              title: _isRtl ? 'الشروط والأحكام' : 'Terms and Conditions',
                              isOpen: _termsOpen,
                              onToggle: () =>
                                  setState(() => _termsOpen = !_termsOpen),
                              child: _sectionPreview(
                                section:  widget.model.termsAndConditions,
                                svgBytes: _termsSvgBytes,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ── Privacy Policy accordion ───────────────────────────
                            _previewAccordion(
                              title: _isRtl ? 'سياسة الخصوصية' : 'Privacy Policy',
                              isOpen: _privacyOpen,
                              onToggle: () =>
                                  setState(() => _privacyOpen = !_privacyOpen),
                              child: _sectionPreview(
                                section:  widget.model.privacyPolicy,
                                svgBytes: _privacySvgBytes,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Back | Save ────────────────────────────────────────
                            Row(children: [
                              Expanded(child: SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r))),
                                    child: Text('Back',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white)),
                                  ))),
                              SizedBox(width: 12.w),
                              Expanded(child: SizedBox(
                                  height: 44.h,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Language toggle button ────────────────────────────────────────────────
  Widget _langBtn(String label, _PreviewLang lang, {required bool isLeft}) {
    final active = _lang == lang;
    return GestureDetector(
      onTap: () => setState(() => _lang = lang),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? _C.primary : _C.cardBg,
          borderRadius: BorderRadius.only(
            topLeft:     Radius.circular(isLeft ? 6.r : 0),
            bottomLeft:  Radius.circular(isLeft ? 6.r : 0),
            topRight:    Radius.circular(isLeft ? 0 : 6.r),
            bottomRight: Radius.circular(isLeft ? 0 : 6.r),
          ),
          border: Border.all(color: _C.primary),
        ),
        child: Text(label,
            style: StyleText.fontSize12Weight600
                .copyWith(color: active ? Colors.white : _C.primary)),
      ),
    );
  }

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
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
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
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

  // ── Section preview — passes both bytes AND url to sub-widgets ────────────
  Widget _sectionPreview({
    required TermsSection section,
    required Uint8List?   svgBytes,   // in-memory from file picker
  }) {
    final desc   = _isRtl ? section.description.ar : section.description.en;
    final svgUrl = section.svgUrl;

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: switch (_mode) {
        _PreviewMode.desktop => _TermsDesktopPreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes),
        _PreviewMode.tablet  => _TermsTabletPreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes),
        _PreviewMode.mobile  => _TermsMobilePreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes),
      },
    );
  }
}

// ── Shared SVG renderer — bytes take priority over url ────────────────────────
Widget _svgWidget({
  required Uint8List? bytes,
  required String     url,
  required double     width,
  required double     height,
}) {
  if (bytes != null && bytes.isNotEmpty) {
    // Render from in-memory bytes (newly picked file, not yet uploaded)
    return SvgPicture.memory(bytes,
        width: width, height: height, fit: BoxFit.contain);
  }
  if (url.isNotEmpty) {
    // Render from Firebase Storage URL (existing saved file)
    return SvgPicture.network(
      url,
      width: width, height: height, fit: BoxFit.contain,
      placeholderBuilder: (_) => SizedBox(
        width: width, height: height,
        child: const Center(child: CircularProgressIndicator(
            color: Color(0xFF008037), strokeWidth: 2)),
      ),
    );
  }
  return SizedBox(
    width: width, height: height,
    child: Icon(Icons.image_outlined,
        color: Colors.grey[400], size: width * 0.4),
  );
}

// ─── Desktop ──────────────────────────────────────────────────────────────────
class _TermsDesktopPreview extends StatelessWidget {
  final String desc, svgUrl;
  final Uint8List? svgBytes;
  const _TermsDesktopPreview(
      {required this.desc, required this.svgUrl, this.svgBytes});

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(
              desc.isEmpty ? 'Description text here…' : desc,
              style: StyleText.fontSize14Weight400
                  .copyWith(fontSize: 13.sp, height: 1.75)),
        ),
        if (hasSvg) ...[
          SizedBox(width: 24.w),
          _svgWidget(bytes: svgBytes, url: svgUrl,
              width: 200.w, height: 200.h),
        ],
      ]),
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────────────────────
class _TermsTabletPreview extends StatelessWidget {
  final String desc, svgUrl;
  final Uint8List? svgBytes;
  const _TermsTabletPreview(
      {required this.desc, required this.svgUrl, this.svgBytes});

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(children: [
        if (hasSvg) ...[
          Center(child: _svgWidget(bytes: svgBytes, url: svgUrl,
              width: 160.w, height: 160.h)),
          SizedBox(height: 12.h),
        ],
        Text(
            desc.isEmpty ? 'Description text here…' : desc,
            style: StyleText.fontSize14Weight400
                .copyWith(fontSize: 12.sp, height: 1.75)),
      ]),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────
class _TermsMobilePreview extends StatelessWidget {
  final String desc, svgUrl;
  final Uint8List? svgBytes;
  const _TermsMobilePreview(
      {required this.desc, required this.svgUrl, this.svgBytes});

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(children: [
        if (hasSvg) ...[
          Center(child: _svgWidget(bytes: svgBytes, url: svgUrl,
              width: 120.w, height: 120.h)),
          SizedBox(height: 10.h),
        ],
        Text(
            desc.isEmpty ? 'Description text here…' : desc,
            style: StyleText.fontSize14Weight400
                .copyWith(fontSize: 11.sp, height: 1.7)),
      ]),
    );
  }
}

// ── Confirm dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r)),
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
        Text('EDITING TERMS OF SERVICE DETAILS',
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight600
                .copyWith(color: const Color(0xFF1A1A1A))),
        SizedBox(height: 8.h),
        Text(
            'Do you want to save the changes made to Terms of Service?',
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack)),
        SizedBox(height: 20.h),
        Row(children: [
          Expanded(child: SizedBox(
              height: 40.h,
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
          Expanded(child: SizedBox(
              height: 40.h,
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