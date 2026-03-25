/// ******************* FILE INFO *******************
/// File Name: home_page_editor.dart
/// Created by: Amr Mesbah

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
}

enum ImgEditBtnPos { bottomRight, bottomCenter, bottomLeft }

const List<Map<String, String>> _kRoutes = [
  {'key': '',          'value': 'None'},
  {'key': '/',         'value': 'Home (/)'},
  {'key': '/services', 'value': 'Services (/services)'},
  {'key': '/about',    'value': 'About Us (/about)'},
  {'key': '/contact',  'value': 'Contact Us (/contact)'},
  {'key': '/careers',  'value': 'Careers (/careers)'},
  {'key': '/jobs',     'value': 'Jobs (/jobs)'},
];

const List<Map<String, String>> _kFonts = [
  {'key': 'Cairo',     'value': 'Cairo'},
  {'key': 'Roboto',    'value': 'Roboto'},
  {'key': 'Poppins',   'value': 'Poppins'},
  {'key': 'Tajawal',   'value': 'Tajawal'},
  {'key': 'Almarai',   'value': 'Almarai'},
  {'key': 'Noto Sans', 'value': 'Noto Sans'},
];

class _HeaderItem {
  final TextEditingController en;
  final TextEditingController ar;
  bool status;
  final String id;

  _HeaderItem({required this.id})
      : en     = TextEditingController(),
        ar     = TextEditingController(),
        status = true;

  void dispose() { en.dispose(); ar.dispose(); }
}

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

// ── Link Item (dynamic) ───────────────────────────────────────────────────────
class _LinkItem {
  final TextEditingController text;
  _PickedImage icon;

  _LinkItem()
      : text = TextEditingController(),
        icon = const _PickedImage();

  void dispose() { text.dispose(); }
}

// ── Color Picker Field ────────────────────────────────────────────────────────
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
          '${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  void _openPicker() {
    _closePicker();
    _overlay = OverlayEntry(
      builder: (_) => _ColorWheelOverlay(
        layerLink:    _layerLink,
        initialColor: _currentColor,
        onApply: (color) {
          widget.controller.text = _colorToHex(color);
          // ignore: invalid_use_of_protected_member
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

  void _closePicker() { _overlay?.remove(); _overlay = null; }

  @override
  void dispose() { _closePicker(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          SizedBox(height: 5.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            height: 36.h,
            child: TextFormField(
              controller: widget.controller,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged: (_) { setState(() {}); widget.onColorChanged?.call(); },
              onTap: _openPicker,
              decoration: InputDecoration(
                hintText:  widget.hintText,
                hintStyle: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
                filled: true, fillColor: AppColors.background,
                isDense: true, counterText: '',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    width: 16.w, height: 16.h,
                    decoration: BoxDecoration(color: _currentColor, shape: BoxShape.circle, border: Border.all(color: _C.border)),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: BorderSide(color: AppColors.primary, width: 1)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: Colors.transparent)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Color Wheel Overlay ───────────────────────────────────────────────────────
class _ColorWheelOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final Color initialColor;
  final ValueChanged<Color> onApply;
  final VoidCallback onClose;

  const _ColorWheelOverlay({
    required this.layerLink, required this.initialColor,
    required this.onApply,   required this.onClose,
  });

  @override
  State<_ColorWheelOverlay> createState() => _ColorWheelOverlayState();
}

class _ColorWheelOverlayState extends State<_ColorWheelOverlay> {
  late Color _picked;

  @override
  void initState() { super.initState(); _picked = widget.initialColor; }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: GestureDetector(
              onTap: widget.onClose,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black.withOpacity(0.3))
          )
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
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8)
                    )
                  ],
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Color',
                        style: StyleText.fontSize16Weight600.copyWith(color: _C.labelText),
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
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(color: _C.border)
                                ),
                                child: Text('Cancel',
                                    style: StyleText.fontSize14Weight500.copyWith(color: _C.labelText)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () => widget.onApply(_picked),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius: BorderRadius.circular(6.r)
                                ),
                                child: Text('Apply',
                                    style: StyleText.fontSize14Weight500.copyWith(color: Colors.white)),
                              ),
                            ),
                          ]
                      ),
                    ]
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class HomePageEditor extends StatefulWidget {
  const HomePageEditor({super.key});
  @override
  State<HomePageEditor> createState() => _HomePageEditorState();
}

