// ******************* FILE INFO *******************
// File Name: blog_create_edit_page.dart
// Created by: Amr Mesbah
// UPDATED:
//   • Publish button disabled until ALL fields valid + SVG image present
//   • SVG ONLY - Only SVG images are allowed
//   • Real-time validation drives button enable/disable state
//   • After publish → navigates to ServicesMainPageMaster (pushAndRemoveUntil)
//   • After successful save (any status) → navigates to ServicesMainPageMaster
//   • showPublishConfirmDialog with async onConfirm (loader inside dialog)
// Last Update: 21/04/2026

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/core/custom_dialog.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../careers/presentation/ui/pages/careers_main_dashboard.dart';
import '../../../../../job/presentation/ui/pages/job_listing_main_page.dart';
import '../../../../../main/presentation/ui/pages/home_main_page.dart';
import '../../../../data/model/blog_model.dart';
import '../../../controller/blog_cubit.dart';
import '../services_main/services_main_page.dart';
import 'blog_preview_page.dart';


class _C {
  static const Color primary    = Color(0xFF008037);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color labelText  = Color(0xFF1A1A1A);
  static const Color grey       = Color(0xFF9E9E9E);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color border     = Color(0xFFDDE8DD);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color error      = Color(0xFFD32F2F);
  static const Color draftBadge = Color(0xFFF59E0B);
}

void _log(String message, {String level = '🔵'}) {
  debugPrint('$level [BlogCreateEditPage] $message');
}

class BlogCreateEditPage extends StatefulWidget {
  final BlogPostModel? existing;
  final bool isFromDraft;

  const BlogCreateEditPage({super.key, this.existing, this.isFromDraft = false});

  @override
  State<BlogCreateEditPage> createState() => _BlogCreateEditPageState();
}

class _BlogCreateEditPageState extends State<BlogCreateEditPage> {
  final Map<String, bool> _open = {
    'postInfo':    true,
    'button':      true,
    'description': true,
  };

  bool _submitted      = false;
  bool _isEditingDraft = false;

  // Image
  Uint8List? _imageBytes;
  String     _existingImageUrl = '';
  bool       _isPickedSvg      = false;

  // Controllers
  late final TextEditingController _questionEnCtrl;
  late final TextEditingController _questionArCtrl;
  late final TextEditingController _shortDescEnCtrl;
  late final TextEditingController _shortDescArCtrl;
  late final TextEditingController _btnLabelEnCtrl;
  late final TextEditingController _btnLabelArCtrl;
  late final TextEditingController _descTitleEnCtrl;
  late final TextEditingController _descTitleArCtrl;

  final List<Map<String, dynamic>> _blocks         = [];
  final ScrollController           _scrollController = ScrollController();

  bool get _isEdit => widget.existing != null;

