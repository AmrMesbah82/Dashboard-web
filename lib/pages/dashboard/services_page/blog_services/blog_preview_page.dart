// ******************* FILE INFO *******************
// File Name: blog_preview_page.dart
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
//   • Footer buttons match blog_create_edit_page.dart style (ElevatedButton, 2×2 grid)
//   • Loading overlay + snackbar feedback + double-tap guard

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Flutter Web only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';

import '../../../../widgets/admin_sub_navbar.dart';

// ── Color palette ──────────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFDDE8DD);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color textBody  = Color(0xFF555555);
  static const Color grey      = Color(0xFF9E9E9E);
}

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

  const BlogPreviewPage({super.key, required this.draft});

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
          .createPost(post: widget.draft.copyWith(status: 'published'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post published successfully!'),
            backgroundColor: _C.primary,
          ),
        );
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

  Future<void> _saveForLater() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await context
          .read<BlogCubit>()
          .createPost(post: widget.draft.copyWith(status: 'draft'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Draft saved successfully!'),
            backgroundColor: _C.primary,
          ),
        );
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
  void _discard() => Navigator.pop(context);

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final BlogPostModel p = widget.draft;

    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          color:      _C.primary,
                          fontSize:   28.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _accordion(
                        key:   'card',
                        title: 'Card View',
                        child: _CardPreview(post: p),
                      ),
                      SizedBox(height: 16.h),

                      _accordion(
                        key:   'readMore',
                        title: 'Read More',
                        child: _ReadMorePreview(post: p),
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

          // ── Loading overlay ────────────────────────────────────────
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_C.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS — identical layout to blog_create_edit_page.dart
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
                  backgroundColor: _C.primary,
                  disabledBackgroundColor: _C.grey,
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
                onPressed: _loading ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  disabledBackgroundColor: _C.grey,
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
                  backgroundColor: _C.grey,
                  disabledBackgroundColor: _C.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Discard',
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
                onPressed: _loading ? null : _saveForLater,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.grey,
                  disabledBackgroundColor: _C.grey.withOpacity(0.5),
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
          color: _C.cardBg, borderRadius: BorderRadius.circular(6.r)),
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
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft:  Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
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
              padding: EdgeInsets.all(16.w),
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
// ══════════════════════════════════════════════════════════════════════════════

class _CardPreview extends StatelessWidget {
  final BlogPostModel post;
  const _CardPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = post.buttonLabel.en.isNotEmpty
        ? post.buttonLabel.en
        : 'Read More';

    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.question.en.isNotEmpty
                        ? post.question.en
                        : 'Question text',
                    style: StyleText.fontSize13Weight500.copyWith(
                        color: _C.primary, fontWeight: FontWeight.w600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: post.imageUrl.isNotEmpty
                      ? _XhrImage(
                    url:    post.imageUrl,
                    width:  100.w,
                    height: 70.h,
                  )
                      : Container(
                    width:  100.w,
                    height: 70.h,
                    color:  _C.border,
                    child: Icon(Icons.image_outlined,
                        size: 24.sp, color: _C.hintText),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            Text(_fmtDate(post.createdAt),
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.hintText)),
            SizedBox(height: 10.h),

            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                  color:        _C.primary,
                  borderRadius: BorderRadius.circular(6.r)),
              child: Text(buttonLabel,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// READ MORE PREVIEW  (full article — matches Figma desktop layout)
// ══════════════════════════════════════════════════════════════════════════════

class _ReadMorePreview extends StatelessWidget {
  final BlogPostModel post;
  const _ReadMorePreview({required this.post});

  MarkdownStyleSheet _mdStyle() {
    return MarkdownStyleSheet(
      p: StyleText.fontSize13Weight400.copyWith(
          color: _C.textBody, height: 1.7),
      strong: StyleText.fontSize13Weight400.copyWith(
          color: _C.labelText, fontWeight: FontWeight.w700, height: 1.7),
      em: StyleText.fontSize13Weight400.copyWith(
          color: _C.textBody, fontStyle: FontStyle.italic, height: 1.7),
      h1: StyleText.fontSize22Weight700.copyWith(
          color: _C.labelText),
      h2: StyleText.fontSize14Weight600.copyWith(
          color: _C.labelText, fontSize: 18.sp),
      h3: StyleText.fontSize14Weight600.copyWith(
          color: _C.labelText),
      a: StyleText.fontSize13Weight400.copyWith(
          color: _C.primary, decoration: TextDecoration.underline),
      listBullet: StyleText.fontSize13Weight400.copyWith(
          color: _C.textBody, height: 1.7),
      blockquoteDecoration: BoxDecoration(
        color: _C.sectionBg,
        border: Border(
          left: BorderSide(color: _C.primary, width: 3.w),
        ),
      ),
      blockquotePadding: EdgeInsets.symmetric(
          horizontal: 12.w, vertical: 8.h),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6.r),
      ),
      codeblockPadding: EdgeInsets.all(12.w),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize:   12.sp,
        color:      _C.labelText,
        backgroundColor: const Color(0xFFF0F0F0),
      ),
      tableBorder: TableBorder.all(color: _C.border, width: 1),
      tableHead: StyleText.fontSize13Weight400.copyWith(
          color: _C.labelText, fontWeight: FontWeight.w700),
      tableBody: StyleText.fontSize13Weight400.copyWith(
          color: _C.textBody),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _C.border, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = post.question.en.isNotEmpty
        ? post.question.en
        : 'Why digital transformation is important?';
    final String sectionHead = post.descriptionTitle.en.isNotEmpty
        ? post.descriptionTitle.en
        : 'Digital Transformation';
    final String intro = post.shortDescription.en.isNotEmpty
        ? post.shortDescription.en
        : '';
    final String dateStr = _fmtDate(post.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize22Weight700.copyWith(
              color:      _C.primary,
              fontSize:   22.sp,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 20.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sectionHead,
                      style: StyleText.fontSize14Weight600.copyWith(
                          color:      _C.labelText,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 8.h),
                  if (intro.isNotEmpty) ...[
                    Text(intro,
                        style: StyleText.fontSize13Weight400.copyWith(
                            color: _C.textBody, height: 1.7)),
                    SizedBox(height: 8.h),
                  ],
                  Text(dateStr,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: _C.hintText)),
                ],
              ),
            ),
            SizedBox(width: 24.w),

            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: post.imageUrl.isNotEmpty
                  ? _XhrImage(
                url:    post.imageUrl,
                width:  200.w,
                height: 150.h,
              )
                  : Container(
                width:  200.w,
                height: 150.h,
                decoration: BoxDecoration(
                  color:        _C.border,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.image_outlined,
                    size: 40.sp, color: _C.hintText),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        ...post.blocks.asMap().entries.map(
                (e) => _blockWidget(index: e.key, block: e.value)),

        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _blockWidget(
      {required int index, required BlogDescriptionBlock block}) {
    final String text =
    block.content.en.isNotEmpty ? block.content.en : '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: switch (block.type) {
        BlogBlockType.paragraph => MarkdownBody(
          data:       text,
          selectable: true,
          styleSheet: _mdStyle(),
          shrinkWrap: true,
        ),

        BlogBlockType.numbering => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}.  ',
                style: StyleText.fontSize13Weight500.copyWith(
                    color:      _C.labelText,
                    fontWeight: FontWeight.w600)),
            Expanded(
              child: MarkdownBody(
                data:       text,
                selectable: true,
                styleSheet: _mdStyle(),
                shrinkWrap: true,
              ),
            ),
          ],
        ),

        BlogBlockType.bulletPoint => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ',
                style: StyleText.fontSize13Weight500.copyWith(
                    color:      _C.primary,
                    fontWeight: FontWeight.w700)),
            Expanded(
              child: MarkdownBody(
                data:       text,
                selectable: true,
                styleSheet: _mdStyle(),
                shrinkWrap: true,
              ),
            ),
          ],
        ),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR image loader — auto-detects SVG vs raster (PNG/JPG/WebP)
