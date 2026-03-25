/// ******************* FILE INFO *******************
/// File Name: home_edit_page.dart
/// Pages 4–6 — "Editing Home" (Figma screens 4, 5, 6)
/// Sections: Headings, Navigation Button (+Button), Section 1–4,
///           Social Links (with Visibility toggle — ✅ now fully saved),
///           Publish Schedule — then Preview / Publish / Discard / Save For Later
/// FIXED: _links now stores 'visibility' key (bool)
/// FIXED: _seedFromModel() seeds visibility from SocialLinkModel.visibility
/// FIXED: _save() passes visibility to cubit.updateSocialLink()
/// FIXED: _linkItem() toggle writes to _links[i]['visibility']

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
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
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
  static const Color back    = Color(0xFFF1F2ED);
}

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

const List<String> _kSectionTitles = [
  'Section 1 - Left',
  'Section 2 - Left Corner',
  'Section 3 - Right',
  'Section 4 - Right Corner',
];

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class _NavBtnItem {
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  String? route;

  _NavBtnItem()
      : nameEn = TextEditingController(),
        nameAr = TextEditingController(),
        route  = null;

  void dispose() { nameEn.dispose(); nameAr.dispose(); }
}

class _SectionItem {
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage image;
  _PickedImage icon;
  bool visibility;

  _SectionItem()
      : descEn     = TextEditingController(),
        descAr     = TextEditingController(),
        image      = const _PickedImage(),
        icon       = const _PickedImage(),
        visibility = true;

