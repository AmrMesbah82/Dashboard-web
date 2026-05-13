// ******************* FILE INFO *******************
// File Name: contact_us_cms_edit_page.dart
// Created by: Claude Assistant
// UPDATED: Follow Us extracted as its own accordion with Title EN/AR + social links grid
// UPDATED: followUsTitle added to ContactUsCmsModel and fully wired

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';

import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import '../../core/custom_dialog.dart';
import '../../core/custom_svg.dart';
import '../dashboard/contact_page/contact_us_main_page.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsCmsEditPage extends StatefulWidget {
  const ContactUsCmsEditPage({super.key});

  @override
  State<ContactUsCmsEditPage> createState() => _ContactUsCmsEditPageState();
}

class _ContactUsCmsEditPageState extends State<ContactUsCmsEditPage> {

  // ── Info section ──
  final _subDescEnCtrl = TextEditingController();
  final _subDescArCtrl = TextEditingController();
  final _emailCtrl     = TextEditingController();

  // ── Follow Us section ──
  final _followTitleEnCtrl = TextEditingController();
  final _followTitleArCtrl = TextEditingController();

  // ── Social Icons (Follow Us) ──
  final List<_SocialIconItem> _socialIconItems = [];
  int _socialIconCounter = 0;

  // ── Office Locations ──
  final List<_OfficeLocationItem> _officeLocationItems = [];
  int _officeLocationCounter = 0;

  // ── Confirm Message ──
  final _confirmTitleEnCtrl = TextEditingController();
  final _confirmTitleArCtrl = TextEditingController();
  final _confirmDescEnCtrl  = TextEditingController();
  final _confirmDescArCtrl  = TextEditingController();
  Uint8List? _confirmSvgBytes;
  String     _confirmSvgUrl = '';

  // ── Accordion open/close ──
  bool _infoOpen      = true;
  bool _followUsOpen  = true;
  bool _officesOpen   = true;
  bool _confirmOpen   = true;

  bool _submitted  = false;
  bool _seeded     = false;
  bool _isSaving   = false;
  bool _hasChanges = false;

  // ── Validation tracking ──
  bool _subDescEnValid       = true;
  bool _subDescArValid       = true;
  bool _emailValid           = true;
  bool _followTitleEnValid   = true;
  bool _followTitleArValid   = true;
  bool _confirmTitleEnValid  = true;
  bool _confirmTitleArValid  = true;
  bool _confirmDescEnValid   = true;
  bool _confirmDescArValid   = true;

  // ── Store original values ──
  late String _originalSubDescEn;
  late String _originalSubDescAr;
  late String _originalEmail;
  late String _originalFollowTitleEn;
  late String _originalFollowTitleAr;
  late String _originalConfirmTitleEn;
  late String _originalConfirmTitleAr;
  late String _originalConfirmDescEn;
  late String _originalConfirmDescAr;

  // ── Footer social links (loaded from HomeCmsCubit) ──
  List<SocialLinkModel> _footerSocialLinks = [];

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.read<ContactUsCmsCubit>().load();
    context.read<HomeCmsCubit>().load();

