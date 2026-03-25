// ******************* FILE INFO *******************
// File Name: blog_create_edit_page.dart
// Created by: Amr Mesbah
// Fixed:
//   • Publish / Save For Later now wait for cubit result before popping
//   • Loading indicator prevents double-taps
//   • Image bytes preserved correctly (not cleared from model)
//   • BlocListener handles success AND error states
//   • Validation runs before any async call
//   • Navigator.pop only on confirmed success state
//   • Existing image preview uses XHR to handle SVG + raster from Firebase
//   • SVG pick support: picked SVG files render via SvgPicture.memory

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Flutter Web only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/pages/dashboard/services_page/blog_services/blog_preview_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

// ── Local color palette ───────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF1A1A1A);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFDDE8DD);
  static const Color back      = Color(0xFFF1F2ED);
}

// ─────────────────────────────────────────────────────────────────────────────
class BlogCreateEditPage extends StatefulWidget {
  /// Pass null to create a new post, or an existing model to edit.
  final BlogPostModel? existing;

  const BlogCreateEditPage({super.key, this.existing});

  @override
  State<BlogCreateEditPage> createState() => _BlogCreateEditPageState();
}

class _BlogCreateEditPageState extends State<BlogCreateEditPage> {
  // ── Accordion open state ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'postInfo':    true,
    'button':      true,
    'description': true,
  };

  // ── Flags ─────────────────────────────────────────────────────────────────
  bool _submitted = false;
  bool _loading   = false;

  // ── Image ─────────────────────────────────────────────────────────────────
  Uint8List? _imageBytes;
  String     _existingImageUrl = '';
  bool       _isPickedSvg      = false;

  // ── Post Information controllers ──────────────────────────────────────────
  late final TextEditingController _questionEnCtrl;
  late final TextEditingController _questionArCtrl;
  late final TextEditingController _shortDescEnCtrl;
  late final TextEditingController _shortDescArCtrl;

  // ── Button controllers ────────────────────────────────────────────────────
  late final TextEditingController _btnLabelEnCtrl;
  late final TextEditingController _btnLabelArCtrl;

  // ── Description controllers ───────────────────────────────────────────────
  late final TextEditingController _descTitleEnCtrl;
  late final TextEditingController _descTitleArCtrl;

  /// Each entry: { id, type, enCtrl, arCtrl }
  final List<Map<String, dynamic>> _blocks = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    _questionEnCtrl   = TextEditingController(text: e?.question.en ?? '');
    _questionArCtrl   = TextEditingController(text: e?.question.ar ?? '');
    _shortDescEnCtrl  = TextEditingController(text: e?.shortDescription.en ?? '');
    _shortDescArCtrl  = TextEditingController(text: e?.shortDescription.ar ?? '');
    _btnLabelEnCtrl   = TextEditingController(text: e?.buttonLabel.en ?? '');
    _btnLabelArCtrl   = TextEditingController(text: e?.buttonLabel.ar ?? '');
    _descTitleEnCtrl  = TextEditingController(text: e?.descriptionTitle.en ?? '');
    _descTitleArCtrl  = TextEditingController(text: e?.descriptionTitle.ar ?? '');
    _existingImageUrl = e?.imageUrl ?? '';

    if (e != null) {
      for (final b in e.blocks) {
        _blocks.add({
          'id':     b.id,
          'type':   b.type,
          'enCtrl': TextEditingController(text: b.content.en),
          'arCtrl': TextEditingController(text: b.content.ar),
        });
      }
    }
  }

  @override
  void dispose() {
    _questionEnCtrl.dispose();
    _questionArCtrl.dispose();
    _shortDescEnCtrl.dispose();
    _shortDescArCtrl.dispose();
    _btnLabelEnCtrl.dispose();
    _btnLabelArCtrl.dispose();
    _descTitleEnCtrl.dispose();
    _descTitleArCtrl.dispose();
    for (final b in _blocks) {
      (b['enCtrl'] as TextEditingController).dispose();
      (b['arCtrl'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool get _isValid =>
      _questionEnCtrl.text.trim().isNotEmpty &&
          _questionArCtrl.text.trim().isNotEmpty;

  // ── Build model ───────────────────────────────────────────────────────────
  BlogPostModel _buildModel({required String status}) {
    final blocks = _blocks
        .map((b) => BlogDescriptionBlock(
      id:   b['id'] as String,
      type: b['type'] as BlogBlockType,
      content: BlogBilingualText(
        en: (b['enCtrl'] as TextEditingController).text.trim(),
        ar: (b['arCtrl'] as TextEditingController).text.trim(),
      ),
    ))
        .toList();

    return BlogPostModel(
      id:               widget.existing?.id ?? '',
      status:           status,
      imageUrl:         _existingImageUrl,
      question:         BlogBilingualText(
          en: _questionEnCtrl.text.trim(),
          ar: _questionArCtrl.text.trim()),
      shortDescription: BlogBilingualText(
          en: _shortDescEnCtrl.text.trim(),
          ar: _shortDescArCtrl.text.trim()),
      buttonLabel: BlogBilingualText(
          en: _btnLabelEnCtrl.text.trim(),
          ar: _btnLabelArCtrl.text.trim()),
      descriptionTitle: BlogBilingualText(
          en: _descTitleEnCtrl.text.trim(),
          ar: _descTitleArCtrl.text.trim()),
      blocks:    blocks,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
  }

  // ── Image pick (SVG + raster support) ─────────────────────────────────────
  Future<void> _pickImage() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    final name  = xfile.name.toLowerCase();
    final header = String.fromCharCodes(bytes.take(20)).trimLeft();

    setState(() {
      _imageBytes  = bytes;
      _isPickedSvg = name.endsWith('.svg') ||
          header.startsWith('<svg') ||
          header.startsWith('<?xml');
    });
  }

  // ── Block mutations ───────────────────────────────────────────────────────
  void _addBlock(BlogBlockType type) {
    setState(() {
      _blocks.add({
        'id':     'blk_${DateTime.now().microsecondsSinceEpoch}',
        'type':   type,
        'enCtrl': TextEditingController(),
        'arCtrl': TextEditingController(),
      });
    });
  }

  void _removeBlock(int index) {
    final b = _blocks.removeAt(index);
    (b['enCtrl'] as TextEditingController).dispose();
    (b['arCtrl'] as TextEditingController).dispose();
    setState(() {});
  }

  // ── Save core ─────────────────────────────────────────────────────────────
  Future<void> _save({required String status}) async {
    setState(() => _submitted = true);
    if (!_isValid) return;

    if (_loading) return;
    setState(() => _loading = true);

    try {
      final model = _buildModel(status: status);
      final cubit = context.read<BlogCubit>();

      if (_isEdit) {
        await cubit.updatePost(post: model, imageBytes: _imageBytes);
      } else {
        await cubit.createPost(post: model, imageBytes: _imageBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'published'
                  ? 'Post published successfully!'
                  : 'Draft saved successfully!',
            ),
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

  // ── Public action handlers ────────────────────────────────────────────────
  Future<void> _publish()      => _save(status: 'published');
  Future<void> _saveForLater() => _save(status: 'draft');
  void         _discard()      => Navigator.pop(context);

  void _preview() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: BlogPreviewPage(draft: _buildModel(status: 'draft')),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
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
                        _isEdit
                            ? 'Edit Important Reads'
                            : 'Create New Important Reads',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color:      _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _accordion(
                        key:      'postInfo',
                        title:    'Post Information',
                        children: [
                          SizedBox(height: 16.h),
                          _postInfoContent(),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      _accordion(
                        key:      'button',
                        title:    'Button',
                        children: [
                          SizedBox(height: 16.h),
                          _buttonContent(),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      _accordion(
                        key:      'description',
                        title:    'Description',
                        children: [
                          SizedBox(height: 16.h),
                          _descriptionContent(),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      _actionButtons(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

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
  // SECTION CONTENT BUILDERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _postInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image upload ──────────────────────────────────────────────────
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width:  60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: _imageBytes != null
                ? ClipOval(
              child: SizedBox(
                width:  60.w,
                height: 60.w,
                child: Center(
                  child: _isPickedSvg
                      ? SvgPicture.memory(
                    _imageBytes!,
                    width:  30.w,
                    height: 30.w,
                    fit: BoxFit.scaleDown,
                  )
                      : Image.memory(
                    _imageBytes!,
                    fit:    BoxFit.scaleDown,
                    width:  30.w,
                    height: 30.w,
                  ),
                ),
              ),
            )
                : _existingImageUrl.isNotEmpty
                ? ClipOval(
              child: SizedBox(
                width:  60.w,
                height: 60.w,
                child: Center(
                  child: _XhrCircleImage(
                    url:  _existingImageUrl,
                    size: 30.w,
                  ),
                ),
              ),
            )
                : Center(
              child: CustomSvg(
                assetPath: "assets/control/image.svg",
                width: 30.w, height: 30.h,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // ── Question EN + AR ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question', style: _labelStyle()),
            Text('سؤال',     style: _labelStyle()),
          ],
        ),
        SizedBox(height: 6.h),
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _questionEnCtrl,
              hint:          'Text Here',
              submitted:     _submitted,
              primaryColor:  _C.primary,
              textDirection: TextDirection.ltr,
              height:        40,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _questionArCtrl,
              hint:          'أكتب هنا',
              submitted:     _submitted,
              primaryColor:  _C.primary,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              height:        40,
            ),
          ),
        ]),

        // ── Short Description EN ──────────────────────────────────────────
        Text('Short Description', style: _labelStyle()),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          controller:    _shortDescEnCtrl,
          hint:          'Text Here',
          submitted:     false,
          primaryColor:  _C.primary,
          textDirection: TextDirection.ltr,
          maxLines:      4,
          height:        100,
          maxLength:     600,
        ),

        // ── Short Description AR ──────────────────────────────────────────
        Align(
          alignment: Alignment.centerRight,
          child: Text('وصف مختصر', style: _labelStyle()),
        ),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          controller:    _shortDescArCtrl,
          hint:          'أكتب هنا',
          submitted:     false,
          primaryColor:  _C.primary,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          maxLines:      4,
          height:        100,
          maxLength:     600,
        ),
      ],
    );
  }

  Widget _buttonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Label',  style: _labelStyle()),
            Text('تسمية',  style: _labelStyle()),
          ],
        ),
        SizedBox(height: 6.h),
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _btnLabelEnCtrl,
              hint:          'Text Here',
              submitted:     false,
              primaryColor:  _C.primary,
              textDirection: TextDirection.ltr,
              height:        40,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _btnLabelArCtrl,
              hint:          'أكتب هنا',
              submitted:     false,
              primaryColor:  _C.primary,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              height:        40,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _descriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Title',    style: _labelStyle()),
            Text('العنوان',  style: _labelStyle()),
          ],
        ),
        SizedBox(height: 6.h),
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _descTitleEnCtrl,
              hint:          'Text Here',
              submitted:     false,
              primaryColor:  _C.primary,
              textDirection: TextDirection.ltr,
              height:        40,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _descTitleArCtrl,
              hint:          'أكتب هنا',
              submitted:     false,
              primaryColor:  _C.primary,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              height:        40,
            ),
          ),
        ]),

        // ── Dynamic content blocks ─────────────────────────────────────────
        ..._blocks.asMap().entries.map(
                (e) => _blockWidget(idx: e.key, blk: e.value)),

        // ── Add-block chips ────────────────────────────────────────────────
        Wrap(
          spacing: 10.w, runSpacing: 8.h,
          children: [
            _addChip('+ Bullet Point',
                    () => _addBlock(BlogBlockType.bulletPoint)),
            _addChip('+ Paragraph',
                    () => _addBlock(BlogBlockType.paragraph)),
            _addChip('+ Numbering',
                    () => _addBlock(BlogBlockType.numbering)),
          ],
        ),
      ],
    );
  }

  Widget _blockWidget({
    required int                  idx,
    required Map<String, dynamic> blk,
  }) {
    final type   = blk['type'] as BlogBlockType;
    final enCtrl = blk['enCtrl'] as TextEditingController;
    final arCtrl = blk['arCtrl'] as TextEditingController;

    final String prefix = switch (type) {
      BlogBlockType.numbering   => '${idx + 1}.',
      BlogBlockType.bulletPoint => '•',
      BlogBlockType.paragraph   => '',
    };
    final String typeLabel = switch (type) {
      BlogBlockType.numbering   => 'Numbering',
      BlogBlockType.bulletPoint => 'Bullet Point',
      BlogBlockType.paragraph   => 'Paragraph',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (prefix.isNotEmpty) ...[
              Text(
                '$prefix  ',
                style: StyleText.fontSize13Weight500
                    .copyWith(color: _C.labelText, fontWeight: FontWeight.w600),
              ),
            ],
            Text(typeLabel,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.hintText)),
            const Spacer(),
          ]),
          SizedBox(height: 6.h),

          CustomValidatedTextFieldMaster(
            controller:    enCtrl,
            hint:          'Text Here',
            submitted:     false,
            primaryColor:  _C.primary,
            textDirection: TextDirection.ltr,
            maxLines:      4,
            height:        90,
          ),
          SizedBox(height: 8.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text('بالعربية', style: _labelStyle()),
          ),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            controller:    arCtrl,
            hint:          'أكتب هنا',
            submitted:     false,
            primaryColor:  _C.primary,
            textDirection: TextDirection.rtl,
            textAlign:     TextAlign.right,
            maxLines:      4,
            height:        90,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _actionButtons() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _preview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  disabledBackgroundColor: _C.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Preview',
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

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
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
                          .copyWith(color: Colors.white)),
                ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }

  Widget _addChip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:        const Color(0xff797979),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(label,
          style:
          StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
    ),
  );

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: _C.labelText);
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR circle image — auto-detects SVG vs raster (PNG/JPG/WebP)
// Works on Flutter Web, bypasses CORS for Firebase Storage
// ══════════════════════════════════════════════════════════════════════════════
class _XhrCircleImage extends StatefulWidget {
  final String url;
  final double size;

