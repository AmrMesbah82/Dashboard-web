// ******************* FILE INFO *******************
// File Name: blog_edit_page.dart
// Created by: Amr Mesbah
// Updated: Image upload restricted to SVG only.
//          Browser picker filtered to .svg + double-check validation on file name/mime.

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';
import 'package:web_app_admin/widgets/app_footer.dart';

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color bg      = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border  = Color(0xFFE0E0E0);
  static const Color label   = Color(0xFF333333);
  static const Color hint    = Color(0xFFAAAAAA);
  static const Color remove  = Color(0xFFE53935);
}

class BlogEditPage extends StatefulWidget {
  final String? postId; // null = create mode
  const BlogEditPage({super.key, this.postId});
  @override
  State<BlogEditPage> createState() => _BlogEditPageState();
}

class _BlogEditPageState extends State<BlogEditPage> {
  bool get _isEdit => widget.postId != null && widget.postId!.isNotEmpty;
  bool _isSaving  = false;
  bool _submitted = false;

  // ── Post information ──────────────────────────────────────────────────────
  Uint8List? _imageBytes;
  String     _imageUrl    = '';
  final _questionEn       = TextEditingController();
  final _questionAr       = TextEditingController();
  final _shortDescEn      = TextEditingController();
  final _shortDescAr      = TextEditingController();

  // ── Button section ────────────────────────────────────────────────────────
  final _btnLabelEn = TextEditingController();
  final _btnLabelAr = TextEditingController();

  // ── Description section ───────────────────────────────────────────────────
  final _descTitleEn = TextEditingController();
  final _descTitleAr = TextEditingController();

  // ── Dynamic blocks ────────────────────────────────────────────────────────
  final List<_BlockItem> _blocks = [];
  int _blockCounter = 0;

