// ******************* FILE INFO *******************
// File Name: careers_edit_page.dart
// Created by: Amr Mesbah
// Screen: 1.2 — Edit form for Careers Overview + Career Statistics
// FIXED: SVG bytes are uploaded to Firebase Storage → iconUrl saved to Firestore
// UPDATED: Publish button disabled on validation errors / empty fields
// UPDATED: After confirm dialog → navigates to CareersMainPageMaster
// UPDATED: Pattern matches ServicesMainEditPage (BlocConsumer, _hasChanges, _isFormValid)

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../core/custom_svg.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import '../../careers_main_dashboard.dart';
import 'careers_main_page.dart'; // CareersMainPageMaster lives here


class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color labelText = Color(0xFF333333);
  static const Color red       = Color(0xFFD32F2F);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color back      = Color(0xFFF1F2ED);
}

class CareersEditPage extends StatefulWidget {
  const CareersEditPage({super.key});
  @override
  State<CareersEditPage> createState() => _CareersEditPageState();
}

class _CareersEditPageState extends State<CareersEditPage> {
  late CareersCmsModel _draft;

  late TextEditingController _overviewDescEnCtrl;
  late TextEditingController _overviewDescArCtrl;
  late TextEditingController _overviewBtnEnCtrl;
  late TextEditingController _overviewBtnArCtrl;

  final Map<String, Map<String, TextEditingController>> _statCtrls = {};
  final Map<String, bool> _open = {'overview': true, 'statistics': true};

  bool _saving     = false;
  bool _ready      = false;
  bool _submitted  = false;
  bool _hasChanges = false;
  bool _isSaving   = false;

  // ── Icon tracking ──────────────────────────────────────────────────────────
  // _statIcons    : newly picked SVG bytes (pending upload)
  // _statIconUrls : current URL (existing from Firestore or just uploaded)
  final Map<String, Uint8List?> _statIcons    = {};
  final Map<String, String>     _statIconUrls = {};

