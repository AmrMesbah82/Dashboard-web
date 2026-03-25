// ******************* FILE INFO *******************
// File Name: terms_edit_page.dart
// Screen 2 of 3 — Terms of Service CMS: Edit page

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:web_app_admin/model/about_us.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import 'terms_preview_page.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ── Local UI-only holder (never leaves this file) ─────────────────────────────
class _DocItem {
  Uint8List? bytes;
  String fileName;
  String existingUrl;

  _DocItem({this.bytes, this.fileName = '', this.existingUrl = ''});

  bool get hasFile => bytes != null || existingUrl.isNotEmpty;
  String get displayName => bytes != null
      ? fileName
      : existingUrl.split('/').last.split('?').first;
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
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // Terms and Conditions
  final _termsDescEnCtrl = TextEditingController();
  final _termsDescArCtrl = TextEditingController();
  Uint8List? _termsSvgBytes;
  String _termsSvgUrl = '';
  final _termsDocEn = _DocItem();
  final _termsDocAr = _DocItem();

  // Privacy Policy
  final _privacyDescEnCtrl = TextEditingController();
  final _privacyDescArCtrl = TextEditingController();
  Uint8List? _privacySvgBytes;
  String _privacySvgUrl = '';
  final _privacyDocEn = _DocItem();
  final _privacyDocAr = _DocItem();

  bool _navLabelOpen = true;
  bool _termsOpen    = true;
  bool _privacyOpen  = true;
  bool _submitted    = false;
  bool _isSaving     = false;

  // ── NO _seeded flag — every TermsLoaded overwrites local state ─────────────
  // Previously _seeded=true blocked re-seeding on re-entry, leaving fields blank.