  // ── Accordion state ───────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'postInfo': true,
    'button':   true,
    'desc':     true,
  };

  // ── Seed tracking ─────────────────────────────────────────────────────────
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEdit) context.read<BlogCubit>().load();
    });
  }

  void _seedFromPost(BlogPostModel post) {
    if (_seeded) return;
    _seeded = true;
    _imageUrl           = post.imageUrl;
    _questionEn.text    = post.question.en;
    _questionAr.text    = post.question.ar;
    _shortDescEn.text   = post.shortDescription.en;
    _shortDescAr.text   = post.shortDescription.ar;
    _btnLabelEn.text    = post.buttonLabel.en;
    _btnLabelAr.text    = post.buttonLabel.ar;
    _descTitleEn.text   = post.descriptionTitle.en;
    _descTitleAr.text   = post.descriptionTitle.ar;

    for (final b in _blocks) b.dispose();
    _blocks.clear();
    for (final b in post.blocks) {
      final item = _BlockItem(
        id:           b.id,
        type:         b.type,
        blockCounter: _blockCounter++,
      );
      item.enCtrl.text = b.content.en;
      item.arCtrl.text = b.content.ar;
      _blocks.add(item);
    }
    setState(() {});
  }

  // ── Image pick — SVG ONLY ─────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final completer = Completer<Uint8List?>();
    bool completed  = false;

    // Restrict browser file picker to SVG only
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((e) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      final file = files.first;

      // Double-check file name + MIME type — reject anything that is not SVG
      final name = file.name.toLowerCase();
      final mime = file.type.toLowerCase();
      final isSvg = name.endsWith('.svg') || mime == 'image/svg+xml';

      if (!isSvg) {
        if (!completed) { completed = true; completer.complete(null); }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only SVG files are allowed.'),
            backgroundColor: _C.remove,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (!completed) {
          completed = true;
          completer.complete(r is List<int> ? Uint8List.fromList(r) : null);
        }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();
    final bytes = await completer.future;
    if (bytes != null) setState(() => _imageBytes = bytes);
  }

  // ── Add block ─────────────────────────────────────────────────────────────
  void _addBlock(BlogBlockType type) {
    setState(() {
      _blocks.add(_BlockItem(
        id:           'blk_${DateTime.now().microsecondsSinceEpoch}',
        type:         type,
        blockCounter: _blockCounter++,
      ));
    });
  }

  // ── Build post from UI ────────────────────────────────────────────────────
  BlogPostModel _buildPost(String status) => BlogPostModel(
    id:               _isEdit ? widget.postId! : '',
    status:           status,
    imageUrl:         _imageUrl,
    question:         BlogBilingualText(en: _questionEn.text,   ar: _questionAr.text),
    shortDescription: BlogBilingualText(en: _shortDescEn.text,  ar: _shortDescAr.text),
    buttonLabel:      BlogBilingualText(en: _btnLabelEn.text,   ar: _btnLabelAr.text),
    descriptionTitle: BlogBilingualText(en: _descTitleEn.text,  ar: _descTitleAr.text),
    blocks: _blocks.map((b) => BlogDescriptionBlock(
      id:      b.id,
      type:    b.type,
      content: BlogBilingualText(en: b.enCtrl.text, ar: b.arCtrl.text),
    )).toList(),
  );

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() { _submitted = true; _isSaving = true; });
    try {
      final post  = _buildPost(status);
      final cubit = context.read<BlogCubit>();
      if (_isEdit) {
        await cubit.updatePost(post: post, imageBytes: _imageBytes);
      } else {
        await cubit.createPost(post: post, imageBytes: _imageBytes);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _questionEn.dispose();  _questionAr.dispose();
    _shortDescEn.dispose(); _shortDescAr.dispose();
    _btnLabelEn.dispose();  _btnLabelAr.dispose();
    _descTitleEn.dispose(); _descTitleAr.dispose();
    for (final b in _blocks) b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlogCubit, BlogState>(
      listener: (context, state) {
        if (state is BlogPostSaved) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved successfully!'),
            backgroundColor: _C.primary,
          ));
          context.goNamed('blog-list');
        }
        if (state is BlogError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        // Seed when editing
        if (_isEdit && state is BlogLoaded) {
          final post = state.posts.firstWhere(
                (p) => p.id == widget.postId,
            orElse: () => BlogPostModel.empty(),
          );
          if (post.id.isNotEmpty) _seedFromPost(post);
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.bg,
              body: Column(
                children: [
                  AppNavbar(currentRoute: '/blog-list'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40.w,
                              vertical: 24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ── Page title ──────────────────────────────
                                Text(
                                  _isEdit
                                      ? 'Edit Important Read'
                                      : 'Create New Important Reads',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _C.primary,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // ── Post Information ────────────────────────
                                _accordion(
                                  key: 'postInfo',
                                  title: 'Post Information',
                                  children: [
                                    // Cover image picker — SVG only label
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: _pickImage,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 80.w, height: 80.h,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFD9D9D9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _imageBytes != null
                                                    ? ClipOval(
                                                  child: SvgPicture.memory(
                                                    _imageBytes!,
                                                    width: 80.w, height: 80.h,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                    : _imageUrl.isNotEmpty
                                                    ? ClipOval(
                                                  child: SvgPicture.network(
                                                    _imageUrl,
                                                    width: 80.w, height: 80.h,
                                                    fit: BoxFit.cover,
                                                    placeholderBuilder: (_) => Center(
                                                      child: Icon(Icons.image_outlined,
                                                          size: 32.sp, color: _C.hint),
                                                    ),
                                                  ),
                                                )
                                                    : Center(
                                                  child: Icon(
                                                    Icons.image_outlined,
                                                    size: 32.sp,
                                                    color: _C.hint,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0, right: 0,
                                                child: Container(
                                                  width: 26.w, height: 26.h,
                                                  decoration: BoxDecoration(
                                                    color: _C.primary,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 13.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        // SVG-only hint label
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline,
                                                size: 12.sp,
                                                color: _C.hint),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'SVG format only',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 11.sp,
                                                color: _C.hint,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    _biRow('Question', 'سؤال',
                                        _questionEn, _questionAr),
                                    SizedBox(height: 14.h),
                                    _fullField('Short Description',
                                        _shortDescEn, maxLines: 4),
                                    SizedBox(height: 10.h),
                                    _fullFieldRtl('وصف مختصر',
                                        _shortDescAr, maxLines: 4),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                // ── Button ──────────────────────────────────
                                _accordion(
                                  key: 'button',
                                  title: 'Button',
                                  children: [
                                    _biRow('Label', 'تسمية',
                                        _btnLabelEn, _btnLabelAr),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                // ── Description ─────────────────────────────
                                _accordion(
                                  key: 'desc',
                                  title: 'Description',
                                  children: [
                                    _biRow('Title', 'العنوان',
                                        _descTitleEn, _descTitleAr),
                                    SizedBox(height: 14.h),
                                    _fullField(
                                      'Paragraph',
                                      _blocks.isNotEmpty
                                          ? _blocks.first.enCtrl
                                          : TextEditingController(),
                                      maxLines: 6,
                                    ),
                                    SizedBox(height: 10.h),
                                    _fullFieldRtl(
                                      'فقرة',
                                      _blocks.isNotEmpty
                                          ? _blocks.first.arCtrl
                                          : TextEditingController(),
                                      maxLines: 6,
                                    ),
                                    SizedBox(height: 14.h),

                                    // Dynamic blocks
                                    ..._blocks.skip(1).toList().asMap().entries
                                        .map((entry) => _blockWidget(
                                      entry.key + 1,
                                      _blocks[entry.key + 1],
                                    )),

                                    // Add block buttons
                                    SizedBox(height: 8.h),
                                    Wrap(
                                      spacing: 10.w,
                                      runSpacing: 8.h,
                                      children: [
                                        _addBlockBtn('+ Bullet Points',
                                                () => _addBlock(BlogBlockType.bulletPoint)),
                                        _addBlockBtn('+ Paragraph',
                                                () => _addBlock(BlogBlockType.paragraph)),
                                        _addBlockBtn('+ Numbering',
                                                () => _addBlock(BlogBlockType.numbering)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),

                                // ── Action buttons ───────────────────────────
                                Row(
                                  children: [
                                    Expanded(
                                      child: _actionBtn(
                                        'Preview',
                                        _C.primary.withOpacity(0.7),
                                            () {},
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _actionBtn(
                                        'Publish',
                                        _C.primary,
                                            () => _save('published'),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _actionBtn(
                                        'Discard',
                                        const Color(0xFF9E9E9E),
                                            () => context.pop(),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _actionBtn(
                                        'Save For Later',
                                        const Color(0xFF9E9E9E),
                                            () => _save('draft'),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Saving overlay ─────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: _C.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  // ── Block widget ──────────────────────────────────────────────────────────
  Widget _blockWidget(int index, _BlockItem block) {
    final label = block.type == BlogBlockType.numbering
        ? '$index.'
        : block.type == BlogBlockType.bulletPoint
        ? 'Bullet Point'
        : 'Paragraph';
    final labelAr = block.type == BlogBlockType.numbering
        ? '.$index'
        : block.type == BlogBlockType.bulletPoint
        ? 'نقطة تعداد'
        : 'فقرة';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: _C.label,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _blocks.remove(block);
                  block.dispose();
                }),
                child: Icon(Icons.close, size: 16.sp, color: _C.remove),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          _fullField(
            label, block.enCtrl,
            maxLines: block.type == BlogBlockType.paragraph ? 5 : 2,
          ),
          SizedBox(height: 6.h),
          _fullFieldRtl(
            labelAr, block.arCtrl,
            maxLines: block.type == BlogBlockType.paragraph ? 5 : 2,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _biRow(
      String enLabel,
      String arLabel,
      TextEditingController en,
      TextEditingController ar,
      ) =>
      Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: enLabel, hint: 'Text Here', controller: en,
              maxLines: 1, height: 36, showCharCount: false,
              submitted: _submitted,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: arLabel, hint: 'أدخل النص هنا', controller: ar,
                maxLines: 1, height: 36, showCharCount: false,
                submitted: _submitted,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      );

  Widget _fullField(
      String label,
      TextEditingController ctrl, {
        int maxLines = 3,
      }) =>
      CustomValidatedTextFieldMaster(
        label: label, hint: 'Text Here', controller: ctrl,
        maxLines: maxLines, height: maxLines > 2 ? 100 : 60,
        showCharCount: maxLines > 2, maxLength: 500,
        submitted: _submitted,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );

  Widget _fullFieldRtl(
      String label,
      TextEditingController ctrl, {
        int maxLines = 3,
      }) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: label, hint: 'أدخل النص هنا', controller: ctrl,
          maxLines: maxLines, height: maxLines > 2 ? 100 : 60,
          showCharCount: maxLines > 2, maxLength: 500,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
      );

  Widget _addBlockBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: _C.label,
        ),
      ),
    ),
  );

  Widget _actionBtn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: _isSaving ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}

// ── Block item helper ─────────────────────────────────────────────────────────

class _BlockItem {
  final String        id;
  final BlogBlockType type;
  final int           blockCounter;
  final TextEditingController enCtrl;
  final TextEditingController arCtrl;

  _BlockItem({
    required this.id,
    required this.type,
    required this.blockCounter,
  })  : enCtrl = TextEditingController(),
        arCtrl = TextEditingController();

  void dispose() {
    enCtrl.dispose();
    arCtrl.dispose();
  }
}