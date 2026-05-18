// ******************* FILE INFO *******************
// File Name: terms_edit_page.dart
// Screen 2 of 3 — Terms of Service CMS: Edit page
// UPDATED: Fixed save/publish functionality
// UPDATED: Proper async/await handling with cubit
// UPDATED: Removed all field validation
// UPDATED: Removed success dialog — navigates back immediately on save

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../../core/custom_dialog.dart';
import '../../../../theme/appcolors.dart';
import 'terms_preview_page.dart';

const Color _kGreen = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed = Color(0xFFD32F2F);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBg = Color(0xFFF1F2ED);

// ── Picked Image holder (SVG only) ─────────────────────────────────────────
class _PickedImage {
  Uint8List? bytes;
  String? url;
  String fileName;

  _PickedImage({this.bytes, this.url, this.fileName = ''});

  bool get hasImage => bytes != null || (url != null && url!.isNotEmpty);
  void clear() {
    bytes = null;
    url = null;
    fileName = '';
  }
}

// ── Local UI-only holder for documents ─────────────────────────────────────
class _DocItem {
  Uint8List? bytes;
  String fileName;
  String existingUrl;

  _DocItem({this.bytes, this.fileName = '', this.existingUrl = ''});

  bool get hasFile => bytes != null || existingUrl.isNotEmpty;
  String get displayName =>
      bytes != null ? fileName : existingUrl.split('/').last.split('?').first;
}

// ═══════════════════════════════════════════════════════════════════════════════

class TermsEditPage extends StatefulWidget {
  const TermsEditPage({super.key});

  @override
  State<TermsEditPage> createState() => _TermsEditPageState();
}

class _TermsEditPageState extends State<TermsEditPage> {
  // Navigation Label
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  final _navIcon = _PickedImage();

  // Terms and Conditions
  final _termsDescEnCtrl = TextEditingController();
  final _termsDescArCtrl = TextEditingController();
  final _termsSvg = _PickedImage();
  final _termsDocEn = _DocItem();
  final _termsDocAr = _DocItem();

  // Privacy Policy
  final _privacyDescEnCtrl = TextEditingController();
  final _privacyDescArCtrl = TextEditingController();
  final _privacySvg = _PickedImage();
  final _privacyDocEn = _DocItem();
  final _privacyDocAr = _DocItem();

  bool _navLabelOpen = true;
  bool _termsOpen = true;
  bool _privacyOpen = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _seeded = false;

  // Store original values to track changes
  String _originalNavTitleEn = '';
  String _originalNavTitleAr = '';
  String _originalNavIconUrl = '';
  String _originalTermsSvgUrl = '';
  String _originalTermsDescEn = '';
  String _originalTermsDescAr = '';
  String _originalTermsDocEnUrl = '';
  String _originalTermsDocArUrl = '';
  String _originalPrivacySvgUrl = '';
  String _originalPrivacyDescEn = '';
  String _originalPrivacyDescAr = '';
  String _originalPrivacyDocEnUrl = '';
  String _originalPrivacyDocArUrl = '';

