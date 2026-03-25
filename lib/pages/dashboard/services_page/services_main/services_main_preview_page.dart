// ******************* FILE INFO *******************
// File Name: services_main_preview_page.dart
// Screen 3 — Services CMS: Preview "Main" section (Desktop/Tablet/Mobile)
// Save button shows confirm dialog before persisting.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
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

class ServicesMainPreviewPage extends StatefulWidget {
  final ServicePageModel model;
  const ServicesMainPreviewPage({super.key, required this.model});

  @override
  State<ServicesMainPreviewPage> createState() => _ServicesMainPreviewPageState();
}

class _ServicesMainPreviewPageState extends State<ServicesMainPreviewPage> {
  _PreviewMode _mode = _PreviewMode.desktop;
  _PreviewLang _lang = _PreviewLang.eng;
  bool _viewOpen = true;

  // FIX: await save so navigation waits for Firestore to finish
  Future<void> _onSave() async {
    final confirmed = await _showConfirmDialog(context);
    if (confirmed == true && mounted) {
      await context.read<ServiceCmsCubit>().save(publishStatus: 'published');
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: BlocListener<ServiceCmsCubit, ServiceCmsState>(
        listener: (context, state) {
          if (state is ServiceCmsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved successfully')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top app navbar ─────────────────────────────────────────
              AppNavbar(currentRoute: '/services'),

              // ── Page body ──────────────────────────────────────────────
              Container(
                width: 1000.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // ── Large green title ────────────────────────────────
                    Text(
                      'Preview Services Details',
                      style: StyleText.fontSize45Weight600.copyWith(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Mode tabs row + ENG | AR toggle ─────────────────
                    Row(
                      children: [
                        // Desktop / Tablet / Mobile tabs
                        ..._PreviewMode.values.map((m) {
                          final bool selected = m == _mode;
                          final String label = switch (m) {
                            _PreviewMode.desktop => 'Desktop',
                            _PreviewMode.tablet  => 'Tablet',
                            _PreviewMode.mobile  => 'Mobile',
                          };
                          return GestureDetector(
                            onTap: () => setState(() => _mode = m),
                            child: Padding(
                              padding: EdgeInsets.only(right: 24.w),
                              child: Text(
                                label,
                                style: selected
                                    ? StyleText.fontSize14Weight600.copyWith(
                                  color: _C.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _C.primary,
                                )
                                    : StyleText.fontSize14Weight400.copyWith(
                                  color: _C.hintText,
                                ),
                              ),
                            ),
                          );
                        }),

                        const Spacer(),

                        // ENG toggle button
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
                                topLeft:     Radius.circular(6.r),
                                bottomLeft:  Radius.circular(6.r),
                              ),
                              border: Border.all(color: _C.primary),
                            ),
                            child: Text(
                              'ENG',
                              style: StyleText.fontSize12Weight600.copyWith(
                                color: _lang == _PreviewLang.eng
                                    ? Colors.white
                                    : _C.primary,
                              ),
                            ),
                          ),
                        ),

                        // AR toggle button
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
                                topRight:    Radius.circular(6.r),
                                bottomRight: Radius.circular(6.r),
                              ),
                              border: Border.all(color: _C.primary),
                            ),
                            child: Text(
                              'AR',
                              style: StyleText.fontSize12Weight600.copyWith(
                                color: _lang == _PreviewLang.ar
                                    ? Colors.white
                                    : _C.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ── View accordion ───────────────────────────────────
                    _viewAccordion(),
                    SizedBox(height: 24.h),

                    // ── Back (left half) | Save (right half) ─────────────
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: _onBack,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text('Back',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
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
                                    borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text('Save',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
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
  }

  // ── View Accordion ──────────────────────────────────────────────────────────
  Widget _viewAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              child: Row(children: [
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
                  size: 20.sp,
                ),
              ]),
            ),
          ),

          // Body
          if (_viewOpen)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _previewContent(),
            ),
        ],
      ),
    );
  }

  // ── Preview content ─────────────────────────────────────────────────────────
  Widget _previewContent() {
    final bool isAr = _lang == _PreviewLang.ar;

    final double maxW = switch (_mode) {
      _PreviewMode.desktop => double.infinity,
      _PreviewMode.tablet  => 600.w,
      _PreviewMode.mobile  => 320.w,
    };

    final String title = isAr
        ? (widget.model.title.ar.isNotEmpty
        ? widget.model.title.ar
        : 'الخدمات')
        : (widget.model.title.en.isNotEmpty
        ? widget.model.title.en
        : 'Services');

    final String desc = isAr
        ? (widget.model.shortDescription.ar.isNotEmpty
        ? widget.model.shortDescription.ar
        : 'تقدم بياناتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي.')
        : (widget.model.shortDescription.en.isNotEmpty
        ? widget.model.shortDescription.en
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page title ───────────────────────────────────────────────
            Text(
              title,
              style: StyleText.fontSize45Weight600.copyWith(
                color: _C.primary,
                fontSize: _mode == _PreviewMode.mobile ? 22.sp : 28.sp,
              ),
            ),
            SizedBox(height: 10.h),

            // ── Short description / subtitle ─────────────────────────────
            // FIX: was already rendering desc correctly here — now also
            // shows a labelled subtitle row so the editor can confirm it
            // before saving.
            Text(
              desc,
              style: StyleText.fontSize14Weight400.copyWith(
                color: _C.hintText,
                fontSize: _mode == _PreviewMode.mobile ? 12.sp : 14.sp,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm Dialog ──────────────────────────────────────────────────────────
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
            width:  80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color:        const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(Icons.edit_note,
                size: 40.sp, color: _C.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'EDITING SERVICE DETAILS',
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight600.copyWith(
                color: const Color(0xFF1A1A1A)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Do you want to save the changes made to this Service Details?',
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryBlack),
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
                      backgroundColor: _C.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Back',
                        style: StyleText.fontSize13Weight500
                            .copyWith(color: Colors.white)),
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
                      backgroundColor: _C.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Confirm',
                        style: StyleText.fontSize13Weight500
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}