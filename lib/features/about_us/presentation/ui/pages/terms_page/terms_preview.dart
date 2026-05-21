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
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';

part '../../widget/terms_preview/a_c.dart';
part '../../widget/terms_preview/desktop_frame.dart';
part '../../widget/terms_preview/tablet_frame.dart';
part '../../widget/terms_preview/mobile_frame.dart';
part '../../widget/terms_preview/terms_preview_content.dart';
part '../../widget/terms_preview/browser_chrome.dart';

// ── Admin-shell colors ────────────────────────────────────────────────────────

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
