// ******************* FILE INFO *******************
// File Name: contact_us_cms_edit_page.dart
// Created by: Claude Assistant

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
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

const Color _kGreen = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kRed = Color(0xFFD32F2F);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBg = Color(0xFFF2F2F2);

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
  final _emailCtrl = TextEditingController();

  // ── Social Icons (Follow Us) ──
  final List<_SocialIconItem> _socialIconItems = [];
  int _socialIconCounter = 0;

  // ── Office Locations ──
  final List<_OfficeLocationItem> _officeLocationItems = [];
  int _officeLocationCounter = 0;

  // ── Confirm Message ──
  final _confirmTitleEnCtrl = TextEditingController();
  final _confirmTitleArCtrl = TextEditingController();
  final _confirmDescEnCtrl = TextEditingController();
  final _confirmDescArCtrl = TextEditingController();
  Uint8List? _confirmSvgBytes;
  String _confirmSvgUrl = '';

  // ── Accordion open/close ──
  bool _infoOpen = true;
  bool _followUsOpen = true;
  bool _officesOpen = true;
  bool _confirmOpen = true;

  bool _submitted = false;
  bool _seeded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    context.read<ContactUsCmsCubit>().load();
  }

  @override
  void dispose() {
    _subDescEnCtrl.dispose();
    _subDescArCtrl.dispose();
    _emailCtrl.dispose();
    _confirmTitleEnCtrl.dispose();
    _confirmTitleArCtrl.dispose();
    _confirmDescEnCtrl.dispose();
    _confirmDescArCtrl.dispose();
    for (final s in _socialIconItems) {
      s.linkCtrl.dispose();
    }
    for (final o in _officeLocationItems) {
      o.locationNameEnCtrl.dispose();
      o.locationNameArCtrl.dispose();
      o.text1EnCtrl.dispose();
      o.text1ArCtrl.dispose();
      o.text2EnCtrl.dispose();
      o.text2ArCtrl.dispose();
    }
    super.dispose();
  }

  // ── Seed from loaded model ────────────────────────────────────────────────

  void _seedFromModel(ContactUsCmsModel m) {
    if (_seeded) return;
    _seeded = true;

    _subDescEnCtrl.text = m.subDescription.en;
    _subDescArCtrl.text = m.subDescription.ar;
    _emailCtrl.text = m.email;

    // Social icons
    _socialIconItems.clear();
    for (final s in m.socialIcons) {
      final item = _SocialIconItem(id: s.id, counter: ++_socialIconCounter);
      item.linkCtrl.text = s.link;
      item.iconUrl = s.iconUrl;
      _socialIconItems.add(item);
    }

    // Office locations
    _officeLocationItems.clear();
    for (final o in m.officeLocations) {
      final item = _OfficeLocationItem(
        id: o.id,
        counter: ++_officeLocationCounter,
      );
      item.locationNameEnCtrl.text = o.locationName.en;
      item.locationNameArCtrl.text = o.locationName.ar;
      item.text1EnCtrl.text = o.text1.en;
      item.text1ArCtrl.text = o.text1.ar;
      item.text2EnCtrl.text = o.text2.en;
      item.text2ArCtrl.text = o.text2.ar;
      item.iconUrl = o.iconUrl;
      _officeLocationItems.add(item);
    }

    // Confirm message
    _confirmTitleEnCtrl.text = m.confirmMessage.title.en;
    _confirmTitleArCtrl.text = m.confirmMessage.title.ar;
    _confirmDescEnCtrl.text = m.confirmMessage.description.en;
    _confirmDescArCtrl.text = m.confirmMessage.description.ar;
    _confirmSvgUrl = m.confirmMessage.svgUrl;
  }

  // ── Image picker (for regular icons AND SVG) ──────────────────────────────────────

  Future<Uint8List?> _pickImage({bool allowSvg = false}) async {
    print('🔵 _pickImage called (allowSvg: $allowSvg)');
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = allowSvg ? 'image/*,.svg' : 'image/*';

    input.onChange.listen((_) {
      print('🟢 onChange triggered');
      final files = input.files;
      print('🟡 Files: $files, isEmpty: ${files?.isEmpty}');

      if (files == null || files.isEmpty) {
        print('🔴 No files selected');
        completer.complete(null);
        return;
      }

      final file = files.first;
      print('🟣 File selected: ${file.name}, size: ${file.size}');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        print('🟠 onLoadEnd triggered, readyState: ${reader.readyState}');
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          print('🟤 Result type: ${result.runtimeType}');

          if (result is ByteBuffer) {
            final bytes = result.asUint8List();
            print(
              '✅ Successfully converted ByteBuffer to Uint8List, length: ${bytes.length}',
            );
            completer.complete(bytes);
          } else if (result is Uint8List) {
            print('✅ Already Uint8List, length: ${result.length}');
            completer.complete(result);
          } else {
            print('❌ Result is neither ByteBuffer nor Uint8List: $result');
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((error) {
        print('❌ Reader error: $error');
        completer.complete(null);
      });
    });

    print('🔵 Clicking input');
    input.click();
    print('🔵 Waiting for future');

    return completer.future;
  }

  // ── SVG picker (only for SVG files) ───────────────────────────────────────

  Future<Uint8List?> _pickSvgFile() async {
    print('🔵 _pickSvgFile called (SVG only)');
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('🔴 No files selected');
        completer.complete(null);
        return;
      }

      final file = files.first;
      final fileName = file.name.toLowerCase();

      // Validate: only accept SVG files
      if (!fileName.endsWith('.svg')) {
        print('❌ Non-SVG file rejected: $fileName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Please upload SVG files only! You selected: ${file.name}',
            ),
            backgroundColor: _kRed,
            duration: const Duration(seconds: 3),
          ),
        );
        completer.complete(null);
        return;
      }

      print('🟣 SVG file selected: ${file.name}, size: ${file.size}');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          if (result is ByteBuffer) {
            final bytes = result.asUint8List();
            print('✅ SVG bytes ready: ${bytes.length}');
            completer.complete(bytes);
          } else if (result is Uint8List) {
            print('✅ SVG bytes ready: ${result.length}');
            completer.complete(result);
          } else {
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((error) {
        print('❌ Reader error: $error');
        completer.complete(null);
      });
    });

    input.click();
    return completer.future;
  }

  // ── Build model from current state ───────────────────────────────────────

  ContactUsCmsModel _buildModel(String status) {
    return ContactUsCmsModel(
      publishStatus: status,
      subDescription: ContactBilingualText(
        en: _subDescEnCtrl.text.trim(),
        ar: _subDescArCtrl.text.trim(),
      ),
      email: _emailCtrl.text.trim(),
      socialIcons: _socialIconItems
          .map(
            (s) => ContactSocialIcon(
          id: s.id,
          iconUrl: s.iconUrl,
          link: s.linkCtrl.text.trim(),
        ),
      )
          .toList(),
      officeLocations: _officeLocationItems
          .map(
            (o) => ContactOfficeLocation(
          id: o.id,
          iconUrl: o.iconUrl,
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
        ),
      )
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

  // ── Collect image uploads ─────────────────────────────────────────────────

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};

    // Social icon uploads
    for (final s in _socialIconItems) {
      if (s.iconBytes != null) {
        uploads['contact_cms/social_icons/${s.id}/icon'] = s.iconBytes!;
      }
    }

    // Office location uploads
    for (final o in _officeLocationItems) {
      if (o.iconBytes != null) {
        uploads['contact_cms/office_locations/${o.id}/icon'] = o.iconBytes!;
      }
    }

    // Confirm message SVG
    if (_confirmSvgBytes != null) {
      uploads['contact_cms/confirm_message/svg'] = _confirmSvgBytes!;
    }

    return uploads;
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save(String status) async {
    setState(() => _submitted = true);

    final requiredCtrls = [
      _subDescEnCtrl,
      _subDescArCtrl,
      _emailCtrl,
      _confirmTitleEnCtrl,
      _confirmTitleArCtrl,
      _confirmDescEnCtrl,
      _confirmDescArCtrl,
      for (final s in _socialIconItems) s.linkCtrl,
      for (final o in _officeLocationItems) ...[
        o.locationNameEnCtrl,
        o.locationNameArCtrl,
        o.text1EnCtrl,
        o.text1ArCtrl,
      ],
    ];

    final hasEmpty = requiredCtrls.any((c) => c.text.trim().isEmpty);
    if (hasEmpty) return;

    setState(() => _isSaving = true);
    final model = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<ContactUsCmsCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Add / remove items ────────────────────────────────────────────────────

  void _addSocialIcon() {
    setState(() {
      _socialIconItems.add(
        _SocialIconItem(
          id: 'social_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_socialIconCounter,
        ),
      );
    });
  }

  void _removeSocialIcon(String id) {
    setState(() => _socialIconItems.removeWhere((s) => s.id == id));
  }

  void _addOfficeLocation() {
    setState(() {
      _officeLocationItems.add(
        _OfficeLocationItem(
          id: 'office_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_officeLocationCounter,
        ),
      );
    });
  }

  void _removeOfficeLocation(String id) {
    setState(() => _officeLocationItems.removeWhere((o) => o.id == id));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactUsCmsCubit, ContactUsCmsState>(
      listener: (context, state) {
        if (state is ContactUsCmsLoaded) {
          _seedFromModel(state.data);
        }
        if (state is ContactUsCmsSaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact Us saved successfully!'),
              backgroundColor: _kGreenSolid,
            ),
          );
          context.push('/contact-cms');
        }
        if (state is ContactUsCmsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is ContactUsCmsLoading || state is ContactUsCmsInitial;

        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    AdminSubNavBar(activeIndex: 4),
                    SizedBox(
                      width: 1000.w,
                      child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: _kGreenSolid,
                        ),
                      )
                          : _buildForm(),
                    ),
                  ],
                ),
              ),
              if (_isSaving) _buildSavingOverlay(),
            ],
          ),
        );
      },
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
            fontSize: 36.sp,
            color: _kGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title: 'Info',
          isOpen: _infoOpen,
          onToggle: () => setState(() => _infoOpen = !_infoOpen),
          child: _infoSection(),
        ),

        SizedBox(height: 16.h),

        _accordion(
          title: 'Office Locations',
          isOpen: _officesOpen,
          onToggle: () => setState(() => _officesOpen = !_officesOpen),
          child: _officeLocationsSection(),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Confirm Message',
          isOpen: _confirmOpen,
          onToggle: () => setState(() => _confirmOpen = !_confirmOpen),
          child: _confirmMessageSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
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
              borderRadius: isOpen
                  ? BorderRadius.vertical(top: Radius.circular(12.r))
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12.r),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
      ],
    );
  }

  // ── Info Section ──────────────────────────────────────────────────────────

  Widget _infoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: _subDescEnCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 300,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: _subDescArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 300,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint: 'Text Here',
                    controller: _emailCtrl,
                    height: 42,
                    maxLines: 1,
                    maxLength: 100,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 30.sp),
            Expanded(child: Center()),
          ],
        ),
        SizedBox(height: 20.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Grid with 2 items per row
            if (_socialIconItems.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 20.h,
                    mainAxisExtent: 240.sp
                ),
                itemCount: _socialIconItems.length,
                itemBuilder: (context, index) =>
                    _socialIconWidget(_socialIconItems[index]),
              ),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: _addSocialIcon,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF555555),
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
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _socialIconWidget(_SocialIconItem s) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: s.iconBytes,
                url: s.iconUrl,
                onTap: () async {
                  // ✅ Allow SVG uploads for social icons
                  final b = await _pickImage(allowSvg: true);
                  if (b != null) {
                    setState(() {
                      s.iconBytes = b;
                      _socialIconItems[_socialIconItems.indexOf(s)] = s;
                    });
                  }
                },
                isSvg: true, // ✅ Mark as SVG so it renders correctly
              ),
              GestureDetector(
                onTap: () => _removeSocialIcon(s.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed,
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
            ],
          ),
          SizedBox(height: 16.h),

          _fieldLabel('Insert Links'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: s.linkCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 300,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
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
        ..._officeLocationItems.map((o) => _officeLocationWidget(o)).toList(),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addOfficeLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: o.iconBytes,
                url: o.iconUrl,
                onTap: () async {
                  // ✅ Allow SVG uploads for office locations
                  final b = await _pickImage(allowSvg: true);
                  if (b != null) {
                    setState(() {
                      o.iconBytes = b;
                      _officeLocationItems[_officeLocationItems.indexOf(o)] = o;
                    });
                  }
                },
                isSvg: true, // ✅ Mark as SVG so it renders correctly
              ),
              GestureDetector(
                onTap: () => _removeOfficeLocation(o.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed,
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
            ],
          ),
          SizedBox(height: 16.h),

          // ✅ Location Name
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
                      hint: 'Text Here',
                      controller: o.locationNameEnCtrl,
                      height: 42,
                      maxLines: 1,
                      maxLength: 200,
                      submitted: _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.start,
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
                    _fieldLabelAr('اسم الموقع'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'أدخل النص هنا',
                      controller: o.locationNameArCtrl,
                      height: 42,
                      maxLines: 1,
                      maxLength: 200,
                      submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ✅ Text (ONLY ONE TEXT FIELD)
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
                      hint: 'Text Here',
                      controller: o.text1EnCtrl,
                      height: 42,
                      maxLines: 1,
                      maxLength: 200,
                      submitted: _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.start,
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
                    _fieldLabelAr('النص'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'أدخل النص هنا',
                      controller: o.text1ArCtrl,
                      height: 42,
                      maxLines: 1,
                      maxLength: 200,
                      submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
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

  // ── Confirm Message Section ───────────────────────────────────────────────

  Widget _confirmMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'SVG',
          bytes: _confirmSvgBytes,
          url: _confirmSvgUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) {
              setState(() => _confirmSvgBytes = b);
            }
          },
          isSvg: true,
        ),
        SizedBox(height: 20.h),

        // ✅ Title - Both labels on top in one row
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
                    hint: 'Text Here',
                    controller: _confirmTitleEnCtrl,
                    height: 42,
                    maxLines: 1,
                    maxLength: 200,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    onChanged: (_) => setState(() {}),
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
                    hint: 'أدخل النص هنا',
                    controller: _confirmTitleArCtrl,
                    height: 42,
                    maxLines: 1,
                    maxLength: 200,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // ✅ Description - Both labels on top in one row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Description'),
                SizedBox(height: 8.h),
                CustomValidatedTextFieldMaster(
                  hint: 'Text Here',
                  controller: _confirmDescEnCtrl,
                  height: 100,
                  maxLines: 4,
                  maxLength: 500,
                  showCharCount: true,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _fieldLabelAr('الوصف'),
                SizedBox(height: 8.h),
                CustomValidatedTextFieldMaster(
                  hint: 'أدخل النص هنا',
                  controller: _confirmDescArCtrl,
                  height: 100,
                  maxLines: 4,
                  maxLength: 500,
                  showCharCount: true,
                  submitted: _submitted,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFF4CAF50),
                onTap: () => context.push('/contact-cms-preview'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label: 'Save',
                color: _kGreenSolid,
                onTap: () => _save('published'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: const Color(0xFF9E9E9E),
                onTap: () => context.push('/contact-cms'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Saving overlay ────────────────────────────────────────────────────────

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _kGreenSolid),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
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
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEEEEEE),
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(
                  isSvg ? Icons.description_outlined : Icons.add,
                  color: Colors.grey[600],
                  size: 28.sp,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGreenSolid,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 13.sp),
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
    // Auto-detect if bytes contain SVG data
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = header.startsWith('<svg') || header.startsWith('<?xml');
    }

    if (isSvg || isSvgData) {
      if (bytes != null) {
        try {
          return SvgPicture.memory(
            bytes,
            fit: BoxFit.cover,
            placeholderBuilder: (context) =>
                Icon(Icons.description, color: Colors.grey[400], size: 28.sp),
          );
        } catch (e) {
          return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp);
        }
      } else if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvg(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(
                Icons.description,
                color: Colors.grey[400],
                size: 28.sp,
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Icon(
                Icons.broken_image,
                color: Colors.red[300],
                size: 28.sp,
              );
            }
            return SvgPicture.memory(snapshot.data!, fit: BoxFit.cover);
          },
        );
      }
    } else {
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      } else if (url.isNotEmpty) {
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
      size: 28.sp,
    );
  }

  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      responseType: 'arraybuffer',
    );

    if (response.status != 200) {
      throw Exception('Failed to load SVG: ${response.status}');
    }

    final buffer = response.response as ByteBuffer;
    return buffer.asUint8List();
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper classes ────────────────────────────────────────────────────────────

class _SocialIconItem {
  final String id;
  final int counter;
  final linkCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _SocialIconItem({required this.id, required this.counter});
}

class _OfficeLocationItem {
  final String id;
  final int counter;
  final locationNameEnCtrl = TextEditingController();
  final locationNameArCtrl = TextEditingController();
  final text1EnCtrl = TextEditingController();
  final text1ArCtrl = TextEditingController();
  final text2EnCtrl = TextEditingController();
  final text2ArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _OfficeLocationItem({required this.id, required this.counter});
}