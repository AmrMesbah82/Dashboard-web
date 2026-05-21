// ******************* FILE INFO *******************
// File Name: strategy_edit.dart
// Screen 2 of 3 — Our Strategy CMS: Edit page
// UPDATED: Added Strategic House - ENG and Strategic House - ARB accordions
// UPDATED: Added device preview tabs (Large Screen / Tablet / Mobile)
// UPDATED: Added custom validation dialog for missing fields
// UPDATED: Added publish confirmation dialog and removed snackbars
// UPDATED: Publish button disabled until ALL fields valid (not just hasChanges)
// UPDATED: Image caching — prevents reload on every keystroke setState
// UPDATED: Fixed change detection - publish disabled until actual changes made

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../../core/constant/color.dart';
import '../../../../../../core/custom_dialog.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';
import 'strategy_preview.dart';

// const Color ColorPick.primary      = Color(0xFF2D8C4E);
// const Color ColorPick.primary = Color(0xFF008037);
// const Color _kRed        = Color(0xFFD32F2F);
// const Color _kSurface    = Color(0xFFFFFFFF);
// const Color _kBg         = Color(0xFFF2F2F2);

// ── Device preview tab enum ─────────────────────────────────────────────────
enum DeviceTab { largeScreen, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyEditPage extends StatefulWidget {
  const StrategyEditPage({super.key});

  @override
  State<StrategyEditPage> createState() => _StrategyEditPageState();
}

class _StrategyEditPageState extends State<StrategyEditPage> {
  // ── Navigation Label ──
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // ── Strategic House — ENG ──
  Uint8List? _strategicHouseEnBytes;
  String _strategicHouseEnUrl = '';

  // ── Strategic House — ARB ──
  Uint8List? _strategicHouseArBytes;
  String _strategicHouseArUrl = '';

  bool _navLabelOpen         = true;
  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  bool _submitted  = false;
  bool _seeded     = false;
  bool _isSaving   = false;
  bool _hasChanges = false;

  // Store original values to track changes
  String _originalNavTitleEn = '';
  String _originalNavTitleAr = '';
  String _originalNavIconUrl = '';
  String _originalStrategicHouseEnUrl = '';
  String _originalStrategicHouseArUrl = '';

  // ── Device preview tabs ──
  DeviceTab _strategicHouseEnTab = DeviceTab.largeScreen;
  DeviceTab _strategicHouseArTab = DeviceTab.largeScreen;

  // ══════════════════════════════════════════════════════════════════════════
  // URL → bytes cache — avoids re-fetching on every rebuild / setState
  // ══════════════════════════════════════════════════════════════════════════
  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  Future<Uint8List> _cachedLoadSvg(String url) {
    return _urlBytesCache.putIfAbsent(url, () => _loadSvgBytes(url));
  }

  Future<Uint8List> _cachedLoadImage(String url) {
    return _urlBytesCache.putIfAbsent(url, () async {
      try {
        final res = await html.HttpRequest.request(
          url,
          method: 'GET',
          responseType: 'arraybuffer',
        );
        if (res.status == 200 && res.response != null) {
          return (res.response as ByteBuffer).asUint8List();
        }
        throw Exception('HTTP ${res.status}');
      } catch (e) {
        throw Exception('Failed to load image: $e');
      }
    });
  }

  /// Computed live — true when every required field has a value.
  bool get _isFormValid {
    return _navTitleEnCtrl.text.trim().isNotEmpty &&
        _navTitleArCtrl.text.trim().isNotEmpty &&
        (_navIconUrl.isNotEmpty || _navIconBytes != null) &&
        (_strategicHouseEnUrl.isNotEmpty || _strategicHouseEnBytes != null) &&
        (_strategicHouseArUrl.isNotEmpty || _strategicHouseArBytes != null);
  }

  @override
  void initState() {
    super.initState();
    context.read<StrategyCubit>().load();

    _navTitleEnCtrl.addListener(_checkForChanges);
    _navTitleArCtrl.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _navTitleEnCtrl.removeListener(_checkForChanges);
    _navTitleArCtrl.removeListener(_checkForChanges);
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
    super.dispose();
  }