  bool _isArabicOnly(String text) {
    // Allows Arabic letters, spaces, punctuation, numbers
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s\d.,،؟!؛:()«»\-]+$');
    return text.trim().isEmpty || arabicRegex.hasMatch(text.trim());
  }

  bool _isEnglishOnly(String text) {
    // Allows standard ASCII printable characters (English letters, numbers, punctuation)
    final englishRegex = RegExp(r'^[\x20-\x7E]+$');
    return text.trim().isEmpty || englishRegex.hasMatch(text.trim());
  }

  bool get _isPublishEnabled {
    if (_imageBytes == null && _existingImageUrl.isEmpty) return false;

    // Question
    if (_questionEnCtrl.text.trim().isEmpty) return false;
    if (!_isEnglishOnly(_questionEnCtrl.text)) return false;
    if (_questionArCtrl.text.trim().isEmpty) return false;
    if (!_isArabicOnly(_questionArCtrl.text)) return false;

    // Short description
    if (_shortDescEnCtrl.text.trim().isEmpty) return false;
    if (!_isEnglishOnly(_shortDescEnCtrl.text)) return false;
    if (_shortDescArCtrl.text.trim().isEmpty) return false;
    if (!_isArabicOnly(_shortDescArCtrl.text)) return false;

    // Button label
    if (_btnLabelEnCtrl.text.trim().isEmpty) return false;
    if (!_isEnglishOnly(_btnLabelEnCtrl.text)) return false;
    if (_btnLabelArCtrl.text.trim().isEmpty) return false;
    if (!_isArabicOnly(_btnLabelArCtrl.text)) return false;

    // Description title
    if (_descTitleEnCtrl.text.trim().isEmpty) return false;
    if (!_isEnglishOnly(_descTitleEnCtrl.text)) return false;
    if (_descTitleArCtrl.text.trim().isEmpty) return false;
    if (!_isArabicOnly(_descTitleArCtrl.text)) return false;

    // Blocks
    for (final b in _blocks) {
      final en = (b['enCtrl'] as TextEditingController).text.trim();
      final ar = (b['arCtrl'] as TextEditingController).text.trim();
      if (en.isEmpty || ar.isEmpty) return false;
      if (!_isEnglishOnly(en)) return false;
      if (!_isArabicOnly(ar)) return false;
    }
    return true;
  }

  // Draft only needs question fields
  bool get _isDraftEnabled =>
      _questionEnCtrl.text.trim().isNotEmpty &&
          _questionArCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isEditingDraft = widget.isFromDraft;
    _log('Page initialized. Mode: ${_isEdit ? "EDIT" : "CREATE"} | isFromDraft: $_isEditingDraft');

    final e = widget.existing;

    _questionEnCtrl  = TextEditingController(text: e?.question.en ?? '');
    _questionArCtrl  = TextEditingController(text: e?.question.ar ?? '');
    _shortDescEnCtrl = TextEditingController(text: e?.shortDescription.en ?? '');
    _shortDescArCtrl = TextEditingController(text: e?.shortDescription.ar ?? '');
    _btnLabelEnCtrl  = TextEditingController(text: e?.buttonLabel.en ?? '');
    _btnLabelArCtrl  = TextEditingController(text: e?.buttonLabel.ar ?? '');
    _descTitleEnCtrl = TextEditingController(text: e?.descriptionTitle.en ?? '');
    _descTitleArCtrl = TextEditingController(text: e?.descriptionTitle.ar ?? '');
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

    // Listen to ALL controllers so button reactively enables/disables
    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _allControllers => [
    _questionEnCtrl,
    _questionArCtrl,
    _shortDescEnCtrl,
    _shortDescArCtrl,
    _btnLabelEnCtrl,
    _btnLabelArCtrl,
    _descTitleEnCtrl,
    _descTitleArCtrl,
  ];

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _scrollController.dispose();
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final b in _blocks) {
      (b['enCtrl'] as TextEditingController).dispose();
      (b['arCtrl'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ── Build model ────────────────────────────────────────────────────────────
  BlogPostModel _buildModel({required String status}) {
    final blocks = _blocks.map((b) => BlogDescriptionBlock(
      id:      b['id'] as String,
      type:    b['type'] as BlogBlockType,
      content: BlogBilingualText(
        en: (b['enCtrl'] as TextEditingController).text.trim(),
        ar: (b['arCtrl'] as TextEditingController).text.trim(),
      ),
    )).toList();

    return BlogPostModel(
      id:               widget.existing?.id ?? '',
      status:           status,
      imageUrl:         _existingImageUrl,
      question:         BlogBilingualText(en: _questionEnCtrl.text.trim(),  ar: _questionArCtrl.text.trim()),
      shortDescription: BlogBilingualText(en: _shortDescEnCtrl.text.trim(), ar: _shortDescArCtrl.text.trim()),
      buttonLabel:      BlogBilingualText(en: _btnLabelEnCtrl.text.trim(),  ar: _btnLabelArCtrl.text.trim()),
      descriptionTitle: BlogBilingualText(en: _descTitleEnCtrl.text.trim(), ar: _descTitleArCtrl.text.trim()),
      blocks:           blocks,
      createdAt:        widget.existing?.createdAt ?? DateTime.now(),
    );
  }

  // ── SVG-only image picker ──────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';
    uploadInput.click();

    await uploadInput.onChange.first;
    if (uploadInput.files == null || uploadInput.files!.isEmpty) return;

    final file = uploadInput.files!.first;

    // 1. Check file extension
    final fileName = file.name.toLowerCase();
    if (!fileName.endsWith('.svg')) {
      if (mounted) {
        _showErrorDialog(
          title: 'Invalid File Type',
          subtitle: 'Only SVG files are allowed. Please select an SVG file.',
        );
      }
      return;
    }

    // 2. Check MIME type
    if (file.type.isNotEmpty && file.type != 'image/svg+xml') {
      if (mounted) {
        _showErrorDialog(
          title: 'Invalid File Type',
          subtitle: 'Only SVG files are allowed. Please select an SVG file.',
        );
      }
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;

    final result = reader.result;
    if (result == null) return;

    final bytes = Uint8List.fromList((result as List<int>));
    final fileContent = String.fromCharCodes(bytes.take(100)).toLowerCase().trimLeft();

    // 3. Validate SVG content (must start with <svg or <?xml)
    if (!fileContent.startsWith('<svg') && !fileContent.startsWith('<?xml')) {
      if (mounted) {
        _showErrorDialog(
          title: 'Invalid SVG File',
          subtitle: 'The selected file is not a valid SVG image. Please select a valid SVG file.',
        );
      }
      return;
    }

    // 4. Success - update the state
    setState(() {
      _imageBytes = bytes;
      _isPickedSvg = true;
      _existingImageUrl = '';
    });
  }

  // Helper method for error dialogs
  void _showErrorDialog({required String title, required String subtitle}) {
    showConfirmDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      confirmLabel: 'OK',
      cancelLabel: '',
      onConfirm: () {},
      iconWidget: Container(
        width: 60.r,
        height: 60.r,
        decoration: const BoxDecoration(
          color: Color(0xFFE53935),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
      ),
    );
  }

  // ── Block mutations ────────────────────────────────────────────────────────
  void _addBlock(BlogBlockType type) {
    final enCtrl = TextEditingController();
    final arCtrl = TextEditingController();
    // Hook into reactive rebuild so publish button updates when blocks change
    enCtrl.addListener(_onFieldChanged);
    arCtrl.addListener(_onFieldChanged);
    setState(() {
      _blocks.add({
        'id':     'blk_${DateTime.now().microsecondsSinceEpoch}',
        'type':   type,
        'enCtrl': enCtrl,
        'arCtrl': arCtrl,
      });
    });
  }

  void _removeBlock(int index) {
    final b = _blocks.removeAt(index);
    (b['enCtrl'] as TextEditingController)
      ..removeListener(_onFieldChanged)
      ..dispose();
    (b['arCtrl'] as TextEditingController)
      ..removeListener(_onFieldChanged)
      ..dispose();
    setState(() {});
  }

  // ── Core save logic (called by dialog's onConfirm) ─────────────────────────
  Future<void> _doSave({required String status}) async {
    _log('💾 _doSave() status="$status"');
    try {
      final model = _buildModel(status: status);
      final cubit = context.read<BlogCubit>();

      if (_isEdit) {
        await cubit.updatePost(post: model, imageBytes: _imageBytes);
      } else {
        await cubit.createPost(post: model, imageBytes: _imageBytes);
      }

      _log('🔄 Refreshing BlogCubit...');
      await cubit.load();

      // Navigate after dialog closes (postFrameCallback avoids navigator
      // assertion). Navigate to ServicesMainPageMaster on ANY successful save.
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // Navigate to ServicesMainPageMaster, clearing the entire stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ServicesMainPageMaster(),
            ),
                (route) => false,
          );
        });
      }
    } catch (e) {
      _log('❌ Error: $e', level: '🔴');
      rethrow; // Let dialog catch it and reset loader
    }
  }

  // ── Publish button handler ─────────────────────────────────────────────────
  Future<void> _publish() async {
    setState(() => _submitted = true);

    // Guard (button should already be disabled, but double-check)
    if (!_isPublishEnabled) return;

    await showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH POST',
      subtitle: 'Do you want to publish this post? It will go live immediately.',
      confirmLabel: 'Publish',
      backLabel: 'Cancel',
      onConfirm: () => _doSave(status: 'published'),
    );
  }

  // ── Save for later handler ─────────────────────────────────────────────────
  Future<void> _saveForLater() async {
    setState(() => _submitted = true);
    if (!_isDraftEnabled) {
      showSuccessDialog(
        context: context,
        title: 'Required Fields Missing',
        subtitle: 'Please fill in the question fields before saving as draft.',
      );
      return;
    }
    await showPublishConfirmDialog(
      context: context,
      title: 'SAVE AS DRAFT',
      subtitle: _isEdit && widget.existing?.status == 'published'
          ? 'Your changes will be saved as a draft. The published version will remain live.'
          : 'Are you sure you want to save this post as a draft?',
      confirmLabel: 'Save Draft',
      backLabel: 'Cancel',
      onConfirm: () => _doSave(status: 'draft'),
    );
  }

  // ── Discard ────────────────────────────────────────────────────────────────
  void _discard() {
    if (_isEditingDraft && _isEdit) {
      showPublishConfirmDialog(
        context: context,
        title: 'DISCARD DRAFT',
        subtitle: 'Are you sure you want to discard this draft? The published version will remain unchanged.',
        confirmLabel: 'Discard',
        backLabel: 'Cancel',
        onConfirm: () async {
          final cubit = context.read<BlogCubit>();
          await cubit.discardDraft(widget.existing!.id);
          await cubit.load();
          if (mounted) {
            // Navigate to ServicesMainPageMaster after discarding draft as well
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const ServicesMainPageMaster(),
                ),
                    (route) => false,
              );
            });
          }
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ── Preview ────────────────────────────────────────────────────────────────
  void _preview() {
    setState(() => _submitted = true);
    if (_questionEnCtrl.text.trim().isEmpty || _questionArCtrl.text.trim().isEmpty) {
      showSuccessDialog(
        context: context,
        title: 'Required Fields Missing',
        subtitle: 'Please fill in the question fields before previewing.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: BlogPreviewPage(
            draft:       _buildModel(status: 'draft'),
            imageBytes:  _imageBytes,
            isPickedSvg: _isPickedSvg,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: SizedBox(
            width: 1000.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAdminNavbar(
                  activeLabel:     'Web Page',
                  homePage:       CareersMainPageDashboard(),
                  webPage:        HomeMainPage(),
                  jobListingPage: JobListingMainPage(),
                ),
                AdminSubNavBar(activeIndex: 2),
                SizedBox(height: 15.h),

                // ── Title row with draft badge ─────────────────────────
                Row(
                  children: [
                    Text(
                      _isEdit ? 'Edit Important Reads' : 'Create New Important Reads',
                      style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary, fontWeight: FontWeight.w700),
                    ),
                    if (_isEditingDraft) ...[
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _C.draftBadge.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('EDITING DRAFT',
                            style: StyleText.fontSize12Weight600
                                .copyWith(color: _C.draftBadge)),
                      ),
                    ],
                  ],
                ),
                if (_isEditingDraft)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'You are editing a saved draft. The published version is still live.',
                      style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
                    ),
                  ),
                SizedBox(height: 24.h),

                _accordion(key: 'postInfo',    title: 'Post Information',
                    children: [SizedBox(height: 16.h), _postInfoContent()]),
                SizedBox(height: 16.h),
                _accordion(key: 'button',      title: 'Button',
                    children: [SizedBox(height: 16.h), _buttonContent()]),
                SizedBox(height: 16.h),
                _accordion(key: 'description', title: 'Description',
                    children: [SizedBox(height: 16.h), _descriptionContent()]),
                SizedBox(height: 20.h),

                _actionButtons(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION CONTENT BUILDERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _postInfoContent() {
    final bool imageError = _submitted && _imageBytes == null && _existingImageUrl.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SVG image picker ───────────────────────────────────────────────
        Stack(
          alignment: AlignmentGeometry.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 60.w, height: 60.w,
                decoration: BoxDecoration(
                  color:  AppColors.card,
                  shape:  BoxShape.circle,
                  border: imageError
                      ? Border.all(color: _C.error, width: 1.5)
                      : null,
                ),
                child: _imageBytes != null
                    ? ClipOval(
                  child: SizedBox(
                    width: 60.w, height: 60.w,
                    child: Center(
                      child: SvgPicture.memory(
                        _imageBytes!,
                        width: 30.w, height: 30.w,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                )
                    : _existingImageUrl.isNotEmpty
                    ? ClipOval(
                  child: SizedBox(
                    width: 60.w, height: 60.w,
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
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 25.w, height: 25.h,
                  decoration: BoxDecoration(
                    color:  _C.primary,
                    shape:  BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: CustomSvg(
                      assetPath: "assets/control/camera.svg",
                      width: 10.w, height: 10.h,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ── Question ───────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Question', style: _labelStyle()),
          Text('سؤال',    style: _labelStyle()),
        ]),
        SizedBox(height: 6.h),
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              controller:    _questionEnCtrl,
              hint:          'Text Here',
              isRequired:    true,
              submitted:     _submitted,
              fillColor:     Colors.white,
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
              fillColor:     Colors.white,
              isRequired:    true,
              primaryColor:  _C.primary,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              height:        40,
            ),
          ),
        ]),

        // ── Short description ──────────────────────────────────────────────
        Text('Short Description', style: _labelStyle()),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          controller:    _shortDescEnCtrl,
          hint:          'Text Here',
          fillColor:     Colors.white,
          submitted:     _submitted,
          maxLength: 150,
          showCharCount: true,
          isRequired:    true,
          primaryColor:  _C.primary,
          textDirection: TextDirection.ltr,
          maxLines:      4,
          height:        100,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text('وصف مختصر', style: _labelStyle()),
        ),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          controller:    _shortDescArCtrl,
          hint:          'أكتب هنا',
          fillColor:     Colors.white,
          isRequired:    true,
          submitted:     _submitted,
          maxLength: 150,
          showCharCount: true,
          primaryColor:  _C.primary,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          maxLines:      4,
          height:        100,
        ),
      ],
    );
  }

  Widget _buttonContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Label',    style: _labelStyle()),
        Text('تسمية', style: _labelStyle()),
      ]),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            controller:    _btnLabelEnCtrl,
            hint:          'Text Here',
            fillColor:     Colors.white,
            submitted:     _submitted,
            isRequired:    true,
            primaryColor:  _C.primary,
            textDirection: TextDirection.ltr,
            height:        40,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            controller:    _btnLabelArCtrl,
            fillColor:     Colors.white,
            hint:          'أكتب هنا',
            submitted:     _submitted,
            primaryColor:  _C.primary,
            isRequired:    true,
            textDirection: TextDirection.rtl,
            textAlign:     TextAlign.right,
            height:        40,
          ),
        ),
      ]),
    ]);
  }

  Widget _descriptionContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Title',    style: _labelStyle()),
        Text('العنوان', style: _labelStyle()),
      ]),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            controller:    _descTitleEnCtrl,
            hint:          'Text Here',
            isRequired:    true,
            submitted:     _submitted,
            primaryColor:  _C.primary,
            fillColor:     Colors.white,
            textDirection: TextDirection.ltr,
            height:        40,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            controller:    _descTitleArCtrl,
            hint:          'أكتب هنا',
            submitted:     _submitted,
            fillColor:     Colors.white,
            isRequired:    true,
            primaryColor:  _C.primary,
            textDirection: TextDirection.rtl,
            textAlign:     TextAlign.right,
            height:        40,
          ),
        ),
      ]),

      ..._blocks.asMap().entries.map((e) => _blockWidget(idx: e.key, blk: e.value)),

      Wrap(spacing: 10.w, runSpacing: 8.h, children: [
        _addChip('+ Bullet Point', () => _addBlock(BlogBlockType.bulletPoint)),
        _addChip('+ Paragraph',    () => _addBlock(BlogBlockType.paragraph)),
        _addChip('+ Numbering',    () => _addBlock(BlogBlockType.numbering)),
      ]),
    ]);
  }

  Widget _blockWidget({required int idx, required Map<String, dynamic> blk}) {
    final type   = blk['type'] as BlogBlockType;
    final enCtrl = blk['enCtrl'] as TextEditingController;
    final arCtrl = blk['arCtrl'] as TextEditingController;
    final int enMaxLines  = type == BlogBlockType.paragraph ? 20 : 6;
    final double enHeight = type == BlogBlockType.paragraph ? 180 : 90;
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (prefix.isNotEmpty)
            Text('$prefix  ',
                style: StyleText.fontSize13Weight500
                    .copyWith(color: _C.labelText, fontWeight: FontWeight.w600)),
          Text('$typeLabel *',
              style: StyleText.fontSize12Weight500.copyWith(color: Colors.black)),
          const Spacer(),
          GestureDetector(
            onTap: () => _removeBlock(idx),
            child: Icon(Icons.close, size: 18.sp, color: _C.error),
          ),
        ]),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          controller:    enCtrl,
          fillColor:     Colors.white,
          hint:          'Text Here',
          submitted:     _submitted,
          isRequired:    true,
          maxLength: 10000,
          primaryColor:  _C.primary,
          textDirection: TextDirection.ltr,
          maxLines:      enMaxLines,
          height:        enHeight,
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text('بالعربية *', style: _labelStyle()),
        ),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          controller:    arCtrl,
          fillColor:     Colors.white,
          hint:          'أكتب هنا',
          isRequired:    true,
          submitted:     _submitted,
          primaryColor:  _C.primary,
          maxLength: 10000,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          maxLines:      enMaxLines,
          height:        enHeight,
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _actionButtons() {
    return Column(children: [
      Row(children: [
        // Preview
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _preview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF608570),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 300.w),

        // ── Publish — disabled until _isPublishEnabled ─────────────────────
        Expanded(
          child: Tooltip(
            message: _isPublishEnabled
                ? ''
                : 'Fill in all required fields and add an SVG image to publish',
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                // null onPressed = visually + functionally disabled
                onPressed: _isPublishEnabled ? _publish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:         _C.primary,
                  disabledBackgroundColor: _C.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Publish',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
      SizedBox(height: 10.h),
      Row(children: [
        // Discard
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _discard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF797979),
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

        // Save For Later
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _saveForLater,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF525252),
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
    ]);
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(6.r),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ]),
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
          style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
    ),
  );

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: _C.labelText);
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR circle SVG image loader
// ══════════════════════════════════════════════════════════════════════════════
class _XhrCircleImage extends StatefulWidget {
  final String url;
  final double size;
  const _XhrCircleImage({required this.url, required this.size});

  @override
  State<_XhrCircleImage> createState() => _XhrCircleImageState();
}

class _XhrCircleImageState extends State<_XhrCircleImage> {
  String? _svgString;
  bool    _failed = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void didUpdateWidget(covariant _XhrCircleImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      setState(() { _svgString = null; _failed = false; });
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
          completer.complete((xhr.response as ByteBuffer).asUint8List());
        } else {
          completer.completeError('HTTP ${xhr.status}');
        }
      });
      xhr.onError.listen((_) => completer.completeError('XHR error'));
      xhr.send();
      final bytes = await completer.future;
      if (mounted) setState(() => _svgString = String.fromCharCodes(bytes));
    } catch (e) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return SizedBox(
        width: widget.size, height: widget.size,
        child: Icon(Icons.broken_image_outlined,
            size: 24.sp, color: _C.hintText),
      );
    }
    if (_svgString == null) {
      return SizedBox(
        width: widget.size, height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _C.primary),
        ),
      );
    }
    return SizedBox(
      width: widget.size, height: widget.size,
      child: SvgPicture.string(
        _svgString!,
        width: widget.size, height: widget.size,
        fit: BoxFit.cover,
      ),
    );
  }
}