  @override
  void initState() {
    super.initState();
    context.read<TermsCubit>().load();

    _navTitleEnCtrl.addListener(_checkForChanges);
    _navTitleArCtrl.addListener(_checkForChanges);
    _termsDescEnCtrl.addListener(_checkForChanges);
    _termsDescArCtrl.addListener(_checkForChanges);
    _privacyDescEnCtrl.addListener(_checkForChanges);
    _privacyDescArCtrl.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
    _termsDescEnCtrl.dispose();
    _termsDescArCtrl.dispose();
    _privacyDescEnCtrl.dispose();
    _privacyDescArCtrl.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    if (!_seeded) return;

    final bool hasTextChanges =
        _navTitleEnCtrl.text != _originalNavTitleEn ||
            _navTitleArCtrl.text != _originalNavTitleAr ||
            _termsDescEnCtrl.text != _originalTermsDescEn ||
            _termsDescArCtrl.text != _originalTermsDescAr ||
            _privacyDescEnCtrl.text != _originalPrivacyDescEn ||
            _privacyDescArCtrl.text != _originalPrivacyDescAr;

    final bool hasImageChanges =
        (_navIcon.url ?? '') != _originalNavIconUrl ||
            (_termsSvg.url ?? '') != _originalTermsSvgUrl ||
            (_privacySvg.url ?? '') != _originalPrivacySvgUrl ||
            _navIcon.bytes != null ||
            _termsSvg.bytes != null ||
            _privacySvg.bytes != null;

    final bool hasDocChanges =
        _termsDocEn.bytes != null ||
            _termsDocAr.bytes != null ||
            _privacyDocEn.bytes != null ||
            _privacyDocAr.bytes != null ||
            (_termsDocEn.existingUrl != _originalTermsDocEnUrl &&
                _termsDocEn.bytes == null) ||
            (_termsDocAr.existingUrl != _originalTermsDocArUrl &&
                _termsDocAr.bytes == null) ||
            (_privacyDocEn.existingUrl != _originalPrivacyDocEnUrl &&
                _privacyDocEn.bytes == null) ||
            (_privacyDocAr.existingUrl != _originalPrivacyDocArUrl &&
                _privacyDocAr.bytes == null);

    final bool hasChanges = hasTextChanges || hasImageChanges || hasDocChanges;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _resetChangesTracking() {
    _originalNavTitleEn = _navTitleEnCtrl.text;
    _originalNavTitleAr = _navTitleArCtrl.text;
    _originalNavIconUrl = _navIcon.url ?? '';
    _originalTermsSvgUrl = _termsSvg.url ?? '';
    _originalTermsDescEn = _termsDescEnCtrl.text;
    _originalTermsDescAr = _termsDescArCtrl.text;
    _originalTermsDocEnUrl = _termsDocEn.existingUrl;
    _originalTermsDocArUrl = _termsDocAr.existingUrl;
    _originalPrivacySvgUrl = _privacySvg.url ?? '';
    _originalPrivacyDescEn = _privacyDescEnCtrl.text;
    _originalPrivacyDescAr = _privacyDescArCtrl.text;
    _originalPrivacyDocEnUrl = _privacyDocEn.existingUrl;
    _originalPrivacyDocArUrl = _privacyDocAr.existingUrl;

    _navIcon.bytes = null;
    _termsSvg.bytes = null;
    _privacySvg.bytes = null;
    _termsDocEn.bytes = null;
    _termsDocAr.bytes = null;
    _privacyDocEn.bytes = null;
    _privacyDocAr.bytes = null;

    _hasChanges = false;
  }

  // ── File pickers ──────────────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgOnly() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = 'image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(null); return; }

      final file = files.first;

      if (!file.name.toLowerCase().endsWith('.svg')) {
        _showErrorDialog('Invalid File Type',
            'Please select an SVG file only. Selected: ${file.name}');
        c.complete(null);
        return;
      }
      if (file.type != 'image/svg+xml') {
        _showErrorDialog('Invalid File Type',
            'Please select a valid SVG file. Selected: ${file.name}');
        c.complete(null);
        return;
      }

      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) bytes = r.asUint8List();
        else if (r is Uint8List) bytes = r;

