/// ******************* FILE INFO *******************
/// File Name: home_edit_page.dart
/// Page 2 — "Editing Main Details"
/// UPDATED: Footer column title is now a dropdown populated from nav items.
///          Selecting a nav item auto-fills EN + AR title and sets the route.
///          Each label row now has a destination dropdown (fixed list) plus
///          free-text EN / AR fields.
///          Label map type changed from Map<String,TextEditingController>
///          to Map<String,dynamic> to hold the extra 'route' String? field.
/// FIXED:   _save() now syncs navButtons ORDER to cubit before updating
///          name/status — uses reorderNavButtons() so drag reorder persists.
/// UPDATED: _kLabelDestinations now use /about?tab=... query-param routes
///          so footer links deep-link directly into the correct About Us tab.

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/circle_progress.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../../core/custom_dialog.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back    = Color(0xFFF1F2ED);
}

// ── Route dropdown used only for nav-section route picker ──────────────────
const List<Map<String, String>> _kRoutes = [
  {'key': '',          'value': 'None'},
  {'key': '/',         'value': 'Home (/)'},
  {'key': '/services', 'value': 'Services (/services)'},
  {'key': '/about',    'value': 'About Us (/about)'},
  {'key': '/contact',  'value': 'Contact Us (/contact)'},
  {'key': '/careers',  'value': 'Careers (/careers)'},
  {'key': '/jobs',     'value': 'Jobs (/jobs)'},
];