// Works on Flutter Web, bypasses CORS for Firebase Storage
// ══════════════════════════════════════════════════════════════════════════════
class _XhrImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const _XhrImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<_XhrImage> createState() => _XhrImageState();
}

class _XhrImageState extends State<_XhrImage> {
  String?    _svgString;
  Uint8List? _rasterBytes;
  bool _isSvg  = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _XhrImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _svgString   = null;
      _rasterBytes = null;
      _isSvg  = false;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final xhr = html.HttpRequest();
      xhr.open('GET', widget.url, async: true);
      xhr.responseType = 'arraybuffer';

      final completer = Completer<Uint8List>();

      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          final buf = xhr.response as ByteBuffer;
          completer.complete(buf.asUint8List());
        } else {
          completer.completeError('HTTP ${xhr.status}');
        }
      });
      xhr.onError.listen((_) => completer.completeError('XHR error'));
      xhr.send();

      final bytes = await completer.future;
      final header = String.fromCharCodes(bytes.take(20));

      if (header.trimLeft().startsWith('<svg') ||
          header.trimLeft().startsWith('<?xml')) {
        final svgStr = String.fromCharCodes(bytes);
        if (mounted) {
          setState(() {
            _svgString = svgStr;
            _isSvg = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _rasterBytes = bytes;
            _isSvg = false;
          });
        }
      }
    } catch (e) {
      debugPrint('_XhrImage load error: $e | url: ${widget.url}');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        width: widget.width, height: widget.height,
        color: _C.sectionBg,
        child: Icon(Icons.broken_image_outlined,
            size: 24.sp, color: _C.hintText),
      );
    }

    if (_svgString == null && _rasterBytes == null) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _C.primary),
        ),
      );
    }

    if (_isSvg && _svgString != null) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: Center(
          child: SvgPicture.string(
            _svgString!,
            width:  widget.width  * 0.5,
            height: widget.height * 0.5,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    }

    if (_rasterBytes != null) {
      return Image.memory(
        _rasterBytes!,
        width:  widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: widget.width, height: widget.height,
          color: _C.sectionBg,
          child: Icon(Icons.broken_image_outlined,
              size: 24.sp, color: _C.hintText),
        ),
      );
    }

    return Container(
      width: widget.width, height: widget.height,
      color: _C.sectionBg,
      child: Icon(Icons.image_outlined,
          size: 24.sp, color: _C.hintText),
    );
  }
}