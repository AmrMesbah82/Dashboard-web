// ******************* FILE INFO *******************
// File Name: about_edit_page.dart
// Screen 2 — About Us CMS: Edit all sections
// Navigates to: AboutPreviewPage (screen 3)
// UPDATE: Values section — first item labeled "Main Icon", rest labeled "Icon"
//         matching Figma design exactly.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import 'about_preview_page.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class AboutEditPageMaster extends StatefulWidget {
  const AboutEditPageMaster({super.key});

  @override
  State<AboutEditPageMaster> createState() => _AboutEditPageMasterState();
}

class _AboutEditPageMasterState extends State<AboutEditPageMaster> {
  // ── Headings ──
  final _titleEnCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();

  // ── Vision ──
  final _visionSubEnCtrl  = TextEditingController();
  final _visionSubArCtrl  = TextEditingController();
  final _visionDescEnCtrl = TextEditingController();
  final _visionDescArCtrl = TextEditingController();
  Uint8List? _visionIconBytes;
  Uint8List? _visionSvgBytes;
  String _visionIconUrl = '';
  String _visionSvgUrl  = '';

  // ── Mission ──
  final _missionSubEnCtrl  = TextEditingController();
  final _missionSubArCtrl  = TextEditingController();
  final _missionDescEnCtrl = TextEditingController();
  final _missionDescArCtrl = TextEditingController();
  Uint8List? _missionIconBytes;
  Uint8List? _missionSvgBytes;
  String _missionIconUrl = '';
  String _missionSvgUrl  = '';

  // ── Values ──
  final List<_ValueItem> _valueItems = [];
  int _valueCounter = 0;

  // ── Accordion open/close ──
  bool _headingsOpen = true;
  bool _visionOpen   = true;
  bool _missionOpen  = true;
  bool _valuesOpen   = true;

  bool _submitted = false;
  bool _seeded    = false;
  bool _isSaving  = false;