  // ── Original values for change detection ──────────────────────────────────
  String _originalDescEn = '';
  String _originalDescAr = '';
  String _originalBtnEn  = '';
  String _originalBtnAr  = '';

  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final s = context.read<CareersCmsCubit>().state;
    if (s is CareersCmsLoaded || s is CareersCmsSaved) {
      _initFromModel(context.read<CareersCmsCubit>().current);
      _ready = true;
    } else {
      context.read<CareersCmsCubit>().load().then((_) {
        if (mounted) {
          setState(() {
            _initFromModel(context.read<CareersCmsCubit>().current);
            _ready = true;
          });
        }
      });
    }
  }

  void _initFromModel(CareersCmsModel model) {
    _draft = model;

    _originalDescEn = model.overview.description.en;
    _originalDescAr = model.overview.description.ar;
    _originalBtnEn  = model.overview.actionButtonLabel.en;
    _originalBtnAr  = model.overview.actionButtonLabel.ar;

    _overviewDescEnCtrl = TextEditingController(text: _originalDescEn);
    _overviewDescArCtrl = TextEditingController(text: _originalDescAr);
    _overviewBtnEnCtrl  = TextEditingController(text: _originalBtnEn);
    _overviewBtnArCtrl  = TextEditingController(text: _originalBtnAr);

    _overviewDescEnCtrl.addListener(_checkForChanges);
    _overviewDescArCtrl.addListener(_checkForChanges);
    _overviewBtnEnCtrl.addListener(_checkForChanges);
    _overviewBtnArCtrl.addListener(_checkForChanges);

    for (final s in model.statistics) {
      _initStatCtrl(s);
      _statIcons[s.id]    = null;       // no new bytes yet
      _statIconUrls[s.id] = s.iconUrl;  // restore saved URL from Firestore
    }
  }

  void _initStatCtrl(CareerStatItem s) {
    _statCtrls[s.id] = {
      'titleEn':     TextEditingController(text: s.title.en),
      'titleAr':     TextEditingController(text: s.title.ar),
      'shortDescEn': TextEditingController(text: s.shortDescription.en),
      'shortDescAr': TextEditingController(text: s.shortDescription.ar),
    };
    for (final c in _statCtrls[s.id]!.values) {
      c.addListener(_checkForChanges);
    }
  }

  // ── Change detection ───────────────────────────────────────────────────────
  void _checkForChanges() {
    final bool hasChanges =
        _overviewDescEnCtrl.text != _originalDescEn ||
            _overviewDescArCtrl.text != _originalDescAr ||
            _overviewBtnEnCtrl.text  != _originalBtnEn  ||
            _overviewBtnArCtrl.text  != _originalBtnAr  ||
            _statIcons.values.any((v) => v != null);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  void dispose() {
    if (_ready) {
      _overviewDescEnCtrl.removeListener(_checkForChanges);
      _overviewDescArCtrl.removeListener(_checkForChanges);
      _overviewBtnEnCtrl.removeListener(_checkForChanges);
      _overviewBtnArCtrl.removeListener(_checkForChanges);

      _overviewDescEnCtrl.dispose();
      _overviewDescArCtrl.dispose();
      _overviewBtnEnCtrl.dispose();
      _overviewBtnArCtrl.dispose();

      for (final m in _statCtrls.values) {
        for (final c in m.values) {
          c.removeListener(_checkForChanges);
          c.dispose();
        }
      }
    }
    super.dispose();
  }

  // ── SVG-only file picker ───────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only SVG files are allowed.'),
              backgroundColor: _C.red,
            ),
          );
        }
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) {
            completer.complete(result.asUint8List());
          } else if (result is Uint8List) {
            completer.complete(result);
          } else {
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  // ── Upload SVG bytes → Firebase Storage → returns download URL ─────────────
  Future<String> _uploadSvgToStorage({
    required String statId,
    required Uint8List bytes,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('careers/statistics/$statId/icon.svg');

    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/svg+xml'),
    );
    final url = await task.ref.getDownloadURL();
    print('🟢 [CareersEditPage] SVG uploaded → $url');
    return url;
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool get _isFormValid {
    if (_overviewDescEnCtrl.text.trim().isEmpty) return false;
    if (_overviewDescArCtrl.text.trim().isEmpty) return false;
    if (_overviewBtnEnCtrl.text.trim().isEmpty)  return false;
    if (_overviewBtnArCtrl.text.trim().isEmpty)  return false;

    for (final stat in _draft.statistics) {
      final ctrls = _statCtrls[stat.id];
      if (ctrls == null) continue;
      if (ctrls['titleEn']!.text.trim().isEmpty)     return false;
      if (ctrls['titleAr']!.text.trim().isEmpty)     return false;
      if (ctrls['shortDescEn']!.text.trim().isEmpty) return false;
      if (ctrls['shortDescAr']!.text.trim().isEmpty) return false;
      // Icon valid if new bytes picked OR existing URL already saved
      final hasIcon = (_statIcons[stat.id] != null) ||
          (_statIconUrls[stat.id]?.isNotEmpty ?? false);
      if (!hasIcon) return false;
    }
    return true;
  }

  bool get _isPublishEnabled => _hasChanges && !_isSaving && _isFormValid;

  String get _publishTooltip {
    if (_isSaving)    return '';
    if (!_hasChanges) return 'No changes to publish';
    if (!_isFormValid) return 'Please fix validation errors before publishing';
    return '';
  }

  // ── Upload any new icons, then build model with all iconUrls ───────────────
  Future<CareersCmsModel> _buildDraftWithUploads() async {
    for (final stat in _draft.statistics) {
      final newBytes = _statIcons[stat.id];
      if (newBytes != null) {
        final url = await _uploadSvgToStorage(
          statId: stat.id,
          bytes: newBytes,
        );
        _statIconUrls[stat.id] = url;
        _statIcons[stat.id]    = null; // consumed — avoid re-upload
      }
    }

    return _draft.copyWith(
      overview: CareersOverview(
        description: BilingualText(
            en: _overviewDescEnCtrl.text.trim(),
            ar: _overviewDescArCtrl.text.trim()),
        actionButtonLabel: BilingualText(
            en: _overviewBtnEnCtrl.text.trim(),
            ar: _overviewBtnArCtrl.text.trim()),
      ),
      statistics: _draft.statistics.map((s) {
        final m = _statCtrls[s.id];
        if (m == null) return s;
        return s.copyWith(
          title: BilingualText(
              en: m['titleEn']!.text.trim(),
              ar: m['titleAr']!.text.trim()),
          shortDescription: BilingualText(
              en: m['shortDescEn']!.text.trim(),
              ar: m['shortDescAr']!.text.trim()),
          // ✅ This is the key line — save the URL into the model
          iconUrl: _statIconUrls[s.id] ?? s.iconUrl,
        );
      }).toList(),
    );
  }

  // ── Add / remove stat ──────────────────────────────────────────────────────
  void _addStat() {
    final newStat = CareerStatItem.empty();
    setState(() {
      _draft = _draft.copyWith(statistics: [..._draft.statistics, newStat]);
      _initStatCtrl(newStat);
      _statIcons[newStat.id]    = null;
      _statIconUrls[newStat.id] = '';
    });
  }

  void _removeStat(String id) {
    setState(() {
      _draft = _draft.copyWith(
          statistics: _draft.statistics.where((s) => s.id != id).toList());
      final m = _statCtrls.remove(id);
      if (m != null) {
        for (final c in m.values) {
          c.removeListener(_checkForChanges);
          c.dispose();
        }
      }
      _statIcons.remove(id);
      _statIconUrls.remove(id);
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _performSave() async {
    setState(() { _saving = true; _isSaving = true; });
    try {
      final model = await _buildDraftWithUploads(); // ← uploads SVGs first
      await context.read<CareersCmsCubit>().save(model);
      // Navigation is handled by BlocConsumer on CareersCmsSaved
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: _C.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _saving = false; _isSaving = false; });
    }
  }

  Future<void> _handlePublish() async {
    setState(() => _submitted = true);
    if (!_isFormValid) return;

    await showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH CAREERS PAGE',
      subtitle: 'Do you want to publish the changes made to this Careers page?',
      confirmLabel: 'Publish',
      backLabel: 'Back',
      onConfirm: _performSave,
    );
  }

  Future<void> _preview() async {
    setState(() { _saving = true; _submitted = true; });
    try {
      final model = await _buildDraftWithUploads();
      await context.read<CareersCmsCubit>().save(model);
      if (mounted) context.pushNamed('careers-cms-preview');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _discard() {
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

  // ── Field helpers ──────────────────────────────────────────────────────────
  Widget _arField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height   = 36,
    int maxLines    = 1,
    bool isRequired = true,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label:         label,
        hint:          hint,
        controller:    ctrl,
        height:        height,
        maxLines:      maxLines,
        fillColor:     Colors.white,
        textDirection: TextDirection.rtl,
        textAlign:     TextAlign.right,
        primaryColor:  _C.primary,
        submitted:     _submitted,
        isRequired:    isRequired,
      ),
    );
  }

  Widget _enField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height   = 36,
    int maxLines    = 1,
    bool isRequired = true,
  }) {
    return CustomValidatedTextFieldMaster(
      label:         label,
      hint:          hint,
      fillColor:     Colors.white,
      controller:    ctrl,
      height:        height,
      maxLines:      maxLines,
      textDirection: TextDirection.ltr,
      primaryColor:  _C.primary,
      submitted:     _submitted,
      isRequired:    isRequired,
    );
  }

  // ── Icon Upload Widget ─────────────────────────────────────────────────────
  Widget _iconUploadWidget({
    required String statId,
    required String label,
  }) {
    final newBytes = _statIcons[statId];
    final savedUrl = _statIconUrls[statId] ?? '';
    final hasIcon  = newBytes != null || savedUrl.isNotEmpty;
    final hasError = _submitted && !hasIcon;

    Future<void> pickIcon() async {
      final bytes = await _pickSvgFile();
      if (bytes != null) {
        setState(() {
          _statIcons[statId] = bytes;
          _hasChanges = true;
        });
      }
    }

    // Decide what to render inside the circle
    Widget iconContent;
    if (newBytes != null) {
      // Freshly picked — show from memory bytes
      iconContent = Padding(
        padding: EdgeInsets.all(8.r),
        child: SvgPicture.memory(newBytes, fit: BoxFit.contain),
      );
    } else if (savedUrl.isNotEmpty) {
      // Previously saved — show from Firebase Storage URL
      iconContent = Padding(
        padding: EdgeInsets.all(8.r),
        child: SvgPicture.network(savedUrl, fit: BoxFit.contain),
      );
    } else {
      // Empty — show camera placeholder
      iconContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvg(
            assetPath: "assets/control/camera.svg",
            width:  20.w,
            height: 20.h,
            fit:    BoxFit.scaleDown,
            color:  hasError ? _C.red : null,
          ),
          SizedBox(height: 2.h),
        ],
      );
    }

    final Widget circle = Container(
      width:  56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color:  hasError ? _C.red.withOpacity(0.08) : Colors.white,
        shape:  BoxShape.circle,
        border: hasError ? Border.all(color: _C.red, width: 1.5) : null,
      ),
      child: ClipOval(child: iconContent),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(onTap: pickIcon, child: circle),
            Positioned(
              bottom: -4, right: -4,
              child: GestureDetector(
                onTap: pickIcon,
                child: Container(
                  width:  20.w, height: 20.h,
                  decoration: BoxDecoration(
                    color:  _C.primary,
                    shape:  BoxShape.circle,
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
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text('SVG icon is required',
              style: TextStyle(fontSize: 11.sp, color: _C.red)),
        ],
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: _C.back,
        body: const Center(child: CircularProgressIndicator(color: _C.primary)),
      );
    }

    return BlocConsumer<CareersCmsCubit, CareersCmsState>(
      listener: (context, state) {
        // ── Navigate to CareersMainPageMaster on successful save ─────────────
        if (state is CareersCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const CareersMainPageMaster()),
                    (route) => false,
              );
            }
          });
        }
        if (state is CareersCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: _C.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _C.back,
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppAdminNavbar(
                        activeLabel:    'Web Page',
                        homePage:       HomeMainPage(),
                        webPage:        HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(height: 20.h),
                      Container(
                        width:   1000.w,
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editing Main Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color:      _C.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 20.h),

                            // ── Careers Overview ───────────────────────────
                            _accordion(
                              key:   'overview',
                              title: 'Careers Overview',
                              children: [
                                SizedBox(height: 15.h),
                                _enField(
                                  label: 'Description', hint: 'Text Here',
                                  ctrl: _overviewDescEnCtrl,
                                  height: 80, maxLines: 4,
                                ),
                                SizedBox(height: 10.h),
                                _arField(
                                  label: 'الوصف', hint: 'أكتب هنا',
                                  ctrl: _overviewDescArCtrl,
                                  height: 80, maxLines: 4,
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _enField(
                                        label: 'Action Button',
                                        hint:  'Text Here',
                                        ctrl:  _overviewBtnEnCtrl,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: _arField(
                                        label: 'زر الإجراء',
                                        hint:  'أدخل النص',
                                        ctrl:  _overviewBtnArCtrl,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // ── Career Statistics ──────────────────────────
                            _accordion(
                              key:   'statistics',
                              title: 'Career Statistics',
                              children: [
                                SizedBox(height: 15.h),
                                ..._draft.statistics.asMap().entries.map((e) {
                                  final i    = e.key;
                                  final stat = e.value;
                                  final m    = _statCtrls[stat.id]!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (i > 0) SizedBox(height: 12.h),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${_ord(i + 1)} Statistics',
                                              style: StyleText.fontSize16Weight600
                                                  .copyWith(color: _C.labelText)),
                                          GestureDetector(
                                            onTap: () => _removeStat(stat.id),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color:        _C.red,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text('Remove',
                                                  style: StyleText.fontSize12Weight500
                                                      .copyWith(color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      _iconUploadWidget(statId: stat.id, label: 'Icon'),
                                      SizedBox(height: 12.h),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _enField(
                                              label: 'Title', hint: 'Text Here',
                                              ctrl: m['titleEn']!,
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: _arField(
                                              label: 'العنوان', hint: 'أدخل النص',
                                              ctrl: m['titleAr']!,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      _enField(
                                        label: 'Short Description', hint: 'Text Here',
                                        ctrl: m['shortDescEn']!, height: 60, maxLines: 3,
                                      ),
                                      SizedBox(height: 8.h),
                                      _arField(
                                        label: 'وصف مختصر', hint: 'أكتب هنا',
                                        ctrl: m['shortDescAr']!, height: 60, maxLines: 3,
                                      ),
                                      SizedBox(height: 12.h),
                                    ],
                                  );
                                }),

                                GestureDetector(
                                  onTap: _addStat,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 7.h),
                                    decoration: BoxDecoration(
                                      color:        const Color(0xFF797979),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, size: 14.sp, color: Colors.white),
                                        SizedBox(width: 4.w),
                                        Text('Statistics',
                                            style: StyleText.fontSize12Weight500
                                                .copyWith(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            _actionButtons(),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_saving) _buildSavingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: _btn(
                label: 'Preview',
                color: const Color(0xFF608570),
                onTap: _preview),
          ),
          SizedBox(width: 300.w),
          Expanded(
            child: Tooltip(
              message: _publishTooltip,
              child: _btn(
                label:   'Publish',
                color:   _C.primary,
                onTap:   _isPublishEnabled ? _handlePublish : null,
                loading: _saving,
              ),
            ),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(
            child: _btn(
                label: 'Discard',
                color: const Color(0xFF797979),
                onTap: _discard),
          ),
          SizedBox(width: 300.w),
          Expanded(child: const SizedBox()),
        ]),
        if (_submitted && !_isFormValid)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(
              'Please fix validation errors above before publishing',
              style: TextStyle(
                  color: _C.red, fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
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
            width:   double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color:        _C.primary,
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
                color: Colors.white, size: 25.sp,
              ),
            ]),
          ),
        ),
        if (isOpen)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ]),
    );
  }

  // ── Button ─────────────────────────────────────────────────────────────────
  Widget _btn({
    required String label,
    required Color  color,
    VoidCallback?   onTap,
    bool            loading = false,
  }) {
    final bool disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color:        disabled ? color.withOpacity(0.45) : color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : Text(label,
            style: StyleText.fontSize14Weight600
                .copyWith(color: Colors.white)),
      ),
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
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _C.primary),
              SizedBox(height: 12.h),
              Text('Saving...',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   14.sp,
                      color:      Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  String _ord(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}