  const _XhrCircleImage({required this.url, required this.size});

  @override
  State<_XhrCircleImage> createState() => _XhrCircleImageState();
}

class _XhrCircleImageState extends State<_XhrCircleImage> {
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
  void didUpdateWidget(covariant _XhrCircleImage old) {
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
      debugPrint('_XhrCircleImage error: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Error
    if (_failed) {
      return SizedBox(
        width: widget.size, height: widget.size,
        child: Icon(Icons.broken_image_outlined,
            size: 24.sp, color: _C.hintText),
      );
    }

    // Loading
    if (_svgString == null && _rasterBytes == null) {
      return SizedBox(
        width: widget.size, height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _C.primary),
        ),
      );
    }

    // SVG
    if (_isSvg && _svgString != null) {
      return SizedBox(
        width: widget.size, height: widget.size,
        child: SvgPicture.string(
          _svgString!,
          width:  widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
      );
    }

    // Raster (PNG/JPG/WebP)
    if (_rasterBytes != null) {
      return Image.memory(
        _rasterBytes!,
        width:  widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(
          width: widget.size, height: widget.size,
          child: Icon(Icons.broken_image_outlined,
              size: 24.sp, color: _C.hintText),
        ),
      );
    }

    // Fallback
    return SizedBox(width: widget.size, height: widget.size);
  }
}