    _subDescEnCtrl.addListener(_checkForChangesAndValidate);
    _subDescArCtrl.addListener(_checkForChangesAndValidate);
    _emailCtrl.addListener(_checkForChangesAndValidate);
    _followTitleEnCtrl.addListener(_checkForChangesAndValidate);
    _followTitleArCtrl.addListener(_checkForChangesAndValidate);
    _confirmTitleEnCtrl.addListener(_checkForChangesAndValidate);
    _confirmTitleArCtrl.addListener(_checkForChangesAndValidate);
    _confirmDescEnCtrl.addListener(_checkForChangesAndValidate);
    _confirmDescArCtrl.addListener(_checkForChangesAndValidate);
  }

  @override
  void dispose() {
    _subDescEnCtrl.removeListener(_checkForChangesAndValidate);
    _subDescArCtrl.removeListener(_checkForChangesAndValidate);
    _emailCtrl.removeListener(_checkForChangesAndValidate);
    _followTitleEnCtrl.removeListener(_checkForChangesAndValidate);
    _followTitleArCtrl.removeListener(_checkForChangesAndValidate);
    _confirmTitleEnCtrl.removeListener(_checkForChangesAndValidate);
    _confirmTitleArCtrl.removeListener(_checkForChangesAndValidate);
    _confirmDescEnCtrl.removeListener(_checkForChangesAndValidate);
    _confirmDescArCtrl.removeListener(_checkForChangesAndValidate);

    _subDescEnCtrl.dispose();
    _subDescArCtrl.dispose();
    _emailCtrl.dispose();
    _followTitleEnCtrl.dispose();
    _followTitleArCtrl.dispose();
    _confirmTitleEnCtrl.dispose();
    _confirmTitleArCtrl.dispose();
    _confirmDescEnCtrl.dispose();
    _confirmDescArCtrl.dispose();

    for (final o in _officeLocationItems) {
      o.locationNameEnCtrl.dispose();
      o.locationNameArCtrl.dispose();
      o.text1EnCtrl.dispose();
      o.text1ArCtrl.dispose();
      o.text2EnCtrl.dispose();
      o.text2ArCtrl.dispose();
      o.mapLinkCtrl.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION & CHANGE DETECTION
  // ─────────────────────────────────────────────────────────────────────────

  void _checkForChangesAndValidate() {
    final bool hasChanges =
        _subDescEnCtrl.text     != _originalSubDescEn      ||
            _subDescArCtrl.text     != _originalSubDescAr      ||
            _emailCtrl.text         != _originalEmail          ||
            _followTitleEnCtrl.text != _originalFollowTitleEn  ||
            _followTitleArCtrl.text != _originalFollowTitleAr  ||
            _confirmTitleEnCtrl.text != _originalConfirmTitleEn ||
            _confirmTitleArCtrl.text != _originalConfirmTitleAr ||
            _confirmDescEnCtrl.text  != _originalConfirmDescEn  ||
            _confirmDescArCtrl.text  != _originalConfirmDescAr;

    final bool subDescEnValid      = _validateSingleField(_subDescEnCtrl.text,      'en', isRequired: true);
    final bool subDescArValid      = _validateSingleField(_subDescArCtrl.text,      'ar', isRequired: true);
    final bool emailValid          = _validateEmail(_emailCtrl.text);
    final bool followTitleEnValid  = _validateSingleField(_followTitleEnCtrl.text,  'en', isRequired: true);
    final bool followTitleArValid  = _validateSingleField(_followTitleArCtrl.text,  'ar', isRequired: true);
    final bool confirmTitleEnValid = _validateSingleField(_confirmTitleEnCtrl.text, 'en', isRequired: true);
    final bool confirmTitleArValid = _validateSingleField(_confirmTitleArCtrl.text, 'ar', isRequired: true);
    final bool confirmDescEnValid  = _validateSingleField(_confirmDescEnCtrl.text,  'en', isRequired: true);
    final bool confirmDescArValid  = _validateSingleField(_confirmDescArCtrl.text,  'ar', isRequired: true);

    if (hasChanges         != _hasChanges         ||
        subDescEnValid     != _subDescEnValid      ||
        subDescArValid     != _subDescArValid      ||
        emailValid         != _emailValid          ||
        followTitleEnValid != _followTitleEnValid  ||
        followTitleArValid != _followTitleArValid  ||
        confirmTitleEnValid != _confirmTitleEnValid ||
        confirmTitleArValid != _confirmTitleArValid ||
        confirmDescEnValid  != _confirmDescEnValid  ||
        confirmDescArValid  != _confirmDescArValid) {
      setState(() {
        _hasChanges         = hasChanges;
        _subDescEnValid     = subDescEnValid;
        _subDescArValid     = subDescArValid;
        _emailValid         = emailValid;
        _followTitleEnValid = followTitleEnValid;
        _followTitleArValid = followTitleArValid;
        _confirmTitleEnValid = confirmTitleEnValid;
        _confirmTitleArValid = confirmTitleArValid;
        _confirmDescEnValid  = confirmDescEnValid;
        _confirmDescArValid  = confirmDescArValid;
      });
    }
  }

  bool _validateSingleField(String text, String language, {required bool isRequired}) {
    if (isRequired && text.trim().isEmpty) return false;
    if (text.isEmpty) return true;
    final bool hasArabic  = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    if (language == 'en' && hasArabic)  return false;
    if (language == 'ar' && hasEnglish) return false;
    return true;
  }

  bool _validateEmail(String email) {
    if (email.trim().isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool get _isFormValid {
    if (!_subDescEnValid     || !_subDescArValid      || !_emailValid         ||
        !_followTitleEnValid || !_followTitleArValid   ||
        !_confirmTitleEnValid || !_confirmTitleArValid ||
        !_confirmDescEnValid  || !_confirmDescArValid) {
      return false;
    }
    for (final o in _officeLocationItems) {
      if (o.locationNameEnCtrl.text.trim().isEmpty ||
          o.locationNameArCtrl.text.trim().isEmpty ||
          o.text1EnCtrl.text.trim().isEmpty        ||
          o.text1ArCtrl.text.trim().isEmpty) {
        return false;
      }
    }
    for (final s in _socialIconItems) {
      if (s.selectedIndex == null) return false;
    }
    return true;
  }

  bool get _isPublishEnabled => _hasChanges && !_isSaving && _isFormValid;

  // ─────────────────────────────────────────────────────────────────────────
  // SEED FROM MODEL
  // ─────────────────────────────────────────────────────────────────────────

  void _seedFromModel(ContactUsCmsModel m) {
    if (_seeded) return;
    _seeded = true;

    // Info
    _subDescEnCtrl.text = m.subDescription.en;
    _subDescArCtrl.text = m.subDescription.ar;
    _emailCtrl.text     = m.email;
    _originalSubDescEn  = m.subDescription.en;
    _originalSubDescAr  = m.subDescription.ar;
    _originalEmail      = m.email;

    // Follow Us title
    _followTitleEnCtrl.text = m.followUsTitle.en;
    _followTitleArCtrl.text = m.followUsTitle.ar;
    _originalFollowTitleEn  = m.followUsTitle.en;
    _originalFollowTitleAr  = m.followUsTitle.ar;

    // Social icons
    _socialIconItems.clear();
    for (final s in m.socialIcons) {
      final item = _SocialIconItem(id: s.id, counter: ++_socialIconCounter);
      final idx  = _footerSocialLinks.indexWhere((l) => l.url == s.link);
      item.selectedIndex = idx >= 0 ? idx : null;
      item.iconUrl       = s.iconUrl;
      _socialIconItems.add(item);
    }

    // Office locations
    _officeLocationItems.clear();
    for (final o in m.officeLocations) {
      final item = _OfficeLocationItem(id: o.id, counter: ++_officeLocationCounter);
      item.locationNameEnCtrl.text = o.locationName.en;
      item.locationNameArCtrl.text = o.locationName.ar;
      item.text1EnCtrl.text        = o.text1.en;
      item.text1ArCtrl.text        = o.text1.ar;
      item.text2EnCtrl.text        = o.text2.en;
      item.text2ArCtrl.text        = o.text2.ar;
      item.mapLinkCtrl.text        = o.mapLink;
      item.iconUrl                 = o.iconUrl;
      _officeLocationItems.add(item);
    }

    // Confirm message
    _confirmTitleEnCtrl.text = m.confirmMessage.title.en;
    _confirmTitleArCtrl.text = m.confirmMessage.title.ar;
    _confirmDescEnCtrl.text  = m.confirmMessage.description.en;
    _confirmDescArCtrl.text  = m.confirmMessage.description.ar;
    _confirmSvgUrl           = m.confirmMessage.svgUrl;
    _originalConfirmTitleEn  = m.confirmMessage.title.en;
    _originalConfirmTitleAr  = m.confirmMessage.title.ar;
    _originalConfirmDescEn   = m.confirmMessage.description.en;
    _originalConfirmDescAr   = m.confirmMessage.description.ar;

    _checkForChangesAndValidate();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IMAGE PICKER (SVG ONLY)
  // ─────────────────────────────────────────────────────────────────────────

  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { completer.complete(null); return; }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please select an SVG file only'), backgroundColor: _kRed),
        );
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer)   completer.complete(result.asUint8List());
          else if (result is Uint8List) completer.complete(result);
          else completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD MODEL
  // ─────────────────────────────────────────────────────────────────────────

  ContactUsCmsModel _buildModel(String status) {
    return ContactUsCmsModel(
      publishStatus: status,
      subDescription: ContactBilingualText(
        en: _subDescEnCtrl.text.trim(),
        ar: _subDescArCtrl.text.trim(),
      ),
      email: _emailCtrl.text.trim(),
      followUsTitle: ContactBilingualText(
        en: _followTitleEnCtrl.text.trim(),
        ar: _followTitleArCtrl.text.trim(),
      ),
      socialIcons: _socialIconItems.map((s) {
        final url = (s.selectedIndex != null && s.selectedIndex! < _footerSocialLinks.length)
            ? _footerSocialLinks[s.selectedIndex!].url
            : '';
        return ContactSocialIcon(id: s.id, iconUrl: s.iconUrl, link: url);
      }).toList(),
      officeLocations: _officeLocationItems.map((o) => ContactOfficeLocation(
        id:           o.id,
        iconUrl:      o.iconUrl,
        mapLink:      o.mapLinkCtrl.text.trim(),
        locationName: ContactBilingualText(en: o.locationNameEnCtrl.text.trim(), ar: o.locationNameArCtrl.text.trim()),
        text1:        ContactBilingualText(en: o.text1EnCtrl.text.trim(),        ar: o.text1ArCtrl.text.trim()),
        text2:        ContactBilingualText(en: o.text2EnCtrl.text.trim(),        ar: o.text2ArCtrl.text.trim()),
      )).toList(),
      confirmMessage: ContactConfirmMessage(
        svgUrl:      _confirmSvgUrl,
        title:       ContactBilingualText(en: _confirmTitleEnCtrl.text.trim(), ar: _confirmTitleArCtrl.text.trim()),
        description: ContactBilingualText(en: _confirmDescEnCtrl.text.trim(),  ar: _confirmDescArCtrl.text.trim()),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COLLECT UPLOADS
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    for (final s in _socialIconItems) {
      if (s.iconBytes != null) uploads['contact_cms/social_icons/${s.id}/icon'] = s.iconBytes!;
    }
    for (final o in _officeLocationItems) {
      if (o.iconBytes != null) uploads['contact_cms/office_locations/${o.id}/icon'] = o.iconBytes!;
    }
    if (_confirmSvgBytes != null) uploads['contact_cms/confirm_message/svg'] = _confirmSvgBytes!;
    return uploads;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATE ALL
  // ─────────────────────────────────────────────────────────────────────────

  bool _validateAllFields() {
    final requiredCtrls = [
      _subDescEnCtrl, _subDescArCtrl, _emailCtrl,
      _followTitleEnCtrl, _followTitleArCtrl,
      _confirmTitleEnCtrl, _confirmTitleArCtrl,
      _confirmDescEnCtrl, _confirmDescArCtrl,
      for (final o in _officeLocationItems) ...[
        o.locationNameEnCtrl, o.locationNameArCtrl,
        o.text1EnCtrl,        o.text1ArCtrl,
      ],
    ];
    return !requiredCtrls.any((c) => c.text.trim().isEmpty);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validateAllFields()) return;

    setState(() => _isSaving = true);
    final model   = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<ContactUsCmsCubit>().save(
      model:        model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );

    _originalSubDescEn      = _subDescEnCtrl.text;
    _originalSubDescAr      = _subDescArCtrl.text;
    _originalEmail          = _emailCtrl.text;
    _originalFollowTitleEn  = _followTitleEnCtrl.text;
    _originalFollowTitleAr  = _followTitleArCtrl.text;
    _originalConfirmTitleEn = _confirmTitleEnCtrl.text;
    _originalConfirmTitleAr = _confirmTitleArCtrl.text;
    _originalConfirmDescEn  = _confirmDescEnCtrl.text;
    _originalConfirmDescAr  = _confirmDescArCtrl.text;

    setState(() { _hasChanges = false; _isSaving = false; });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLISH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handlePublish() async {
    setState(() => _submitted = true);
    if (!_validateAllFields()) return;

    await showPublishConfirmDialog(
      context:      context,
      title:        'PUBLISH CONTACT US PAGE',
      subtitle:     'Do you want to publish the changes made to this Contact Us page?',
      confirmLabel: 'Publish',
      backLabel:    'Back',
      onConfirm:    () => _save('published'),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADD / REMOVE
  // ─────────────────────────────────────────────────────────────────────────

  void _addSocialIcon() => setState(() {
    _socialIconItems.add(_SocialIconItem(
      id:      'social_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_socialIconCounter,
    ));
  });

  void _removeSocialIcon(String id) =>
      setState(() => _socialIconItems.removeWhere((s) => s.id == id));

  void _addOfficeLocation() => setState(() {
    _officeLocationItems.add(_OfficeLocationItem(
      id:      'office_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_officeLocationCounter,
    ));
  });

  void _removeOfficeLocation(String id) =>
      setState(() => _officeLocationItems.removeWhere((o) => o.id == id));

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCmsCubit, HomeCmsState>(
          listener: (context, homeState) {
            final links = switch (homeState) {
              HomeCmsLoaded(:final data) => data.socialLinks,
              HomeCmsSaved(:final data)  => data.socialLinks,
              _                          => <SocialLinkModel>[],
            };
            if (links.isNotEmpty) setState(() => _footerSocialLinks = links);
          },
        ),
        BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
          listener: (context, state) {
            if (state is ContactUsCmsLoaded) setState(() => _seedFromModel(state.data));
            if (state is ContactUsCmsSaved) {
              setState(() => _isSaving = false);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const ContactUsMainPage()),
                        (route) => false,
                  );
                }
              });
            }
            if (state is ContactUsCmsError) setState(() => _isSaving = false);
          },
        ),
      ],
      child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          final isLoading = state is ContactUsCmsLoading || state is ContactUsCmsInitial;
          return Scaffold(
            backgroundColor: const Color(0xFFF1F2ED),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 1000.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 25.h),
                              AdminSubNavBar(activeIndex: 4),
                              SizedBox(height: 25.h),
                              SizedBox(
                                width: 1000.w,
                                child: isLoading
                                    ? const Center(child: CircularProgressIndicator(color: _kGreenSolid))
                                    : _buildForm(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSaving) _buildSavingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORM
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Contact Us Details',
          style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
            fontSize: 36.sp, color: _kGreen, fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        // ── Info ──
        _accordion(
          title:    'Info',
          isOpen:   _infoOpen,
          onToggle: () => setState(() => _infoOpen = !_infoOpen),
          child:    _infoSection(),
        ),
        SizedBox(height: 16.h),

        // ── Follow Us ──
        _accordion(
          title:    'Follow Us',
          isOpen:   _followUsOpen,
          onToggle: () => setState(() => _followUsOpen = !_followUsOpen),
          child:    _followUsSection(),
        ),
        SizedBox(height: 16.h),

        // ── Office Locations ──
        _accordion(
          title:    'Office Locations',
          isOpen:   _officesOpen,
          onToggle: () => setState(() => _officesOpen = !_officesOpen),
          child:    _officeLocationsSection(),
        ),
        SizedBox(height: 16.h),

        // ── Confirm Message ──
        _accordion(
          title:    'Confirm Message',
          isOpen:   _confirmOpen,
          onToggle: () => setState(() => _confirmOpen = !_confirmOpen),
          child:    _confirmMessageSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCORDION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _accordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 22.sp),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r))),
            child: child,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INFO SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _infoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        // Sub description EN
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', fillColor: Colors.white,
          controller: _subDescEnCtrl, height: 100, maxLines: 4, maxLength: 300,
          showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),

        // Sub description AR
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', fillColor: Colors.white,
          controller: _subDescArCtrl, height: 100, maxLines: 4, maxLength: 300,
          showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // Email
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint: 'Text Here', fillColor: Colors.white,
                    controller: _emailCtrl, height: 42, maxLines: 1, maxLength: 100,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 30.sp),
            const Expanded(child: Center()),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FOLLOW US SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _followUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        // Title EN + AR row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint: 'Text Here', fillColor: Colors.white,
                    controller: _followTitleEnCtrl, height: 42, maxLines: 1, maxLength: 100,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _fieldLabelAr('العنوان'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint: 'أدخل النص هنا', fillColor: Colors.white,
                    controller: _followTitleArCtrl, height: 42, maxLines: 1, maxLength: 100,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Social icons 2-column grid
        if (_socialIconItems.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing:  12.h,
              mainAxisExtent:   110.sp,
            ),
            itemCount:   _socialIconItems.length,
            itemBuilder: (context, index) => _socialIconWidget(_socialIconItems[index]),
          ),

        SizedBox(height: 16.h),

        // Add Link button
        GestureDetector(
          onTap: _addSocialIcon,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: const Color(0xFF555555), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Link', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCIAL ICON WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _socialIconWidget(_SocialIconItem s) {
    return Container(
      decoration: BoxDecoration( borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: label + remove
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('Links'),
              GestureDetector(
                onTap: () => _removeSocialIcon(s.id),
                child: Container(

                  width: 120.w,
                  height: 28.h,

                  decoration: BoxDecoration(color: _kRed, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(child: Text('Remove', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Dropdown
          _SocialLinkDropdown(
            footerLinks:   _footerSocialLinks,
            selectedIndex: s.selectedIndex,
            onChanged:     (idx) => setState(() => s.selectedIndex = idx),
            submitted:     _submitted,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OFFICE LOCATIONS SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _officeLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._officeLocationItems.map(_officeLocationWidget).toList(),
        GestureDetector(
          onTap: _addOfficeLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: const Color(0xFF555555), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Location', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _officeLocationWidget(_OfficeLocationItem o) {
    return Container(
      margin:     EdgeInsets.only(bottom: 0.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon', bytes: o.iconBytes, url: o.iconUrl, isSvg: true,
                onTap: () async { final b = await _pickSvgFile(); if (b != null) setState(() => o.iconBytes = b); },
              ),
              GestureDetector(
                onTap: () => _removeOfficeLocation(o.id),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(color: _kRed, borderRadius: BorderRadius.circular(6.r)),
                  child: Text('Remove', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Location Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('Location Name'), SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(hint: 'Text Here', controller: o.locationNameEnCtrl, height: 42, maxLines: 1, fillColor: Colors.white, maxLength: 200, submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.start, onChanged: (_) => setState(() {})),
                ]),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _fieldLabelAr('اسم الموقع'), SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(hint: 'أدخل النص هنا', controller: o.locationNameArCtrl, fillColor: Colors.white, height: 42, maxLines: 1, maxLength: 200, submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right, onChanged: (_) => setState(() {})),
                ]),
              ),
            ],
          ),

          // Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('Text'), SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(hint: 'Text Here', fillColor: Colors.white, controller: o.text1EnCtrl, height: 42, maxLines: 1, maxLength: 200, submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.start, onChanged: (_) => setState(() {})),
                ]),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _fieldLabelAr('النص'), SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(hint: 'أدخل النص هنا', fillColor: Colors.white, controller: o.text1ArCtrl, height: 42, maxLines: 1, maxLength: 200, submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right, onChanged: (_) => setState(() {})),
                ]),
              ),
            ],
          ),

          _fieldLabel('Insert Link'),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint: 'https://maps.google.com/?q=...', controller: o.mapLinkCtrl,
                  height: 42, fillColor: Colors.white, maxLines: 1, maxLength: 500,
                  submitted: false, textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 15.sp),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONFIRM MESSAGE SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _confirmMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _imageUploadCircle(
          label: 'SVG', bytes: _confirmSvgBytes, url: _confirmSvgUrl, isSvg: true,
          onTap: () async { final b = await _pickSvgFile(); if (b != null) setState(() => _confirmSvgBytes = b); },
        ),
        SizedBox(height: 20.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Title'), SizedBox(height: 8.h),
                CustomValidatedTextFieldMaster(hint: 'Text Here', fillColor: Colors.white, controller: _confirmTitleEnCtrl, height: 42, maxLines: 1, maxLength: 200, submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.start, onChanged: (_) => setState(() {})),
              ]),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _fieldLabelAr('العنوان'), SizedBox(height: 8.h),
                CustomValidatedTextFieldMaster(hint: 'أدخل النص هنا', controller: _confirmTitleArCtrl, height: 42, fillColor: Colors.white, maxLines: 1, maxLength: 200, submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right, onChanged: (_) => setState(() {})),
              ]),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Description'), SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(hint: 'Text Here', controller: _confirmDescEnCtrl, height: 100, fillColor: Colors.white, maxLines: 4, maxLength: 500, showCharCount: true, submitted: _submitted, textDirection: TextDirection.ltr, textAlign: TextAlign.start, onChanged: (_) => setState(() {})),
            SizedBox(height: 16.h),
            _fieldLabelAr('الوصف'), SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(hint: 'أدخل النص هنا', controller: _confirmDescArCtrl, fillColor: Colors.white, height: 100, maxLines: 4, maxLength: 500, showCharCount: true, submitted: _submitted, textDirection: TextDirection.rtl, textAlign: TextAlign.right, onChanged: (_) => setState(() {})),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _btn(label: 'Preview', color: const Color(0xFF608570), onTap: () => context.goNamed('contact-cms-preview'))),
            SizedBox(width: 16.w),
            Expanded(
              child: Tooltip(
                message: !_isPublishEnabled
                    ? (_hasChanges ? (_isFormValid ? '' : 'Please fix validation errors before publishing') : 'No changes to publish')
                    : '',
                child: _btn(
                  label: 'Publish',
                  color: _isPublishEnabled ? _kGreenSolid : const Color(0xFF9E9E9E),
                  onTap: _isPublishEnabled ? _handlePublish : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _btn(label: 'Discard', color: const Color(0xFF797979), onTap: () => context.goNamed('contact-cms'))),
            SizedBox(width: 15.sp),
            Expanded(child: Container()),
          ],
        ),
        if (!_isFormValid && _hasChanges)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text('Please fix validation errors above before publishing',
                style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVING OVERLAY
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w, height: 100.h,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _kGreenSolid),
              SizedBox(height: 12.h),
              Text('Saving...', style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String       label,
    required Uint8List?   bytes,
    required String       url,
    required VoidCallback onTap,
    bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w, height: 64.h,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(isSvg ? Icons.description_outlined : Icons.add, color: Colors.grey[600], size: 28.sp),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 25.w, height: 25.h,
                    decoration: BoxDecoration(color: Colors.green[700], shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: Center(child: CustomSvg(assetPath: "assets/control/camera.svg", width: 10.w, height: 10.h, fit: BoxFit.scaleDown)),
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
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = header.startsWith('<svg') || header.startsWith('<?xml');
    }
    if (isSvg || isSvgData) {
      if (bytes != null) {
        try {
          return Padding(padding: EdgeInsets.all(16.r), child: SvgPicture.memory(bytes, fit: BoxFit.contain, placeholderBuilder: (context) => Icon(Icons.description, color: Colors.grey[400], size: 28.sp)));
        } catch (_) { return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp); }
      } else if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvg(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Icon(Icons.description, color: Colors.grey[400], size: 28.sp);
            if (snapshot.hasError || !snapshot.hasData)              return Icon(Icons.broken_image,  color: Colors.red[300],  size: 28.sp);
            return Padding(padding: EdgeInsets.all(16.r), child: SvgPicture.memory(snapshot.data!, fit: BoxFit.contain));
          },
        );
      }
    } else {
      if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty) return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp));
    }
    return Icon(isSvg ? Icons.description : Icons.image, color: Colors.grey, size: 28.sp);
  }

  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(url, method: 'GET', responseType: 'arraybuffer');
    if (response.status != 200) throw Exception('Failed to load SVG: ${response.status}');
    return (response.response as ByteBuffer).asUint8List();
  }

  Widget _fieldLabel(String text) => Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _btn({required String label, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 48.h,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.r)),
        child: Center(child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white))),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL LINK DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialLinkDropdown extends StatelessWidget {
  final List<SocialLinkModel> footerLinks;
  final int?                  selectedIndex;
  final ValueChanged<int?>    onChanged;
  final bool                  submitted;

  const _SocialLinkDropdown({
    required this.footerLinks,
    required this.selectedIndex,
    required this.onChanged,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = submitted && selectedIndex == null;

    if (footerLinks.isEmpty) {
      return Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            SizedBox(width: 14.w, height: 14.w, child: const CircularProgressIndicator(strokeWidth: 2, color: _kGreenSolid)),
            SizedBox(width: 10.w),
            Text('Loading footer social links...', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final items = footerLinks.asMap().entries.map((entry) {
      final index  = entry.key;
      final link   = entry.value;
      final hasUrl = link.url.isNotEmpty;
      return DropdownMenuItem<int>(
        value:   index,
        enabled: hasUrl,
        child: Row(
          children: [
            Container(
              width: 36.w, height: 36.w,
              decoration: BoxDecoration(color: hasUrl ? const Color(0xFFE8F5EE) : const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(6.r)),
              child: Center(
                child: link.iconUrl.isNotEmpty
                    ? SvgPicture.network(link.iconUrl, width: 20.w, height: 20.w, fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(hasUrl ? _kGreenSolid : Colors.grey.shade400, BlendMode.srcIn),
                    placeholderBuilder: (_) => Icon(Icons.link, size: 16.sp, color: hasUrl ? _kGreenSolid : Colors.grey.shade400))
                    : Icon(Icons.link, size: 16.sp, color: hasUrl ? _kGreenSolid : Colors.grey.shade400),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasUrl ? _truncateUrl(link.url) : 'Social ${index + 1} — no URL set',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: hasUrl ? Colors.black87 : Colors.grey.shade400, fontStyle: hasUrl ? FontStyle.normal : FontStyle.italic),
              ),
            ),
            if (!hasUrl)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4.r)),
                child: Text('No URL', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: Colors.grey.shade500)),
              ),
          ],
        ),
      );
    }).toList();

    final selectedLink = selectedIndex != null && selectedIndex! < footerLinks.length
        ? footerLinks[selectedIndex!]
        : null;

    Widget selectedDisplay() {
      if (selectedLink == null) {
        return Row(children: [
          Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400), SizedBox(width: 8.w),
          Text('Select a social link from footer', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey.shade400)),
        ]);
      }
      return Row(children: [
        if (selectedLink.iconUrl.isNotEmpty)
          SvgPicture.network(selectedLink.iconUrl, width: 18.w, height: 18.w, fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(_kGreenSolid, BlendMode.srcIn),
              placeholderBuilder: (_) => Icon(Icons.link, size: 16.sp, color: _kGreenSolid))
        else
          Icon(Icons.link, size: 16.sp, color: _kGreenSolid),
        SizedBox(width: 8.w),
        Expanded(child: Text(
          selectedLink.url.isNotEmpty ? _truncateUrl(selectedLink.url) : 'Social ${selectedIndex! + 1}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.black87),
        )),
      ]);
    }

    final selectedItemWidgets = List.generate(footerLinks.length, (_) => selectedDisplay());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex, isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: Colors.grey.shade600),
              hint: Row(children: [
                Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400), SizedBox(width: 8.w),
                Text('Select a social link from footer', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey.shade400)),
              ]),
              selectedItemBuilder: (_) => selectedItemWidgets,
              items: items,
              onChanged: (idx) {
                if (idx == null) return;
                if (footerLinks[idx].url.isEmpty) return;
                onChanged(idx);
              },
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text('Please select a social link', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: _kRed)),
        ],
      ],
    );
  }

  String _truncateUrl(String url) {
    final clean = url.replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '');
    return clean.length > 38 ? '${clean.substring(0, 38)}…' : clean;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialIconItem {
  final String id;
  final int    counter;
  int?       selectedIndex;
  Uint8List? iconBytes;
  String     iconUrl = '';
  _SocialIconItem({required this.id, required this.counter});
}

class _OfficeLocationItem {
  final String id;
  final int    counter;
  final locationNameEnCtrl = TextEditingController();
  final locationNameArCtrl = TextEditingController();
  final text1EnCtrl        = TextEditingController();
  final text1ArCtrl        = TextEditingController();
  final text2EnCtrl        = TextEditingController();
  final text2ArCtrl        = TextEditingController();
  final mapLinkCtrl        = TextEditingController();
  Uint8List? iconBytes;
  String     iconUrl = '';
  _OfficeLocationItem({required this.id, required this.counter});
}