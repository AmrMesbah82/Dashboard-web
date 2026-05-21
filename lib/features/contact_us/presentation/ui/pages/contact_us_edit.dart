// ******************* FILE INFO *******************
// File Name: contact_us_edit.dart
// Created by: Claude Assistant
// UPDATED: Social icon "Insert Links" replaced with dropdown from footer social links
// UPDATED: Publish button now shows confirmation dialog with validation
// UPDATED: Fixed race condition — seed deferred until both Home & Contact CMS are loaded

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/text.dart';
import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../data/models/contact_us_model_location.dart';
import '../../controller/contacu_us_location_cubit.dart';
import '../../controller/contacu_us_location_state.dart';

part '../widget/contact_us_edit/social_link_dropdown.dart';
part '../widget/contact_us_edit/social_icon_item.dart';
part '../widget/contact_us_edit/office_location_item.dart';

// const Color ColorPick.primary      = Color(0xFF2D8C4E);
// const Color ColorPick.primary = Color(0xFF008037);
// const Color ColorPick.primaryLight = Color(0xFFE8F5EE);
// const Color ColorPick.red        = Color(0xFFD32F2F);
// const Color _kSurface    = Color(0xFFFFFFFF);
// const Color _kBg         = Color(0xFFF2F2F2);

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
  bool _infoOpen    = true;
  bool _officesOpen = true;
  bool _confirmOpen = true;

  bool _submitted = false;
  bool _seeded    = false;
  bool _isSaving  = false;

  // ── Footer social links (loaded from HomeCmsCubit) ──
  List<SocialLinkModel> _footerSocialLinks = [];

  // ── Deferred seed: wait for BOTH cubits ──
  ContactUsCmsModel? _pendingModel;
  final _followTitleEnCtrl = TextEditingController();
  final _followTitleArCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<ContactUsCmsCubit>().load();
    // Load Home CMS to get footer social links
    context.read<HomeCmsCubit>().load();
  }

  @override
  void dispose() {
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

  // ── Try seed — only runs when BOTH footer links AND CMS model are ready ──

  void _trySeed() {
    if (_seeded) return;
    if (_pendingModel == null || _footerSocialLinks.isEmpty) return;
    _seeded = true;
    _seedFromModel(_pendingModel!);
  }

  // ── Seed from loaded model ────────────────────────────────────────────────

  void _seedFromModel(ContactUsCmsModel m) {
    _subDescEnCtrl.text = m.subDescription.en;
    _subDescArCtrl.text = m.subDescription.ar;
    _emailCtrl.text     = m.email;

    // Social icons
    _socialIconItems.clear();
    for (final s in m.socialIcons) {
      final item = _SocialIconItem(id: s.id, counter: ++_socialIconCounter);
      // Resolve saved URL back to its index in the footer links list
      final idx = _footerSocialLinks.indexWhere((l) => l.url == s.link);
      item.selectedIndex = idx >= 0 ? idx : null;
      item.iconUrl       = s.iconUrl;
      _socialIconItems.add(item);
    }

    // Office locations
    _officeLocationItems.clear();
    for (final o in m.officeLocations) {
      final item = _OfficeLocationItem(
        id:      o.id,
        counter: ++_officeLocationCounter,
      );
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
  }

  // ── Image pickers ─────────────────────────────────────────────────────────

  Future<Uint8List?> _pickImage({bool allowSvg = false}) async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = allowSvg ? 'image/*,.svg' : 'image/*';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file   = files.first;
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

  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file     = files.first;
      final fileName = file.name.toLowerCase();
      if (!fileName.endsWith('.svg')) {
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

  // ── Build model ───────────────────────────────────────────────────────────

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
      socialIcons: _socialIconItems
          .map((s) {
        // Resolve index → URL safely
        final url = (s.selectedIndex != null &&
            s.selectedIndex! < _footerSocialLinks.length)
            ? _footerSocialLinks[s.selectedIndex!].url
            : '';
        return ContactSocialIcon(
          id:      s.id,
          iconUrl: s.iconUrl,
          link:    url,
        );
      })
          .toList(),
      officeLocations: _officeLocationItems
          .map((o) => ContactOfficeLocation(
        id:      o.id,
        iconUrl: o.iconUrl,
        mapLink: o.mapLinkCtrl.text.trim(),
        locationName: ContactBilingualText(
          en: o.locationNameEnCtrl.text.trim(),
          ar: o.locationNameArCtrl.text.trim(),
        ),
        text1: ContactBilingualText(
          en: o.text1EnCtrl.text.trim(),
          ar: o.text1ArCtrl.text.trim(),
        ),
        text2: ContactBilingualText(
          en: o.text2EnCtrl.text.trim(),
          ar: o.text2ArCtrl.text.trim(),
        ),
      ))
          .toList(),
      confirmMessage: ContactConfirmMessage(
        svgUrl: _confirmSvgUrl,
        title: ContactBilingualText(
          en: _confirmTitleEnCtrl.text.trim(),
          ar: _confirmTitleArCtrl.text.trim(),
        ),
        description: ContactBilingualText(
          en: _confirmDescEnCtrl.text.trim(),
          ar: _confirmDescArCtrl.text.trim(),
        ),
      ),
    );
  }

  // ── Collect uploads ───────────────────────────────────────────────────────

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    for (final s in _socialIconItems) {
      if (s.iconBytes != null) {
        uploads['contact_cms/social_icons/${s.id}/icon'] = s.iconBytes!;
      }
    }
    for (final o in _officeLocationItems) {
      if (o.iconBytes != null) {
        uploads['contact_cms/office_locations/${o.id}/icon'] = o.iconBytes!;
      }
    }
    if (_confirmSvgBytes != null) {
      uploads['contact_cms/confirm_message/svg'] = _confirmSvgBytes!;
    }
    return uploads;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateAllFields() {
    final requiredCtrls = [
      _subDescEnCtrl,
      _subDescArCtrl,
      _emailCtrl,
      _confirmTitleEnCtrl,
      _confirmTitleArCtrl,
      _confirmDescEnCtrl,
      _confirmDescArCtrl,
      for (final o in _officeLocationItems) ...[
        o.locationNameEnCtrl,
        o.locationNameArCtrl,
        o.text1EnCtrl,
        o.text1ArCtrl,
      ],
    ];

    return !requiredCtrls.any((c) => c.text.trim().isEmpty);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

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
    setState(() => _isSaving = false);
  }

  // ── Publish with confirmation dialog ──────────────────────────────────────

  Future<void> _handlePublish() async {
    // First validate all fields
    setState(() => _submitted = true);

    if (!_validateAllFields()) {
      // If validation fails, scroll to top so user can see errors
      return;
    }

    // Show confirmation dialog
    await showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH CONTACT US PAGE',
      subtitle: 'Do you want to publish the changes made to this Contact Us page?',
      confirmLabel: 'Publish',
      backLabel: 'Back',
      onConfirm: () => _save('published'),
    );
  }

  // ── Add / remove ──────────────────────────────────────────────────────────

  void _addSocialIcon() {
    setState(() {
      _socialIconItems.add(
        _SocialIconItem(
          id:      'social_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_socialIconCounter,
        ),
      );
    });
  }

  void _removeSocialIcon(String id) =>
      setState(() => _socialIconItems.removeWhere((s) => s.id == id));

  void _addOfficeLocation() {
    setState(() {
      _officeLocationItems.add(
        _OfficeLocationItem(
          id:      'office_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_officeLocationCounter,
        ),
      );
    });
  }

  void _removeOfficeLocation(String id) =>
      setState(() => _officeLocationItems.removeWhere((o) => o.id == id));

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ── Listen to HomeCmsCubit to get footer social links ──
        BlocListener<HomeCmsCubit, HomeCmsState>(
          listener: (context, homeState) {
            final links = switch (homeState) {
              HomeCmsLoaded(:final data) => data.socialLinks,
              HomeCmsSaved(:final data)  => data.socialLinks,
              _                          => <SocialLinkModel>[],
            };
            if (links.isNotEmpty) {
              setState(() {
                _footerSocialLinks = links;
                _trySeed();
              });
            }
          },
        ),
        // ── Listen to ContactUsCmsCubit ──
        BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
          listener: (context, state) {
            if (state is ContactUsCmsLoaded) {
              setState(() {
                _pendingModel = state.data;
                _trySeed();
              });
            }
            if (state is ContactUsCmsSaved) {
              setState(() => _isSaving = false);
            }
            if (state is ContactUsCmsError) {
              setState(() => _isSaving = false);
            }
          },
        ),
      ],
      child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          final isLoading =
              state is ContactUsCmsLoading || state is ContactUsCmsInitial;

          return Scaffold(
            backgroundColor:  Color(0xFFF1F2ED),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
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

  // ── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Contact Us Details',
          style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
            fontSize:   36.sp,
            color:      ColorPick.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title:    'Info',
          isOpen:   _infoOpen,
          onToggle: () => setState(() => _infoOpen = !_infoOpen),
          child:    _infoSection(),
        ),

        _accordion(
          title:    'Office Locations',
          isOpen:   _officesOpen,
          onToggle: () => setState(() => _officesOpen = !_officesOpen),
          child:    _officeLocationsSection(),
        ),
        SizedBox(height: 16.h),

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

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _accordion({
    required String   title,
    required bool     isOpen,
    required VoidCallback onToggle,
    required Widget   child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: isOpen
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   16.sp,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size:  22.sp,
                ),
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
            child:   child,
          ),
      ],
    );
  }

  // ── Info Section ──────────────────────────────────────────────────────────

  Widget _infoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor: Colors.white,
          controller:    _subDescEnCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     300,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          controller:    _subDescArCtrl,
          fillColor: Colors.white,
          height:        100,
          maxLines:      4,
          maxLength:     300,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // ── Email ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'Text Here',
                    fillColor: Colors.white,
                    controller:    _emailCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     100,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 30.sp),
            const Expanded(child: Center()),
          ],
        ),
        SizedBox(height: 20.h),

        // ── Social Icons Grid ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_socialIconItems.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:  2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing:  20.h,
                  mainAxisExtent:   100.sp,
                ),
                itemCount:    _socialIconItems.length,
                itemBuilder:  (context, index) =>
                    _socialIconWidget(_socialIconItems[index]),
              ),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: _addSocialIcon,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color:        const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Icon',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w600,
                        color:      Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ],
    );
  }

  // ── Social Icon Widget ────────────────────────────────────────────────────

  Widget _socialIconWidget(_SocialIconItem s) {
    return Container(

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Link Dropdown ──────────────────────────────────────────────
          Row(
            children: [
              _fieldLabel('Select Link'),
              Spacer(),
              GestureDetector(
                onTap: () => _removeSocialIcon(s.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color:        ColorPick.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
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

  // ── Office Locations Section ──────────────────────────────────────────────

  Widget _officeLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._officeLocationItems.map(_officeLocationWidget).toList(),
        GestureDetector(
          onTap: _addOfficeLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color:        const Color(0xFF555555),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _officeLocationWidget(_OfficeLocationItem o) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.h),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: o.iconBytes,
                url:   o.iconUrl,
                onTap: () async {
                  final b = await _pickImage(allowSvg: true);
                  if (b != null) setState(() => o.iconBytes = b);
                },
                isSvg: true,
              ),
              GestureDetector(
                onTap: () => _removeOfficeLocation(o.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color:        ColorPick.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Location Name'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'Text Here',
                      controller:    o.locationNameEnCtrl,
                      height:        42,
                      maxLines:      1,
                      fillColor: Colors.white,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign:     TextAlign.start,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabelAr('اسم الموقع'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'أدخل النص هنا',
                      controller:    o.locationNameArCtrl,
                      fillColor: Colors.white,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Text'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'Text Here',
                      fillColor: Colors.white,
                      controller:    o.text1EnCtrl,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign:     TextAlign.start,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabelAr('النص'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'أدخل النص هنا',
                      fillColor: Colors.white,
                      controller:    o.text1ArCtrl,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _fieldLabel('Google Maps Link'),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint:          'https://maps.google.com/?q=...',
                  controller:    o.mapLinkCtrl,
                  height:        42,
                  fillColor: Colors.white,
                  maxLines:      1,
                  maxLength:     500,
                  submitted:     false, // optional field — no error shown
                  textDirection: TextDirection.ltr,
                  textAlign:     TextAlign.start,
                  onChanged:     (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 15.sp),
              Expanded(child: Container())
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirmMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _imageUploadCircle(
          label: 'SVG',
          bytes: _confirmSvgBytes,
          url:   _confirmSvgUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) setState(() => _confirmSvgBytes = b);
          },
          isSvg: true,
        ),
        SizedBox(height: 20.h),

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
                    hint:          'Text Here',
                    fillColor: Colors.white,
                    controller:    _confirmTitleEnCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _fieldLabelAr('العنوان'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'أدخل النص هنا',
                    controller:    _confirmTitleArCtrl,
                    height:        42,
                    fillColor: Colors.white,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign:     TextAlign.right,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Description'),
            SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(
              hint:          'Text Here',
              controller:    _confirmDescEnCtrl,
              height:        100,
              fillColor: Colors.white,
              maxLines:      4,
              maxLength:     500,
              showCharCount: true,
              submitted:     _submitted,
              textDirection: TextDirection.ltr,
              textAlign:     TextAlign.start,
              onChanged:     (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),
            _fieldLabelAr('الوصف'),
            SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(
              hint:          'أدخل النص هنا',
              controller:    _confirmDescArCtrl,
              fillColor: Colors.white,
              height:        100,
              maxLines:      4,
              maxLength:     500,
              showCharCount: true,
              submitted:     _submitted,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              onChanged:     (_) => setState(() {}),
            ),
          ],
        ),
      ],
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label:  'Preview',
                color:  const Color(0xFF608570),
                onTap:  () => context.goNamed('contact-cms-preview'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label:  'Publish',
                color:  ColorPick.primary,
                onTap:  _handlePublish,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label:  'Discard',
                color:  const Color(0xFF797979),
                onTap:  () => context.goNamed('contact-cms'),
              ),
            ),
            SizedBox(width: 15.sp),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Saving Overlay ────────────────────────────────────────────────────────

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width:  180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: ColorPick.primary),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   14.sp,
                  color:      Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

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
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize:   13.sp,
            fontWeight: FontWeight.w600,
            color:      Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(
                  isSvg
                      ? Icons.description_outlined
                      : Icons.add,
                  color: Colors.grey[600],
                  size:  28.sp,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 25.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                        child: CustomSvg(assetPath: "assets/control/camera.svg",width: 10.w,height: 10.h,fit: BoxFit.scaleDown,)
                    ),
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
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: SvgPicture.memory(
              bytes,
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  Icon(Icons.description, color: Colors.grey[400], size: 28.sp),
            ),
          );
        } catch (_) {
          return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp);
        }
      } else if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvg(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(Icons.description, color: Colors.grey[400], size: 28.sp);
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp);
            }
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: SvgPicture.memory(snapshot.data!, fit: BoxFit.contain),
            );          },
        );
      }
    } else {
      if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp),
        );
      }
    }

    return Icon(
      isSvg ? Icons.description : Icons.image,
      color: Colors.grey,
      size:  28.sp,
    );
  }

  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(
      url,
      method:       'GET',
      responseType: 'arraybuffer',
    );
    if (response.status != 200) {
      throw Exception('Failed to load SVG: ${response.status}');
    }
    return (response.response as ByteBuffer).asUint8List();
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize:   13.sp,
      fontWeight: FontWeight.w600,
      color:      Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize:   13.sp,
        fontWeight: FontWeight.w600,
        color:      Colors.black87,
      ),
    ),
  );

  Widget _btn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   15.sp,
              fontWeight: FontWeight.w700,
              color:      Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL LINK DROPDOWN
// Uses the item's LIST INDEX as the DropdownButton value — this guarantees
// uniqueness even when two footer links share the same URL.
// Items with empty URL are shown grayed out / not selectable.
// ═══════════════════════════════════════════════════════════════════════════════