  // Check if any changes exist compared to original values
  void _checkForChanges() {
    if (!_seeded) return; // Don't check changes until data is seeded

    final bool hasTextChanges =
        _navTitleEnCtrl.text != _originalNavTitleEn ||
            _navTitleArCtrl.text != _originalNavTitleAr;

    final bool hasImageChanges =
        _navIconUrl != _originalNavIconUrl ||
            _strategicHouseEnUrl != _originalStrategicHouseEnUrl ||
            _strategicHouseArUrl != _originalStrategicHouseArUrl ||
            _navIconBytes != null ||
            _strategicHouseEnBytes != null ||
            _strategicHouseArBytes != null;

    final bool hasChanges = hasTextChanges || hasImageChanges;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  // Reset changes tracking after save
  void _resetChangesTracking() {
    _originalNavTitleEn = _navTitleEnCtrl.text;
    _originalNavTitleAr = _navTitleArCtrl.text;
    _originalNavIconUrl = _navIconUrl;
    _originalStrategicHouseEnUrl = _strategicHouseEnUrl;
    _originalStrategicHouseArUrl = _strategicHouseArUrl;

    _navIconBytes = null;
    _strategicHouseEnBytes = null;
    _strategicHouseArBytes = null;

    _hasChanges = false;
  }

  // ── File picker — SVG only ────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgFile() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
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
        c.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) {
          bytes = r.asUint8List();
        } else if (r is Uint8List) {
          bytes = r;
        }

