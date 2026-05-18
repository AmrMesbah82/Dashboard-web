/// ******************* FILE INFO *******************
/// File Name: home_edit_page_master.dart
/// FIXED: _navRoutes undefined → use _navBtns[i].route directly
/// FIXED: link.icon / link.text → access _links[i] via map keys
/// FIXED: dart:html deprecated → replaced with package:web + dart:js_interop
/// UPDATED: Validation gate — Publish dimmed + blocked until all required fields filled
/// UPDATED: showPublishConfirmDialog only — navigation via BlocConsumer (HomeCmsSaved)
/// UPDATED: Navigate to HomeMainPageMaster (pushAndRemoveUntil) after HomeCmsSaved
/// ADDED: Navigation Button accordion UI (add/remove/edit name EN+AR/route dropdown/status toggle)
///
///  ✅ DUAL-DOCUMENT ARCHITECTURE:
///     - "Publish" (no schedule date)  → saves to published doc, deletes draft
///     - "Publish" (with future date)  → saves to draft doc with status='scheduled'
///     - "Save For Later"              → saves to draft doc ONLY (published untouched)
///     - "Discard" (editing draft)     → deletes the draft doc
///     - Schedule mode                 → saves to draft doc with status='scheduled'
/// Last Update: 20/04/2026
/// UPDATED: Dual-document draft system ✅

import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:ui' as ui;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';


import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/custom_dropdwon.dart';
import '../../../../../core/widget/date_pic.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/model/home_model.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import 'home_main.dart';
import 'home_preview.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
  static const Color scheduled = Color(0xFFFF8F00);
  static const Color error = Color(0xFFE53935);
  static const Color draftBadge = Color(0xFFF59E0B);
}

const List<String> _kSectionTitles = [
  'Section 1 - Left',
  'Section 2 - Left Corner',
  'Section 3 - Right',
  'Section 4 - Right Corner',
];

