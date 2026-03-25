// ******************* FILE INFO *******************
// File Name: about_edit_page.dart
// Created by: Amr Mesbah

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
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class AboutEditPage extends StatefulWidget {
  const AboutEditPage({super.key});

  @override
  State<AboutEditPage> createState() => _AboutEditPageState();
}

class _AboutEditPageState extends State<AboutEditPage> {
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
      v.descEnCtrl.dispose();    // ← ADDED
      v.descArCtrl.dispose();    // ← ADDED
    }
    super.dispose();
  }



  // ══════════════════════════════════════════════════════════════════════════
// FIXED: Separate pickers with validation
// ══════════════════════════════════════════════════════════════════════════

  Future<Uint8List?> _pickImageIcon() async {
    print('🔵 _pickImageIcon called (PNG/JPG/SVG)');
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml'; // ✅ Added SVG

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('🔴 No files selected');
        completer.complete(null);
        return;
      }

      final file = files.first;
      print('🟣 Icon file selected: ${file.name}, size: ${file.size}');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) {
            final bytes = result.asUint8List();
            print('✅ Icon bytes ready: ${bytes.length}');
            completer.complete(bytes);
          } else if (result is Uint8List) {
            print('✅ Icon bytes ready: ${result.length}');
            completer.complete(result);
          } else {
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((error) {
        print('❌ Reader error: $error');
        completer.complete(null);
      });
    });

    input.click();
    return completer.future;
  }

  Future<Uint8List?> _pickSvgFile() async {
    print('🔵 _pickSvgFile called (SVG only)');
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();  // ✅ NO accept attribute - show all files

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('🔴 No files selected');
        completer.complete(null);
        return;
      }

      final file = files.first;
      final fileName = file.name.toLowerCase();

      // ✅ Validate: only accept SVG files
      if (!fileName.endsWith('.svg')) {
        print('❌ Non-SVG file rejected: $fileName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Please upload SVG files only! You selected: ${file.name}'),
            backgroundColor: _kRed,
            duration: const Duration(seconds: 3),
          ),
        );
        completer.complete(null);
        return;
      }

      print('🟣 SVG file selected: ${file.name}, size: ${file.size}');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) {
            final bytes = result.asUint8List();
            print('✅ SVG bytes ready: ${bytes.length}');
            completer.complete(bytes);
          } else if (result is Uint8List) {
            print('✅ SVG bytes ready: ${result.length}');
            completer.complete(result);
          } else {
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((error) {
        print('❌ Reader error: $error');
        completer.complete(null);
      });
    });

    input.click();
    return completer.future;
  }



  // ── Seed from loaded model ────────────────────────────────────────────────

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
      item.descEnCtrl.text      = v.description.en;  // ← ADDED
      item.descArCtrl.text      = v.description.ar;  // ← ADDED
      item.iconUrl = v.iconUrl;
      _valueItems.add(item);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  // FIX: readAsArrayBuffer returns a ByteBuffer, not List<int>.
  // Must cast to ByteBuffer then call asUint8List().

  Future<Uint8List?> _pickImage() async {
    print('🔵 _pickImage called');
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = 'image/*';

    input.onChange.listen((_) {
      print('🟢 onChange triggered');
      final files = input.files;
      print('🟡 Files: $files, isEmpty: ${files?.isEmpty}');

      if (files == null || files.isEmpty) {
        print('🔴 No files selected');
        completer.complete(null);
        return;
      }

      final file = files.first;
      print('🟣 File selected: ${file.name}, size: ${file.size}');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        print('🟠 onLoadEnd triggered, readyState: ${reader.readyState}');
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          print('🟤 Result type: ${result.runtimeType}');

          // FIX: Check for both ByteBuffer AND Uint8List
          if (result is ByteBuffer) {
            final bytes = result.asUint8List();
            print('✅ Successfully converted ByteBuffer to Uint8List, length: ${bytes.length}');
            completer.complete(bytes);
          } else if (result is Uint8List) {
            // Sometimes readAsArrayBuffer returns Uint8List directly
            print('✅ Already Uint8List, length: ${result.length}');
            completer.complete(result);
          } else {
            print('❌ Result is neither ByteBuffer nor Uint8List: $result');
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((error) {
        print('❌ Reader error: $error');
        completer.complete(null);
      });
    });

    print('🔵 Clicking input');
    input.click();
    print('🔵 Waiting for future');

    return completer.future;
  }

  // ── Build model from current state ───────────────────────────────────────

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
        description: AboutBilingualText(en: v.descEnCtrl.text.trim(), ar: v.descArCtrl.text.trim()), // ← ADDED
      )).toList(),
    );
  }

  // ── Collect image uploads ─────────────────────────────────────────────────

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

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save(String status) async {
    setState(() => _submitted = true);

    final requiredCtrls = [
      _titleEnCtrl, _titleArCtrl,
      _visionSubEnCtrl, _visionSubArCtrl,
      _visionDescEnCtrl, _visionDescArCtrl,
      _missionSubEnCtrl, _missionSubArCtrl,
      _missionDescEnCtrl, _missionDescArCtrl,
      for (final v in _valueItems) ...[
        v.titleEnCtrl, v.titleArCtrl,
        v.shortDescEnCtrl, v.shortDescArCtrl,
        v.descEnCtrl, v.descArCtrl,  // ← ADDED
      ],
    ];

    final hasEmpty = requiredCtrls.any((c) => c.text.trim().isEmpty);
    if (hasEmpty) return;

    setState(() => _isSaving = true);
    final model   = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<AboutCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Add / remove value item ───────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

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
          context.goNamed('about');
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
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    AppNavbar(currentRoute: '/about-us'),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: _kGreenSolid))
                          : _buildForm(),
                    ),
                  ],
                ),
              ),
              if (_isSaving) _buildSavingOverlay(),
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
        Text(
          'About Us',
          style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
            fontSize: 36.sp,
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
        SizedBox(height: 16.h),

        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: _sectionEditor(
            iconBytes: _visionIconBytes,
            svgBytes: _visionSvgBytes,
            iconUrl: _visionIconUrl,
            svgUrl: _visionSvgUrl,
            onPickIcon: () async {
              print('📸 Vision Icon picker called');
              final b = await _pickImageIcon();  // ← Use _pickImageIcon
              print('📸 Vision Icon picker returned: ${b?.length} bytes');
              if (b != null) {
                setState(() {
                  _visionIconBytes = b;
                  print('✅ Vision Icon bytes set');
                });
              }
            },
            onPickSvg: () async {
              print('📄 Vision SVG picker called');
              final b = await _pickSvgFile();  // ← Use _pickSvgFile
              print('📄 Vision SVG picker returned: ${b?.length} bytes');
              if (b != null) {
                setState(() {
                  _visionSvgBytes = b;
                  print('✅ Vision SVG bytes set');
                });
              }
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
            svgBytes: _missionSvgBytes,
            iconUrl: _missionIconUrl,
            svgUrl: _missionSvgUrl,
            onPickIcon: () async {
              print('📸 Mission Icon picker called');
              final b = await _pickImageIcon();  // ✅ Use _pickImageIcon
              print('📸 Mission Icon picker returned: ${b?.length} bytes');
              if (b != null) {
                setState(() {
                  _missionIconBytes = b;
                  print('✅ Mission Icon bytes set');
                });
              }
            },
            onPickSvg: () async {
              print('📄 Mission SVG picker called');
              final b = await _pickSvgFile();  // ✅ Use _pickSvgFile
              print('📄 Mission SVG picker returned: ${b?.length} bytes');
              if (b != null) {
                setState(() {
                  _missionSvgBytes = b;
                  print('✅ Mission SVG bytes set');
                });
              }
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

  // ── Accordion ─────────────────────────────────────────────────────────────

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
                Text(
                  title,
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
              color: _kSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
      ],
    );
  }

  // ── Headings section ──────────────────────────────────────────────────────

  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
  })
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image uploads ──
        Row(
          children: [
            _imageUploadCircle(
              label: 'Icon',
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,  // ← Make sure this is being called
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'SVG',
              bytes: svgBytes,
              url: svgUrl,
              onTap: onPickSvg,  // ← Make sure this is being called
              isSvg: true,
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // ── Sub description ──
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: subEnCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 150,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 150,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // ── Description ──
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ── Values section ────────────────────────────────────────────────────────

  Widget _valuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._valueItems.map((v) => _valueItemWidget(v)).toList(),
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
                Text(
                  'Point',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueItemWidget(_ValueItem v) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + Remove ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: v.iconBytes,
                url: v.iconUrl,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) {
                    setState(() {
                      v.iconBytes = b;
                      // Force rebuild by modifying the list reference
                      _valueItems[_valueItems.indexOf(v)] = v;
                    });
                  }
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Title bilingual ──
          _fieldLabel('Title'),
          SizedBox(height: 8.h),
          _bilingualRow(
            enCtrl: v.titleEnCtrl,
            arCtrl: v.titleArCtrl,
            enHint: 'Text Here',
            arHint: 'أدخل النص هنا',
          ),
          SizedBox(height: 16.h),

          // ── Short Description ──
          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.shortDescEnCtrl,
            height: 100,
            maxLines: 4,
            maxLength: 300,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 8.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.shortDescArCtrl,
            height: 100,
            maxLines: 4,
            maxLength: 300,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 16.h),

          // ── Description EN + AR ── ← ADDED BLOCK
          _fieldLabel('Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.descEnCtrl,
            height: 100,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 8.h),
          _fieldLabelAr('الوصف'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.descArCtrl,
            height: 100,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFF4CAF50),
                onTap: () => context.goNamed('about-preview'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label: 'Publish',
                color: _kGreenSolid,
                onTap: () => _save('published'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: const Color(0xFF9E9E9E),
                onTap: () => context.goNamed('about'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Saving overlay ────────────────────────────────────────────────────────

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _kGreenSolid),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            print('👆 Tap detected on $label');
            onTap();
          },
          child: Stack(
            clipBehavior: Clip.none,  // ← Allow overflow
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEEEEEE),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(
                  isSvg ? Icons.description_outlined : Icons.add,
                  color: Colors.grey[600],
                  size: 28.sp,
                ),
              ),
              Positioned(
                bottom: -2,  // ← Slight offset for better visual
                right: -2,
                child: GestureDetector(
                  onTap: () {
                    print('✏️ Edit button tapped on $label');
                    onTap();
                  },
                  behavior: HitTestBehavior.opaque,  // ← Ensure tap detection
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGreenSolid,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
    // ✅ NEW: Auto-detect if bytes contain SVG data
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = header.startsWith('<svg') || header.startsWith('<?xml');
    }

    if (isSvg || isSvgData) {
      // Handle SVG
      if (bytes != null) {
        try {
          return SvgPicture.memory(
            bytes,
            fit: BoxFit.cover,
            placeholderBuilder: (context) => Icon(
              Icons.description,
              color: Colors.grey[400],
              size: 28.sp,
            ),
          );
        } catch (e) {
          print('❌ SVG memory error: $e');
          return Icon(
            Icons.broken_image,
            color: Colors.red[300],
            size: 28.sp,
          );
        }
      } else if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvg(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(
                Icons.description,
                color: Colors.grey[400],
                size: 28.sp,
              );
            }
            if (snapshot.hasError) {
              print('❌ SVG load error: ${snapshot.error}');
              return Icon(
                Icons.broken_image,
                color: Colors.red[300],
                size: 28.sp,
              );
            }
            if (snapshot.hasData) {
              return SvgPicture.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
            return Icon(
              Icons.description,
              color: Colors.grey[400],
              size: 28.sp,
            );
          },
        );
      }
    } else {
      // Handle raster images (PNG, JPG, etc.)
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      } else if (url.isNotEmpty) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image,
              color: Colors.red[300],
              size: 28.sp,
            );
          },
        );
      }
    }

    // Fallback
    return Icon(
      isSvg ? Icons.description : Icons.image,
      color: Colors.grey,
      size: 28.sp,
    );
  }

// Add this helper method to load SVG safely
  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      responseType: 'arraybuffer',
    );

    if (response.status != 200) {
      throw Exception('Failed to load SVG: ${response.status}');
    }

    final buffer = response.response as ByteBuffer;
    return buffer.asUint8List();
  }



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
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Value item helper class ───────────────────────────────────────────────────

class _ValueItem {
  final String id;
  final int    counter;
  final titleEnCtrl    = TextEditingController();
  final titleArCtrl    = TextEditingController();
  final shortDescEnCtrl = TextEditingController(); // ← renamed from descEnCtrl
  final shortDescArCtrl = TextEditingController(); // ← renamed from descArCtrl
  final descEnCtrl     = TextEditingController();  // ← ADDED: full description EN
  final descArCtrl     = TextEditingController();  // ← ADDED: full description AR
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}