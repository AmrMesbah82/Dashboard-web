// ******************* FILE INFO *******************
// File Name: blog_preview.dart
// Created by: Amr Mesbah
// Screen: Blog CMS — Preview a Blog Post (before publish)
// Layout:
//   • "Preview Read Details" title
//   • Card View accordion  → compact blog card (as it appears on Services page)
//   • Read More accordion  → full article: image | text, date, numbered/bulleted blocks, conclusion
//   • Footer buttons now match edit page layout exactly:
//     Row 1: [Back (green)]  [Publish (green)]
//     Row 2: [Discard (grey)] [Save For Later (grey)]
// Fixed:
//   • Card Preview button uses post.buttonLabel.en (from Button section)
//   • Card Preview now includes short description (between question and date/button row)
//   • Footer buttons match blog_edit.dart style (ElevatedButton, 2×2 grid)
//   • Loading overlay + snackbar feedback + double-tap guard
//   • Accepts imageBytes for previewing newly picked images (not yet uploaded)
//   • Accepts isPickedSvg flag for correct SVG vs raster rendering
//   • Removed hardcoded fallback for descriptionTitle

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Flutter Web only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/constant/color.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../data/models/blog_model.dart';
import '../../../controller/blog_cubit.dart';

part '../../widgets/blog_preview/card_preview.dart';
part '../../widgets/blog_preview/read_more_preview.dart';
part '../../widgets/blog_preview/xhr_image.dart';

// ── Color palette ──────────────────────────────────────────────────────────────

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[d.month]} ${d.day}, ${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────

class BlogPreviewPage extends StatefulWidget {
  final BlogPostModel draft;

  /// Picked image bytes (not yet uploaded) — for previewing new/changed images
  final Uint8List? imageBytes;

  /// Whether the picked image is SVG
  final bool isPickedSvg;

  const BlogPreviewPage({
    super.key,
    required this.draft,
    this.imageBytes,
    this.isPickedSvg = false,
  });

  @override
  State<BlogPreviewPage> createState() => _BlogPreviewPageState();
}

class _BlogPreviewPageState extends State<BlogPreviewPage> {
  final Map<String, bool> _open = {
    'card':     true,
    'readMore': true,
  };

  bool _loading = false;

  Future<void> _publish() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await context
          .read<BlogCubit>()
          .createPost(
        post: widget.draft.copyWith(status: 'published'),
        imageBytes: widget.imageBytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post published successfully!'),
            backgroundColor: ColorPick.primary,
          ),
        );
        // Pop preview + edit page
        Navigator.pop(context); // pop preview
        Navigator.pop(context); // pop edit
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveForLater() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await context
          .read<BlogCubit>()
          .createPost(
        post: widget.draft.copyWith(status: 'draft'),
        imageBytes: widget.imageBytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Draft saved successfully!'),
            backgroundColor: ColorPick.primary,
          ),
        );
        // Pop preview + edit page
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back()    => Navigator.pop(context);
  void _discard() {
    // Pop preview + edit page (discard everything)
    Navigator.pop(context);
    Navigator.pop(context);
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final BlogPostModel p = widget.draft;

    return Scaffold(
      backgroundColor: ColorPick.background,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1000.w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSubNavBar(activeIndex: 2),
                  SizedBox(height: 24.h),

                  Text(
                    'Preview Read Details',
                    style: StyleText.fontSize22Weight700.copyWith(
                      color:      ColorPick.primary,
                      fontSize:   28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _accordion(
                    key:   'card',
                    title: 'Card View',
                    child: _CardPreview(
                      post:       p,
                      imageBytes: widget.imageBytes,
                      isPickedSvg: widget.isPickedSvg,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _accordion(
                    key:   'readMore',
                    title: 'Read More',
                    child: _ReadMorePreview(
                      post:       p,
                      imageBytes: widget.imageBytes,
                      isPickedSvg: widget.isPickedSvg,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Action buttons — matches edit page exactly ──
                  _actionButtons(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS — identical layout to blog_edit.dart
  // Row 1: [Back (green)]  [Publish (green)]
  // Row 2: [Discard (grey)] [Save For Later (grey)]
  // ══════════════════════════════════════════════════════════════════════════
  Widget _actionButtons() {
    return Column(
      children: [
        // ── Row 1: Back + Publish (green) ─────────────────────────────
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.primary,
                  disabledBackgroundColor: ColorPick.back,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Back',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(width: 300.w),
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.primary,
                  disabledBackgroundColor: ColorPick.primary.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _loading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text('Publish',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ]),
        SizedBox(height: 10.h),

        // ── Row 2: Discard + Save For Later (grey) ────────────────────
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _discard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.back,
                  disabledBackgroundColor: ColorPick.back.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Discard',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(width: 300.w),
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveForLater,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.back,
                  disabledBackgroundColor: ColorPick.back.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Save For Later',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required Widget child,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size:  20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: child,
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD PREVIEW  (compact card — mirrors Figma: text left, image right)
// Button label uses post.buttonLabel.en (from Button section in edit page)
// NOW INCLUDES SHORT DESCRIPTION between question and date/button row
// ══════════════════════════════════════════════════════════════════════════════