        if (bytes != null) {
          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });
      reader.onError.listen((e) {
        c.complete(null);
      });
    });
    input.click();
    return c.future;
  }

  // ── Image picker (all image types) for strategic house ────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }

      final file = files.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) {
          bytes = r.asUint8List();
        } else if (r is Uint8List) {
          bytes = r;
        }

        if (bytes != null) {
          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });
      reader.onError.listen((e) {
        c.complete(null);
      });
    });
    input.click();
    return c.future;
  }

  // ── Seed ─────────────────────────────────────────────────────────────────
  void _seed(OurStrategyModel m) {
    if (_seeded) return;
    _seeded = true;


    _originalNavTitleEn          = m.navigationLabel.title.en;
    _originalNavTitleAr          = m.navigationLabel.title.ar;
    _originalNavIconUrl          = m.navigationLabel.iconUrl;
    _originalStrategicHouseEnUrl = m.strategicHouseEnUrl;
    _originalStrategicHouseArUrl = m.strategicHouseArUrl;

    _navTitleEnCtrl.text  = _originalNavTitleEn;
    _navTitleArCtrl.text  = _originalNavTitleAr;
    _navIconUrl           = _originalNavIconUrl;
    _strategicHouseEnUrl  = _originalStrategicHouseEnUrl;
    _strategicHouseArUrl  = _originalStrategicHouseArUrl;

    // Ensure hasChanges is false initially
    _hasChanges = false;
  }

  OurStrategyModel _buildModel(String status) => OurStrategyModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    vision: const StrategySection(),
    strategicHouseEnUrl: _strategicHouseEnUrl,
    strategicHouseArUrl: _strategicHouseArUrl,
  );

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_navIconBytes != null)
      uploads['strategy_cms/navLabel/icon'] = _navIconBytes!;
    if (_strategicHouseEnBytes != null)
      uploads['strategy_cms/strategicHouse/en'] = _strategicHouseEnBytes!;
    if (_strategicHouseArBytes != null)
      uploads['strategy_cms/strategicHouse/ar'] = _strategicHouseArBytes!;
    return uploads;
  }

  // ── Validation ────────────────────────────────────────────────────────────
  List<String> _getMissingFields() {
    final missing = <String>[];

    if (_navTitleEnCtrl.text.trim().isEmpty) {
      missing.add('Navigation Title (English)');
    }
    if (_navTitleArCtrl.text.trim().isEmpty) {
      missing.add('Navigation Title (Arabic)');
    }
    if (_navIconUrl.isEmpty && _navIconBytes == null) {
      missing.add('Navigation Icon');
    }
    if (_strategicHouseEnUrl.isEmpty && _strategicHouseEnBytes == null) {
      missing.add('Strategic House Image (English)');
    }
    if (_strategicHouseArUrl.isEmpty && _strategicHouseArBytes == null) {
      missing.add('Strategic House Image (Arabic)');
    }

    return missing;
  }

  void _showValidationDialog() {
    final missingFields = _getMissingFields();

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

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_isFormValid) {
      _showValidationDialog();
      return;
    }
    final cubit   = context.read<StrategyCubit>();
    final model   = _buildModel('draft');
    final uploads = _collectUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StrategyPreviewPage(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save / Publish ────────────────────────────────────────────────────────
  Future<void> _onSave() async {
    setState(() => _submitted = true);

    if (!_isFormValid) {
      _showValidationDialog();
      return;
    }

    setState(() => _isSaving = true);

    final model   = _buildModel('published');
    final uploads = _collectUploads();


    try {
      await context.read<StrategyCubit>().save(
        model: model,
        imageUploads: uploads.isEmpty ? null : uploads,
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
    }
  }

  void _showPublishConfirmDialog() {
    setState(() => _submitted = true);

    if (!_isFormValid) {
      _showValidationDialog();
      return;
    }

    showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH STRATEGY',
      subtitle: 'Do you want to publish this strategy page now?',
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

  // ── Device preview width helper ───────────────────────────────────────────
  double _previewWidth(DeviceTab tab) {
    switch (tab) {
      case DeviceTab.largeScreen:
        return double.infinity;
      case DeviceTab.tablet:
        return 600.w;
      case DeviceTab.mobile:
        return 320.w;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyCubit, StrategyState>(
      listener: (context, state) {
        if (state is StrategyLoaded) {
          _seed(state.data);
        }
        if (state is StrategySaved) {
          setState(() => _isSaving = false);

          setState(() {
            _navIconUrl          = state.data.navigationLabel.iconUrl;
            _strategicHouseEnUrl = state.data.strategicHouseEnUrl;
            _strategicHouseArUrl = state.data.strategicHouseArUrl;

            // Reset change tracking
            _resetChangesTracking();

            // Clear cache
            _urlBytesCache.clear();
          });

          if (mounted) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) Navigator.pop(context);
            });
          }
        }
        if (state is StrategyError) {
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
        }
      },
      builder: (context, state) {
        final loading = state is StrategyLoading || state is StrategyInitial;

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 1000.w,
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            AdminSubNavBar(activeIndex: 3),
                            SizedBox(height: 20.h),
                            loading
                                ?  Center(
                                child: CircularProgressIndicator(
                                    color: ColorPick.primary))
                                : _buildForm(),
                          ],
                        ),
                      ),
                    ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // FORM
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildForm() {
    final bool formValid = _isFormValid;
    final bool canPublish = formValid && _hasChanges && !_isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editing Our Strategy',
            style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary, fontWeight: FontWeight.w700)),
        SizedBox(height: 24.h),

        // ── Navigation Label ──────────────────────────────────────────────
        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () =>
              setState(() => _navLabelOpen = !_navLabelOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUploadCircle(
                label: 'Icon *',
                bytes: _navIconBytes,
                url: _navIconUrl,
                showError: _submitted &&
                    _navIconBytes == null &&
                    _navIconUrl.isEmpty,
                onTap: () async {
                  final b = await _pickSvgFile();
                  if (b != null) {
                    setState(() {
                      _navIconBytes = b;
                      _checkForChanges();
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
              _fieldLabel('Title *'),
              SizedBox(height: 8.h),
              _bilingualRow(
                  enCtrl: _navTitleEnCtrl,
                  arCtrl: _navTitleArCtrl,
                  enHint: 'Text Here',
                  arHint: 'أدخل النص هنا'),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ENG ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ENG',
          isOpen: _strategicHouseEnOpen,
          onToggle: () =>
              setState(() => _strategicHouseEnOpen = !_strategicHouseEnOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseEnTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseEnTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _imageUploadBox(
                label: 'Upload Image *',
                bytes: _strategicHouseEnBytes,
                url: _strategicHouseEnUrl,
                previewWidth: _previewWidth(_strategicHouseEnTab),
                showError: _submitted &&
                    _strategicHouseEnBytes == null &&
                    _strategicHouseEnUrl.isEmpty,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseEnBytes = b;
                      _checkForChanges();
                    });
                  }
                },
                onRemove: (_strategicHouseEnBytes != null ||
                    _strategicHouseEnUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnBytes = null;
                  _strategicHouseEnUrl   = '';
                  _urlBytesCache.remove(_originalStrategicHouseEnUrl);
                  _checkForChanges();
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ARB ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ARB',
          isOpen: _strategicHouseArOpen,
          onToggle: () =>
              setState(() => _strategicHouseArOpen = !_strategicHouseArOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseArTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseArTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _imageUploadBox(
                label: 'Upload Image *',
                bytes: _strategicHouseArBytes,
                url: _strategicHouseArUrl,
                previewWidth: _previewWidth(_strategicHouseArTab),
                showError: _submitted &&
                    _strategicHouseArBytes == null &&
                    _strategicHouseArUrl.isEmpty,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseArBytes = b;
                      _checkForChanges();
                    });
                  }
                },
                onRemove: (_strategicHouseArBytes != null ||
                    _strategicHouseArUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArBytes = null;
                  _strategicHouseArUrl   = '';
                  _urlBytesCache.remove(_originalStrategicHouseArUrl);
                  _checkForChanges();
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        // ── Action buttons ────────────────────────────────────────────────
        Row(children: [
          Expanded(
              child: _btn(
                  label: 'Preview',
                  color: Color(0XFF608570),
                  onTap: formValid ? _onPreview : null)),
          SizedBox(width: 300.w),
          Expanded(
              child: _btn(
                  label: 'Publish',
                  color: canPublish
                      ? ColorPick.primary
                      : ColorPick.primary.withOpacity(0.4),
                  onTap: canPublish ? _showPublishConfirmDialog : null)),
        ]),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                  label: 'Discard',
                  color: const Color(0xFF9E9E9E),
                  onTap: _onDiscard),
            ),
            SizedBox(width: 300.w),
            Expanded(child: Column())
          ],
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: ColorPick.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp),
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
          padding: EdgeInsets.only(top: 16.h),
          child: child,
        ),
    ]);
  }

  // ── Device Tab Bar ────────────────────────────────────────────────────────
  Widget _deviceTabBar({
    required DeviceTab selected,
    required ValueChanged<DeviceTab> onChanged,
  }) {
    Widget tab(String label, DeviceTab value) {
      final isActive = selected == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isActive ? ColorPick.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          tab('Large Screen', DeviceTab.largeScreen),
          SizedBox(width: 4.w),
          tab('Tablet', DeviceTab.tablet),
          SizedBox(width: 4.w),
          tab('Mobile', DeviceTab.mobile),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD BOX — large rectangle (Strategic House sections)
  // Uses _cachedLoadSvg / _cachedLoadImage to prevent reload on setState
  // ══════════════════════════════════════════════════════════════════════════
  Widget _imageUploadBox({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    double previewWidth = double.infinity,
    bool showError = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── image area ──
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: previewWidth,
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: hasImage
                ? Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Builder(
                    builder: (context) {
                      // Handle uploaded bytes (new upload)
                      if (bytes != null) {
                        if (_isSvgBytesCheck(bytes)) {
                          return SvgPicture.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Image.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                          );
                        }
                      }

                      // Handle existing URL — use CACHED loader
                      if (url.isNotEmpty) {
                        final isSvg = _isSvgUrlCheck(url);

                        if (isSvg) {
                          return FutureBuilder<Uint8List>(
                            future: _cachedLoadSvg(url),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData) {
                                return SvgPicture.memory(
                                  snapshot.data!,
                                  width: previewWidth,
                                  height: 220.h,
                                  fit: BoxFit.contain,
                                );
                              }
                              return _brokenImagePlaceholder();
                            },
                          );
                        } else {
                          return FutureBuilder<Uint8List>(
                            future: _cachedLoadImage(url),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: previewWidth,
                                  height: 220.h,
                                  fit: BoxFit.contain,
                                );
                              }
                              return _brokenImagePlaceholder();
                            },
                          );
                        }
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Remove button
                if (onRemove != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: ColorPick.red,
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
                  ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: "assets/images/upload-image.svg",
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Drop your image here',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Error text ──
        if (showError)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'This field is required',
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
            ),
          ),

        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithImage(
              title: label,
              function: onTap,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white),
              height: 38.h,
              space: 8.sp,
              width: 250.w,
              radius: 8.r,
              color: ColorPick.primary,
              image: "",
              widthImage: 16.w,
              heightImage: 16.h,
              colorBorder: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD CIRCLE — Navigation Label icon
  // Uses _cachedLoadSvg to prevent reload on setState
  // ══════════════════════════════════════════════════════════════════════════
  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool showError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Builder(
                    builder: (context) {
                      // ── New bytes uploaded ──
                      if (bytes != null) {
                        if (_isSvgBytesCheck(bytes)) {
                          return Padding(
                            padding: EdgeInsets.all(15.r),
                            child: SvgPicture.memory(
                              bytes,
                              width: 30.w,
                              height: 30.h,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return Image.memory(
                          bytes,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 28.sp,
                          ),
                        );
                      }

                      // ── Existing URL — use CACHED loader ──
                      if (url.isNotEmpty) {
                        final isSvg = _isSvgUrlCheck(url);
                        final Future<Uint8List> future = isSvg
                            ? _cachedLoadSvg(url)
                            : _cachedLoadImage(url);

                        return FutureBuilder<Uint8List>(
                          future: future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF008037),
                                    strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasData) {
                              final data = snapshot.data!;
                              if (isSvg || _isSvgBytesCheck(data)) {
                                return Padding(
                                  padding: EdgeInsets.all(15.r),
                                  child: SvgPicture.memory(
                                    data,
                                    width: 30.w,
                                    height: 30.h,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }
                              return Image.memory(
                                data,
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              );
                            }
                            return Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 28.sp,
                            );
                          },
                        );
                      }

                      // ── No image ──
                      return Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 22.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Camera overlay
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 25.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary,
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
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SVG / Image detection helpers
  // ══════════════════════════════════════════════════════════════════════════

  bool _isSvgBytesCheck(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final checkLen = bytes.length > 100 ? 100 : bytes.length;
    final headerStr = String.fromCharCodes(bytes.sublist(0, checkLen));
    return headerStr.contains('<svg') || headerStr.contains('<?xml');
  }

  bool _isSvgUrlCheck(String url) {
    final decodedUrl = Uri.decodeFull(url).toLowerCase();
    return decodedUrl.contains('.svg') ||
        decodedUrl.contains('%2Esvg') ||
        decodedUrl.contains('image/svg+xml');
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    try {
      final res = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (res.status != 200) {
        throw Exception('Failed to load SVG: ${res.status}');
      }
      final bytes = (res.response as ByteBuffer).asUint8List();
      return bytes;
    } catch (e) {
      rethrow;
    }
  }

  Widget _brokenImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey[400], size: 48.sp),
          SizedBox(height: 8.h),
          Text(
            'Failed to load image',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORM FIELD HELPERS
  // ══════════════════════════════════════════════════════════════════════════

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
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            fillColor: Colors.white,
            maxLength: 200,
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
            maxLines: 1,
            fillColor: Colors.white,
            maxLength: 200,
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

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

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
              color: color,
              borderRadius: BorderRadius.circular(10.r)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w,
        height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: ColorPick.primary),
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