class _HomePageEditorState extends State<HomePageEditor> {

  bool _submitted  = false;
  bool _isSaving   = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.of(
    List.generate(3, (_) => {'nameEn': TextEditingController(), 'nameAr': TextEditingController()}),
  );
  final List<String?> _navRoutes = List.of([null, null, null]);

  // ── Sections 1-4 ──────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections = List.generate(4, (_) => {
    'textBox':       TextEditingController(text: '#008037'),
    'description':   TextEditingController(),
    'descriptionAr': TextEditingController(),
  });

  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4, (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Header titles ─────────────────────────────────────────────────────────
  late final List<_HeaderItem> _headerItems;

  // ── Footer columns ────────────────────────────────────────────────────────
  late final List<Map<String, dynamic>> _footerColumns;

  // ── Links (dynamic) ───────────────────────────────────────────────────────
  late final List<_LinkItem> _links;

  // ── Logo ──────────────────────────────────────────────────────────────────
  _PickedImage _logoPicked = const _PickedImage();

  // ── Branding ──────────────────────────────────────────────────────────────
  final _primaryColor   = TextEditingController(text: '#008037');
  final _secondaryColor = TextEditingController(text: '#4049B9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';
  final _copyRightEn = TextEditingController(text: 'COPYRIGHT © 2025 BAYANATZ. ALL-RIGHT RESERVED');
  final _copyRightAr = TextEditingController();

  // ── Collapse state ────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'headings': true, 'navBtn': true,
    's1': true, 's2': true, 's3': true, 's4': true,
    'header': true, 'footer': true, 'links': true, 'logo': true,
  };

  int _selectedTab = 0;

  // ── Seed tracking ─────────────────────────────────────────────────────────
  int? _seededModelHash;

  // ── Resolved primary color from branding picker ───────────────────────────
  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  @override
  void initState() {
    super.initState();
    _seededModelHash = null;
    _headerItems   = List.generate(5, (i) => _HeaderItem(id: 'hi_$i'));
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links = List.generate(4, (_) => _LinkItem());
  }

  // ── Image picking (SVG only) ───────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      final file = files.first;

      if (!file.name.toLowerCase().endsWith('.svg') && file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Only SVG files are allowed',
                  style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ));
          }
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is List<int>) {
            completer.complete(_PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) { completed = true; completer.complete(null); }
    });

    return completer.future;
  }

  // ── Seed controllers from model ────────────────────────────────────────────
  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en, d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      ...d.socialLinks.map((s) => s.iconUrl),
      d.branding.logoUrl,
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    // Nav buttons
    while (_navBtns.length > d.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose(); removed['nameAr']!.dispose();
      _navRoutes.removeLast();
    }
    while (_navBtns.length < d.navButtons.length) {
      _navBtns.add({'nameEn': TextEditingController(), 'nameAr': TextEditingController()});
      _navRoutes.add(null);
    }
    for (var i = 0; i < d.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = d.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = d.navButtons[i].name.ar;
      _navRoutes[i] = d.navButtons[i].route.isEmpty ? null : d.navButtons[i].route;
    }

    // Sections
    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i]['textBox']!.text       = d.sections[i].textBoxColor;
      _sections[i]['description']!.text   = d.sections[i].description.en;
      _sections[i]['descriptionAr']!.text = d.sections[i].description.ar;

      _sectionImages[i]['image'] = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sectionImages[i]['icon'] = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
    }

    // Header items
    for (var i = 0; i < _headerItems.length && i < d.headerItems.length; i++) {
      _headerItems[i].en.text = d.headerItems[i].title.en;
      _headerItems[i].ar.text = d.headerItems[i].title.ar;
      _headerItems[i].status  = d.headerItems[i].status;
    }

    // Footer columns
    while (_footerColumns.length > d.footerColumns.length) {
      final removed = _footerColumns.removeLast();
      _disposeColumn(removed);
    }
    while (_footerColumns.length < d.footerColumns.length) {
      _footerColumns.add(_newFooterColumn());
    }
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text = d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text = d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] = d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;

      final labels = _footerColumns[i]['labels'] as List<Map<String, TextEditingController>>;
      while (labels.length > d.footerColumns[i].labels.length) _disposeLabel(labels.removeLast());
      while (labels.length < d.footerColumns[i].labels.length) labels.add(_newLabelRow());
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        labels[li]['en']!.text = d.footerColumns[i].labels[li].label.en;
        labels[li]['ar']!.text = d.footerColumns[i].labels[li].label.ar;
      }
    }

    // Links
    while (_links.length > d.socialLinks.length) {
      _links.removeLast().dispose();
    }
    while (_links.length < d.socialLinks.length) {
      _links.add(_LinkItem());
    }
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
    }

    // Branding
    _primaryColor.text   = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _engFont             = d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont              = d.branding.arabicFont.isEmpty  ? 'Cairo' : d.branding.arabicFont;


    // Logo
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();
  }

  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route':   null as String?,
    'labels':  <Map<String, TextEditingController>>[_newLabelRow()],
  };

  Map<String, TextEditingController> _newLabelRow() => {
    'en': TextEditingController(),
    'ar': TextEditingController(),
  };

  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, TextEditingController>>) {
      l['en']!.dispose(); l['ar']!.dispose();
    }
  }

  void _disposeLabel(Map<String, TextEditingController> label) {
    label['en']!.dispose(); label['ar']!.dispose();
  }

  @override
  void dispose() {
    _titleEn.dispose(); _titleAr.dispose();
    _shortDescEn.dispose(); _shortDescAr.dispose();
    for (final m in [..._navBtns, ..._sections]) {
      for (final c in m.values) c.dispose();
    }
    for (final item in _headerItems) item.dispose();
    for (final col  in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor.dispose(); _secondaryColor.dispose();
    _copyRightEn.dispose(); _copyRightAr.dispose();
    super.dispose();
  }

  // ─── Save ─────────────────────────────────────────────────────────────────
  Future<void> _save(HomeCmsCubit cubit) async {
    setState(() { _submitted = true; _isSaving = true; });

    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(en: _shortDescEn.text, ar: _shortDescAr.text);

      final currentModel = cubit.current;

      // Nav buttons
      for (var i = 0; i < _navBtns.length; i++) {
        if (i < currentModel.navButtons.length) {
          final id = currentModel.navButtons[i].id;
          cubit.updateNavButtonName(id, en: _navBtns[i]['nameEn']!.text, ar: _navBtns[i]['nameAr']!.text);
          cubit.updateNavButtonRoute(id, _navRoutes[i] ?? '');
        }
      }

      // Sections
      for (var i = 0; i < _sections.length; i++) {
        cubit.updateSectionTextBoxColor(i, _sections[i]['textBox']!.text);
        cubit.updateSectionDescription(i,
            en: _sections[i]['description']!.text,
            ar: _sections[i]['descriptionAr']!.text);
        final img  = _sectionImages[i]['image']!;
        final icon = _sectionImages[i]['icon']!;
        if (img.bytes  != null) await cubit.uploadSectionImage(i, img.bytes!);
        if (icon.bytes != null) await cubit.uploadSectionIcon(i, icon.bytes!);
      }

      // Header items
      for (var i = 0; i < _headerItems.length; i++) {
        if (i < currentModel.headerItems.length) {
          final id = currentModel.headerItems[i].id;
          cubit.updateHeaderItemTitle(id, en: _headerItems[i].en.text, ar: _headerItems[i].ar.text);
          if (currentModel.headerItems[i].status != _headerItems[i].status) {
            cubit.toggleHeaderItemStatus(id);
          }
        }
      }

      // Footer columns
      while (cubit.current.footerColumns.length < _footerColumns.length) {
        cubit.addFooterColumn();
      }
      while (cubit.current.footerColumns.length > _footerColumns.length) {
        cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
      }
      for (var i = 0; i < _footerColumns.length; i++) {
        final colId = cubit.current.footerColumns[i].id;
        cubit.updateFooterColumnTitle(colId,
            en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
            ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
        cubit.updateFooterColumnRoute(colId, _footerColumns[i]['route'] as String? ?? '');

        final labels = _footerColumns[i]['labels'] as List<Map<String, TextEditingController>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length) {
          cubit.addFooterLabel(colId);
        }
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId = cubit.current.footerColumns[i].labels[li].id;
          cubit.updateFooterLabel(colId, lblId,
              en: labels[li]['en']!.text, ar: labels[li]['ar']!.text);
        }
      }

      // Social links
      while (cubit.current.socialLinks.length < _links.length) {
        cubit.addSocialLink();
      }
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(id, url: _links[i].text.text);
        if (_links[i].icon.bytes != null) {
          await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
        }
      }

      // Logo
      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);

      // Branding
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      final status = _selectedTab == 0 ? 'published' : _selectedTab == 1 ? 'scheduled' : 'draft';
      await cubit.save(publishStatus: status);

    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        if (state is HomeCmsSaved) {
          _seededModelHash = null;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Home page saved!',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is HomeCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is HomeCmsLoaded) _seedFromModel(state.data);
        if (state is HomeCmsSaved)  _seedFromModel(state.data);

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.sectionBg,
              body: Column(
                children: [
                  AppNavbar(currentRoute: '/'),
                  _topBar(cubit),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 258.w, height: 40.h,
                              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
                              child: Center(child: Text('Last Updated At', style: StyleText.fontSize18Weight500.copyWith(color: _C.primary))),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.pushNamed('home_edit'),
                              child: Container(
                                width: 205.w, height: 40.h,
                                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
                                child: Center(
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text('Edit Home View', style: StyleText.fontSize18Weight500.copyWith(color: _C.primary)),
                                    SizedBox(width: 20.w),
                                    Icon(Icons.open_in_new, size: 14.sp, color: _C.primary),
                                  ]),
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(height: 10.h),
                          _headingsSection(),    _gap(),
                          _navBtnSection(),      _gap(),
                          _sectionCard(0, 'Section 1 - Left'),         _gap(),
                          _sectionCard(1, 'Section 2 - Left Corner'),  _gap(),
                          _sectionCard(2, 'Section 3 - Right'),        _gap(),
                          _sectionCard(3, 'Section 4 - Right Corner'), _gap(),
                          _headerSection(),      _gap(),
                          _footerSection(),      _gap(),
                          _linksSection(),       _gap(),
                          _logoSection(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Full-screen saving overlay
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 24)],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const CircularProgressIndicator(color: _C.primary),
                      SizedBox(height: 20.h),
                      Text('Saving...', style: StyleText.fontSize14Weight600.copyWith(color: _C.primary)),
                      SizedBox(height: 6.h),
                      Text('Uploading images & saving data', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
                    ]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topBar(HomeCmsCubit cubit) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 14.h, right: 24.w),
          child: Row(children: [
            Text('Home Layout', style: StyleText.fontSize45Weight600.copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: _isSaving ? null : () => _save(cubit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _isSaving ? _C.primary.withOpacity(0.5) : _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: _isSaving
                    ? SizedBox(width: 18.w, height: 18.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Save', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ]),
        ),
        Row(children: [
          _tabBtn('Published', 0),
          _tabBtn('Schedule',  1),
          _tabBtn('Draft',     2),
        ]),
      ],
    ),
  );

  Widget _tabBtn(String label, int index) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.only(right: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
                child: Text(label,
                    style: active
                        ? StyleText.fontSize16Weight600.copyWith(color: _C.primary)
                        : StyleText.fontSize16Weight600.copyWith(color: _C.hintText)),
              ),
              Container(
                height: 3.sp, width: double.infinity,
                decoration: BoxDecoration(
                  color: active ? _C.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gap() => SizedBox(height: 10.h);

  // ─── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({required String key, required String title, required List<Widget> children}) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: _C.border)),
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
                borderRadius: isOpen
                    ? BorderRadius.only(topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20.sp),
              ]),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
        ],
      ),
    );
  }

  // ─── Headings ──────────────────────────────────────────────────────────────
  Widget _headingsSection() => _accordion(
    key: 'headings', title: 'Headings',
    children: [
      _biRow('Title', 'العنوان', _titleEn, _titleAr, useRow: true),
      SizedBox(height: 14.h),
      _biRow('Short Description', 'وصف مختصر', _shortDescEn, _shortDescAr, maxLines: 3, showCharCount: true),
    ],
  );

  // ─── Navigation Buttons ────────────────────────────────────────────────────
  Widget _navBtnSection() => _accordion(
    key: 'navBtn', title: 'Navigation Button',
    children: [
      ...List.generate(_navBtns.length, (i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${i + 1}${_ord(i + 1)} Button', style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
              GestureDetector(
                onTap: () => setState(() {
                  final removed = _navBtns.removeAt(i);
                  _navRoutes.removeAt(i);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    removed['nameEn']!.dispose(); removed['nameAr']!.dispose();
                  });
                }),
                child: Container(
                  width: 22.w, height: 22.h,
                  decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
                  child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _biRow('Button Name', 'اسم الزر', _navBtns[i]['nameEn']!, _navBtns[i]['nameAr']!, useRow: true),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: CustomDropdownFormFieldInvMaster(
              label: 'Button Navigation',
              hint: Text('Select route', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
              selectedValue: _navRoutes[i], items: _kRoutes,
              widthIcon: 18, heightIcon: 18, height: 36,
              onChanged: (val) => setState(() => _navRoutes[i] = val),
            )),
            SizedBox(width: 15.w),
            const Expanded(child: SizedBox()),
          ]),
          SizedBox(height: 14.h),
        ],
      )),
      GestureDetector(
        onTap: () => setState(() {
          _navBtns.add({'nameEn': TextEditingController(), 'nameAr': TextEditingController()});
          _navRoutes.add(null);
        }),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r), border: Border.all(color: _C.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: _C.labelText),
            SizedBox(width: 4.w),
            Text('Button', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          ]),
        ),
      ),
    ],
  );

  // ─── Section Card ──────────────────────────────────────────────────────────
  Widget _sectionCard(int index, String title) => _accordion(
    key: 's${index + 1}', title: title,
    children: [
      Row(children: [
        _imgPickerCol(
          label: 'Image', picked: _sectionImages[index]['image']!,
          placeholderAsset: 'assets/home_control/image.svg', pickIconAsset: 'assets/home_control/camera.svg',
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _sectionImages[index]['image'] = p);
          },
        ),
        SizedBox(width: 20.w),
        _imgPickerCol(
          label: 'Icon', picked: _sectionImages[index]['icon']!,
          placeholderAsset: 'assets/home_control/edit_icon.svg', pickIconAsset: 'assets/home_control/camera.svg',
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _sectionImages[index]['icon'] = p);
          },
        ),
      ]),
      SizedBox(height: 14.h),
      _ColorPickerField(controller: _sections[index]['textBox']!, label: 'Text Box', onColorChanged: () => setState(() {})),
      SizedBox(height: 14.h),
      CustomValidatedTextFieldMaster(
        label: 'Description', hint: 'None', controller: _sections[index]['description']!,
        maxLines: 5, height: 100, showCharCount: true, maxLength: 500, submitted: _submitted,
        textDirection: TextDirection.ltr, textAlign: TextAlign.left,
        primaryColor: _resolvedPrimaryColor,
      ),
      SizedBox(height: 10.h),
      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'الوصف', hint: 'أدخل النص هنا', controller: _sections[index]['descriptionAr']!,
          maxLines: 5, height: 100, showCharCount: true, maxLength: 500, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          primaryColor: _resolvedPrimaryColor,
        ),
      ),
    ],
  );

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _headerSection() {
    final isOpen = _open['header'] ?? true;
    return Container(
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: _C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['header'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(child: Text('Header', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _headerItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _headerItems.removeAt(oldIndex);
                  _headerItems.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) => _buildHeaderRow(key: ValueKey(_headerItems[i]), index: i, item: _headerItems[i]),
            ),
          ),
      ]),
    );
  }

  Widget _buildHeaderRow({required Key key, required int index, required _HeaderItem item}) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
              child: Icon(Icons.drag_indicator_rounded, size: 20.sp, color: _C.hintText),
            ),
          ),
          Expanded(
            child: Stack(children: [
              CustomValidatedTextFieldMaster(
                label: 'Title', hint: 'None', controller: item.en, height: 36,
                submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.left,
                primaryColor: _resolvedPrimaryColor,
              ),
              Positioned(
                right: 0,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Status: ', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                  SizedBox(height: 2.h),
                  FlutterSwitch(
                    width: 38.sp, height: 22.sp, padding: 3.sp, borderRadius: 20.sp, toggleSize: 16.sp,
                    activeColor: _C.primary, inactiveColor: Colors.grey.withOpacity(.16),
                    value: item.status, onToggle: (val) => setState(() => item.status = val),
                  ),
                ]),
              ),
            ]),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'العنوان', hint: 'اكتب هنا', controller: item.ar, height: 36,
                submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer ────────────────────────────────────────────────────────────────
  Widget _footerSection() => _accordion(
    key: 'footer', title: 'Footer',
    children: [
      ...List.generate(_footerColumns.length, (i) => _buildFooterColumn(i)),
      SizedBox(height: 4.h),
      GestureDetector(
        onTap: () => setState(() => _footerColumns.add(_newFooterColumn())),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: _C.border)
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: _C.labelText),
            SizedBox(width: 4.w),
            Text('Column', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildFooterColumn(int colIndex) {
    final col    = _footerColumns[colIndex];
    final labels = col['labels'] as List<Map<String, TextEditingController>>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (colIndex > 0) ...[Divider(color: _C.divider, height: 1), SizedBox(height: 12.h)],
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column', style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
          _removeBtn(label: 'Remove', onTap: () => setState(() {
            final removed = _footerColumns.removeAt(colIndex);
            WidgetsBinding.instance.addPostFrameCallback((_) => _disposeColumn(removed));
          })),
        ],
      ),
      SizedBox(height: 8.h),
      _biRow('Group Title', 'عنوان المجموعة',
          col['titleEn'] as TextEditingController, col['titleAr'] as TextEditingController, useRow: true),
      SizedBox(height: 8.h),
      Row(children: [
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'Navigation',
          hint: Text('Select route', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
          selectedValue: col['route'] as String?, items: _kRoutes,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => col['route'] = val),
        )),
        SizedBox(width: 10.w),
        const Expanded(child: SizedBox()),
      ]),
      SizedBox(height: 10.h),
      ...List.generate(labels.length, (li) => _buildLabelRow(colIndex, li)),
      SizedBox(height: 4.h),
      _addLabelBtn(onTap: () => setState(() => labels.add(_newLabelRow()))),
      SizedBox(height: 12.h),
    ]);
  }

  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels = _footerColumns[colIndex]['labels'] as List<Map<String, TextEditingController>>;
    final label  = labels[labelIndex];
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: CustomValidatedTextFieldMaster(
          label: 'Label', hint: 'Text Here', controller: label['en']!, height: 36,
          submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: _resolvedPrimaryColor,
        )),
        SizedBox(width: 8.w),
        Expanded(child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'تسمية', hint: 'أدخل النص هنا', controller: label['ar']!, height: 36,
            submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: _resolvedPrimaryColor,
          ),
        )),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: GestureDetector(
            onTap: () => setState(() {
              final removed = labels.removeAt(labelIndex);
              WidgetsBinding.instance.addPostFrameCallback((_) => _disposeLabel(removed));
            }),
            child: Container(
              width: 28.w, height: 28.h,
              decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
              child: Icon(Icons.remove, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Links ─────────────────────────────────────────────────────────────────
  Widget _linksSection() => _accordion(
    key: 'links', title: 'Links',
    children: [
      ...List.generate((_links.length / 2).ceil(), (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _linkItem(left)),
              SizedBox(width: 16.w),
              right < _links.length
                  ? Expanded(child: _linkItem(right))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
      SizedBox(height: 4.h),
      GestureDetector(
        onTap: () => setState(() => _links.add(_LinkItem())),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: _C.border)
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: _C.labelText),
            SizedBox(width: 4.w),
            Text('Link', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          ]),
        ),
      ),
    ],
  );

  Widget _linkItem(int i) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel('Link ${i + 1}'),
          GestureDetector(
            onTap: () => setState(() {
              final removed = _links.removeAt(i);
              WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
            }),
            child: Container(
              width: 22.w, height: 22.h,
              decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
              child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
      SizedBox(height: 5.h),
      _sectionLabel('Icon'),
      SizedBox(height: 5.h),
      _imgBox(
        picked: _links[i].icon,
        placeholderAsset: 'assets/home_control/edit_icon.svg', pickIconAsset: 'assets/home_control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _links[i].icon = p);
        },
      ),
      SizedBox(height: 8.h),
      CustomValidatedTextFieldMaster(
        label: 'Link', hint: 'https://', controller: _links[i].text,
        height: 36, submitted: _submitted,
        primaryColor: _resolvedPrimaryColor,
      ),
    ],
  );

  // ─── Logo & Copyright ──────────────────────────────────────────────────────
  Widget _logoSection() => _accordion(
    key: 'logo', title: 'Logo and Copy Right',
    children: [
      _sectionLabel('Logo'),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _logoPicked,
        placeholderAsset: 'assets/home_control/image.svg', pickIconAsset: 'assets/home_control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(controller: _primaryColor, label: 'Primary Color', onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(controller: _secondaryColor, label: 'Secondary', onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'English Font',
          hint: Text('Select font', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
          selectedValue: _engFont, items: _kFonts, widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _engFont = val),
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'Arabic Font',
          hint: Text('Select font', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
          selectedValue: _arFont, items: _kFonts, widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _arFont = val),
        )),
      ]),
      SizedBox(height: 14.h),
      _biRow('Copy Right', 'حقوق النشر', _copyRightEn, _copyRightAr, showCharCount: false, useRow: true),
    ],
  );

  // ─── Shared helpers ────────────────────────────────────────────────────────
  Widget _removeBtn({required String label, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
      child: Text(label, style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
    ),
  );

  Widget _addLabelBtn({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r), border: Border.all(color: _C.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: _C.labelText),
        SizedBox(width: 4.w),
        Text('Label', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
      ]),
    ),
  );

  Widget _biRow(String enLabel, String arLabel, TextEditingController enCtrl, TextEditingController arCtrl, {
    int maxLines = 1, bool showCharCount = false, bool useRow = false,
  }) {
    final double fieldH = maxLines > 1 ? 80 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel, hint: 'None', controller: enCtrl,
      maxLines: maxLines, height: fieldH, showCharCount: showCharCount, submitted: _submitted,
      textDirection: TextDirection.ltr, textAlign: TextAlign.left,
      primaryColor: _resolvedPrimaryColor,
    );
    final arField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel, hint: 'اكتب هنا', controller: arCtrl,
        maxLines: maxLines, height: fieldH, showCharCount: showCharCount, submitted: _submitted,
        textDirection: TextDirection.rtl, textAlign: TextAlign.right,
        primaryColor: _resolvedPrimaryColor,
      ),
    );
    if (useRow) return Row(children: [Expanded(child: enField), SizedBox(width: 16.w), Expanded(child: arField)]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [enField, SizedBox(height: 10.h), arField]);
  }

  Widget _sectionLabel(String text) => Text(text, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/home_control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 100.w, height: 100.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: SvgPicture.memory(
            picked.bytes!, width: 100.w, height: 100.h, fit: BoxFit.cover,
            placeholderBuilder: (_) => _placeholderCircle(placeholderAsset),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 100.w, height: 100.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: SvgPicture.network(
            picked.url!, width: 100.w, height: 100.h, fit: BoxFit.cover,
            placeholderBuilder: (_) => const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else {
      content = _placeholderCircle(placeholderAsset);
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 35.w, height: 35.h,
            decoration: BoxDecoration(color: _C.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Center(child: CustomSvg(assetPath: pickIconAsset, width: 16.w, height: 16.h, fit: BoxFit.fill)),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle(String assetPath) => Container(
    width: 100.w, height: 100.h,
    decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(child: CustomSvg(assetPath: assetPath, width: 40.w, height: 40.h, fit: BoxFit.fill)),
  );

  Widget _imgPickerCol({
    required String label, required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/home_control/camera.svg',
    VoidCallback? onPick,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel(label),
      SizedBox(height: 5.h),
      _imgBox(picked: picked, placeholderAsset: placeholderAsset, pickIconAsset: pickIconAsset, onPick: onPick),
    ],
  );

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}