  // ── URL → bytes cache (avoids re-fetching on every rebuild) ──
  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  @override
  void initState() {
    super.initState();
    context.read<AboutCubit>().load();
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _visionSubEnCtrl.dispose();
    _visionSubArCtrl.dispose();
    _visionDescEnCtrl.dispose();
    _visionDescArCtrl.dispose();
    _missionSubEnCtrl.dispose();
    _missionSubArCtrl.dispose();
    _missionDescEnCtrl.dispose();
    _missionDescArCtrl.dispose();
    for (final v in _valueItems) {
      v.titleEnCtrl.dispose();
      v.titleArCtrl.dispose();
      v.shortDescEnCtrl.dispose();
      v.shortDescArCtrl.dispose();
    }
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // File pickers
  // ══════════════════════════════════════════════════════════════════════════

  Future<Uint8List?> _pickImageIcon() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { completer.complete(null); return; }
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) completer.complete(result.asUint8List());
          else if (result is Uint8List) completer.complete(result);
          else completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { completer.complete(null); return; }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ Please upload SVG files only! You selected: ${file.name}'),
          backgroundColor: _kRed,
          duration: const Duration(seconds: 3),
        ));
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) completer.complete(result.asUint8List());
          else if (result is Uint8List) completer.complete(result);
          else completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  Future<Uint8List?> _pickImage() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = 'image/*';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { completer.complete(null); return; }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files.first);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) completer.complete(result.asUint8List());
          else if (result is Uint8List) completer.complete(result);
          else completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // URL loaders (XHR — CORS-safe for Firebase Storage)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns a cached Future so FutureBuilder never re-fetches on rebuild.
  Future<Uint8List> _cachedLoad(String url, {bool isSvg = false}) {
    return _urlBytesCache.putIfAbsent(
      url,
          () => isSvg ? _loadSvg(url) : _loadImageBytes(url),
    );
  }

  Future<Uint8List> _loadImageBytes(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  Future<Uint8List> _loadSvg(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: 'image/svg+xml',
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  // ── Seed from loaded model ─────────────────────────────────────────────────
  void _seedFromModel(AboutPageModel m) {
    if (_seeded) return;
    _seeded = true;

    _titleEnCtrl.text = m.title.en;
    _titleArCtrl.text = m.title.ar;

    _visionSubEnCtrl.text  = m.vision.subDescription.en;
    _visionSubArCtrl.text  = m.vision.subDescription.ar;
    _visionDescEnCtrl.text = m.vision.description.en;
    _visionDescArCtrl.text = m.vision.description.ar;
    _visionIconUrl = m.vision.iconUrl;
    _visionSvgUrl  = m.vision.svgUrl;

    _missionSubEnCtrl.text  = m.mission.subDescription.en;
    _missionSubArCtrl.text  = m.mission.subDescription.ar;
    _missionDescEnCtrl.text = m.mission.description.en;
    _missionDescArCtrl.text = m.mission.description.ar;
    _missionIconUrl = m.mission.iconUrl;
    _missionSvgUrl  = m.mission.svgUrl;

    _valueItems.clear();
    for (final v in m.values) {
      final item = _ValueItem(id: v.id, counter: ++_valueCounter);
      item.titleEnCtrl.text     = v.title.en;
      item.titleArCtrl.text     = v.title.ar;
      item.shortDescEnCtrl.text = v.shortDescription.en;
      item.shortDescArCtrl.text = v.shortDescription.ar;
      item.iconUrl = v.iconUrl;
      _valueItems.add(item);
    }
  }

  // ── Build model from current state ────────────────────────────────────────
  AboutPageModel _buildModel(String status) {
    return AboutPageModel(
      publishStatus: status,
      title: AboutBilingualText(en: _titleEnCtrl.text.trim(), ar: _titleArCtrl.text.trim()),
      vision: AboutSection(
        iconUrl: _visionIconUrl,
        svgUrl: _visionSvgUrl,
        subDescription: AboutBilingualText(en: _visionSubEnCtrl.text.trim(), ar: _visionSubArCtrl.text.trim()),
        description: AboutBilingualText(en: _visionDescEnCtrl.text.trim(), ar: _visionDescArCtrl.text.trim()),
      ),
      mission: AboutSection(
        iconUrl: _missionIconUrl,
        svgUrl: _missionSvgUrl,
        subDescription: AboutBilingualText(en: _missionSubEnCtrl.text.trim(), ar: _missionSubArCtrl.text.trim()),
        description: AboutBilingualText(en: _missionDescEnCtrl.text.trim(), ar: _missionDescArCtrl.text.trim()),
      ),
      values: _valueItems.map((v) => AboutValueItem(
        id: v.id,
        iconUrl: v.iconUrl,
        title: AboutBilingualText(en: v.titleEnCtrl.text.trim(), ar: v.titleArCtrl.text.trim()),
        shortDescription: AboutBilingualText(en: v.shortDescEnCtrl.text.trim(), ar: v.shortDescArCtrl.text.trim()),
      )).toList(),
    );
  }

  // ── Collect image uploads ──────────────────────────────────────────────────
  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_visionIconBytes  != null) uploads['about_cms/vision/icon']   = _visionIconBytes!;
    if (_visionSvgBytes   != null) uploads['about_cms/vision/svg']    = _visionSvgBytes!;
    if (_missionIconBytes != null) uploads['about_cms/mission/icon']  = _missionIconBytes!;
    if (_missionSvgBytes  != null) uploads['about_cms/mission/svg']   = _missionSvgBytes!;
    for (final v in _valueItems) {
      if (v.iconBytes != null) uploads['about_cms/values/${v.id}/icon'] = v.iconBytes!;
    }
    return uploads;
  }

  // ── Validate fields ────────────────────────────────────────────────────────
  bool _validateFields() {
    final requiredCtrls = [
      _titleEnCtrl, _titleArCtrl,
      _visionSubEnCtrl, _visionSubArCtrl,
      _visionDescEnCtrl, _visionDescArCtrl,
      _missionSubEnCtrl, _missionSubArCtrl,
      _missionDescEnCtrl, _missionDescArCtrl,
      for (final v in _valueItems) ...[
        v.titleEnCtrl, v.titleArCtrl,
        v.shortDescEnCtrl, v.shortDescArCtrl,
      ],
    ];
    return !requiredCtrls.any((c) => c.text.trim().isEmpty);
  }

  // ── Preview ────────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validateFields()) return;
    final model   = _buildModel('draft');
    final uploads = _collectUploads();
    final cubit   = context.read<AboutCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AboutPreviewPageLast(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save / Publish ─────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validateFields()) return;

    setState(() => _isSaving = true);
    final model   = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<AboutCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Add / remove value item ────────────────────────────────────────────────
  void _addValueItem() {
    setState(() {
      _valueItems.add(_ValueItem(
        id: 'val_${DateTime.now().millisecondsSinceEpoch}',
        counter: ++_valueCounter,
      ));
    });
  }

  void _removeValueItem(String id) {
    setState(() => _valueItems.removeWhere((v) => v.id == id));
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AboutCubit, AboutState>(
      listener: (context, state) {
        if (state is AboutLoaded) _seedFromModel(state.data);
        if (state is AboutSaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('About Us saved successfully!'),
              backgroundColor: _kGreenSolid,
            ),
          );
          // no navigation — stay on edit page after publish
        }
        if (state is AboutError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AboutLoading || state is AboutInitial;

        return Scaffold(
          backgroundColor: Color(0xFFF1F2ED),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 3),
                      SizedBox(
                        width: 1000.w,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: _kGreenSolid))
                            : _buildForm(),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving) _buildSavingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ───────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          'Editing About Us',
          style: StyleText.fontSize45Weight600.copyWith(
            color: _kGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title: 'Headings',
          isOpen: _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child: _headingsSection(),
        ),


        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: _sectionEditor(
            iconBytes: _visionIconBytes,
            svgBytes:  _visionSvgBytes,
            iconUrl:   _visionIconUrl,
            svgUrl:    _visionSvgUrl,
            onPickIcon: () async {
              final b = await _pickImageIcon();
              if (b != null) setState(() => _visionIconBytes = b);
            },
            onPickSvg: () async {
              final b = await _pickSvgFile();
              if (b != null) setState(() => _visionSvgBytes = b);
            },
            subEnCtrl:  _visionSubEnCtrl,
            subArCtrl:  _visionSubArCtrl,
            descEnCtrl: _visionDescEnCtrl,
            descArCtrl: _visionDescArCtrl,
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Mission',
          isOpen: _missionOpen,
          onToggle: () => setState(() => _missionOpen = !_missionOpen),
          child: _sectionEditor(
            iconBytes: _missionIconBytes,
            svgBytes:  _missionSvgBytes,
            iconUrl:   _missionIconUrl,
            svgUrl:    _missionSvgUrl,
            onPickIcon: () async {
              final b = await _pickImageIcon();
              if (b != null) setState(() => _missionIconBytes = b);
            },
            onPickSvg: () async {
              final b = await _pickSvgFile();
              if (b != null) setState(() => _missionSvgBytes = b);
            },
            subEnCtrl:  _missionSubEnCtrl,
            subArCtrl:  _missionSubArCtrl,
            descEnCtrl: _missionDescEnCtrl,
            descArCtrl: _missionDescArCtrl,
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Values',
          isOpen: _valuesOpen,
          onToggle: () => setState(() => _valuesOpen = !_valuesOpen),
          child: _valuesSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
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
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            child: child,
          ),
      ],
    );
  }

  // ── Headings section ───────────────────────────────────────────────────────
  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),

        _fieldLabel('Title'),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _titleEnCtrl,
          arCtrl: _titleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Vision / Mission section editor ───────────────────────────────────────
  Widget _sectionEditor({
    required Uint8List? iconBytes,
    required Uint8List? svgBytes,
    required String iconUrl,
    required String svgUrl,
    required VoidCallback onPickIcon,
    required VoidCallback onPickSvg,
    required TextEditingController subEnCtrl,
    required TextEditingController subArCtrl,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 20.h
        ),

        Row(
          children: [


            _imageUploadCircle(
              label: 'Icon', bytes: iconBytes, url: iconUrl,
              onTap: onPickIcon, isSvg: false,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'SVG', bytes: svgBytes, url: svgUrl,
              onTap: onPickSvg, isSvg: true,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', controller: subEnCtrl,
          height: 100, maxLines: 4, maxLength: 200, showCharCount: true,
          submitted: _submitted, textDirection: TextDirection.ltr,
          textAlign: TextAlign.start, onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', controller: subArCtrl,
          height: 100, maxLines: 4, maxLength: 200, showCharCount: true,
          submitted: _submitted, textDirection: TextDirection.rtl,
          textAlign: TextAlign.right, onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', controller: descEnCtrl,
          height: 100, maxLines: 4, maxLength: 800, showCharCount: true,
          submitted: _submitted, textDirection: TextDirection.ltr,
          textAlign: TextAlign.start, onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', controller: descArCtrl,
          height: 100, maxLines: 4, maxLength: 800, showCharCount: true,
          submitted: _submitted, textDirection: TextDirection.rtl,
          textAlign: TextAlign.right, onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALUES SECTION — first item = "Main Icon", rest = "Icon"
  // ══════════════════════════════════════════════════════════════════════════

  Widget _valuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_valueItems.length, (index) {
          final v = _valueItems[index];
          final bool isMain = index == 0;
          return _valueItemWidget(v, isMain: isMain);
        }),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addValueItem,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Point',
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 13.sp,
                    fontWeight: FontWeight.w600, color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueItemWidget(_ValueItem v, {required bool isMain}) {
    final String itemLabel = isMain ? 'Main Icon' : 'Icon';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: label + icon upload on left, Remove on right ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon upload with "Main Icon" or "Icon" label
              _imageUploadCircle(
                label: itemLabel,
                bytes: v.iconBytes,
                url: v.iconUrl,
                isSvg: false,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) setState(() => v.iconBytes = b);
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                      color: _kRed, borderRadius: BorderRadius.circular(6.r)),
                  child: Text('Remove',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Title (bilingual) ──
          _fieldLabel('Title'),
          SizedBox(height: 8.h),
          _bilingualRow(enCtrl: v.titleEnCtrl, arCtrl: v.titleArCtrl,
              enHint: 'Text Here', arHint: 'أدخل النص هنا'),
          SizedBox(height: 16.h),

          // ── Short Description (bilingual) ──
          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here', controller: v.shortDescEnCtrl,
            height: 100, maxLines: 4, maxLength: 200, showCharCount: true,
            submitted: _submitted, textDirection: TextDirection.ltr,
            textAlign: TextAlign.start, onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 8.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا', controller: v.shortDescArCtrl,
            height: 100, maxLines: 4, maxLength: 200, showCharCount: true,
            submitted: _submitted, textDirection: TextDirection.rtl,
            textAlign: TextAlign.right, onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _btn(label: 'Preview', color: const Color(0xFF4CAF50), onTap: _onPreview)),
            SizedBox(width: 16.w),
            Expanded(child: _btn(label: 'Publish', color: _kGreenSolid, onTap: () => _save('published'))),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _btn(label: 'Discard', color: const Color(0xFF9E9E9E), onTap: () => Navigator.pop(context)),
            )],
        ),
      ],
    );
  }

  // ── Saving overlay ─────────────────────────────────────────────────────────
  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w, height: 100.h,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _kGreenSolid),
              SizedBox(height: 12.h),
              Text('Saving...',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared image helpers
  // ══════════════════════════════════════════════════════════════════════════

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool isSvg = false,
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w, height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEEEEEE),
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(
                  isSvg ? Icons.description_outlined : Icons.add,
                  color: Colors.grey[600], size: 28.sp,
                ),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24.w, height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: _kGreenSolid,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4, offset: const Offset(0, 2),
                      )],
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 13.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(Uint8List? bytes, String url, bool isSvg) {
    // ── Helper: detect SVG from bytes ──
    bool _isSvgBytes(Uint8List b) {
      if (b.length < 5) return false;
      final header = String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
      return header.startsWith('<svg') || header.startsWith('<?xml');
    }

    // ── Helper: render bytes (auto-detects SVG vs image) ──
    Widget _renderBytes(Uint8List b) {
      if (isSvg || _isSvgBytes(b)) {
        return Padding(
          padding: EdgeInsets.all(16.r),
          child: SvgPicture.memory(b, fit: BoxFit.contain),
        );
      }
      return Image.memory(b, fit: BoxFit.cover);
    }

    final Widget spinner = SizedBox(
      width: 20, height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: _kGreenSolid),
    );

    // ── 1. Already have bytes in memory (freshly picked) ──
    if (bytes != null) {
      return _renderBytes(bytes);
    }

    // ── 2. Load from URL via XHR ──
    if (url.isNotEmpty) {
      return FutureBuilder<Uint8List>(
        future: _cachedLoad(url, isSvg: isSvg),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinner);
          }
          if (snapshot.hasData) {
            return _renderBytes(snapshot.data!);
          }
          // error
          return Icon(
            isSvg ? Icons.description_outlined : Icons.broken_image,
            color: isSvg ? Colors.grey[400] : Colors.red[300],
            size: 28.sp,
          );
        },
      );
    }

    // ── 3. No bytes, no URL — placeholder ──
    return Icon(
      isSvg ? Icons.description_outlined : Icons.image_outlined,
      color: Colors.grey[500], size: 28.sp,
    );
  }

  // ── Shared form helpers ────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
    int maxLength = 200,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint, controller: enCtrl, height: 42, maxLines: 1,
            maxLength: maxLength, submitted: _submitted,
            textDirection: TextDirection.ltr, textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint, controller: arCtrl, height: 42, maxLines: 1,
            maxLength: maxLength, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
          fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(text,
        style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
            fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _btn({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 48.h,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.r)),
        child: Center(
          child: Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp,
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

// ── Value item helper class ────────────────────────────────────────────────────
class _ValueItem {
  final String id;
  final int    counter;
  final titleEnCtrl     = TextEditingController();
  final titleArCtrl     = TextEditingController();
  final shortDescEnCtrl = TextEditingController();
  final shortDescArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}