  @override
  void initState() {
    super.initState();
    // Always fetch fresh from Firestore on every page entry
    context.read<TermsCubit>().load();
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

  // ── File pickers ──────────────────────────────────────────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(null); return; }
      final reader = html.FileReader()..readAsArrayBuffer(files.first);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer) c.complete(r.asUint8List());
        else if (r is Uint8List) c.complete(r);
        else c.complete(null);
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  Future<Uint8List?> _pickSvg() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(null); return; }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ SVG files only! Selected: ${file.name}'),
          backgroundColor: _kRed,
        ));
        c.complete(null);
        return;
      }
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer) c.complete(r.asUint8List());
        else if (r is Uint8List) c.complete(r);
        else c.complete(null);
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
      final file   = files.first;
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) bytes = r.asUint8List();
        else if (r is Uint8List) bytes = r;
        if (bytes != null) {
          setState(() {
            docItem.bytes    = bytes;
            docItem.fileName = file.name;
          });
        }
        c.complete();
      });
      reader.onError.listen((_) => c.complete());
    });
    input.click();
    return c.future;
  }

  // ── Seed — called on every TermsLoaded (no guard) ─────────────────────────
  void _seed(TermsOfServiceModel m) {
    setState(() {
      _navTitleEnCtrl.text      = m.navigationLabel.title.en;
      _navTitleArCtrl.text      = m.navigationLabel.title.ar;
      _navIconUrl               = m.navigationLabel.iconUrl;
      _navIconBytes             = null; // clear stale picked bytes

      _termsSvgUrl              = m.termsAndConditions.svgUrl;
      _termsSvgBytes            = null;
      _termsDescEnCtrl.text     = m.termsAndConditions.description.en;
      _termsDescArCtrl.text     = m.termsAndConditions.description.ar;
      _termsDocEn.bytes         = null;
      _termsDocEn.fileName      = '';
      _termsDocEn.existingUrl   = m.termsAndConditions.attachEnUrl;
      _termsDocAr.bytes         = null;
      _termsDocAr.fileName      = '';
      _termsDocAr.existingUrl   = m.termsAndConditions.attachArUrl;

      _privacySvgUrl            = m.privacyPolicy.svgUrl;
      _privacySvgBytes          = null;
      _privacyDescEnCtrl.text   = m.privacyPolicy.description.en;
      _privacyDescArCtrl.text   = m.privacyPolicy.description.ar;
      _privacyDocEn.bytes       = null;
      _privacyDocEn.fileName    = '';
      _privacyDocEn.existingUrl = m.privacyPolicy.attachEnUrl;
      _privacyDocAr.bytes       = null;
      _privacyDocAr.fileName    = '';
      _privacyDocAr.existingUrl = m.privacyPolicy.attachArUrl;
    });
  }

  // ── Build model ───────────────────────────────────────────────────────────
  TermsOfServiceModel _buildModel(String status) => TermsOfServiceModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    termsAndConditions: TermsSection(
      svgUrl: _termsSvgUrl,
      description: AboutBilingualText(
        en: _termsDescEnCtrl.text.trim(),
        ar: _termsDescArCtrl.text.trim(),
      ),
      attachEnUrl: _termsDocEn.existingUrl,
      attachArUrl: _termsDocAr.existingUrl,
    ),
    privacyPolicy: TermsSection(
      svgUrl: _privacySvgUrl,
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
    if (_navIconBytes    != null) u['terms_cms/navLabel/icon'] = _navIconBytes!;
    if (_termsSvgBytes   != null) u['terms_cms/terms/svg']     = _termsSvgBytes!;
    if (_privacySvgBytes != null) u['terms_cms/privacy/svg']   = _privacySvgBytes!;
    return u;
  }

  Map<String, DocUpload> _collectDocUploads() {
    final u = <String, DocUpload>{};
    if (_termsDocEn.bytes != null)
      u['terms_cms/terms/en'] =
          DocUpload(bytes: _termsDocEn.bytes!, fileName: _termsDocEn.fileName);
    if (_termsDocAr.bytes != null)
      u['terms_cms/terms/ar'] =
          DocUpload(bytes: _termsDocAr.bytes!, fileName: _termsDocAr.fileName);
    if (_privacyDocEn.bytes != null)
      u['terms_cms/privacy/en'] =
          DocUpload(bytes: _privacyDocEn.bytes!, fileName: _privacyDocEn.fileName);
    if (_privacyDocAr.bytes != null)
      u['terms_cms/privacy/ar'] =
          DocUpload(bytes: _privacyDocAr.bytes!, fileName: _privacyDocAr.fileName);
    return u;
  }

  bool _validate() => [
    _navTitleEnCtrl, _navTitleArCtrl,
    _termsDescEnCtrl, _termsDescArCtrl,
    _privacyDescEnCtrl, _privacyDescArCtrl,
  ].every((c) => c.text.trim().isNotEmpty);

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validate()) return;
    final cubit      = context.read<TermsCubit>();
    final model      = _buildModel('draft');
    final imgUploads = _collectImageUploads();
    final docUps     = _collectDocUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TermsPreviewPage(
            model:        model,
            imageUploads: imgUploads,
            docUploads:   docUps,
          ),
        ),
      ),
    );
  }

  // ── Save (direct publish without preview) ────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validate()) return;
    setState(() => _isSaving = true);
    final imgs = _collectImageUploads();
    final docs = _collectDocUploads();
    await context.read<TermsCubit>().save(
      model:        _buildModel(status),
      imageUploads: imgs.isEmpty ? null : imgs,
      docUploads:   docs.isEmpty ? null : docs,
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TermsCubit, TermsState>(
      listener: (context, state) {
        // Seed on every fresh load — this is the fix for blank fields on re-entry
        if (state is TermsLoaded) _seed(state.data);

        if (state is TermsSaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Terms of Service saved!'),
              backgroundColor: _kGreenSolid));
          Navigator.pop(context);
        }
        if (state is TermsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed));
        }
      },
      builder: (context, state) {
        final loading = state is TermsLoading || state is TermsInitial;
        return Scaffold(
          backgroundColor: Color(0xFFF1F2ED),
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
                              ? const Center(
                              child: CircularProgressIndicator(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editing Terms of Service Details',
            style: StyleText.fontSize45Weight600.copyWith(
                color: _kGreen, fontWeight: FontWeight.w700)),
        SizedBox(height: 24.h),

        // _accordion(
        //   title: 'Navigation Label',
        //   isOpen: _navLabelOpen,
        //   onToggle: () => setState(() => _navLabelOpen = !_navLabelOpen),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       _imageUploadCircle(
        //         label: 'Icon', bytes: _navIconBytes, url: _navIconUrl,
        //         onTap: () async {
        //           final b = await _pickImage();
        //           if (b != null) setState(() => _navIconBytes = b);
        //         },
        //       ),
        //       SizedBox(height: 16.h),
        //       _fieldLabel('Title'),
        //       SizedBox(height: 8.h),
        //       _bilingualRow(
        //         enCtrl: _navTitleEnCtrl, arCtrl: _navTitleArCtrl,
        //         enHint: 'Text Here',     arHint: 'أدخل النص هنا',
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 16.h),

        _accordion(
          title: 'Terms and Conditions',
          isOpen: _termsOpen,
          onToggle: () => setState(() => _termsOpen = !_termsOpen),
          child: _sectionEditor(
            svgBytes: _termsSvgBytes, svgUrl: _termsSvgUrl,
            onPickSvg: () async {
              final b = await _pickSvg();
              if (b != null) setState(() => _termsSvgBytes = b);
            },
            descEnCtrl: _termsDescEnCtrl, descArCtrl: _termsDescArCtrl,
            docEn: _termsDocEn, docAr: _termsDocAr,
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
            svgBytes: _privacySvgBytes, svgUrl: _privacySvgUrl,
            onPickSvg: () async {
              final b = await _pickSvg();
              if (b != null) setState(() => _privacySvgBytes = b);
            },
            descEnCtrl: _privacyDescEnCtrl, descArCtrl: _privacyDescArCtrl,
            docEn: _privacyDocEn, docAr: _privacyDocAr,
            onPickDocEn: () => _pickDoc(_privacyDocEn),
            onPickDocAr: () => _pickDoc(_privacyDocAr),
          ),
        ),
        SizedBox(height: 32.h),

        Row(children: [
          Expanded(child: _btn(
              label: 'Preview', color: const Color(0xFF4CAF50),
              onTap: _onPreview)),
          SizedBox(width: 16.w),
          Expanded(child: _btn(
              label: 'Publish', color: _kGreenSolid,
              onTap: () => _save('published'))),
        ]),
        SizedBox(height: 12.h),
        _btn(label: 'Discard', color: const Color(0xFF9E9E9E),
            onTap: () => Navigator.pop(context)),
        SizedBox(height: 48.h),
      ],
    );
  }

  Widget _sectionEditor({
    required Uint8List?            svgBytes,
    required String                svgUrl,
    required VoidCallback          onPickSvg,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required _DocItem              docEn,
    required _DocItem              docAr,
    required VoidCallback          onPickDocEn,
    required VoidCallback          onPickDocAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 16.h),
        _imageUploadCircle(
            label: 'SVG', bytes: svgBytes, url: svgUrl,
            isSvg: true, onTap: onPickSvg),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', controller: descEnCtrl,
          height: 120, maxLines: 5, maxLength: 800,
          showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', controller: descArCtrl,
          height: 120, maxLines: 5, maxLength: 800,
          showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(child: _docUploadField(
            label: 'Attach Eng Document', docItem: docEn,
            onPick: onPickDocEn,
            onRemove: () => setState(() {
              docEn.bytes = null; docEn.fileName = ''; docEn.existingUrl = '';
            }),
          )),
          SizedBox(width: 16.w),
          Expanded(child: _docUploadField(
            label: 'Attach Ar Document', docItem: docAr,
            onPick: onPickDocAr,
            onRemove: () => setState(() {
              docAr.bytes = null; docAr.fileName = ''; docAr.existingUrl = '';
            }),
          )),
        ]),
      ],
    );
  }

  Widget _docUploadField({
    required String       label,
    required _DocItem     docItem,
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
          padding: EdgeInsets.symmetric(
              horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(children: [
            Icon(Icons.picture_as_pdf, size: 18.sp, color: _kRed),
            SizedBox(width: 8.w),
            Expanded(
                child: Text(docItem.displayName,
                    style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 12.sp, color: Colors.black87),
                    overflow: TextOverflow.ellipsis)),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22.w, height: 22.h,
                decoration: BoxDecoration(
                    color: _kRed, shape: BoxShape.circle),
                child: Icon(Icons.close,
                    color: Colors.white, size: 14.sp),
              ),
            ),
          ]),
        )
            : GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity, height: 44.h,
            decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text('Attach Document',
                    style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 13.sp, fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _accordion({
    required String title, required bool isOpen,
    required VoidCallback onToggle, required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _kGreenSolid,
            borderRadius: isOpen
                ? BorderRadius.vertical(top: Radius.circular(12.r))
                : BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp,
                      fontWeight: FontWeight.w700, color: Colors.white)),
              Icon(isOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 22.sp),
            ],
          ),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(

            borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),

          child: child,
        ),
    ]);
  }

  Widget _imageUploadCircle({
    required String label, required Uint8List? bytes,
    required String url,   required VoidCallback onTap, bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Text(label,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
              fontWeight: FontWeight.w600, color: Colors.black87)),
      SizedBox(height: 8.h),
      GestureDetector(
        onTap: onTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 64.w, height: 64.h,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFEEEEEE)),
            child: hasImage
                ? ClipOval(child: _buildImgWidget(bytes, url, isSvg))
                : Icon(isSvg ? Icons.description_outlined : Icons.add,
                color: Colors.grey[600], size: 28.sp),
          ),
          Positioned(
            bottom: -2, right: -2,
            child: Container(
              width: 24.w, height: 24.h,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: _kGreenSolid),
              child: Icon(Icons.edit, color: Colors.white, size: 13.sp),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildImgWidget(Uint8List? bytes, String url, bool isSvg) {
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final h = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = h.startsWith('<svg') || h.startsWith('<?xml');
    }
    if (isSvg || isSvgData) {
      if (bytes != null) return SvgPicture.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty)
        return FutureBuilder(
          future: _loadSvgBytes(url),
          builder: (_, snap) => snap.hasData
              ? SvgPicture.memory(snap.data!, fit: BoxFit.cover)
              : Icon(Icons.description, color: Colors.grey[400], size: 28.sp),
        );
    } else {
      if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty)
        return Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp));
    }
    return Icon(isSvg ? Icons.description : Icons.image,
        color: Colors.grey, size: 28.sp);
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    final res = await html.HttpRequest.request(url,
        method: 'GET', responseType: 'arraybuffer');
    if (res.status != 200)
      throw Exception('Failed to load SVG: ${res.status}');
    return (res.response as ByteBuffer).asUint8List();
  }

  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: CustomValidatedTextFieldMaster(
        hint: enHint, controller: enCtrl, height: 42, maxLines: 1,
        maxLength: 200, submitted: _submitted,
        textDirection: TextDirection.ltr, textAlign: TextAlign.start,
        onChanged: (_) => setState(() {}),
      )),
      SizedBox(width: 12.w),
      Expanded(child: CustomValidatedTextFieldMaster(
        hint: arHint, controller: arCtrl, height: 42, maxLines: 1,
        maxLength: 200, submitted: _submitted,
        textDirection: TextDirection.rtl, textAlign: TextAlign.right,
        onChanged: (_) => setState(() {}),
      )),
    ]);
  }

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
          fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _fieldLabelAr(String t) => Align(
      alignment: Alignment.centerRight,
      child: Text(t, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
          fontWeight: FontWeight.w600, color: Colors.black87)));

  Widget _btn({required String label, required Color color,
    required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 48.h,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10.r)),
          child: Center(child: Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp,
                  fontWeight: FontWeight.w700, color: Colors.white))),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(child: Container(
      width: 180.w, height: 100.h,
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: _kGreenSolid),
        SizedBox(height: 12.h),
        Text('Saving...', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 14.sp, color: Colors.black87)),
      ]),
    )),
  );
}