  void dispose() { descEn.dispose(); descAr.dispose(); }
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
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.border),
                    ),
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
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
      Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 500.w),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _C.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Color', style: StyleText.fontSize16Weight600.copyWith(color: _C.labelText)),
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
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: _C.border)),
                            child: Text('Cancel', style: StyleText.fontSize14Weight500.copyWith(color: _C.labelText)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => widget.onApply(_picked),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                            child: Text('Apply', style: StyleText.fontSize14Weight500.copyWith(color: Colors.white)),
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
// HomeEditPageMaster
// ─────────────────────────────────────────────────────────────────────────────
class HomeEditPageMaster extends StatefulWidget {
  const HomeEditPageMaster({super.key});
  @override
  State<HomeEditPageMaster> createState() => _HomeEditPageMasterState();
}

class _HomeEditPageMasterState extends State<HomeEditPageMaster> {
  bool _submitted = false;
  bool _isSaving  = false;

  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  final List<_NavBtnItem> _navBtns = [];
  final List<_SectionItem> _sections = List.generate(4, (_) => _SectionItem());
  late final List<Map<String, dynamic>> _footerColumns;

  // ✅ Each entry: {'text': TextEditingController, 'icon': _PickedImage, 'visibility': bool}
  final List<Map<String, dynamic>> _links = [];

  _PickedImage _logoPicked = const _PickedImage();

  final _primaryColor   = TextEditingController(text: '#008037');
  final _secondaryColor = TextEditingController(text: '#4049B9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';
  final _copyRightEn = TextEditingController(text: 'COPYRIGHT © 2025 BAYANATZ. ALL-RIGHT RESERVED');
  final _copyRightAr = TextEditingController();

  DateTime? _publishDate;

  final Map<String, bool> _open = {
    'headings': true,
    'navBtn':   true,
    's0': true, 's1': true, 's2': true, 's3': true,
    'links':    true, // ✅ social links
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

  @override
  void initState() {
    super.initState();
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
  }

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

  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en, d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      // ✅ include visibility in hash so re-seed fires when visibility changes
      ...d.socialLinks.map((s) => s.iconUrl + s.visibility.toString()),
      d.branding.logoUrl,
    ]);
    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    for (final nb in _navBtns) nb.dispose();
    _navBtns.clear();
    for (final btn in d.navButtons) {
      final item = _NavBtnItem();
      item.nameEn.text = btn.name.en;
      item.nameAr.text = btn.name.ar;
      item.route = btn.route.isEmpty ? null : btn.route;
      _navBtns.add(item);
    }

    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i].descEn.text = d.sections[i].description.en;
      _sections[i].descAr.text = d.sections[i].description.ar;
      _sections[i].image = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl) : const _PickedImage();
      _sections[i].icon = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl) : const _PickedImage();
    }

    _primaryColor.text   = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _engFont = d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont  = d.branding.arabicFont.isEmpty  ? 'Cairo' : d.branding.arabicFont;
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl) : const _PickedImage();

    while (_footerColumns.length > d.footerColumns.length) {
      _disposeColumn(_footerColumns.removeLast());
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

    // ✅ Seed social links WITH visibility from model
    for (final l in _links) (l['text'] as TextEditingController).dispose();
    _links.clear();
    for (final sl in d.socialLinks) {
      _links.add({
        'text':       TextEditingController(text: sl.url),
        'icon':       sl.iconUrl.isNotEmpty
            ? _PickedImage(url: sl.iconUrl)
            : const _PickedImage(),
        'visibility': sl.visibility, // ✅ load from Firestore
      });
    }

    print('[HomeEditPage] _seedFromModel: seeded ${_links.length} social links');
    for (var i = 0; i < _links.length; i++) {
      print('[HomeEditPage]   link[$i] visibility=${_links[i]['visibility']}');
    }
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
    for (final nb in _navBtns) nb.dispose();
    for (final s in _sections) s.dispose();
    for (final col in _footerColumns) _disposeColumn(col);
    for (final l in _links) (l['text'] as TextEditingController).dispose();
    _primaryColor.dispose(); _secondaryColor.dispose();
    _copyRightEn.dispose(); _copyRightAr.dispose();
    super.dispose();
  }

  Future<void> _save(HomeCmsCubit cubit, {String publishStatus = 'published'}) async {
    setState(() { _submitted = true; _isSaving = true; });
    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(en: _shortDescEn.text, ar: _shortDescAr.text);

      final currentModel = cubit.current;

      for (var i = 0; i < _navBtns.length; i++) {
        if (i < currentModel.navButtons.length) {
          final id = currentModel.navButtons[i].id;
          cubit.updateNavButtonName(id, en: _navBtns[i].nameEn.text, ar: _navBtns[i].nameAr.text);
          cubit.updateNavButtonRoute(id, _navBtns[i].route ?? '');
        }
      }

      for (var i = 0; i < _sections.length; i++) {
        cubit.updateSectionDescription(i,
            en: _sections[i].descEn.text,
            ar: _sections[i].descAr.text);
        if (_sections[i].image.bytes != null) await cubit.uploadSectionImage(i, _sections[i].image.bytes!);
        if (_sections[i].icon.bytes  != null) await cubit.uploadSectionIcon(i, _sections[i].icon.bytes!);
      }

      while (cubit.current.footerColumns.length < _footerColumns.length) cubit.addFooterColumn();
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
        while (cubit.current.footerColumns[i].labels.length < labels.length) cubit.addFooterLabel(colId);
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId = cubit.current.footerColumns[i].labels[li].id;
          cubit.updateFooterLabel(colId, lblId,
              en: labels[li]['en']!.text, ar: labels[li]['ar']!.text);
        }
      }

      // ✅ Social links — save url + visibility to cubit → Firestore
      while (cubit.current.socialLinks.length < _links.length) cubit.addSocialLink();
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id         = cubit.current.socialLinks[i].id;
        final url        = (_links[i]['text'] as TextEditingController).text;
        final visibility = _links[i]['visibility'] as bool? ?? true; // ✅

        print('[HomeEditPage] _save: socialLink[$i] id=$id '
            'url="$url" visibility=$visibility');

        cubit.updateSocialLink(
          id,
          url:        url,
          visibility: visibility, // ✅ saved to Firestore via cubit
        );

        final icon = _links[i]['icon'] as _PickedImage;
        if (icon.bytes != null) await cubit.uploadSocialLinkIcon(id, icon.bytes!);
      }

      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      await cubit.save(publishStatus: publishStatus);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
              backgroundColor: _C.back,
              body: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(height: 20.h),

                      AdminSubNavBar(activeIndex: 1),

                      SizedBox(height: 20.h),
                      Container(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text('Editing Home',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary, fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _accordion(key: 'headings', title: 'Headings', children: [
                              SizedBox(height: 16.h),
                              _headingsSection()]),


                            _gap(),


                            _gap(),

                            ...List.generate(4, (i) => Column(children: [
                              _accordion(key: 's$i', title: _kSectionTitles[i], children: [_sectionEdit(i)]),
                              _gap(),
                            ])),


                            _accordion(key: 'schedule', title: 'Publish Schedule', children: [_publishScheduleSection()]),
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
            ),
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
                      Text('Uploading images & saving data',
                          style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
                    ]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _headingsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: CustomValidatedTextFieldMaster(
          label: 'Title', hint: 'Text Here', controller: _titleEn, height: 36,
          submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: _resolvedPrimary,
        )),
        SizedBox(width: 16.w),
        Expanded(child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'العنوان', hint: 'أكتب هنا', controller: _titleAr, height: 36,
            submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        )),
      ]),

      CustomValidatedTextFieldMaster(
        label: 'Short Description', hint: 'Text Here', controller: _shortDescEn,
        height: 80, maxLines: 3, submitted: _submitted,
        textDirection: TextDirection.ltr, textAlign: TextAlign.left,
        primaryColor: _resolvedPrimary,
      ),

      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'وصف مختصر', hint: 'أكتب هنا', controller: _shortDescAr,
          height: 80, maxLines: 3, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          primaryColor: _resolvedPrimary,
        ),
      ),
    ],
  );

  Widget _navButtonSection(HomeCmsCubit cubit) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...List.generate(_navBtns.length, (i) => _buildNavBtnRow(i)),
      SizedBox(height: 8.h),
      GestureDetector(
        onTap: () {
          setState(() => _navBtns.add(_NavBtnItem()));
          cubit.addNavButton();
        },
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

  Widget _buildNavBtnRow(int i) {
    final btn = _navBtns[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_ordinal(i + 1)} Button', style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
            GestureDetector(
              onTap: () => setState(() {
                final removed = _navBtns.removeAt(i);
                WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
              }),
              child: Container(
                width: 20.w, height: 20.h,
                decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
                child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(children: [
          Expanded(child: CustomValidatedTextFieldMaster(
            label: 'Button Name', hint: 'Text Here', controller: btn.nameEn, height: 36,
            submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.left,
            primaryColor: _resolvedPrimary,
          )),
          SizedBox(width: 16.w),
          Expanded(child: Directionality(
            textDirection: TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'عنوان الزر', hint: 'أكتب هنا', controller: btn.nameAr, height: 36,
              submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              primaryColor: _resolvedPrimary,
            ),
          )),
        ]),
        SizedBox(height: 8.h),
        Row(children: [
          Expanded(child: CustomDropdownFormFieldInvMaster(
            label: 'Button Navigation',
            hint: Text('Services', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
            selectedValue: btn.route, items: _kRoutes,
            widthIcon: 18, heightIcon: 18, height: 36,
            onChanged: (val) => setState(() => btn.route = val),
          )),
          SizedBox(width: 10.w),
          const Expanded(child: SizedBox()),
        ]),
      ]),
    );
  }

  Widget _sectionEdit(int i) {
    final sec = _sections[i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Image', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgBox(picked: sec.image, onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => sec.image = p);
            }),
          ]),
          SizedBox(width: 24.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgBox(picked: sec.icon, isAdd: true, onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => sec.icon = p);
            }),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SizedBox(height: 6.h),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Visibility', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
              SizedBox(width: 8.w),
              FlutterSwitch(
                width: 42.sp, height: 24.sp, padding: 3.sp,
                borderRadius: 20.sp, toggleSize: 18.sp,
                activeColor: _C.primary, inactiveColor: Colors.grey.withOpacity(.16),
                value: sec.visibility,
                onToggle: (val) => setState(() => sec.visibility = val),
              ),
            ]),
          ]),
        ]),
        SizedBox(height: 14.h),
        CustomValidatedTextFieldMaster(
          label: 'Description', hint: 'Text Here', controller: sec.descEn,
          height: 80, maxLines: 3, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 10.h),
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف', hint: 'أكتب هنا', controller: sec.descAr,
            height: 80, maxLines: 3, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ],
    );
  }

  // ── Social Links ──────────────────────────────────────────────────────────

  Widget _linksSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
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
        onTap: () => setState(() => _links.add({
          'text':       TextEditingController(),
          'icon':       const _PickedImage(),
          'visibility': true, // ✅ new links start visible
        })),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: _C.border),
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

  Widget _linkItem(int i) {
    final bool currentVisibility = _links[i]['visibility'] as bool? ?? true; // ✅

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            GestureDetector(
              onTap: () => setState(() {
                final removed = _links.removeAt(i);
                (removed['text'] as TextEditingController).dispose();
              }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
                child: Text('Remove', style: StyleText.fontSize11Weight400.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(children: [
          _imgBox(
            picked: _links[i]['icon'] as _PickedImage,
            isAdd: true,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => _links[i]['icon'] = p);
            },
          ),
          const Spacer(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Visibility', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            SizedBox(width: 6.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: _C.primary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: currentVisibility,
              onToggle: (val) {
                print('[HomeEditPage] link[$i] visibility → $val');
                setState(() => _links[i]['visibility'] = val); // ✅ update map
              },
            ),
          ]),
        ]),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          label: 'Insert Link',
          hint: 'Insert Links',
          controller: _links[i]['text'] as TextEditingController,
          height: 36,
          submitted: _submitted,
          primaryColor: _resolvedPrimary,
        ),
      ],
    );
  }

  Widget _imgBox({required _PickedImage picked, bool isAdd = false, VoidCallback? onPick}) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(picked.bytes!, width: 30.w, height: 30.h, fit: BoxFit.contain),
          ),
        ),      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(
              picked.url!, width: 30.w, height: 30.h, fit: BoxFit.contain,
              placeholderBuilder: (_) => const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(child: Icon(isAdd ? Icons.add : Icons.image_outlined, color: Colors.grey, size: 22.sp)),
      );
    }
    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 22.w, height: 22.h,
            decoration: BoxDecoration(color: _C.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Center(child: Icon(Icons.edit, color: Colors.white, size: 11.sp)),
          ),
        ),
      ),
    ]);
  }

  Widget _publishScheduleSection() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            Text('Publish Date', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _publishDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _C.primary)),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _publishDate = picked);
              },
              child: Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
                child: Row(children: [
                  Expanded(child: Text(
                    _publishDate != null
                        ? '${_publishDate!.day}/${_publishDate!.month}/${_publishDate!.year}'
                        : 'Select Date',
                    style: StyleText.fontSize12Weight400.copyWith(color: _publishDate != null ? _C.labelText : _C.hintText),
                  )),
                  CustomSvg(assetPath: "assets/control/Calendar.svg",width: 20.w,height: 20.h,fit:  BoxFit.scaleDown,),
                ]),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 15.sp),
      Expanded(child: Container()),

    ],
  );

  Widget _bottomButtons(HomeCmsCubit cubit) => Column(children: [
    Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => context.pushNamed('home_preview'),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(6.r)),
            child: Center(child: Text('Preview', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
          ),
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: GestureDetector(
          onTap: _isSaving ? null : () => _save(cubit, publishStatus: 'published'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44.h,
            decoration: BoxDecoration(
              color: _isSaving ? _C.primary.withOpacity(0.5) : _C.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(child: _isSaving
                ? SizedBox(width: 18.w, height: 18.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Publish', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
          ),
        ),
      ),
    ]),
    SizedBox(height: 10.h),
    Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(6.r)),
            child: Center(child: Text('Discard', style: StyleText.fontSize14Weight600.copyWith(color: _C.labelText))),
          ),
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: GestureDetector(
          onTap: _isSaving ? null : () => _save(cubit, publishStatus: 'draft'),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(6.r)),
            child: Center(child: Text('Save For Later', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
          ),
        ),
      ),
    ]),
  ]);

  Widget _accordion({required String key, required String title, required List<Widget> children}) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ]),
    );
  }

  Widget _gap() => SizedBox(height: 10.h);

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}