const List<Map<String, String>> _kNavRouteOptions = [
  {'label': 'Home', 'route': '/'},
  {'label': 'Services', 'route': '/services'},
  {'label': 'About', 'route': '/about'},
  {'label': 'Contact Us', 'route': '/contact'},
  {'label': 'Careers', 'route': '/careers'},
];

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class _NavBtnItem {
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  String? route;
  bool status;

  _NavBtnItem()
    : nameEn = TextEditingController(),
      nameAr = TextEditingController(),
      status = true;

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

class _SectionItem {
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage image;
  _PickedImage icon;
  bool visibility;

  _SectionItem()
    : descEn = TextEditingController(),
      descAr = TextEditingController(),
      image = const _PickedImage(),
      icon = const _PickedImage(),
      visibility = true;

  void dispose() {
    descEn.dispose();
    descAr.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color Picker (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _ColorPickerField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final VoidCallback? onColorChanged;

  const _ColorPickerField({
    required this.controller,
    this.label,
    this.hintText = '#008037',
    this.onColorChanged,
  });

  @override
  State<_ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<_ColorPickerField> {
  OverlayEntry? _overlay;
  final LayerLink _layerLink = LayerLink();

  Color get _currentColor {
    try {
      final hex = widget.controller.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  static String _colorToHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}'
              '${c.green.toRadixString(16).padLeft(2, '0')}'
              '${c.blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();

  void _openPicker() {
    _closePicker();
    _overlay = OverlayEntry(
      builder: (_) => _ColorWheelOverlay(
        layerLink: _layerLink,
        initialColor: _currentColor,
        onApply: (color) {
          widget.controller.text = _colorToHex(color);
          widget.controller.notifyListeners();
          _closePicker();
          if (mounted) setState(() {});
          widget.onColorChanged?.call();
        },
        onClose: _closePicker,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _closePicker() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _closePicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
          ),
          SizedBox(height: 5.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            height: 36.h,
            child: TextFormField(
              controller: widget.controller,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
              ),
              onChanged: (_) {
                setState(() {});
                widget.onColorChanged?.call();
              },
              onTap: _openPicker,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: StyleText.fontSize12Weight400.copyWith(
                  color: _C.hintText,
                ),
                filled: true,
                fillColor: AppColors.background,
                isDense: true,
                counterText: '',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.border),
                    ),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 36.w,
                  minHeight: 36.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorWheelOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final Color initialColor;
  final ValueChanged<Color> onApply;
  final VoidCallback onClose;
  const _ColorWheelOverlay({
    required this.layerLink,
    required this.initialColor,
    required this.onApply,
    required this.onClose,
  });
  @override
  State<_ColorWheelOverlay> createState() => _ColorWheelOverlayState();
}

class _ColorWheelOverlayState extends State<_ColorWheelOverlay> {
  late Color _picked;
  @override
  void initState() {
    super.initState();
    _picked = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                maxWidth: 500.w,
              ),
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _C.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Color',
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: _C.labelText,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ColorPicker(
                        pickerColor: _picked,
                        onColorChanged: (c) => setState(() => _picked = c),
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: false,
                        displayThumbColor: true,
                        pickerAreaBorderRadius: BorderRadius.circular(8.r),
                        hexInputBar: true,
                        labelTypes: const [],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: _C.border),
                              ),
                              child: Text(
                                'Cancel',
                                style: StyleText.fontSize14Weight500.copyWith(
                                  color: _C.labelText,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () => widget.onApply(_picked),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'Apply',
                                style: StyleText.fontSize14Weight500.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeEditPageMaster
// ─────────────────────────────────────────────────────────────────────────────

class HomeEditPageMaster extends StatefulWidget {
  const HomeEditPageMaster({super.key});
  @override
  State<HomeEditPageMaster> createState() => _HomeEditPageMasterState();
}

class _HomeEditPageMasterState extends State<HomeEditPageMaster> {
  bool _submitted = false;
  bool _isSaving = false;

  /// Whether the data currently loaded came from a draft document.
  bool _isEditingDraft = false;

  final _titleEn = TextEditingController();
  final _titleAr = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();
  final List<_NavBtnItem> _navBtns = [];
  final List<_SectionItem> _sections = List.generate(4, (_) => _SectionItem());
  late final List<Map<String, dynamic>> _footerColumns;
  final List<Map<String, dynamic>> _links = [];
  _PickedImage _logoPicked = const _PickedImage();
  final _primaryColor = TextEditingController(text: '#008037');
  final _secondaryColor = TextEditingController(text: '#4049B9');
  String? _engFont = 'Cairo';
  String? _arFont = 'Cairo';
  final _copyRightEn = TextEditingController(
    text: 'COPYRIGHT © 2025 BAYANATZ. ALL-RIGHT RESERVED',
  );
  final _copyRightAr = TextEditingController();
  DateTime? _publishDate;

  final Map<String, bool> _open = {
    'headings': true,
    'navButtons': true,
    's0': true,
    's1': true,
    's2': true,
    's3': true,
    'links': true,
    'schedule': true,
  };

  int? _seededModelHash;

  Color get _resolvedPrimary {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  bool get _isFormValid {
    if (_titleEn.text.trim().isEmpty || _titleAr.text.trim().isEmpty)
      return false;
    if (_shortDescEn.text.trim().isEmpty || _shortDescAr.text.trim().isEmpty)
      return false;
    final hasArabicInEn = RegExp(r'[\u0600-\u06FF]');
    final hasEnglishInAr = RegExp(r'[a-zA-Z]');
    if (hasArabicInEn.hasMatch(_titleEn.text) ||
        hasArabicInEn.hasMatch(_shortDescEn.text))
      return false;
    if (hasEnglishInAr.hasMatch(_titleAr.text) ||
        hasEnglishInAr.hasMatch(_shortDescAr.text))
      return false;
    for (final sec in _sections) {
      if (sec.descEn.text.trim().isEmpty || sec.descAr.text.trim().isEmpty)
        return false;
      if (sec.image.isEmpty || sec.icon.isEmpty) return false;
      if (hasArabicInEn.hasMatch(sec.descEn.text) ||
          hasEnglishInAr.hasMatch(sec.descAr.text))
        return false;
    }
    return true;
  }

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    for (final ctrl in [_titleEn, _titleAr, _shortDescEn, _shortDescAr])
      ctrl.addListener(_onFieldChanged);
    for (final sec in _sections) {
      sec.descEn.addListener(_onFieldChanged);
      sec.descAr.addListener(_onFieldChanged);
    }
  }

  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.svg,image/svg+xml';
    void complete(_PickedImage? val) {
      if (!completed) {
        completed = true;
        completer.complete(val);
      }
    }

    input.addEventListener(
      'change',
      (web.Event _) {
        final files = input.files;
        if (files == null || files.length == 0) {
          complete(null);
          return;
        }
        final file = files.item(0)!;
        if (!file.name.toLowerCase().endsWith('.svg') &&
            file.type != 'image/svg+xml') {
          complete(null);
          if (mounted) {
            showConfirmDialog(
              context: context,
              title: 'Invalid File',
              subtitle: 'Only SVG files are allowed',
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
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 36.r,
                ),
              ),
            );
          }
          return;
        }
        final reader = web.FileReader();
        reader.addEventListener(
          'loadend',
          (web.Event _) {
            final result = reader.result;
            if (result != null) {
              try {
                complete(
                  _PickedImage(
                    bytes: Uint8List.view((result as JSArrayBuffer).toDart),
                  ),
                );
              } catch (_) {
                complete(null);
              }
            } else {
              complete(null);
            }
          }.toJS,
        );
        reader.addEventListener(
          'error',
          ((web.Event _) => complete(null)).toJS,
        );
        reader.readAsArrayBuffer(file);
      }.toJS,
    );
    input.click();
    Future.delayed(const Duration(minutes: 5), () => complete(null));
    return completer.future;
  }

  void _seedFromModel(HomePageModel d, {bool isFromDraft = false}) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.navButtons.map((b) => b.name.en + b.route + b.status.toString()),
      ...d.sections.map(
        (s) => s.imageUrl + s.iconUrl + s.visibility.toString(),
      ),
      ...d.socialLinks.map((s) => s.iconUrl + s.visibility.toString()),
      d.branding.logoUrl,
      d.scheduledPublishDate?.toIso8601String() ?? '',
    ]);
    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;
    _isEditingDraft = isFromDraft;

    _titleEn.text = d.title.en;
    _titleAr.text = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    for (final nb in _navBtns) nb.dispose();
    _navBtns.clear();
    for (final btn in d.navButtons) {
      final item = _NavBtnItem();
      item.nameEn.text = btn.name.en;
      item.nameAr.text = btn.name.ar;
      item.route = btn.route.isEmpty ? null : btn.route;
      item.status = btn.status;
      _navBtns.add(item);
    }

    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i].descEn.text = d.sections[i].description.en;
      _sections[i].descAr.text = d.sections[i].description.ar;
      _sections[i].image = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sections[i].icon = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
      _sections[i].visibility = d.sections[i].visibility;
    }

    _primaryColor.text = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _engFont = d.branding.englishFont.isEmpty
        ? 'Cairo'
        : d.branding.englishFont;
    _arFont = d.branding.arabicFont.isEmpty ? 'Cairo' : d.branding.arabicFont;
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();

    while (_footerColumns.length > d.footerColumns.length)
      _disposeColumn(_footerColumns.removeLast());
    while (_footerColumns.length < d.footerColumns.length)
      _footerColumns.add(_newFooterColumn());
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text =
          d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text =
          d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] = d.footerColumns[i].route.isEmpty
          ? null
          : d.footerColumns[i].route;
      final labels =
          _footerColumns[i]['labels']
              as List<Map<String, TextEditingController>>;
      while (labels.length > d.footerColumns[i].labels.length)
        _disposeLabel(labels.removeLast());
      while (labels.length < d.footerColumns[i].labels.length)
        labels.add(_newLabelRow());
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        labels[li]['en']!.text = d.footerColumns[i].labels[li].label.en;
        labels[li]['ar']!.text = d.footerColumns[i].labels[li].label.ar;
      }
    }

    for (final l in _links) (l['text'] as TextEditingController).dispose();
    _links.clear();
    for (final sl in d.socialLinks) {
      _links.add({
        'text': TextEditingController(text: sl.url),
        'icon': sl.iconUrl.isNotEmpty
            ? _PickedImage(url: sl.iconUrl)
            : const _PickedImage(),
        'visibility': sl.visibility,
      });
    }

    _publishDate = d.scheduledPublishDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route': null as String?,
    'labels': <Map<String, TextEditingController>>[_newLabelRow()],
  };
  Map<String, TextEditingController> _newLabelRow() => {
    'en': TextEditingController(),
    'ar': TextEditingController(),
  };
  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, TextEditingController>>) {
      l['en']!.dispose();
      l['ar']!.dispose();
    }
  }

  void _disposeLabel(Map<String, TextEditingController> label) {
    label['en']!.dispose();
    label['ar']!.dispose();
  }

  @override
  void dispose() {
    for (final ctrl in [_titleEn, _titleAr, _shortDescEn, _shortDescAr]) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final nb in _navBtns) nb.dispose();
    for (final s in _sections) {
      s.descEn.removeListener(_onFieldChanged);
      s.descAr.removeListener(_onFieldChanged);
      s.dispose();
    }
    for (final col in _footerColumns) _disposeColumn(col);
    for (final l in _links) (l['text'] as TextEditingController).dispose();
    _primaryColor.dispose();
    _secondaryColor.dispose();
    _copyRightEn.dispose();
    _copyRightAr.dispose();
    super.dispose();
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(
    HomeCmsCubit cubit, {
    String publishStatus = 'published',
    DateTime? scheduledPublishDate,
  }) async {
    // Only validate fully for 'published' — drafts can be partial
    if (publishStatus == 'published') {
      setState(() => _submitted = true);
      if (!_isFormValid) return;
    }

    setState(() => _isSaving = true);
    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(
        en: _shortDescEn.text,
        ar: _shortDescAr.text,
      );

      // ── Sync nav buttons ──────────────────────────────────────────────
      while (cubit.current.navButtons.length > _navBtns.length)
        cubit.removeNavButton(cubit.current.navButtons.last.id);
      while (cubit.current.navButtons.length < _navBtns.length)
        cubit.addNavButton();
      for (var i = 0; i < _navBtns.length; i++) {
        if (i < cubit.current.navButtons.length) {
          final id = cubit.current.navButtons[i].id;
          cubit.updateNavButtonName(
            id,
            en: _navBtns[i].nameEn.text,
            ar: _navBtns[i].nameAr.text,
          );
          cubit.updateNavButtonRoute(id, _navBtns[i].route ?? '');
          if (cubit.current.navButtons[i].status != _navBtns[i].status)
            cubit.toggleNavButtonStatus(id);
        }
      }

      for (var i = 0; i < _sections.length; i++) {
        cubit.updateSectionDescription(
          i,
          en: _sections[i].descEn.text,
          ar: _sections[i].descAr.text,
        );
        cubit.updateSectionVisibility(i, _sections[i].visibility);
        if (_sections[i].image.bytes != null)
          await cubit.uploadSectionImage(i, _sections[i].image.bytes!);
        if (_sections[i].icon.bytes != null)
          await cubit.uploadSectionIcon(i, _sections[i].icon.bytes!);
      }

      while (cubit.current.footerColumns.length < _footerColumns.length)
        cubit.addFooterColumn();
      while (cubit.current.footerColumns.length > _footerColumns.length)
        cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
      for (var i = 0; i < _footerColumns.length; i++) {
        final colId = cubit.current.footerColumns[i].id;
        cubit.updateFooterColumnTitle(
          colId,
          en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
          ar: (_footerColumns[i]['titleAr'] as TextEditingController).text,
        );
        cubit.updateFooterColumnRoute(
          colId,
          _footerColumns[i]['route'] as String? ?? '',
        );
        final labels =
            _footerColumns[i]['labels']
                as List<Map<String, TextEditingController>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length)
          cubit.addFooterLabel(colId);
        while (cubit.current.footerColumns[i].labels.length > labels.length)
          cubit.removeFooterLabel(
            colId,
            cubit.current.footerColumns[i].labels.last.id,
          );
        for (var li = 0; li < labels.length; li++) {
          final lblId = cubit.current.footerColumns[i].labels[li].id;
          cubit.updateFooterLabel(
            colId,
            lblId,
            en: labels[li]['en']!.text,
            ar: labels[li]['ar']!.text,
          );
        }
      }

      while (cubit.current.socialLinks.length < _links.length)
        cubit.addSocialLink();
      while (cubit.current.socialLinks.length > _links.length)
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(
          id,
          url: (_links[i]['text'] as TextEditingController).text,
          visibility: _links[i]['visibility'] as bool? ?? true,
        );
        final icon = _links[i]['icon'] as _PickedImage;
        if (icon.bytes != null)
          await cubit.uploadSocialLinkIcon(id, icon.bytes!);
      }

      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont ?? 'Cairo');

      // ── Determine final status ────────────────────────────────────────
      String finalStatus = publishStatus;
      DateTime? finalScheduleDate = scheduledPublishDate;

      if (publishStatus == 'published' &&
          _publishDate != null &&
          _publishDate!.isAfter(DateTime.now())) {
        finalStatus = 'scheduled';
        finalScheduleDate = _publishDate;
        print(
          '[HomeEditPage] _save: 📅 schedule date is in the future → overriding to "scheduled"',
        );
      }

      await cubit.save(
        publishStatus: finalStatus,
        scheduledPublishDate: finalScheduleDate,
      );
    } catch (e, st) {
      print('[HomeEditPage] _save ❌ $e\n$st');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        print('[HomeEditPage] 👂 listener: ${state.runtimeType}');

        // ── Published successfully ──────────────────────────────────────
        if (state is HomeCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        // ── Draft saved successfully ────────────────────────────────────
        if (state is HomeCmsDraftSaved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.data.publishStatus == 'scheduled'
                      ? 'Scheduled draft saved! Published version is still live.'
                      : 'Draft saved! Published version is still live.',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: _C.draftBadge,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        // ── Draft deleted (discard) ─────────────────────────────────────
        if (state is HomeCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        if (state is HomeCmsError) {
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
      },
      builder: (context, state) {
        if (state is HomeCmsLoaded)
          _seedFromModel(state.data, isFromDraft: state.isFromDraft);
        if (state is HomeCmsSaved) _seedFromModel(state.data);

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel: 'Web Page',
                    homePage: CareersMainPageDashboard(),
                    webPage: HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 1),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        // ── Title row with draft badge ─────────────────────
                        Row(
                          children: [
                            Text(
                              'Editing Home',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_isEditingDraft) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.draftBadge.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'EDITING DRAFT',
                                  style: StyleText.fontSize12Weight600.copyWith(
                                    color: _C.draftBadge,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_isEditingDraft)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'You are editing a saved draft. The published version is still live.',
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: _C.hintText,
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),

                        _accordion(
                          key: 'headings',
                          title: 'Headings',
                          children: [
                            SizedBox(height: 16.h),
                            _headingsSection(),
                          ],
                        ),
                        _gap(),
                        _accordion(
                          key: 'navButtons',
                          title: 'Navigation Button',
                          children: [
                            _navButtonsSection(),
                          ],
                        ),
                        _gap(),
                        ...List.generate(
                          4,
                          (i) => Column(
                            children: [
                              _accordion(
                                key: 's$i',
                                title: _kSectionTitles[i],
                                children: [_sectionEdit(i)],
                              ),
                              _gap(),
                            ],
                          ),
                        ),
                        _accordion(
                          key: 'schedule',
                          title: 'Publish Schedule',
                          children: [_publishScheduleSection()],
                        ),
                        _gap(),
                        _bottomButtons(cubit),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Headings ──────────────────────────────────────────────────────────────
  Widget _headingsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'Title',
              hint: 'Text Here',
              isRequired: true,
              controller: _titleEn,
              height: 40,
              fillColor: Colors.white,
              submitted: _submitted,
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.left,
              primaryColor: _resolvedPrimary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'العنوان',
                isRequired: true,
                hint: 'أكتب هنا',
                controller: _titleAr,
                fillColor: Colors.white,
                height: 40,
                submitted: _submitted,
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.right,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 16.h),
      CustomValidatedTextFieldMaster(
        label: 'Short Description',
        hint: 'Text Here',
        isRequired: true,
        controller: _shortDescEn,
        height: 80,
        maxLines: 3,
        submitted: _submitted,
        textDirection: ui.TextDirection.ltr,
        fillColor: Colors.white,
        textAlign: TextAlign.left,
        primaryColor: _resolvedPrimary,
      ),
      SizedBox(height: 16.h),
      Directionality(
        textDirection: ui.TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'وصف مختصر',
          hint: 'أكتب هنا',
          isRequired: true,
          fillColor: Colors.white,
          controller: _shortDescAr,
          height: 80,
          maxLines: 3,
          submitted: _submitted,
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: _resolvedPrimary,
        ),
      ),
    ],
  );

  Widget _navButtonsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...List.generate(_navBtns.length, (i) {
        final btn = _navBtns[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_ordinal(i + 1)} Button',
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: _C.labelText,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _navBtns[i].dispose();
                    _navBtns.removeAt(i);
                  }),
                  child: Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: 'Button Name',
                    hint: 'Text Here',
                    controller: btn.nameEn,
                    height: 40,
                    fillColor: Colors.white,
                    submitted: _submitted,
                    textDirection: ui.TextDirection.ltr,
                    textAlign: TextAlign.left,
                    primaryColor: _resolvedPrimary,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: CustomValidatedTextFieldMaster(
                      label: 'عنوان الزر',
                      hint: 'أكتب هنا',
                      controller: btn.nameAr,
                      height: 40,
                      fillColor: Colors.white,
                      submitted: _submitted,
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.right,
                      primaryColor: _resolvedPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomDropdownFormFieldInvMaster(
                    label: 'Button Navigation',
                    selectedValue:
                    _kNavRouteOptions.any((o) => o['route'] == btn.route)
                        ? btn.route
                        : null,
                    items: _kNavRouteOptions
                        .map(
                          (opt) => {
                        'key': opt['route']!,
                        'value': opt['label']!,
                      },
                    )
                        .toList(),
                    onChanged: (val) => setState(() => btn.route = val),
                    hint: Text(
                      'Select',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: _C.hintText,
                      ),
                    ),
                    widthIcon: 18,
                    heightIcon: 18,
                    height: 36,
                    dropdownColor: Colors.white,
                    primaryColor: _resolvedPrimary,
                    borderRadius: 4,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(child: SizedBox()),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        );
      }),
      if (_navBtns.length < 5)
        GestureDetector(
          onTap: () => setState(() => _navBtns.add(_NavBtnItem())),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  'Button',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _sectionEdit(int i) {
    final sec = _sections[i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: _C.labelText,
                  ),
                ),
                SizedBox(height: 6.h),
                _imgBox(
                  picked: sec.image,
                  onPick: () async {
                    final p = await _pickImage();
                    if (p != null) setState(() => sec.image = p);
                  },
                ),
                if (_submitted && sec.image.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'Image (SVG) required',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: _C.error,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 24.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Icon',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: _C.labelText,
                  ),
                ),
                SizedBox(height: 6.h),
                _imgBox(
                  picked: sec.icon,
                  isAdd: true,
                  onPick: () async {
                    final p = await _pickImage();
                    if (p != null) setState(() => sec.icon = p);
                  },
                ),
                if (_submitted && sec.icon.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'Icon (SVG) required',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: _C.error,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Visibility',
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: _C.labelText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    FlutterSwitch(
                      width: 35.sp,
                      height: 22.sp,
                      padding: 3.sp,
                      borderRadius: 20.sp,
                      toggleSize: 14.sp,
                      activeColor: _C.primary,
                      inactiveColor: Colors.grey.withOpacity(.16),
                      value: sec.visibility,
                      onToggle: (val) => setState(() => sec.visibility = val),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        CustomValidatedTextFieldMaster(
          label: 'Description',
          isRequired: true,
          hint: 'Text Here',
          controller: sec.descEn,
          maxLength: 500,
          showCharCount: true,
          height: 80,
          maxLines: 3,
          submitted: _submitted,
          fillColor: Colors.white,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.left,
          primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 16.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف',
            hint: 'أكتب هنا',
            isRequired: true,
            controller: sec.descAr,
            maxLength: 500,
            showCharCount: true,
            height: 80,
            maxLines: 3,
            fillColor: Colors.white,
            submitted: _submitted,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ],
    );
  }

  Widget _imgBox({
    required _PickedImage picked,
    bool isAdd = false,
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(
              picked.bytes!,
              width: 30.w,
              height: 30.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(
              picked.url!,
              width: 30.w,
              height: 30.h,
              fit: BoxFit.contain,
              placeholderBuilder: (_) =>
                  const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w,
        height: 60.h,
        decoration: const BoxDecoration(
          color: Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            isAdd ? Icons.add : Icons.image_outlined,
            color: Colors.grey,
            size: 22.sp,
          ),
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 25.w,
              height: 25.h,
              decoration: BoxDecoration(
                color: _C.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: 'assets/control/camera.svg',
                  width: 10.w,
                  height: 10.h,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _publishScheduleSection() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Publish Date',
              style: StyleText.fontSize12Weight500.copyWith(
                color: _C.labelText,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // Use the DatePicker class instead of showDatePicker
                      final picker = DatePicker();
                      final picked = await picker.showDatePicker(
                        context,
                        _publishDate != null ? [_publishDate] : [],
                        _publishDate ?? DateTime.now(),
                        CalendarDatePicker2Type.single,
                        firstDate: DateTime.now(),
                      );

                      if (picked != null &&
                          picked.isNotEmpty &&
                          picked.first != null) {
                        setState(() => _publishDate = picked.first);
                      }
                    },
                    child: Container(
                      height: 36.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _publishDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_publishDate!)
                                  : 'Select Date',
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: _publishDate != null
                                    ? _C.labelText
                                    : _C.hintText,
                              ),
                            ),
                          ),
                          CustomSvg(
                            assetPath: 'assets/control/Calendar.svg',
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.scaleDown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_publishDate != null) ...[
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _publishDate = null),
                    child: Container(
                      height: 36.h,
                      width: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      SizedBox(width: 15.sp),
      Expanded(child: Container()),
    ],
  );

  // ── Bottom buttons ────────────────────────────────────────────────────────
  Widget _bottomButtons(HomeCmsCubit cubit) {
    final bool canPublish = _isFormValid;
    final bool isScheduled =
        _publishDate != null && _publishDate!.isAfter(DateTime.now());

    return Column(
      children: [
        Row(
          children: [
            // Preview
            Expanded(
              child: GestureDetector(
                onTap: () => navigateTo(context, HomePreviewPageMaster()),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF608570),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Preview',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            // Publish / Schedule
            Expanded(
              child: AbsorbPointer(
                absorbing: !canPublish || _isSaving,
                child: Opacity(
                  opacity: (canPublish && !_isSaving) ? 1.0 : 0.6,
                  child: GestureDetector(
                    onTap: () {
                      if (!canPublish) {
                        setState(() => _submitted = true);
                        return;
                      }
                      showPublishConfirmDialog(
                        context: context,
                        title: isScheduled ? 'SCHEDULE PAGE' : 'PUBLISH PAGE',
                        subtitle: isScheduled
                            ? 'Your changes will be scheduled for ${DateFormat('dd/MM/yyyy').format(_publishDate!)}. The published version will remain live until then.'
                            : 'Do you want to publish this page now?',
                        confirmLabel: isScheduled ? 'Schedule' : 'Publish',
                        onConfirm: () => _save(
                          cubit,
                          publishStatus: 'published',
                          scheduledPublishDate: _publishDate,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: _isSaving
                            ? (isScheduled
                                  ? _C.scheduled.withOpacity(0.5)
                                  : _C.primary.withOpacity(0.5))
                            : (isScheduled ? _C.scheduled : _C.primary),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          isScheduled ? 'Schedule' : 'Publish',
                          style: StyleText.fontSize14Weight600.copyWith(
                            color: Colors.white.withOpacity(
                              (canPublish && !_isSaving) ? 1.0 : 0.55,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            // ── Discard ────────────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isEditingDraft) {
                    showPublishConfirmDialog(
                      context: context,
                      title: 'DISCARD DRAFT',
                      subtitle:
                          'Are you sure you want to discard this draft? The published version will remain unchanged.',
                      confirmLabel: 'Discard',
                      onConfirm: () => cubit.discardDraft(),
                    );
                  } else {
                    showConfirmDialog(
                      context: context,
                      title: 'Discard Changes',
                      subtitle: 'Are you sure you want to discard all changes?',
                      confirmLabel: 'Discard',
                      cancelLabel: 'Cancel',
                      onConfirm: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeMainPageMaster(),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF797979),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Discard',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            // ── Save For Later ────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: _isSaving
                    ? null
                    : () {
                        showPublishConfirmDialog(
                          context: context,
                          title: 'SAVE AS DRAFT',
                          subtitle:
                              'Your changes will be saved as a draft. The published version will remain live and unchanged.',
                          confirmLabel: 'Save Draft',
                          onConfirm: () => _save(cubit, publishStatus: 'draft'),
                        );
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _isSaving ? Colors.grey.shade400 : Color(0xFF525252),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Save For Later',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize14Weight600.copyWith(
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
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _gap() => SizedBox(height: 10.h);
}
