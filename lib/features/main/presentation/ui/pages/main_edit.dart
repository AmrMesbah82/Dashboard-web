/// ******************* FILE INFO *******************
/// File Name: home_edit.dart
/// Page 2 — "Editing Main Details"
///
/// ✅ FIXES APPLIED:
///   1. SVG ByteBuffer fix — readAsArrayBuffer returns ByteBuffer, not List<int>
///   2. Validation gate — Publish blocked until ALL required fields are valid
///   3. Only showPublishConfirmDialog used — no success/error snackbars or dialogs
///   4. Navigation via BlocConsumer listener → HomeMainPage (pushAndRemoveUntil)
///   5. _submitted flag reveals inline field errors on first publish attempt

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

import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/circle_progress.dart';
import '../../../../../core/widget/custom_dropdwon.dart';
import '../../../../../core/widget/navigator.dart';
import '../../../../../core/widget/textfield.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/data/model/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import 'main_main.dart';
import 'main_preview.dart'; // adjust import path as needed

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color error     = Color(0xFFE53935);
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
const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  {'key': '/careers?tab=why-join-our-team',      'value': 'Why Join Our Team'},
  {'key': '/careers?tab=interns',                'value': 'Our Interns'},
  {'key': '/careers?tab=our-team',               'value': 'Our Team'},
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

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty  => bytes == null && (url == null || url!.isEmpty);
  bool get isFilled => bytes != null || (url != null && url!.isNotEmpty);
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
                    borderSide: BorderSide(color: _C.primary, width: 1)),
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
  /// Set to true the first time the user taps Publish, to reveal inline errors.
  bool _submitted = false;

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
    'theme': true, 'footer': true, 'links': true,
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ VALIDATION GATE
  //    Returns true ONLY when ALL required fields are filled and valid.
  //    Publish button is disabled (dimmed + tap-blocked) until this is true.
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isFormValid {
    // ── Helper: has Arabic characters ──────────────────────────────────────
    bool hasArabic(String t) => RegExp(r'[\u0600-\u06FF]').hasMatch(t);
    bool hasEnglish(String t) => RegExp(r'[a-zA-Z]').hasMatch(t);

    // Logo required
    if (_logoPicked.isEmpty) return false;

    // Nav buttons
    for (int i = 0; i < _navBtns.length; i++) {
      final route = _navRoutes[i];
      if (route == null || route.isEmpty) return false;

      final en = _navBtns[i]['nameEn']!.text;
      final ar = _navBtns[i]['nameAr']!.text;
      if (en.trim().isEmpty || hasArabic(en)) return false;
      if (ar.trim().isEmpty || hasEnglish(ar)) return false;
    }

    // Footer columns
    for (final col in _footerColumns) {
      final colRoute = col['route'] as String?;
      if (colRoute == null || colRoute.isEmpty) return false;

      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        final labelRoute = label['route'] as String?;
        if (labelRoute == null || labelRoute.isEmpty) return false;

        final en = (label['en'] as TextEditingController).text;
        final ar = (label['ar'] as TextEditingController).text;
        if (en.trim().isEmpty || hasArabic(en)) return false;
        if (ar.trim().isEmpty || hasEnglish(ar)) return false;
      }
    }

    // Social links
    for (final link in _links) {
      if (link.icon.isEmpty) return false;
      if (link.text.text.trim().isEmpty) return false;
    }

    // Fonts
    if (_engFont == null || _engFont!.isEmpty) return false;
    if (_arFont  == null || _arFont!.isEmpty)  return false;

    return true;
  }

  // Collects the first validation error message to display in the dialog.
  String? _getValidationError() {
    if (_logoPicked.isEmpty) {
      return 'Please upload a logo image (SVG format)';
    }

    for (int i = 0; i < _navBtns.length; i++) {
      final route = _navRoutes[i];
      if (route == null || route.isEmpty) {
        return 'Please select a route for navigation button ${i + 1}';
      }
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) {
        return 'Please enter English title for navigation button ${i + 1}';
      }
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) {
        return 'Please enter Arabic title for navigation button ${i + 1}';
      }
    }

    for (int i = 0; i < _footerColumns.length; i++) {
      final col = _footerColumns[i];
      final colRoute = col['route'] as String?;
      if (colRoute == null || colRoute.isEmpty) {
        return 'Please select a navigation route for Footer Column ${i + 1}';
      }

      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (int j = 0; j < labels.length; j++) {
        final label = labels[j];
        final labelRoute = label['route'] as String?;
        if (labelRoute == null || labelRoute.isEmpty) {
          return 'Please select a destination for Label ${j + 1} in Footer Column ${i + 1}';
        }
        if ((label['en'] as TextEditingController).text.trim().isEmpty) {
          return 'Please enter English text for Label ${j + 1} in Footer Column ${i + 1}';
        }
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) {
          return 'Please enter Arabic text for Label ${j + 1} in Footer Column ${i + 1}';
        }
      }
    }

    for (int i = 0; i < _links.length; i++) {
      if (_links[i].icon.isEmpty) {
        return 'Please upload an icon for Social Link ${i + 1}';
      }
      if (_links[i].text.text.trim().isEmpty) {
        return 'Please enter a URL for Social Link ${i + 1}';
      }
    }

    if (_engFont == null || _engFont!.isEmpty) {
      return 'Please select an English Font';
    }
    if (_arFont == null || _arFont!.isEmpty) {
      return 'Please select an Arabic Font';
    }

    return null;
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

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    print('[HomeEditPage] ✅ initState');
    _seededModelHash = null;
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links         = List.generate(4, (_) => _LinkItem());

    // Listen to all text controllers so _isFormValid re-evaluates on change
    for (final m in _sections) {
      for (final c in m.values) c.addListener(_onFieldChanged);
    }
    _primaryColor.addListener(_onFieldChanged);
    _secondaryColor.addListener(_onFieldChanged);
    _bgColor.addListener(_onFieldChanged);
    _headerFooterColor.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeCmsCubit>().load();
    });
  }

  // ── Image picker (SVG only) ───────────────────────────────────────────────
  // ✅ FIX: readAsArrayBuffer returns ByteBuffer, not List<int>.
  //    We must cast to ByteBuffer and wrap with Uint8List.view().
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

      // ── SVG-only guard ──────────────────────────────────────────────────
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        print('[HomeEditPage] _pickImage: ❌ rejected — not SVG');
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          // ✅ ByteBuffer fix: readAsArrayBuffer returns a ByteBuffer object,
          //    not List<int>. Use Uint8List.view() to wrap it correctly.
          if (result is ByteBuffer) {
            print('[HomeEditPage] _pickImage: ✅ read ByteBuffer '
                '(${result.lengthInBytes} bytes)');
            completer.complete(
                _PickedImage(bytes: Uint8List.view(result)));
          } else if (result is List<int>) {
            // Fallback — should not normally happen with readAsArrayBuffer
            print('[HomeEditPage] _pickImage: ✅ read List<int> '
                '(${result.length} bytes)');
            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            print('[HomeEditPage] _pickImage: ❌ unexpected result type: '
                '${result.runtimeType}');
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

    // ── Remove all listeners before seeding to avoid duplicate triggers ───
    for (final m in _navBtns) {
      m['nameEn']!.removeListener(_onFieldChanged);
      m['nameAr']!.removeListener(_onFieldChanged);
    }
    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).removeListener(_onFieldChanged);
      (col['titleAr'] as TextEditingController).removeListener(_onFieldChanged);
      for (final label in col['labels'] as List<Map<String, dynamic>>) {
        (label['en'] as TextEditingController).removeListener(_onFieldChanged);
        (label['ar'] as TextEditingController).removeListener(_onFieldChanged);
      }
    }
    for (final link in _links) {
      link.text.removeListener(_onFieldChanged);
    }

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

    // ── Re-attach listeners to ALL controllers after seeding ──────────────
    for (final m in _navBtns) {
      m['nameEn']!.addListener(_onFieldChanged);
      m['nameAr']!.addListener(_onFieldChanged);
    }
    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).addListener(_onFieldChanged);
      (col['titleAr'] as TextEditingController).addListener(_onFieldChanged);
      for (final label in col['labels'] as List<Map<String, dynamic>>) {
        (label['en'] as TextEditingController).addListener(_onFieldChanged);
        (label['ar'] as TextEditingController).addListener(_onFieldChanged);
      }
    }
    for (final link in _links) {
      link.text.addListener(_onFieldChanged);
    }

    // ── Force rebuild so _isFormValid reflects freshly loaded data ─────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });

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
    for (final m in _navBtns) {
      for (final c in m.values) {
        c.removeListener(_onFieldChanged);
        c.dispose();
      }
    }
    for (final m in _sections) {
      for (final c in m.values) {
        c.removeListener(_onFieldChanged);
        c.dispose();
      }
    }
    for (final col in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor..removeListener(_onFieldChanged)..dispose();
    _secondaryColor..removeListener(_onFieldChanged)..dispose();
    _bgColor..removeListener(_onFieldChanged)..dispose();
    _headerFooterColor..removeListener(_onFieldChanged)..dispose();
    super.dispose();
  }

  // ─── Save / Publish ───────────────────────────────────────────────────────
  // Validation already passed before this is called (from the button's onTap).
  Future<void> _save(HomeCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    try {
      // ── Nav buttons ──────────────────────────────────────────────────────
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
        final localRoute = _navRoutes[i] ?? '';
        final id         = routeToId[localRoute];
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

      // ── Sections ─────────────────────────────────────────────────────────
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

      // ── Footer columns ────────────────────────────────────────────────────
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

      // ── Social links ──────────────────────────────────────────────────────
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

      // ── Logo & Branding ───────────────────────────────────────────────────
      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      await cubit.save(publishStatus: publishStatus);

      // ✅ Navigation is handled in the BlocConsumer listener (HomeCmsSaved).
      // No dialogs or snackbars here.

    } catch (e, st) {
      print('[HomeEditPage] _save: ❌ ERROR: $e\n$st');
      // Errors surface via the HomeCmsError state → handled in the listener.
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        print('[HomeEditPage] 👂 listener: ${state.runtimeType}');

        // ── Published / Saved successfully → navigate to HomeMainPage ──────
        // ✅ Uses pushAndRemoveUntil to clear the entire back stack,
        //    exactly like master_edit_page.dart does.
        if (state is HomeCmsSaved) {
          print('[HomeEditPage] listener: HomeCmsSaved → navigating to HomeMainPage');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const HomeMainPage()),
                    (route) => false,
              );
            }
          });
        }

        // ── Error state ───────────────────────────────────────────────────
        if (state is HomeCmsError) {
          print('[HomeEditPage] listener: HomeCmsError → ${state.message}');
          // Errors are visible to the user through the cubit state;
          // add a snackbar/dialog here if you want, but no success dialogs.
        }
      },
      builder: (context, state) {
        print('[HomeEditPage] 🔨 builder: ${state.runtimeType}');

        if (state is HomeCmsLoaded) {
          _seedFromModel(state.data);
        } else if (state is HomeCmsSaved) {
          _seedFromModel(state.data); // HomeCmsSaved must expose .data
        }
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          AppAdminNavbar(
                            activeLabel:    'Home',
                            homePage:       CareersMainPageDashboard(),
                            webPage:        HomeMainPage(),
                            jobListingPage: JobListingMainPage(),
                          ),

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

                                  // ── Theme & Logo ─────────────────────────
                                  _accordion(
                                      key: 'theme',
                                      title: 'Theme and Logo',
                                      children: [_logoAndBrandingSection()]),
                                  _gap(),

                                  // ── Navigation Items ─────────────────────
                                  _navSection(),
                                  _gap(),

                                  // ── Footer ───────────────────────────────
                                  _footerSection(cubit),
                                  _gap(),

                                  // ── Social Links ─────────────────────────
                                  _linksSection(),
                                  _gap(),

                                  // ── Actions ──────────────────────────────
                                  _bottomActions(cubit),
                                  _gap(),

                                  // ── Discard button ────────────────────────
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                  const HomeMainPage(),
                                                ),
                                              );
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration:
                                            const Duration(milliseconds: 200),
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF797979),
                                              borderRadius:
                                              BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text('Discard',
                                                  style: StyleText
                                                      .fontSize14Weight600
                                                      .copyWith(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 300.w),
                                      Expanded(child: Container()),
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
        );
      },
    );
  }

  // ─── Bottom buttons: Preview + Publish ────────────────────────────────────
  Widget _bottomActions(HomeCmsCubit cubit) {
    final bool canPublish = _isFormValid;

    return Row(
      children: [
        // ── Preview ──────────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              navigateTo(context, HomePreviewPage());
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Color(0xFF608570),
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
        SizedBox(width: 300.w),

        // ── Publish ───────────────────────────────────────────────────────
        // ✅ Visually dimmed + tap-blocked when form is invalid.
        //    On tap when invalid → sets _submitted=true (reveals inline field
        //    errors) + shows validation error dialog.
        //    On tap when valid   → shows showPublishConfirmDialog only.
        Expanded(
          child: AbsorbPointer(
            absorbing: !canPublish,
            child: Opacity(
              opacity: canPublish ? 1.0 : 0.6,
              child: GestureDetector(
                onTap: () {
                  if (!canPublish) {
                    // Reveal inline field errors
                    setState(() => _submitted = true);
                    // This branch is normally unreachable because AbsorbPointer
                    // blocks the tap, but kept as a safety net.
                    return;
                  }

                  // ✅ Only dialog is showPublishConfirmDialog — no others.
                  showPublishConfirmDialog(
                    title: 'EDITING HOMEPAGE DETAILS',
                    subtitle:
                    'Do you want to save the changes made to this HOMEPAGE?',
                    context: context,
                    onConfirm: () => _save(cubit, publishStatus: 'published'),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: canPublish
                        ? _C.primary
                        : _C.primary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Publish',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white
                            .withOpacity(canPublish ? 1.0 : 0.55),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
          borderRadius: BorderRadius.circular(6.r)),
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
                    size: 25.sp),
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
        pickIconAsset: 'assets/control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      // Inline error shown after first publish attempt if logo is missing
      if (_submitted && _logoPicked.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            'Logo SVG image is required',
            style: StyleText.fontSize12Weight400.copyWith(color: _C.error),
          ),
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
          dropdownColor: Colors.white,
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
          dropdownColor: Colors.white,
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
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['navBtn'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(6.r),
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
                  size: 25.sp),
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
                  Padding(
                    padding: EdgeInsets.only(top: 27.h),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                        child: Icon(Icons.menu_rounded,
                            size: 20.sp, color: _C.hintText),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      label: 'Title',
                      isRequired: true,
                      fillColor: Colors.white,
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
                        isRequired: true,
                        fillColor: Colors.white,
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
                left: MediaQuery.sizeOf(context).width * .305,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Status ',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _C.labelText)),
                    FlutterSwitch(
                      width: 35.sp,
                      height: 20.sp,
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

  // ─── Footer ────────────────────────────────────────────────────────────────
  Widget _footerSection(HomeCmsCubit cubit) => _accordion(
    key: 'footer',
    title: 'Footer',
    children: [
      ...List.generate(_footerColumns.length, (i) => _buildFooterColumn(i)),

      GestureDetector(
        onTap: () => setState(() => _footerColumns.add(_newFooterColumn())),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r)),
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
        SizedBox(height: 12.h),
      ],

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column',
              style: StyleText.fontSize14Weight600
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
              dropdownColor: Colors.white,
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
                      Text("عنوان المجموعة",
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.secondaryText)),
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
                        fillColor: Colors.white,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            BorderSide(color: _C.primary, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            const BorderSide(color: Colors.transparent)),
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
      Padding(
        padding:  EdgeInsets.symmetric(vertical: 10.h),
        child: _addLabelBtn(onTap: () => setState(() => labels.add(_newLabelRow()))),
      ),
    ]);
  }

  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels =
    _footerColumns[colIndex]['labels'] as List<Map<String, dynamic>>;
    final label = labels[labelIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: AlignmentGeometry.topRight,
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
                          dropdownColor: Colors.white,
                          widthIcon: 18,
                          heightIcon: 18,
                          height: 36,
                          onChanged: (val) =>
                              setState(() => label['route'] = val),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 0.sp),
                Expanded(child: Container()),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        final removed = labels.removeAt(labelIndex);
                        WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _disposeLabel(removed));
                      }),
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: const BoxDecoration(
                            color: _C.remove, shape: BoxShape.circle),
                        child: Icon(Icons.remove,
                            color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Label',
                hint: 'Text Here',
                isRequired: true,
                controller: label['en'] as TextEditingController,
                height: 36,
                submitted: _submitted,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomValidatedTextFieldMaster(
                  label: 'التسمية',
                  isRequired: true,
                  fillColor: Colors.white,
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
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r)),
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
        crossAxisAlignment: CrossAxisAlignment.end,
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
          // Inline error for missing icon
          if (_submitted && _links[i].icon.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                'SVG icon required',
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.error),
              ),
            ),
          const Spacer(),

        ],
      ),
      SizedBox(height: 8.h),
      Stack(
        alignment: AlignmentGeometry.topRight,
        children: [
          CustomValidatedTextFieldMaster(
            label: 'Insert Link',
            isRequired: true,
            fillColor: Colors.white,
            hint: 'Insert Links',
            controller: _links[i].text,
            height: 36,
            submitted: _submitted,
            primaryColor: _resolvedPrimaryColor,
          ),
          Positioned(
            top: -0.5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Visibility',
                    style: StyleText.fontSize10Weight500
                        .copyWith(color: _C.labelText)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 18.sp,
                  padding: 3.sp,
                  borderRadius: 17.sp,
                  toggleSize: 16.sp,
                  activeColor: _C.primary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: _links[i].visibility,
                  onToggle: (val) =>
                      setState(() => _links[i].visibility = val),
                ),
              ],
            ),
          ),
        ],
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
          color: const Color(0xFF797979),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFF797979))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text('Label',
            style: StyleText.fontSize12Weight500
                .copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w, height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) =>
                    _placeholderCircle(placeholderAsset),
              ),
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                picked.url!,
                width: 30.w, height: 30.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
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