// ── Fixed label-destination list ─────────────────────────────────────────────
// About Us routes  → /about?tab=<key>
// Careers routes   → /careers?tab=<key>
// Other pages      → plain path
// ── ABOUT PAGE tabs ─────────────────────────────────────────────────────────
//   Top-level tabs  (topTab index):
//     our-strategy       → topTab 1
//     terms-and-conditions → topTab 2
//     privacy-policy     → topTab 3
//   "About Us" sub-tabs (topTab 0, subTab index):
//     vision             → subTab 0
//     mission            → subTab 1
//     values             → subTab 2
//
// ── CAREERS PAGE tabs ────────────────────────────────────────────────────────
//   why-join-our-team  → tab 0
//   interns            → tab 1
//   our-team           → tab 2
//
// ── OTHER PAGES ──────────────────────────────────────────────────────────────
//   /contact           → Contact Us page (with form)
const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  // ── About Us page ───────────────────────────
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  // ── Careers page ────────────────────────────
  {'key': '/careers?tab=why-join-our-team',      'value': 'Why Join Our Team'},
  {'key': '/careers?tab=interns',                'value': 'Our Interns'},
  {'key': '/careers?tab=our-team',               'value': 'Our Team'},
  // ── Other pages ─────────────────────────────
  {'key': '/contact',                            'value': 'Contact Form'},
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

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class _LinkItem {
  final TextEditingController text;
  _PickedImage icon;
  bool visibility;

  _LinkItem()
      : text       = TextEditingController(),
        icon       = const _PickedImage(),
        visibility = true;

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
          Text(widget.label!,
              style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
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
                filled: true, fillColor: AppColors.card,
                isDense: true, counterText: '',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    width: 16.w, height: 16.h,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.border),
                    ),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                enabledBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 1)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: Colors.transparent)),
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
  void initState() { super.initState(); _picked = widget.initialColor; }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
              maxWidth: 400.w,
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
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Color',
                        style: StyleText.fontSize16Weight600
                            .copyWith(color: _C.labelText)),
                    SizedBox(height: 16.h),
                    LayoutBuilder(builder: (context, constraints) {
                      final double pickerW =
                      (constraints.maxWidth).clamp(200.0, 320.0);
                      return SizedBox(
                        width: pickerW,
                        child: ColorPicker(
                          pickerColor: _picked,
                          onColorChanged: (c) => setState(() => _picked = c),
                          colorPickerWidth: pickerW,
                          pickerAreaHeightPercent: 0.65,
                          enableAlpha: false,
                          displayThumbColor: true,
                          portraitOnly: true,
                          pickerAreaBorderRadius: BorderRadius.circular(8.r),
                          hexInputBar: true,
                          labelTypes: const [],
                        ),
                      );
                    }),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: _C.border),
                            ),
                            child: Text('Cancel',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: _C.labelText)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => widget.onApply(_picked),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(6.r)),
                            child: Text('Apply',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: Colors.white)),
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
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeEditPage
// ─────────────────────────────────────────────────────────────────────────────
class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});

  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  bool _submitted = false;
  bool _isSaving  = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.of(
    List.generate(3, (_) => {
      'nameEn': TextEditingController(),
      'nameAr': TextEditingController(),
    }),
  );
  final List<String?> _navRoutes = List.of([null, null, null]);
  final List<bool>    _navStatus = List.of([true,  true,  true]);

  // ── Sections 1–4 ──────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections =
  List.generate(4, (_) => {
    'textBox':       TextEditingController(text: '#008037'),
    'description':   TextEditingController(),
    'descriptionAr': TextEditingController(),
  });

  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4,
        (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Header titles ─────────────────────────────────────────────────────────
  late final List<_HeaderItem> _headerItems;

  // ── Footer columns ────────────────────────────────────────────────────────
  late final List<Map<String, dynamic>> _footerColumns;

  // ── Social links ──────────────────────────────────────────────────────────
  late final List<_LinkItem> _links;

  // ── Logo ──────────────────────────────────────────────────────────────────
  _PickedImage _logoPicked = const _PickedImage();

  // ── Branding ──────────────────────────────────────────────────────────────
  final _primaryColor      = TextEditingController(text: '#008037');
  final _secondaryColor    = TextEditingController(text: '#D9D9D9');
  final _bgColor           = TextEditingController(text: '#D9D9D9');
  final _headerFooterColor = TextEditingController(text: '#D9D9D9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';

  // ── Accordion open/close ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'theme': true, 'header': true, 'footer': true, 'links': true,
    'headings': true, 'navBtn': true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  // ── Seed-hash guard ───────────────────────────────────────────────────────
  int? _seededModelHash;

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  // ── Helpers: build a nav-items dropdown list from current local state ──────
  List<Map<String, String>> _buildNavDropdownItems() {
    final items = <Map<String, String>>[
      {'key': '', 'value': 'None'},
    ];
    for (var i = 0; i < _navBtns.length; i++) {
      final en    = _navBtns[i]['nameEn']!.text.trim();
      final route = _navRoutes[i] ?? '';
      if (route.isEmpty) continue;
      items.add({'key': route, 'value': en.isNotEmpty ? en : route});
    }
    return items;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    print('[HomeEditPage] ✅ initState');
    _seededModelHash = null;
    _headerItems   = List.generate(5, (i) => _HeaderItem(id: 'hi_$i'));
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links         = List.generate(4, (_) => _LinkItem());
  }

  // ── Image picker (SVG only) ───────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    print('[HomeEditPage] _pickImage: opening file picker');
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('[HomeEditPage] _pickImage: no file selected');
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      print('[HomeEditPage] _pickImage: file="${file.name}" type="${file.type}"');

      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        print('[HomeEditPage] _pickImage: ❌ rejected — not SVG');
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Only SVG files are allowed',
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
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
            print('[HomeEditPage] _pickImage: ✅ read ${result.length} bytes');
            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            print('[HomeEditPage] _pickImage: ❌ unexpected result type');
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        print('[HomeEditPage] _pickImage: ❌ FileReader error');
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) {
        print('[HomeEditPage] _pickImage: ⏰ TIMEOUT');
        completed = true;
        completer.complete(null);
      }
    });

    return completer.future;
  }

  // ── Seed from model (ONLY on HomeCmsLoaded, never on HomeCmsSaved) ─────────
  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      ...d.socialLinks.map((s) => s.iconUrl),
      d.branding.logoUrl,
    ]);

    print('[HomeEditPage] _seedFromModel: '
        'newHash=$modelHash cachedHash=$_seededModelHash');

    if (_seededModelHash == modelHash) {
      print('[HomeEditPage] _seedFromModel: hash UNCHANGED — skip');
      return;
    }
    _seededModelHash = modelHash;
    print('[HomeEditPage] _seedFromModel: ▶ seeding from model '
        '(navButtons=${d.navButtons.length})');

    // ── Title / short desc ────────────────────────────────────────────────
    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    // ── Nav buttons ───────────────────────────────────────────────────────
    print('[HomeEditPage] _seedFromModel: syncing navBtns '
        'local=${_navBtns.length} server=${d.navButtons.length}');

    while (_navBtns.length > d.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose();
      removed['nameAr']!.dispose();
      _navRoutes.removeLast();
      _navStatus.removeLast();
    }
    while (_navBtns.length < d.navButtons.length) {
      _navBtns.add({
        'nameEn': TextEditingController(),
        'nameAr': TextEditingController(),
      });
      _navRoutes.add(null);
      _navStatus.add(true);
    }

    // ✅ Seed in Firestore order — this preserves the saved drag order
    for (var i = 0; i < d.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = d.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = d.navButtons[i].name.ar;
      _navRoutes[i] =
      d.navButtons[i].route.isEmpty ? null : d.navButtons[i].route;
      _navStatus[i] = d.navButtons[i].status;
    }

    // ── Sections ──────────────────────────────────────────────────────────
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

    // ── Header items ──────────────────────────────────────────────────────
    for (var i = 0;
    i < _headerItems.length && i < d.headerItems.length;
    i++) {
      _headerItems[i].en.text = d.headerItems[i].title.en;
      _headerItems[i].ar.text = d.headerItems[i].title.ar;
      _headerItems[i].status  = d.headerItems[i].status;
    }

    // ── Footer columns ────────────────────────────────────────────────────
    while (_footerColumns.length > d.footerColumns.length) {
      final removed = _footerColumns.removeLast();
      _disposeColumn(removed);
    }
    while (_footerColumns.length < d.footerColumns.length) {
      _footerColumns.add(_newFooterColumn());
    }
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text =
          d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text =
          d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] =
      d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;

      final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
      while (labels.length > d.footerColumns[i].labels.length) {
        _disposeLabel(labels.removeLast());
      }
      while (labels.length < d.footerColumns[i].labels.length) {
        labels.add(_newLabelRow());
      }
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        (labels[li]['en'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.en;
        (labels[li]['ar'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.ar;
        labels[li]['route'] = d.footerColumns[i].labels[li].route.isEmpty
            ? null
            : d.footerColumns[i].labels[li].route;
      }
    }

    // ── Social links ──────────────────────────────────────────────────────
    while (_links.length > d.socialLinks.length) _links.removeLast().dispose();
    while (_links.length < d.socialLinks.length) _links.add(_LinkItem());
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
      _links[i].visibility = d.socialLinks[i].visibility;
    }

    // ── Branding ─────────────────────────────────────────────────────────
    _primaryColor.text = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _bgColor.text = d.branding.backgroundColor.isNotEmpty
        ? d.branding.backgroundColor
        : '#D9D9D9';
    _headerFooterColor.text = d.branding.headerFooterColor.isNotEmpty
        ? d.branding.headerFooterColor
        : '#D9D9D9';
    _engFont =
    d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont =
    d.branding.arabicFont.isEmpty ? 'Cairo' : d.branding.arabicFont;
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();

    print('[HomeEditPage] _seedFromModel: ✅ DONE');
  }

  // ── Footer/label helpers ──────────────────────────────────────────────────
  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route':   null as String?,
    'labels':  <Map<String, dynamic>>[_newLabelRow()],
  };

  Map<String, dynamic> _newLabelRow() => {
    'en':    TextEditingController(),
    'ar':    TextEditingController(),
    'route': null as String?,
  };

  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, dynamic>>) {
      _disposeLabel(l);
    }
  }

  void _disposeLabel(Map<String, dynamic> label) {
    (label['en'] as TextEditingController).dispose();
    (label['ar'] as TextEditingController).dispose();
  }

  @override
  void dispose() {
    print('[HomeEditPage] 🔴 dispose');
    _titleEn.dispose();
    _titleAr.dispose();
    _shortDescEn.dispose();
    _shortDescAr.dispose();
    for (final m in _navBtns) {
      for (final c in m.values) c.dispose();
    }
    for (final m in _sections) {
      for (final c in m.values) c.dispose();
    }
    for (final item in _headerItems) item.dispose();
    for (final col in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor.dispose();
    _secondaryColor.dispose();
    _bgColor.dispose();
    _headerFooterColor.dispose();
    super.dispose();
  }

  // ─── Save / Publish ───────────────────────────────────────────────────────
  Future<void> _save(HomeCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    setState(() { _submitted = true; _isSaving = true; });

    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(en: _shortDescEn.text, ar: _shortDescAr.text);

      // ── Nav buttons ────────────────────────────────────────────────────────
      final snapshot = List<NavButtonModel>.from(cubit.current.navButtons);
      final routeToId = { for (final b in snapshot) b.route: b.id };

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        if (localRoute.isEmpty) continue;

        final currentIndex = cubit.current.navButtons
            .indexWhere((b) => b.route == localRoute);
        if (currentIndex != -1 && currentIndex != i) {
          cubit.reorderNavButtonsSilent(currentIndex, i);
        }
      }

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute  = _navRoutes[i] ?? '';
        final id          = routeToId[localRoute];
        if (id == null) continue;

        cubit.updateNavButtonName(id,
            en: _navBtns[i]['nameEn']!.text,
            ar: _navBtns[i]['nameAr']!.text);
        cubit.updateNavButtonRoute(id, localRoute);

        final modelStatus = cubit.current.navButtons
            .firstWhere((b) => b.id == id,
            orElse: () => NavButtonModel(id: id))
            .status;
        if (modelStatus != _navStatus[i]) {
          cubit.toggleNavButtonStatus(id);
        }
      }

      // ── Sections ───────────────────────────────────────────────────────────
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

      // ── Header items ───────────────────────────────────────────────────────
      final currentModel = cubit.current;
      for (var i = 0; i < _headerItems.length; i++) {
        if (i < currentModel.headerItems.length) {
          final id = currentModel.headerItems[i].id;
          cubit.updateHeaderItemTitle(id,
              en: _headerItems[i].en.text,
              ar: _headerItems[i].ar.text);
          if (currentModel.headerItems[i].status != _headerItems[i].status) {
            cubit.toggleHeaderItemStatus(id);
          }
        }
      }

      // ── Footer columns ─────────────────────────────────────────────────────
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
        cubit.updateFooterColumnRoute(
            colId, _footerColumns[i]['route'] as String? ?? '');

        final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length) {
          cubit.addFooterLabel(colId);
        }
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(
              colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId    = cubit.current.footerColumns[i].labels[li].id;
          final lblRoute = (labels[li]['route'] as String?) ?? '';
          cubit.updateFooterLabel(colId, lblId,
              en: (labels[li]['en'] as TextEditingController).text,
              ar: (labels[li]['ar'] as TextEditingController).text);
          cubit.updateFooterLabelRoute(colId, lblId, lblRoute);
        }
      }

      // ── Social links ───────────────────────────────────────────────────────
      while (cubit.current.socialLinks.length < _links.length) {
        cubit.addSocialLink();
      }
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(id,
            url:        _links[i].text.text,
            visibility: _links[i].visibility);
        if (_links[i].icon.bytes != null) {
          await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
        }
      }

      // ── Logo & Branding ────────────────────────────────────────────────────
      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      await cubit.save(publishStatus: publishStatus);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[HomeEditPage] _save: ❌ ERROR: $e\n$st');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        print('[HomeEditPage] 👂 listener: ${state.runtimeType}');

        if (state is HomeCmsSaved) {
          print('[HomeEditPage] listener: HomeCmsSaved — '
              '✅ NOT re-seeding (preserves local toggle state)');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Home page saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }

        if (state is HomeCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        print('[HomeEditPage] 🔨 builder: ${state.runtimeType}');

        if (state is HomeCmsLoaded) {
          _seedFromModel(state.data);
        }

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.back,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          width: 1000.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 20.w),
                              AdminSubNavBar(activeIndex: 0),
                              SizedBox(
                                width: 1050.w,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 20.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Editing Main Details',
                                        style: StyleText.fontSize45Weight600.copyWith(
                                          color: _C.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),

                                      // ── Theme & Logo ───────────────────────────────
                                      _accordion(
                                          key: 'theme',
                                          title: 'Theme and Logo',
                                          children: [_logoAndBrandingSection()]),
                                      _gap(),

                                      // ── Navigation Items ───────────────────────────
                                      _navSection(),
                                      _gap(),

                                      // ── Footer ─────────────────────────────────────
                                      _footerSection(cubit),
                                      _gap(),

                                      // ── Social Links ───────────────────────────────
                                      _linksSection(),
                                      _gap(),

                                      // ── Actions ────────────────────────────────────
                                      _bottomActions(cubit),
                                      _gap(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                height: 44.h,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF797979),
                                                  borderRadius: BorderRadius.circular(6.r),
                                                ),
                                                child: Center(
                                                  child: Text('Discard',
                                                      style: StyleText.fontSize14Weight600
                                                          .copyWith(color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15.sp),
                                          Expanded(child: Container())
                                        ],
                                      ),
                                      SizedBox(height: 40.h),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Saving overlay ─────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 24)
                      ],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const CircularProgressIndicator(color: _C.primary),
                      SizedBox(height: 20.h),
                      Text('Saving...',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: _C.primary)),
                      SizedBox(height: 6.h),
                      Text('Uploading images & saving data',
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: _C.hintText)),
                    ]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ─── Bottom buttons ───────────────────────────────────────────────────────
  Widget _bottomActions(HomeCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => context.pushNamed('home_preview'),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: GestureDetector(
          onTap: _isSaving
              ? null
              : () {
            showPublishConfirmDialog(
              context: context,
              onConfirm: () => _save(cubit, publishStatus: 'published'),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44.h,
            decoration: BoxDecoration(
              color: _isSaving ? _C.primary.withOpacity(0.5) : _C.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: _isSaving
                  ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text('Publish',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _gap() => SizedBox(height: 10.h);

  // ─── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),

      ),
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
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  // ── Logo & Branding ────────────────────────────────────────────────────────
  Widget _logoAndBrandingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      _sectionLabel('Logo'),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _logoPicked,
        placeholderAsset: 'assets/home_control/image.svg',
        pickIconAsset: 'assets/home_control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _primaryColor,
            label: 'Primary Color',
            hintText: '#008037',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _secondaryColor,
            label: 'Secondary',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _bgColor,
            label: 'Background',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _headerFooterColor,
            label: 'Header and Footer',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'English Font',
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText)),
          selectedValue: _engFont,
          items: _kFonts,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _engFont = val),
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'Arabic Font',
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText)),
          selectedValue: _arFont,
          items: _kFonts,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _arFont = val),
        )),
      ]),
    ],
  );

  // ─── Navigation Items section ──────────────────────────────────────────────
  Widget _navSection() {
    final isOpen = _open['navBtn'] ?? true;
    return Container(
      decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['navBtn'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Navigation Items',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _navBtns.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final btn    = _navBtns.removeAt(oldIndex);
                final route  = _navRoutes.removeAt(oldIndex);
                final status = _navStatus.removeAt(oldIndex);
                _navBtns.insert(newIndex, btn);
                _navRoutes.insert(newIndex, route);
                _navStatus.insert(newIndex, status);
              });
            },
            itemBuilder: (context, i) =>
                _buildNavItemRow(key: ValueKey('nav_$i'), index: i),
          ),
      ]),
    );
  }

  Widget _buildNavItemRow({required Key key, required int index}) {
    final nameEnCtrl = _navBtns[index]['nameEn']!;
    final nameArCtrl = _navBtns[index]['nameAr']!;

    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                      child: Icon(Icons.menu_rounded,
                          size: 20.sp, color: _C.hintText),
                    ),
                  ),
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      label: 'Title',
                      hint: 'Home',
                      controller: nameEnCtrl,
                      height: 36,
                      submitted: _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      primaryColor: _resolvedPrimaryColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomValidatedTextFieldMaster(
                        label: 'عنصر التنقل',
                        hint: 'الرئيسية',
                        controller: nameArCtrl,
                        height: 36,
                        submitted: _submitted,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        primaryColor: _resolvedPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: MediaQuery.sizeOf(context).width*.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Status: ',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _C.labelText)),
                    FlutterSwitch(
                      width: 38.sp,
                      height: 22.sp,
                      padding: 3.sp,
                      borderRadius: 20.sp,
                      toggleSize: 16.sp,
                      activeColor: _C.primary,
                      inactiveColor: Colors.grey.withOpacity(.16),
                      value: _navStatus[index],
                      onToggle: (val) {
                        setState(() => _navStatus[index] = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _headerSection() {
    final isOpen = _open['header'] ?? true;
    return Container(
      decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: _C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['header'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Header Titles',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp),
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
              itemBuilder: (context, i) => _buildHeaderRow(
                  key: ValueKey(_headerItems[i]),
                  index: i,
                  item: _headerItems[i]),
            ),
          ),
      ]),
    );
  }

  Widget _buildHeaderRow({
    required Key key,
    required int index,
    required _HeaderItem item,
  }) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Status: ',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: _C.labelText)),
              FlutterSwitch(
                width: 38.sp,
                height: 22.sp,
                padding: 3.sp,
                borderRadius: 20.sp,
                toggleSize: 16.sp,
                activeColor: _C.primary,
                inactiveColor: Colors.grey.withOpacity(.16),
                value: item.status,
                onToggle: (val) => setState(() => item.status = val),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 20.sp, color: _C.hintText),
                ),
              ),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Title',
                  hint: 'None',
                  controller: item.en,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  primaryColor: _resolvedPrimaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'العنوان',
                    hint: 'اكتب هنا',
                    controller: item.ar,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _resolvedPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ────────────────────────────────────────────────────────────────
  Widget _footerSection(HomeCmsCubit cubit) => _accordion(
    key: 'footer',
    title: 'Footer',
    children: [
      ...List.generate(_footerColumns.length, (i) => _buildFooterColumn(i)),
      SizedBox(height: 4.h),
      GestureDetector(
        onTap: () => setState(() => _footerColumns.add(_newFooterColumn())),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
              ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Column',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildFooterColumn(int colIndex) {
    final col    = _footerColumns[colIndex];
    final labels = col['labels'] as List<Map<String, dynamic>>;
    final navDropdownItems = _buildNavDropdownItems();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      SizedBox(height: 15.h),
      if (colIndex > 0) ...[
        Divider(color: _C.divider, height: 1),
        SizedBox(height: 12.h),
      ],

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column',
              style: StyleText.fontSize13Weight600
                  .copyWith(color: _C.labelText)),
          _removeBtn(
              label: 'Remove',
              onTap: () => setState(() {
                final removed = _footerColumns.removeAt(colIndex);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _disposeColumn(removed));
              })),
        ],
      ),
      SizedBox(height: 8.h),

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: CustomDropdownFormFieldInvMaster(
              label: 'Group Title',
              hint: Text('Select navigation item',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText)),
              selectedValue: col['route'] as String?,
              items: navDropdownItems,
              widthIcon: 18,
              heightIcon: 18,
              height: 36,
              onChanged: (val) {
                setState(() {
                  col['route'] = val;
                  if (val != null && val.isNotEmpty) {
                    final idx = _navRoutes.indexOf(val);
                    if (idx != -1) {
                      (col['titleEn'] as TextEditingController).text =
                          _navBtns[idx]['nameEn']!.text;
                      (col['titleAr'] as TextEditingController).text =
                          _navBtns[idx]['nameAr']!.text;
                    }
                  } else {
                    (col['titleEn'] as TextEditingController).clear();
                    (col['titleAr'] as TextEditingController).clear();
                  }
                });
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 1,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("عنوان المجموعة", style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.secondaryText)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 36.h,
                    child: TextFormField(
                      controller: col['titleAr'] as TextEditingController,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: _C.labelText),
                      decoration: InputDecoration(
                        hintText: 'الاسم بالعربي',
                        hintStyle: StyleText.fontSize12Weight400
                            .copyWith(color: _C.hintText),
                        filled: true,
                        fillColor: AppColors.background,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide: const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide: BorderSide(color: AppColors.primary, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide: const BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),

      ...List.generate(labels.length, (li) => _buildLabelRow(colIndex, li)),
      SizedBox(height: 4.h),
      _addLabelBtn(onTap: () => setState(() => labels.add(_newLabelRow()))),
      SizedBox(height: 12.h),
    ]);
  }

  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels = _footerColumns[colIndex]['labels'] as List<Map<String, dynamic>>;
    final label  = labels[labelIndex];

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdownFormFieldInvMaster(
                        label: 'Navigate To',
                        hint: Text('Select destination',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: _C.hintText)),
                        selectedValue: label['route'] as String?,
                        items: _kLabelDestinations,
                        widthIcon: 18,
                        heightIcon: 18,
                        height: 36,
                        onChanged: (val) =>
                            setState(() => label['route'] = val),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          final removed = labels.removeAt(labelIndex);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _disposeLabel(removed));
                        }),
                        child: Container(
                          width: 16.w,
                          height: 16.h,
                          decoration: const BoxDecoration(
                              color: _C.remove, shape: BoxShape.circle),
                          child: Icon(Icons.remove, color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 0.sp),
              Expanded(child: Container()),
            ],
          ),
          SizedBox(height: 8.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Label',
                  hint: 'Text Here',
                  controller: label['en'] as TextEditingController,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  primaryColor: _resolvedPrimaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'التسمية',
                    hint: 'أدخل النص هنا',
                    controller: label['ar'] as TextEditingController,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _resolvedPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Social Links ──────────────────────────────────────────────────────────
  Widget _linksSection() => _accordion(
    key: 'links',
    title: 'Links',
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
              color: Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Link',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ],
  );

  Widget _linkItem(int i) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel('Icon'),
          GestureDetector(
            onTap: () => setState(() {
              final removed = _links.removeAt(i);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => removed.dispose());
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: _C.remove,
                  borderRadius: BorderRadius.circular(4.r)),
              child: Text('Remove',
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      SizedBox(height: 5.h),
      Row(
        children: [
          _imgBox(
            picked: _links[i].icon,
            placeholderAsset: 'assets/control/edit_icon_pick.svg',
            pickIconAsset: 'assets/control/edit_icon_pick.svg',
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => _links[i].icon = p);
            },
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Visibility',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: _C.labelText)),
              SizedBox(width: 6.w),
              FlutterSwitch(
                width: 38.sp,
                height: 22.sp,
                padding: 3.sp,
                borderRadius: 20.sp,
                toggleSize: 16.sp,
                activeColor: _C.primary,
                inactiveColor: Colors.grey.withOpacity(.16),
                value: _links[i].visibility,
                onToggle: (val) =>
                    setState(() => _links[i].visibility = val),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 8.h),
      CustomValidatedTextFieldMaster(
        label: 'Insert Link',
        hint: 'Insert Links',
        controller: _links[i].text,
        height: 36,
        submitted: _submitted,
        primaryColor: _resolvedPrimaryColor,
      ),
    ],
  );

  // ─── Shared helpers ────────────────────────────────────────────────────────
  Widget _removeBtn(
      {required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
              color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
          child: Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: Colors.white)),
        ),
      );

  Widget _addLabelBtn({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: Color(0xFF797979),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: Color(0xFF797979))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text('Label',
            style: StyleText.fontSize12Weight500
                .copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _biRow(
      String enLabel,
      String arLabel,
      TextEditingController enCtrl,
      TextEditingController arCtrl, {
        int maxLines = 1,
        bool showCharCount = false,
        bool useRow = false,
      }) {
    final double fieldH = maxLines > 1 ? 80 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel,
      hint: 'None',
      controller: enCtrl,
      maxLines: maxLines,
      height: fieldH,
      showCharCount: showCharCount,
      submitted: _submitted,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _resolvedPrimaryColor,
    );
    final arField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel,
        hint: 'اكتب هنا',
        controller: arCtrl,
        maxLines: maxLines,
        height: fieldH,
        showCharCount: showCharCount,
        submitted: _submitted,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _resolvedPrimaryColor,
      ),
    );
    if (useRow) {
      return Row(children: [
        Expanded(child: enField),
        SizedBox(width: 16.w),
        Expanded(child: arField),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [enField, SizedBox(height: 10.h), arField],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/home_control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w), // ← controls white space around image
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w, height: 30.h,
                fit: BoxFit.scaleDown,          // ← keeps aspect ratio, no cropping
                placeholderBuilder: (_) => _placeholderCircle(placeholderAsset),
              ),
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w), // ← same padding for consistency
              child: SvgPicture.network(
                picked.url!,
                width: 30.w, height: 30.h,
                fit: BoxFit.contain,          // ← was BoxFit.cover (caused fill)
                placeholderBuilder: (_) =>
                const CircleProgressMaster(),
              ),
            ),
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
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: CustomSvg(
                assetPath: pickIconAsset,
                width: 12.w, height: 12.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle(String assetPath) => Container(
    width: 70.w, height: 70.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(
        child: CustomSvg(
            assetPath: assetPath,
            width: 30.w, height: 30.h, fit: BoxFit.fill)),
  );

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}