        if (bytes != null) {
          final headerStr = String.fromCharCodes(
            bytes.sublist(0, bytes.length > 100 ? 100 : bytes.length),
          );
          if (!headerStr.contains('<svg') && !headerStr.contains('<?xml')) {
            _showErrorDialog('Invalid SVG',
                'The selected file does not appear to be a valid SVG image.');
            c.complete(null);
            return;
          }
          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  Future<void> _pickDoc(_DocItem docItem) async {
    final c = Completer<void>();
    final input = html.FileUploadInputElement()..accept = '.pdf,.doc,.docx';
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(); return; }
      final file = files.first;
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) bytes = r.asUint8List();
        else if (r is Uint8List) bytes = r;
        if (bytes != null) {
          setState(() {
            docItem.bytes = bytes;
            docItem.fileName = file.name;
            _checkForChanges();
          });
        }
        c.complete();
      });
      reader.onError.listen((_) => c.complete());
    });
    input.click();
    return c.future;
  }

  // ── Seed ──────────────────────────────────────────────────────────────────
  void _seed(TermsOfServiceModel m) {
    if (_seeded) return;
    _seeded = true;

    setState(() {
      _originalNavTitleEn = m.navigationLabel.title.en;
      _originalNavTitleAr = m.navigationLabel.title.ar;
      _originalNavIconUrl = m.navigationLabel.iconUrl;

      _navTitleEnCtrl.text = _originalNavTitleEn;
      _navTitleArCtrl.text = _originalNavTitleAr;
      _navIcon.url = _originalNavIconUrl.isNotEmpty ? _originalNavIconUrl : null;
      _navIcon.bytes = null;
      _navIcon.fileName = '';

      _originalTermsSvgUrl = m.termsAndConditions.svgUrl;
      _originalTermsDescEn = m.termsAndConditions.description.en;
      _originalTermsDescAr = m.termsAndConditions.description.ar;
      _originalTermsDocEnUrl = m.termsAndConditions.attachEnUrl;
      _originalTermsDocArUrl = m.termsAndConditions.attachArUrl;

      _termsSvg.url = _originalTermsSvgUrl.isNotEmpty ? _originalTermsSvgUrl : null;
      _termsSvg.bytes = null;
      _termsDescEnCtrl.text = _originalTermsDescEn;
      _termsDescArCtrl.text = _originalTermsDescAr;
      _termsDocEn.bytes = null;
      _termsDocEn.fileName = '';
      _termsDocEn.existingUrl = _originalTermsDocEnUrl;
      _termsDocAr.bytes = null;
      _termsDocAr.fileName = '';
      _termsDocAr.existingUrl = _originalTermsDocArUrl;

      _originalPrivacySvgUrl = m.privacyPolicy.svgUrl;
      _originalPrivacyDescEn = m.privacyPolicy.description.en;
      _originalPrivacyDescAr = m.privacyPolicy.description.ar;
      _originalPrivacyDocEnUrl = m.privacyPolicy.attachEnUrl;
      _originalPrivacyDocArUrl = m.privacyPolicy.attachArUrl;

      _privacySvg.url = _originalPrivacySvgUrl.isNotEmpty ? _originalPrivacySvgUrl : null;
      _privacySvg.bytes = null;
      _privacyDescEnCtrl.text = _originalPrivacyDescEn;
      _privacyDescArCtrl.text = _originalPrivacyDescAr;
      _privacyDocEn.bytes = null;
      _privacyDocEn.fileName = '';
      _privacyDocEn.existingUrl = _originalPrivacyDocEnUrl;
      _privacyDocAr.bytes = null;
      _privacyDocAr.fileName = '';
      _privacyDocAr.existingUrl = _originalPrivacyDocArUrl;

      _hasChanges = false;
    });
  }

  // ── Build model ───────────────────────────────────────────────────────────
  TermsOfServiceModel _buildModel(String status) => TermsOfServiceModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIcon.url ?? '',
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    termsAndConditions: TermsSection(
      svgUrl: _termsSvg.url ?? '',
      description: AboutBilingualText(
        en: _termsDescEnCtrl.text.trim(),
        ar: _termsDescArCtrl.text.trim(),
      ),
      attachEnUrl: _termsDocEn.existingUrl,
      attachArUrl: _termsDocAr.existingUrl,
    ),
    privacyPolicy: TermsSection(
      svgUrl: _privacySvg.url ?? '',
      description: AboutBilingualText(
        en: _privacyDescEnCtrl.text.trim(),
        ar: _privacyDescArCtrl.text.trim(),
      ),
      attachEnUrl: _privacyDocEn.existingUrl,
      attachArUrl: _privacyDocAr.existingUrl,
    ),
  );

  // ── Collect uploads ───────────────────────────────────────────────────────
  Map<String, Uint8List> _collectImageUploads() {
    final u = <String, Uint8List>{};
    if (_navIcon.bytes != null)   u['terms_cms/navLabel/icon'] = _navIcon.bytes!;
    if (_termsSvg.bytes != null)  u['terms_cms/terms/svg']     = _termsSvg.bytes!;
    if (_privacySvg.bytes != null) u['terms_cms/privacy/svg']  = _privacySvg.bytes!;
    return u;
  }

  Map<String, DocUpload> _collectDocUploads() {
    final u = <String, DocUpload>{};
    if (_termsDocEn.bytes != null)
      u['terms_cms/terms/en'] = DocUpload(bytes: _termsDocEn.bytes!, fileName: _termsDocEn.fileName);
    if (_termsDocAr.bytes != null)
      u['terms_cms/terms/ar'] = DocUpload(bytes: _termsDocAr.bytes!, fileName: _termsDocAr.fileName);
    if (_privacyDocEn.bytes != null)
      u['terms_cms/privacy/en'] = DocUpload(bytes: _privacyDocEn.bytes!, fileName: _privacyDocEn.fileName);
    if (_privacyDocAr.bytes != null)
      u['terms_cms/privacy/ar'] = DocUpload(bytes: _privacyDocAr.bytes!, fileName: _privacyDocAr.fileName);
    return u;
  }

  void _showErrorDialog(String title, String message) {
    showConfirmDialog(
      context: context,
      title: title,
      subtitle: message,
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

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    final cubit = context.read<TermsCubit>();
    final model = _buildModel('draft');
    final imgUploads = _collectImageUploads();
    final docUps = _collectDocUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TermsPreviewPage(
            model: model,
            imageUploads: imgUploads,
            docUploads: docUps,
          ),
        ),
      ),
    );
  }

  // ── Save / Publish ─────────────────────────────────────────────────────────
  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final imgs  = _collectImageUploads();
    final docs  = _collectDocUploads();
    final model = _buildModel('published');

    try {
      await context.read<TermsCubit>().save(
        model:        model,
        imageUploads: imgs.isEmpty ? null : imgs,
        docUploads:   docs.isEmpty ? null : docs,
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        showConfirmDialog(
          context: context,
          title: 'Error',
          subtitle: 'Failed to save: ${e.toString()}',
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
    }
  }

  void _showPublishConfirmDialog() {
    showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH TERMS OF SERVICE',
      subtitle: 'Do you want to publish the Terms of Service page now?',
      confirmLabel: 'Publish',
      onConfirm: _onSave,
    );
  }

  void _onDiscard() {
    if (_hasChanges) {
      showConfirmDialog(
        context: context,
        title: 'Discard Changes',
        subtitle: 'Are you sure you want to discard all changes?',
        confirmLabel: 'Discard',
        cancelLabel: 'Cancel',
        onConfirm: () => Navigator.pop(context),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ── Standardized Image Widget ─────────────────────────────────────────────
  Widget _imgBox({
    required _PickedImage picked,
    bool isAdd = false,
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(picked.bytes!,
                width: 30.w, height: 30.h, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(picked.url!,
                width: 30.w, height: 30.h, fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(
          child: Icon(isAdd ? Icons.add : Icons.image_outlined,
              color: Colors.grey, size: 22.sp),
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 25.w, height: 25.h,
              decoration: BoxDecoration(
                color: _kGreenSolid,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: "assets/control/camera.svg",
                  width: 10.w, height: 10.h, fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TermsCubit, TermsState>(
      listener: (context, state) {
        if (state is TermsLoaded) {
          _seed(state.data);
        }

        if (state is TermsSaved) {
          setState(() => _isSaving = false);
          _resetChangesTracking();
          // Navigate back immediately — no success dialog
          if (mounted) Navigator.pop(context);
        }

        if (state is TermsError) {
          setState(() => _isSaving = false);
          if (mounted) {
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
                child: Icon(Icons.error_outline,
                    color: Colors.white, size: 36.r),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final loading = state is TermsLoading || state is TermsInitial;
        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Container(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 25.h),
                        AdminSubNavBar(activeIndex: 3),
                        SizedBox(height: 25.h),
                        SizedBox(
                          width: 1000.w,
                          child: loading
                              ? const Center(child: CircularProgressIndicator(
                              color: _kGreenSolid))
                              : _buildForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isSaving) _savingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    final bool canPublish = _hasChanges && !_isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Terms of Service Details',
          style: StyleText.fontSize45Weight600.copyWith(
              color: _kGreen, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () => setState(() => _navLabelOpen = !_navLabelOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _fieldLabel('Icon'),
              SizedBox(height: 8.h),
              _imgBox(
                picked: _navIcon,
                onPick: () async {
                  final b = await _pickSvgOnly();
                  if (b != null) setState(() {
                    _navIcon.bytes = b;
                    _navIcon.url = null;
                    _checkForChanges();
                  });
                },
              ),
              SizedBox(height: 16.h),
              _fieldLabel('Title'),
              SizedBox(height: 8.h),
              _bilingualRow(
                enCtrl: _navTitleEnCtrl,
                arCtrl: _navTitleArCtrl,
                enHint: 'Text Here',
                arHint: 'أدخل النص هنا',
              ),
            ],
          ),
        ),

        _accordion(
          title: 'Terms and Conditions',
          isOpen: _termsOpen,
          onToggle: () => setState(() => _termsOpen = !_termsOpen),
          child: _sectionEditor(
            svgPicked: _termsSvg,
            descEnCtrl: _termsDescEnCtrl,
            descArCtrl: _termsDescArCtrl,
            docEn: _termsDocEn,
            docAr: _termsDocAr,
            onPickSvg: () async {
              final b = await _pickSvgOnly();
              if (b != null) setState(() {
                _termsSvg.bytes = b;
                _termsSvg.url = null;
                _checkForChanges();
              });
            },
            onPickDocEn: () => _pickDoc(_termsDocEn),
            onPickDocAr: () => _pickDoc(_termsDocAr),
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Privacy Policy',
          isOpen: _privacyOpen,
          onToggle: () => setState(() => _privacyOpen = !_privacyOpen),
          child: _sectionEditor(
            svgPicked: _privacySvg,
            descEnCtrl: _privacyDescEnCtrl,
            descArCtrl: _privacyDescArCtrl,
            docEn: _privacyDocEn,
            docAr: _privacyDocAr,
            onPickSvg: () async {
              final b = await _pickSvgOnly();
              if (b != null) setState(() {
                _privacySvg.bytes = b;
                _privacySvg.url = null;
                _checkForChanges();
              });
            },
            onPickDocEn: () => _pickDoc(_privacyDocEn),
            onPickDocAr: () => _pickDoc(_privacyDocAr),
          ),
        ),
        SizedBox(height: 32.h),

        Row(
          children: [
            Expanded(child: _btn(
              label: 'Preview',
              color: const Color(0xFF608570),
              onTap: _onPreview,
            )),
            SizedBox(width: 300.w),
            Expanded(child: _btn(
              label: 'Publish',
              color: canPublish ? _kGreenSolid : _kGreenSolid.withOpacity(0.4),
              onTap: canPublish ? _showPublishConfirmDialog : null,
            )),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _btn(
              label: 'Discard',
              color: const Color(0xFF9E9E9E),
              onTap: _onDiscard,
            )),
            SizedBox(width: 300.w),
            Expanded(child: Column()),
          ],
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  Widget _sectionEditor({
    required _PickedImage svgPicked,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required _DocItem docEn,
    required _DocItem docAr,
    required VoidCallback onPickSvg,
    required VoidCallback onPickDocEn,
    required VoidCallback onPickDocAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        _fieldLabel('Icon'),
        SizedBox(height: 8.h),
        _imgBox(picked: svgPicked, onPick: onPickSvg),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'Text Here',
          controller: descEnCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: false,
          isRequired: false,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: _kGreenSolid,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('Description'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: false,
          isRequired: false,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: _kGreenSolid,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _docUploadField(
              label: 'Attach English Document',
              docItem: docEn,
              onPick: onPickDocEn,
              onRemove: () => setState(() {
                docEn.bytes = null;
                docEn.fileName = '';
                docEn.existingUrl = '';
                _checkForChanges();
              }),
            )),
            SizedBox(width: 16.w),
            Expanded(child: _docUploadField(
              label: 'Attach Arabic Document',
              docItem: docAr,
              onPick: onPickDocAr,
              onRemove: () => setState(() {
                docAr.bytes = null;
                docAr.fileName = '';
                docAr.existingUrl = '';
                _checkForChanges();
              }),
            )),
          ],
        ),
      ],
    );
  }

  Widget _docUploadField({
    required String label,
    required _DocItem docItem,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: 8.h),
        docItem.hasFile
            ? Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r)),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 18.sp, color: _kRed),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(docItem.displayName,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.text),
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22.w, height: 22.h,
                  decoration: BoxDecoration(
                      color: _kRed, shape: BoxShape.circle),
                  child: Icon(Icons.remove,
                      color: Colors.white, size: 14.sp),
                ),
              ),
            ],
          ),
        )
            : GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text('Attach Document',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
            decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.white)),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.r))),
            child: child,
          ),
      ],
    );
  }

  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            fillColor: Colors.white,
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: false,
            isRequired: false,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: _kGreenSolid,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            fillColor: Colors.white,
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: false,
            isRequired: false,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _kGreenSolid,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text));

  Widget _fieldLabelAr(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(t,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        )),
  );

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8.r)),
          child: Center(
            child: Text(label,
                style: StyleText.fontSize16Weight400
                    .copyWith(color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w, height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _kGreenSolid),
            SizedBox(height: 12.h),
            Text('Saving...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}