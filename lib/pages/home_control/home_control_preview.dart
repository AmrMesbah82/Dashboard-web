/// ******************* FILE INFO *******************
/// File Name: home_page_preview.dart
/// Description: CMS Preview for Home Page — reads live data from HomeCmsCubit.
/// Created by: Amr Mesbah

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  static const Color remove    = Color(0xFFE53935);
}

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
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

// ─────────────────────────────────────────────────────────────────────────────

class HomePagePreview extends StatefulWidget {
  const HomePagePreview({super.key});
  @override
  State<HomePagePreview> createState() => _HomePagePreviewState();
}

class _HomePagePreviewState extends State<HomePagePreview> {

  bool _submitted = false;
  int  _selectedTab = 0;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.generate(3, (_) => {
    'nameEn': TextEditingController(),
    'nameAr': TextEditingController(),
  });
  final List<String?> _navRoutes = List.filled(3, null, growable: true);

  // ── Sections 1-4 ─────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections = List.generate(4, (_) => {
    'textBox':       TextEditingController(text: '#008037'),
    'description':   TextEditingController(),
    'descriptionAr': TextEditingController(),
  });

  // Section images & icons — holds either local bytes or remote URL
  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4, (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Header titles ─────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _headerTitles = List.generate(5, (_) => {
    'en': TextEditingController(),
    'ar': TextEditingController(),
  });

  // ── Footer columns ────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _footerCols = List.generate(3, (_) => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'labelEn': TextEditingController(),
    'labelAr': TextEditingController(),
  });
  final List<String?> _footerRoutes = List.filled(3, null, growable: true);

  // ── Links (4) ─────────────────────────────────────────────────────────────
  final List<TextEditingController> _linkTexts = List.generate(4, (_) => TextEditingController());
  final List<_PickedImage> _linkIcons = List.generate(4, (_) => const _PickedImage());

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

  // ── Seed tracking ─────────────────────────────────────────────────────────
  int? _seededModelHash;

  // ── Image picking ─────────────────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed  = false;
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
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
      reader.readAsArrayBuffer(files.first);
    });
    input.click();
    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) { completed = true; completer.complete(null); }
    });
    return completer.future;
  }

  // ── Seed from model ───────────────────────────────────────────────────────
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
    for (var i = 0; i < _navBtns.length && i < d.navButtons.length; i++) {
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

    // Header
    for (var i = 0; i < _headerTitles.length && i < d.headerItems.length; i++) {
      _headerTitles[i]['en']!.text = d.headerItems[i].title.en;
      _headerTitles[i]['ar']!.text = d.headerItems[i].title.ar;
    }

    // Footer
    for (var i = 0; i < _footerCols.length && i < d.footerColumns.length; i++) {
      _footerCols[i]['titleEn']!.text = d.footerColumns[i].title.en;
      _footerCols[i]['titleAr']!.text = d.footerColumns[i].title.ar;
      if (d.footerColumns[i].labels.isNotEmpty) {
        _footerCols[i]['labelEn']!.text = d.footerColumns[i].labels.first.label.en;
        _footerCols[i]['labelAr']!.text = d.footerColumns[i].labels.first.label.ar;
      }
      _footerRoutes[i] = d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;
    }

    // Links
    for (var i = 0; i < _linkTexts.length && i < d.socialLinks.length; i++) {
      _linkTexts[i].text = d.socialLinks[i].url;
      _linkIcons[i] = d.socialLinks[i].iconUrl.isNotEmpty
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

  @override
  void dispose() {
    _titleEn.dispose(); _titleAr.dispose();
    _shortDescEn.dispose(); _shortDescAr.dispose();
    for (final m in [..._navBtns, ..._sections, ..._headerTitles, ..._footerCols]) {
      for (final c in m.values) c.dispose();
    }
    for (final c in _linkTexts) c.dispose();
    _primaryColor.dispose(); _secondaryColor.dispose();
    _copyRightEn.dispose(); _copyRightAr.dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _seedFromModel(state.data));
          });
        }
        if (state is HomeCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _seedFromModel(state.data));
          });
        }

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Scaffold(
          backgroundColor: _C.sectionBg,
          body: Column(
            children: [
              AppNavbar(currentRoute: '/'),
              _topBar(),
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
                          child: Center(child: Text('Last Updated At',
                              style: StyleText.fontSize18Weight500.copyWith(color: _C.primary))),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.pushNamed('home_edit'),
                          child: Container(
                            width: 205.w, height: 40.h,
                            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
                            child: Center(
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('Edit Home View',
                                    style: StyleText.fontSize18Weight500.copyWith(color: _C.primary)),
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
        );
      },
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topBar() => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 14.h, right: 24.w),
          child: Text('Home Layout',
              style: StyleText.fontSize45Weight600.copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
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

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({required String key, required String title, required List<Widget> children}) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          color: _C.cardBg, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: _C.border)),
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
              Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
      ]),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────
  Widget _headingsSection() => _accordion(
    key: 'headings', title: 'Headings',
    children: [
      _biRow('Title', 'العنوان', _titleEn, _titleAr, useRow: true),
      SizedBox(height: 14.h),
      _biRow('Short Description', 'وصف مختصر', _shortDescEn, _shortDescAr, maxLines: 3, showCharCount: true),
    ],
  );

  Widget _navBtnSection() => _accordion(
    key: 'navBtn', title: 'Navigation Button',
    children: List.generate(_navBtns.length, (i) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${i + 1}${_ord(i + 1)} Button',
            style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
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
  );

  Widget _sectionCard(int index, String title) => _accordion(
    key: 's${index + 1}', title: title,
    children: [
      Row(children: [
        _imgPickerCol(
          label: 'Image',
          picked: _sectionImages[index]['image']!,
          placeholderAsset: 'assets/home_control/image.svg',
          pickIconAsset: 'assets/home_control/camera.svg',
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _sectionImages[index]['image'] = p);
          },
        ),
        SizedBox(width: 20.w),
        _imgPickerCol(
          label: 'Icon',
          picked: _sectionImages[index]['icon']!,
          placeholderAsset: 'assets/home_control/edit_icon.svg',
          pickIconAsset: 'assets/home_control/camera.svg',
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _sectionImages[index]['icon'] = p);
          },
        ),
      ]),
      SizedBox(height: 14.h),
      _colorRow(_sections[index]['textBox']!, label: 'Text Box'),
      SizedBox(height: 14.h),
      CustomValidatedTextFieldMaster(
        label: 'Description', hint: 'None', controller: _sections[index]['description']!,
        maxLines: 5, height: 100, showCharCount: true, maxLength: 500, submitted: _submitted,
        textDirection: TextDirection.ltr, textAlign: TextAlign.left,
      ),
      SizedBox(height: 10.h),
      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'الوصف', hint: 'أدخل النص هنا', controller: _sections[index]['descriptionAr']!,
          maxLines: 5, height: 100, showCharCount: true, maxLength: 500, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
        ),
      ),
    ],
  );

  Widget _headerSection() => _accordion(
    key: 'header', title: 'Header',
    children: List.generate(5, (i) => Padding(
      padding: EdgeInsets.only(bottom: i < 4 ? 14.h : 0),
      child: _biRow('Title', 'العنوان', _headerTitles[i]['en']!, _headerTitles[i]['ar']!, useRow: true),
    )),
  );

  Widget _footerSection() => _accordion(
    key: 'footer', title: 'Footer',
    children: List.generate(3, (i) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (i > 0) SizedBox(height: 12.h),
        Text('${i + 1}${_ord(i + 1)} Column',
            style: StyleText.fontSize13Weight600.copyWith(color: _C.labelText)),
        SizedBox(height: 5.h),
        _biRow('Group Title', 'عنوان المجموعة', _footerCols[i]['titleEn']!, _footerCols[i]['titleAr']!, useRow: true),
        SizedBox(height: 5.h),
        _biRow('Label', 'العنوان', _footerCols[i]['labelEn']!, _footerCols[i]['labelAr']!, useRow: true),
        SizedBox(height: 5.h),
        Row(children: [
          Expanded(child: CustomDropdownFormFieldInvMaster(
            label: 'Navigation',
            hint: Text('Select route', style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText)),
            selectedValue: _footerRoutes[i], items: _kRoutes,
            widthIcon: 18, heightIcon: 18, height: 36,
            onChanged: (val) => setState(() => _footerRoutes[i] = val),
          )),
          SizedBox(width: 10.w),
          const Expanded(child: SizedBox()),
        ]),
        SizedBox(height: 12.h),
      ],
    )),
  );

  Widget _linksSection() => _accordion(
    key: 'links', title: 'Links',
    children: [
      Row(children: [Expanded(child: _linkItem(0)), SizedBox(width: 16.w), Expanded(child: _linkItem(1))]),
      SizedBox(height: 14.h),
      Row(children: [Expanded(child: _linkItem(2)), SizedBox(width: 16.w), Expanded(child: _linkItem(3))]),
    ],
  );

  Widget _linkItem(int i) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Icon'),
      SizedBox(height: 5.h),
      _imgBox(
        picked: _linkIcons[i],
        placeholderAsset: 'assets/home_control/edit_icon.svg',
        pickIconAsset: 'assets/home_control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _linkIcons[i] = p);
        },
      ),
      SizedBox(height: 8.h),
      CustomValidatedTextFieldMaster(
        label: 'Link', hint: 'https://', controller: _linkTexts[i], height: 36, submitted: _submitted,
      ),
    ],
  );

  Widget _logoSection() => _accordion(
    key: 'logo', title: 'Logo and Copy Right',
    children: [
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
        Expanded(child: _colorRow(_primaryColor, label: 'Primary Color')),
        SizedBox(width: 16.w),
        Expanded(child: _colorRow(_secondaryColor, label: 'Secondary')),
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

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _biRow(String enLabel, String arLabel,
      TextEditingController enCtrl, TextEditingController arCtrl, {
        int maxLines = 1, bool showCharCount = false, bool useRow = false,
      }) {
    final double fieldH = maxLines > 1 ? 80 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel, hint: 'None', controller: enCtrl,
      maxLines: maxLines, height: fieldH, showCharCount: showCharCount, submitted: _submitted,
      textDirection: TextDirection.ltr, textAlign: TextAlign.left,
    );
    final arField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel, hint: 'اكتب هنا', controller: arCtrl,
        maxLines: maxLines, height: fieldH, showCharCount: showCharCount, submitted: _submitted,
        textDirection: TextDirection.rtl, textAlign: TextAlign.right,
      ),
    );
    if (useRow) return Row(children: [Expanded(child: enField), SizedBox(width: 16.w), Expanded(child: arField)]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [enField, SizedBox(height: 10.h), arField]);
  }

  Widget _sectionLabel(String text) =>
      Text(text, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _colorRow(TextEditingController ctrl, {String? label}) {
    Color dot = _C.primary;
    try {
      final hex = ctrl.text.replaceAll('#', '');
      if (hex.length == 6) dot = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[_sectionLabel(label), SizedBox(height: 5.h)],
        SizedBox(
          height: 36.h,
          child: TextFormField(
            controller: ctrl,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '#008037',
              hintStyle: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
              filled: true, fillColor: AppColors.background, isDense: true, counterText: '',
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  width: 16.w, height: 16.h,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle, border: Border.all(color: _C.border)),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
              enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: Colors.transparent)),
              focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: BorderSide(color: AppColors.primary, width: 1)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r), borderSide: const BorderSide(color: Colors.transparent)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Image box — shows real image (URL or bytes) or placeholder ────────────
  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/home_control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.url != null && picked.url!.isNotEmpty) {
      content = ClipOval(child: Image.network(
        picked.url!,
        key: ValueKey(picked.url),
        width: 100.w, height: 100.h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderCircle(placeholderAsset),
      ));
    } else if (picked.bytes != null) {
      content = ClipOval(child: Image.memory(
        picked.bytes!, width: 100.w, height: 100.h, fit: BoxFit.cover,
      ));
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
            decoration: BoxDecoration(
                color: _C.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Center(child: CustomSvg(assetPath: pickIconAsset, width: 16.w, height: 16.h, fit: BoxFit.fill)),
          ),
        ),
      ),
    ]);
  }

  Widget _imgPickerCol({
    required String label,
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/home_control/camera.svg',
    VoidCallback? onPick,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel(label),
        SizedBox(height: 5.h),
        _imgBox(picked: picked, placeholderAsset: placeholderAsset, pickIconAsset: pickIconAsset, onPick: onPick),
      ]);

  Widget _placeholderCircle(String assetPath) => Container(
    width: 100.w, height: 100.h,
    decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(child: CustomSvg(assetPath: assetPath, width: 40.w, height: 40.h, fit: BoxFit.fill)),
  );

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}