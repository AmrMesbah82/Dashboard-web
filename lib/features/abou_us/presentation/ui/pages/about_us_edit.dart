// ******************* FILE INFO *******************
// File Name: about_us_edit.dart
// Screen 2 — About Us CMS: Edit all sections
// Navigates to: AboutPreviewPage (screen 3)
// UPDATE: Values section — first item labeled "Main Icon", rest labeled "Icon"
//         matching Figma design exactly.
// UPDATED: Added custom dialogs for publish/save
// UPDATED: Proper validation with error messages under text fields
// UPDATED: All text fields have isRequired: true for inline validation
// UPDATED: Added Navigation Label section (between Headings and Vision)
// UPDATED: Publish button disabled until all fields valid. Error text only
//          appears after first submit attempt. Button reactively enables/disables.
// FIXED:   Vision onPickIcon was writing to _missionIconBytes → now _visionIconBytes
// FIXED:   Mission onPickIcon was writing to _visionIconBytes → now _missionIconBytes
// FIXED:   Navigation Label onTap called _pickSvgFile() → now _pickImageIcon()

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/core/constant/color.dart';


import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';



import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/model/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';
import 'about_us_main.dart';
import 'about_us_preview.dart';

// const Color _kGreen = Color(0xFF2D8C4E);
// const Color ColorPick.primary = Color(0xFF008037);
// const Color _kGreenLight = Color(0xFFE8F5EE);
// const Color _kRed = Color(0xFFD32F2F);
// const Color _kSurface = Color(0xFFFFFFFF);
// const Color _kBg = Color(0xFFF2F2F2);

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

  // ── Navigation Label ──
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // ── Vision ──
  final _visionSubEnCtrl = TextEditingController();
  final _visionSubArCtrl = TextEditingController();
  final _visionDescEnCtrl = TextEditingController();
  final _visionDescArCtrl = TextEditingController();
  Uint8List? _visionIconBytes;
  Uint8List? _visionSvgBytes;
  String _visionIconUrl = '';
  String _visionSvgUrl = '';

  // ── Mission ──
  final _missionSubEnCtrl = TextEditingController();
  final _missionSubArCtrl = TextEditingController();
  final _missionDescEnCtrl = TextEditingController();
  final _missionDescArCtrl = TextEditingController();
  Uint8List? _missionIconBytes;
  Uint8List? _missionSvgBytes;
  String _missionIconUrl = '';
  String _missionSvgUrl = '';

  // ── Values ──
  final List<_ValueItem> _valueItems = [];
  int _valueCounter = 0;

  // ── Accordion open/close ──
  bool _headingsOpen = true;
  bool _navigationLabelOpen = true;
  bool _visionOpen = true;
  bool _missionOpen = true;
  bool _valuesOpen = true;

  /// True only after user has attempted to submit at least once.
  /// Error text under fields only appears when this is true.
  bool _submitted = false;

  bool _seeded = false;
  bool _isSaving = false;

  // ── URL → bytes cache (avoids re-fetching on every rebuild) ──
  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  /// Computed live — true when every required field has a value.
  bool get _isFormValid => _validateFields();

  @override
  void initState() {
    super.initState();
    context.read<AboutCubit>().load();
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
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

  /// Picks any image format (PNG, JPG, WEBP, SVG).
  Future<Uint8List?> _pickImageIcon() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer)
            completer.complete(result.asUint8List());
          else if (result is Uint8List)
            completer.complete(result);
          else
            completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  /// Picks SVG files only.
  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        showConfirmDialog(
          context: context,
          title: 'Invalid File',
          subtitle: 'Please upload SVG files only! You selected: ${file.name}',
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
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer)
            completer.complete(result.asUint8List());
          else if (result is Uint8List)
            completer.complete(result);
          else
            completer.complete(null);
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
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files.first);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer)
            completer.complete(result.asUint8List());
          else if (result is Uint8List)
            completer.complete(result);
          else
            completer.complete(null);
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

    // ── Navigation Label ──
    _navTitleEnCtrl.text = m.navigationLabel.title.en;
    _navTitleArCtrl.text = m.navigationLabel.title.ar;
    _navIconUrl = m.navigationLabel.iconUrl;

    _visionSubEnCtrl.text = m.vision.subDescription.en;
    _visionSubArCtrl.text = m.vision.subDescription.ar;
    _visionDescEnCtrl.text = m.vision.description.en;
    _visionDescArCtrl.text = m.vision.description.ar;
    _visionIconUrl = m.vision.iconUrl;
    _visionSvgUrl = m.vision.svgUrl;

    _missionSubEnCtrl.text = m.mission.subDescription.en;
    _missionSubArCtrl.text = m.mission.subDescription.ar;
    _missionDescEnCtrl.text = m.mission.description.en;
    _missionDescArCtrl.text = m.mission.description.ar;
    _missionIconUrl = m.mission.iconUrl;
    _missionSvgUrl = m.mission.svgUrl;

    _valueItems.clear();
    for (final v in m.values) {
      final item = _ValueItem(id: v.id, counter: ++_valueCounter);
      item.titleEnCtrl.text = v.title.en;
      item.titleArCtrl.text = v.title.ar;
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
      title: AboutBilingualText(
        en: _titleEnCtrl.text.trim(),
        ar: _titleArCtrl.text.trim(),
      ),
      navigationLabel: AboutNavigationLabel(
        iconUrl: _navIconUrl,
        title: AboutBilingualText(
          en: _navTitleEnCtrl.text.trim(),
          ar: _navTitleArCtrl.text.trim(),
        ),
      ),
      vision: AboutSection(
        iconUrl: _visionIconUrl,
        svgUrl: _visionSvgUrl,
        subDescription: AboutBilingualText(
          en: _visionSubEnCtrl.text.trim(),
          ar: _visionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _visionDescEnCtrl.text.trim(),
          ar: _visionDescArCtrl.text.trim(),
        ),
      ),
      mission: AboutSection(
        iconUrl: _missionIconUrl,
        svgUrl: _missionSvgUrl,
        subDescription: AboutBilingualText(
          en: _missionSubEnCtrl.text.trim(),
          ar: _missionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _missionDescEnCtrl.text.trim(),
          ar: _missionDescArCtrl.text.trim(),
        ),
      ),
      values: _valueItems
          .map(
            (v) => AboutValueItem(
          id: v.id,
          iconUrl: v.iconUrl,
          title: AboutBilingualText(
            en: v.titleEnCtrl.text.trim(),
            ar: v.titleArCtrl.text.trim(),
          ),
          shortDescription: AboutBilingualText(
            en: v.shortDescEnCtrl.text.trim(),
            ar: v.shortDescArCtrl.text.trim(),
          ),
        ),
      )
          .toList(),
    );
  }

  // ── Collect image uploads ──────────────────────────────────────────────────
  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_navIconBytes != null)
      uploads['about_cms/navLabel/icon'] = _navIconBytes!;
    if (_visionIconBytes != null)
      uploads['about_cms/vision/icon'] = _visionIconBytes!;
    if (_visionSvgBytes != null)
      uploads['about_cms/vision/svg'] = _visionSvgBytes!;
    if (_missionIconBytes != null)
      uploads['about_cms/mission/icon'] = _missionIconBytes!;
    if (_missionSvgBytes != null)
      uploads['about_cms/mission/svg'] = _missionSvgBytes!;
    for (final v in _valueItems) {
      if (v.iconBytes != null)
        uploads['about_cms/values/${v.id}/icon'] = v.iconBytes!;
    }
    return uploads;
  }

  // ── Validate fields — pure check, no side effects ──────────────────────────
  bool _validateFields() {
    // Check Headings
    if (_titleEnCtrl.text.trim().isEmpty) return false;
    if (_titleArCtrl.text.trim().isEmpty) return false;

    // Check Navigation Label
    if (_navTitleEnCtrl.text.trim().isEmpty) return false;
    if (_navTitleArCtrl.text.trim().isEmpty) return false;
    if (_navIconBytes == null && _navIconUrl.isEmpty) return false;

    // Check Vision
    if (_visionSubEnCtrl.text.trim().isEmpty) return false;
    if (_visionSubArCtrl.text.trim().isEmpty) return false;
    if (_visionDescEnCtrl.text.trim().isEmpty) return false;
    if (_visionDescArCtrl.text.trim().isEmpty) return false;
    if (_visionIconBytes == null && _visionIconUrl.isEmpty) return false;
    if (_visionSvgBytes == null && _visionSvgUrl.isEmpty) return false;

    // Check Mission
    if (_missionSubEnCtrl.text.trim().isEmpty) return false;
    if (_missionSubArCtrl.text.trim().isEmpty) return false;
    if (_missionDescEnCtrl.text.trim().isEmpty) return false;
    if (_missionDescArCtrl.text.trim().isEmpty) return false;
    if (_missionIconBytes == null && _missionIconUrl.isEmpty) return false;
    if (_missionSvgBytes == null && _missionSvgUrl.isEmpty) return false;

    // Check Values
    for (final v in _valueItems) {
      if (v.titleEnCtrl.text.trim().isEmpty) return false;
      if (v.titleArCtrl.text.trim().isEmpty) return false;
      if (v.shortDescEnCtrl.text.trim().isEmpty) return false;
      if (v.shortDescArCtrl.text.trim().isEmpty) return false;
      if (v.iconBytes == null && v.iconUrl.isEmpty) return false;
    }

    return true;
  }

  // ── Show validation error dialog with missing fields ──────────────────────
  void _showValidationError() {
    final List<String> missingFields = [];

    // Check Headings
    if (_titleEnCtrl.text.trim().isEmpty) missingFields.add('Title (English)');
    if (_titleArCtrl.text.trim().isEmpty) missingFields.add('Title (Arabic)');

    // Check Navigation Label
    if (_navTitleEnCtrl.text.trim().isEmpty)
      missingFields.add('Navigation Label - Title (English)');
    if (_navTitleArCtrl.text.trim().isEmpty)
      missingFields.add('Navigation Label - Title (Arabic)');
    if (_navIconBytes == null && _navIconUrl.isEmpty)
      missingFields.add('Navigation Label - Icon');

    // Check Vision
    if (_visionSubEnCtrl.text.trim().isEmpty)
      missingFields.add('Vision Sub Description (English)');
    if (_visionSubArCtrl.text.trim().isEmpty)
      missingFields.add('Vision Sub Description (Arabic)');
    if (_visionDescEnCtrl.text.trim().isEmpty)
      missingFields.add('Vision Description (English)');
    if (_visionDescArCtrl.text.trim().isEmpty)
      missingFields.add('Vision Description (Arabic)');
    if (_visionIconBytes == null && _visionIconUrl.isEmpty)
      missingFields.add('Vision Icon Image');
    if (_visionSvgBytes == null && _visionSvgUrl.isEmpty)
      missingFields.add('Vision SVG Icon');

    // Check Mission
    if (_missionSubEnCtrl.text.trim().isEmpty)
      missingFields.add('Mission Sub Description (English)');
    if (_missionSubArCtrl.text.trim().isEmpty)
      missingFields.add('Mission Sub Description (Arabic)');
    if (_missionDescEnCtrl.text.trim().isEmpty)
      missingFields.add('Mission Description (English)');
    if (_missionDescArCtrl.text.trim().isEmpty)
      missingFields.add('Mission Description (Arabic)');
    if (_missionIconBytes == null && _missionIconUrl.isEmpty)
      missingFields.add('Mission Icon Image');
    if (_missionSvgBytes == null && _missionSvgUrl.isEmpty)
      missingFields.add('Mission SVG Icon');

    // Check Values
    for (var i = 0; i < _valueItems.length; i++) {
      final v = _valueItems[i];
      final prefix = 'Value ${i + 1}';
      if (v.titleEnCtrl.text.trim().isEmpty)
        missingFields.add('$prefix - Title (English)');
      if (v.titleArCtrl.text.trim().isEmpty)
        missingFields.add('$prefix - Title (Arabic)');
      if (v.shortDescEnCtrl.text.trim().isEmpty)
        missingFields.add('$prefix - Short Description (English)');
      if (v.shortDescArCtrl.text.trim().isEmpty)
        missingFields.add('$prefix - Short Description (Arabic)');
      if (v.iconBytes == null && v.iconUrl.isEmpty)
        missingFields.add('$prefix - Icon Image');
    }

    final message = missingFields.isEmpty
        ? 'Please check all required fields.'
        : 'Please fill the following required fields:\n\n• ${missingFields.join('\n• ')}';

    showConfirmDialog(
      context: context,
      title: 'Required Fields Missing',
      subtitle: message,
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

  // ── Preview ────────────────────────────────────────────────────────────────
  void _onPreview() async {
    setState(() => _submitted = true);
    await Future.delayed(const Duration(milliseconds: 50));

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    final model = _buildModel('draft');
    final uploads = _collectUploads();
    final cubit = context.read<AboutCubit>();
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

  // ── Save / Publish with custom dialog ─────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    await Future.delayed(const Duration(milliseconds: 50));

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final model = _buildModel(status);
      final uploads = _collectUploads();
      await context.read<AboutCubit>().save(
        model: model,
        imageUploads: uploads.isEmpty ? null : uploads,
      );

      // if (mounted) {
      //   if (status == 'published') {
      //     await Future.delayed(const Duration(milliseconds: 1500));
      //     if (mounted) context.go('/');
      //   }
      // }
    } catch (e) {
      if (mounted) {
        showConfirmDialog(
          context: context,
          title: 'Error',
          subtitle: 'Failed to save: ${e.toString()}',
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Add / remove value item ────────────────────────────────────────────────
  void _addValueItem() {
    setState(() {
      _valueItems.add(
        _ValueItem(
          id: 'val_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_valueCounter,
        ),
      );
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AboutMainPageMasterDashboard(),
                ),
                    (route) => false,
              );
            }
          });
        }
        if (state is AboutError) {
          setState(() => _isSaving = false);
          showConfirmDialog(
            context: context,
            title: 'Error',
            subtitle: state.message,
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
              child:
              Icon(Icons.error_outline, color: Colors.white, size: 36.r),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AboutLoading || state is AboutInitial;

        return Scaffold(
          backgroundColor: Color(0xFFF1F2ED),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  AppAdminNavbar(
                    activeLabel: 'Web Page',
                    homePage: CareersMainPageDashboard(),
                    webPage: HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),
                  AdminSubNavBar(activeIndex: 3),
                  SizedBox(
                    width: 1000.w,
                    child: isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorPick.primary,
                      ),
                    )
                        : _buildForm(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Form ───────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Row(
          children: [
            Text(
              'Editing About Us',
              style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── Navigation Label ──
        _accordion(
          title: 'Navigation Label',
          isOpen: _navigationLabelOpen,
          onToggle: () =>
              setState(() => _navigationLabelOpen = !_navigationLabelOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _navigationLabelSection(),
          ),
        ),

        SizedBox(height: 15.h),

        // ── Headings ──
        _accordion(
          title: 'Headings',
          isOpen: _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _headingsSection(),
          ),
        ),

        SizedBox(height: 15.h),

        // ── Vision ──
        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _sectionEditor(
              iconBytes: _visionIconBytes,
              svgBytes: _visionSvgBytes,
              iconUrl: _visionIconUrl,
              svgUrl: _visionSvgUrl,
              // ✅ FIX 1: was setting _missionIconBytes — now correctly sets _visionIconBytes
              onPickIcon: () async {
                final b = await _pickImageIcon();
                if (b != null) setState(() => _visionIconBytes = b);
              },
              onPickSvg: () async {
                final b = await _pickSvgFile();
                if (b != null) setState(() => _visionSvgBytes = b);
              },
              subEnCtrl: _visionSubEnCtrl,
              subArCtrl: _visionSubArCtrl,
              descEnCtrl: _visionDescEnCtrl,
              descArCtrl: _visionDescArCtrl,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Mission ──
        _accordion(
          title: 'Mission',
          isOpen: _missionOpen,
          onToggle: () => setState(() => _missionOpen = !_missionOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _sectionEditor(
              iconBytes: _missionIconBytes,
              svgBytes: _missionSvgBytes,
              iconUrl: _missionIconUrl,
              svgUrl: _missionSvgUrl,
              // ✅ FIX 2: was setting _visionIconBytes — now correctly sets _missionIconBytes
              onPickIcon: () async {
                final b = await _pickImageIcon();
                if (b != null) setState(() => _missionIconBytes = b);
              },
              onPickSvg: () async {
                final b = await _pickSvgFile();
                if (b != null) setState(() => _missionSvgBytes = b);
              },
              subEnCtrl: _missionSubEnCtrl,
              subArCtrl: _missionSubArCtrl,
              descEnCtrl: _missionDescEnCtrl,
              descArCtrl: _missionDescArCtrl,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Values ──
        _accordion(
          title: 'Values',
          isOpen: _valuesOpen,
          onToggle: () => setState(() => _valuesOpen = !_valuesOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _valuesSection(),
          ),
        ),
        SizedBox(height: 16.h),

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
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: StyleText.fontSize16Weight400.copyWith(
                      color: Colors.white
                  )
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen) child,
      ],
    );
  }

  // ── Headings section ───────────────────────────────────────────────────────
  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('Title'),
            Spacer(),
            _fieldLabelAr("العنوان"),
          ],
        ),
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

  // ── Navigation Label section ───────────────────────────────────────────────
  Widget _navigationLabelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ FIX 3: was calling _pickSvgFile() — now correctly calls _pickImageIcon()
        _imageUploadCircle(
          label: 'Icon',
          bytes: _navIconBytes,
          url: _navIconUrl,
          onTap: () async {
            final b = await _pickImageIcon();
            if (b != null) setState(() => _navIconBytes = b);
          },
          isSvg: false,
          showError:
          _submitted && _navIconBytes == null && _navIconUrl.isEmpty,
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            _fieldLabel('Title'),
            Spacer(),
            _fieldLabelAr("العنوان"),
          ],
        ),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _navTitleEnCtrl,
          arCtrl: _navTitleArCtrl,
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
        Row(
          children: [
            _imageUploadCircle(
              label: 'Icon',
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,
              isSvg: false,
              showError: _submitted && iconBytes == null && iconUrl.isEmpty,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'SVG',
              bytes: svgBytes,
              url: svgUrl,
              onTap: onPickSvg,
              isSvg: true,
              showError: _submitted && svgBytes == null && svgUrl.isEmpty,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: subEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          fillColor: Colors.white,
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          fillColor: Colors.white,
          maxLines: 4,
          maxLength: 500,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALUES SECTION — first item = "Main Icon", rest = "Icon"
  // ══════════════════════════════════════════════════════════════════════════

  Widget _valuesSection() {
    if (_valueItems.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 20.h),
          Center(
            child: Text(
              'No values added. Click "Add Point" to create one.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _addValueButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_valueItems.length, (index) {
          final v = _valueItems[index];
          final bool isMain = index == 0;
          return _valueItemWidget(v, isMain: isMain);
        }),
        SizedBox(height: 16.h),
        _addValueButton(),
      ],
    );
  }

  Widget _addValueButton() {
    return GestureDetector(
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
              'Add Point',
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
    );
  }

  Widget _valueItemWidget(_ValueItem v, {required bool isMain}) {
    final String itemLabel = isMain ? 'Main Icon' : 'Icon';
    final bool showIconError =
        _submitted && v.iconBytes == null && v.iconUrl.isEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: itemLabel,
                bytes: v.iconBytes,
                url: v.iconUrl,
                isSvg: false,
                showError: showIconError,
                onTap: () async {
                  final b = await _pickImageIcon();
                  if (b != null) setState(() => v.iconBytes = b);
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
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
          Row(
            children: [
              _fieldLabel('Title'),
              Spacer(),
              _fieldLabelAr("العنوان"),
            ],
          ),
          SizedBox(height: 8.h),
          _bilingualRow(
            enCtrl: v.titleEnCtrl,
            arCtrl: v.titleArCtrl,
            enHint: 'Text Here',
            arHint: 'أدخل النص هنا',
          ),
          SizedBox(height: 16.h),
          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.shortDescEnCtrl,
            height: 100,
            fillColor: Colors.white,
            maxLines: 4,
            maxLength: 10000,
            showCharCount: false,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 16.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.shortDescArCtrl,
            fillColor: Colors.white,
            height: 100,
            maxLines: 4,
            maxLength: 10000,
            showCharCount: false,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons() {
    final bool formValid = _isFormValid;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: formValid
                    ? const Color(0xFF608570)
                    : const Color(0xFF608570).withOpacity(0.4),
                onTap: formValid ? _onPreview : null,
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: _btn(
                label: 'Publish',
                color: formValid
                    ? ColorPick.primary
                    : ColorPick.primary.withOpacity(0.4),
                onTap: formValid ? () => _showPublishConfirmDialog() : null,
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
                color: const Color(0xFF797979),
                onTap: () {
                  showConfirmDialog(
                    context: context,
                    title: 'Discard Changes',
                    subtitle: 'Are you sure you want to discard all changes?',
                    confirmLabel: 'Discard',
                    cancelLabel: 'Cancel',
                    onConfirm: () => context.pop(),
                  );
                },
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: _btn(
                label: 'Save For Later',
                color: formValid
                    ? Colors.grey.shade600
                    : Colors.grey.shade600.withOpacity(0.4),
                onTap: formValid ? () => _showSaveDraftDialog() : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPublishConfirmDialog() {
    setState(() => _submitted = true);

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    showPublishConfirmDialog(
      context: context,
      title: 'EDITING ABOUT US DETAILS',
      subtitle: 'Do you want to save the changes made to this About Us?',
      confirmLabel: 'Publish',
      onConfirm: () => _save('published'),
    );
  }

  void _showSaveDraftDialog() {
    setState(() => _submitted = true);

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    showPublishConfirmDialog(
      context: context,
      title: 'SAVE AS DRAFT',
      subtitle: 'Do you want to save this page as a draft?',
      confirmLabel: 'Save Draft',
      onConfirm: () => _save('draft'),
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
    bool showError = false,
  }) {
    final bool hasBytes = bytes != null;
    final bool hasUrl = url.isNotEmpty;

    Widget content;
    if (hasBytes) {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(

          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: _isSvgMemory(bytes!, isSvg)
                ? SvgPicture.memory(
              bytes,
              width: 30.w,
              height: 30.h,
              fit: BoxFit.contain,
            )
                : Image.memory(bytes,
                width: 30.w, height: 30.h, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (hasUrl) {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: FutureBuilder<Uint8List>(
              future: _cachedLoad(url, isSvg: isSvg),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: ColorPick.primary),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  if (_isSvgMemory(data, isSvg)) {
                    return SvgPicture.memory(
                      data,
                      width: 30.w,
                      height: 30.h,
                      fit: BoxFit.contain,
                    );
                  }
                  return Image.memory(data,
                      width: 30.w, height: 30.h, fit: BoxFit.contain);
                }
                return Center(child: CustomSvg(assetPath: "assets/control/camera.svg",width: 20.w,height: 20.h,fit: BoxFit.fill,color: Colors.grey,));
              },
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color:  Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomSvg(assetPath: "assets/control/camera.svg",width: 20.w,height: 20.h,color: Colors.grey,)
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text
          )
        ),
        SizedBox(height: 8.h),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(onTap: onTap, child: content),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 25.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvg(
                      assetPath: "assets/control/camera.svg",
                      width: 10.w,
                      height: 10.h,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'This field is required',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  bool _isSvgMemory(Uint8List b, bool hintSvg) {
    if (hintSvg) return true;
    if (b.length < 5) return false;
    final header =
    String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
    return header.startsWith('<svg') || header.startsWith('<?xml');
  }

  // ── Shared form helpers ────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
    int maxLength = 150,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint,
            controller: enCtrl,
            fillColor: Colors.white,
            height: 42,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            fillColor: Colors.white,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: StyleText.fontSize14Weight400.copyWith(
      color: AppColors.text
    )
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text
      )
    ),
  );

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback? onTap,
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

// ── Value item helper class ────────────────────────────────────────────────────
class _ValueItem {
  final String id;
  final int counter;
  final titleEnCtrl = TextEditingController();
  final titleArCtrl = TextEditingController();
  final shortDescEnCtrl = TextEditingController();
  final shortDescArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}