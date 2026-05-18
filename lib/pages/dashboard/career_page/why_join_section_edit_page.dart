// ******************* FILE INFO *******************
// File Name: why_join_section_edit_page.dart
// Edit page for Why Join Our Team / Our Interns / Our Teams
// Figma: Editing {SectionTitle} Details
// Accordion with editable items: Icon, Title EN/AR, SVG, Description EN/AR
// + Remove per item, + Reason button, Preview / Save / Discard bottom buttons
// UPDATED: Added validation, SVG-only restriction, and publish confirmation dialog

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/career/careers_section_cubit.dart';
import 'package:web_app_admin/controller/career/careers_section_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/careers_section_model.dart';
import 'package:web_app_admin/pages/dashboard/career_page/why_join_section_preview_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
}

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
  bool get hasImage => !isEmpty;
}

class _ItemEdit {
  String id;
  _PickedImage icon;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  _PickedImage svg;
  final TextEditingController descEn;
  final TextEditingController descAr;

  _ItemEdit({
    required this.id,
    _PickedImage? icon,
    String titleEn = '',
    String titleAr = '',
    _PickedImage? svg,
    String descEn = '',
    String descAr = '',
  })  : icon = icon ?? const _PickedImage(),
        titleEn = TextEditingController(text: titleEn),
        titleAr = TextEditingController(text: titleAr),
        svg = svg ?? const _PickedImage(),
        descEn = TextEditingController(text: descEn),
        descAr = TextEditingController(text: descAr);

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
class CareersSectionEditPage extends StatefulWidget {
  final String sectionKey;
  final String sectionTitle;

  const CareersSectionEditPage({
    super.key,
    required this.sectionKey,
    required this.sectionTitle,
  });

  @override
  State<CareersSectionEditPage> createState() => _CareersSectionEditPageState();
}

class _CareersSectionEditPageState extends State<CareersSectionEditPage> {
  bool _submitted = false;
  bool _isSaving  = false;
  bool _accordionOpen = true;

  final List<_ItemEdit> _items = [];
  int? _seededHash;

  // ── Seed from model ─────────────────────────────────────────────────────────
  void _seedFromModel(CareersSectionModel data) {
    final hash = Object.hashAll([
      data.items.length,
      ...data.items.map((i) =>
      '${i.id}${i.iconUrl}${i.svgUrl}${i.title.en}${i.description.en}'),
    ]);
    if (_seededHash == hash) return;
    _seededHash = hash;

    for (final item in _items) item.dispose();
    _items.clear();

    for (final item in data.items) {
      _items.add(_ItemEdit(
        id:      item.id,
        icon:    item.iconUrl.isNotEmpty
            ? _PickedImage(url: item.iconUrl)
            : const _PickedImage(),
        titleEn: item.title.en,
        titleAr: item.title.ar,
        svg:     item.svgUrl.isNotEmpty
            ? _PickedImage(url: item.svgUrl)
            : const _PickedImage(),
        descEn:  item.description.en,
        descAr:  item.description.ar,
      ));
    }

    print('🟢 [CareersSectionEditPage] seeded ${_items.length} items');
  }

  // ── Validation ──────────────────────────────────────────────────────────────
  bool _validateAllFields() {
    if (_items.isEmpty) return false;

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];

      // Icon & Title only required on first item
      if (i == 0) {
        if (!item.icon.hasImage) return false;
        if (item.titleEn.text.trim().isEmpty) return false;
        if (item.titleAr.text.trim().isEmpty) return false;
      }

      if (item.descEn.text.trim().isEmpty) return false;
      if (item.descAr.text.trim().isEmpty) return false;
      if (!item.svg.hasImage) return false;
    }

    return true;
  }

  // ── Pick SVG image (SVG only) ───────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      final fileName = file.name.toLowerCase();

      // Strict SVG validation
      if (!fileName.endsWith('.svg') && file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only SVG files are allowed',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            );
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

  // ── Perform Save ────────────────────────────────────────────────────────────
  Future<void> _performSave(CareersSectionCubit cubit) async {
    setState(() => _isSaving = true);

    try {
      // Sync items count
      while (cubit.current.items.length < _items.length) cubit.addItem();
      while (cubit.current.items.length > _items.length) {
        cubit.removeItem(cubit.current.items.last.id);
      }

      // Update fields + upload images
      for (var i = 0; i < _items.length; i++) {
        final localItem = _items[i];
        final cubitItem = cubit.current.items[i];

        cubit.updateTitle(cubitItem.id,
            en: localItem.titleEn.text.trim(),
            ar: localItem.titleAr.text.trim());
        cubit.updateDescription(cubitItem.id,
            en: localItem.descEn.text.trim(),
            ar: localItem.descAr.text.trim());

        if (localItem.icon.bytes != null) {
          await cubit.uploadIcon(cubitItem.id, localItem.icon.bytes!);
        }
        if (localItem.svg.bytes != null) {
          await cubit.uploadSvg(cubitItem.id, localItem.svg.bytes!);
        }
      }

      await cubit.save();

      if (mounted) {
        setState(() => _isSaving = false);
        _seededHash = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.sectionTitle} saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Handle Publish with confirmation dialog ─────────────────────────────────
  Future<void> _handlePublish(CareersSectionCubit cubit) async {
    setState(() => _submitted = true);

    if (!_validateAllFields()) {
      // Validation failed - errors will show under text fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields and upload all images',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r)),
        ),
      );
      return;
    }

    // Show confirmation dialog
    await showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH ${widget.sectionTitle.toUpperCase()}',
      subtitle: 'Do you want to publish the changes made to this ${widget.sectionTitle}?',
      confirmLabel: 'Publish',
      backLabel: 'Back',
      onConfirm: () => _performSave(cubit),
    );
  }

  @override
  void dispose() {
    for (final item in _items) item.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CareersSectionCubit, CareersSectionState>(
      listener: (context, state) {
        if (state is CareersSectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}',
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CareersSectionLoaded)  _seedFromModel(state.data);
        if (state is CareersSectionSaved)   _seedFromModel(state.data);

        final cubit = context.read<CareersSectionCubit>();

        if (state is CareersSectionInitial || state is CareersSectionLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
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
                      AppAdminNavbar(
                        activeLabel: 'Web Page',
                        homePage: HomeMainPage(),
                        webPage: HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(height: 20.h),

                      Container(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text(
                              'Editing ${widget.sectionTitle} Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color:      _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // ── Accordion ────────────────────────────────────
                            _accordion(
                              title: widget.sectionTitle,
                              children: [
                                ..._items.asMap().entries.map((entry) {
                                  final i    = entry.key;
                                  final item = entry.value;
                                  return _itemEditWidget(i, item);
                                }),
                                // + Reason button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      final newItem = _ItemEdit(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      );
                                      _items.add(newItem);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF797979),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, color: Colors.white, size: 16.sp),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Reason',
                                          style: StyleText.fontSize13Weight500
                                              .copyWith(color:Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // ── Bottom buttons ──────────────────────────────
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

            // ── Saving overlay ───────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 24),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: _C.primary),
                        SizedBox(height: 20.h),
                        Text('Saving...',
                            style: StyleText.fontSize14Weight600
                                .copyWith(color: _C.primary)),
                        SizedBox(height: 6.h),
                        Text('Uploading images & saving data',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: _C.hintText)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _itemEditWidget(int index, _ItemEdit item) {
    final iconHasError = _submitted && index == 0 && !item.icon.hasImage;
    final svgHasError  = _submitted && !item.svg.hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
        ] else
          SizedBox(height: 12.h),

        // ── Icon + Title — FIRST ITEM ONLY ────────────────────────────────────
        if (index == 0) ...[
          Row(
            children: [
              Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: item.icon,
            isAdd: true,
            hasError: iconHasError,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => item.icon = p);
            },
          ),
          if (iconHasError) ...[
            SizedBox(height: 4.h),
            Text('Icon (SVG) is required', style: TextStyle(fontSize: 11.sp, color: Colors.red)),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(

                  label: 'Title', hint: 'Text Here', controller: item.titleEn,
                  height: 36, fillColor: Colors.white, submitted: _submitted,
                  textDirection: TextDirection.ltr, textAlign: TextAlign.left,
                  primaryColor: _C.primary, isRequired: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'العنوان', hint: 'أدخل النص هنا', controller: item.titleAr,
                    height: 36, fillColor: Colors.white, submitted: _submitted,
                    textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                    primaryColor: _C.primary, isRequired: true,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
        ],

        // ── SVG + Remove row — ALL ITEMS ──────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('SVG', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                    Text(' *', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 6.h),
                _imgBox(
                  picked: item.svg,
                  hasError: svgHasError,
                  onPick: () async {
                    final p = await _pickImage();
                    if (p != null) setState(() => item.svg = p);
                  },
                ),
                if (svgHasError) ...[
                  SizedBox(height: 4.h),
                  Text('SVG image is required', style: TextStyle(fontSize: 11.sp, color: Colors.red)),
                ],
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _items.removeAt(index)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
                child: Text('Remove', style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Description EN — ALL ITEMS ────────────────────────────────────────
        CustomValidatedTextFieldMaster(
          showCharCount: true,
          maxLength: 500,
          label: 'Description', hint: 'Text Here', controller: item.descEn,
          height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: _C.primary, isRequired: true,
        ),
        SizedBox(height: 8.h),

        // ── الوصف AR — ALL ITEMS ──────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            showCharCount: true,
            maxLength: 500,
            label: 'الوصف', hint: 'أدخل النص هنا', controller: item.descAr,
            height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: _C.primary, isRequired: true,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ── Image box with camera overlay ──────────────────────────────────────────
  Widget _imgBox({
    required _PickedImage picked,
    bool isAdd = false,
    bool hasError = false,
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: hasError ? Colors.red : Colors.transparent,
            width: hasError ? 1.5 : 0,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(picked.bytes!,
                width: 30.w, height: 30.h, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(picked.url!,
                width: 30.w, height: 30.h, fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasError ? Colors.red : Colors.transparent,
            width: hasError ? 1.5 : 0,
          ),
        ),
        child: Center(
          child: Icon(
            isAdd ? Icons.add : Icons.image_outlined,
            color: hasError ? Colors.red : Colors.grey,
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
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 25.w, height: 25.h,
              decoration: BoxDecoration(
                color:  _C.primary,
                shape:  BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: "assets/control/camera.svg",
                  width: 10.w, height: 10.h,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _accordionOpen = !_accordionOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _accordionOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_accordionOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }

  // ── Bottom buttons ─────────────────────────────────────────────────────────
  Widget _bottomButtons(CareersSectionCubit cubit) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: CareersSectionPreviewPage(
                        sectionKey:   widget.sectionKey,
                        sectionTitle: widget.sectionTitle,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color:        const Color(0xFF608570),
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
          Expanded(
            child: GestureDetector(
              onTap: _isSaving ? null : () => _handlePublish(cubit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44.h,
                decoration: BoxDecoration(
                  color: _isSaving
                      ? _C.primary.withOpacity(0.5)
                      : _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: _isSaving
                      ? SizedBox(
                      width: 18.w, height: 18.h,
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
      ),
      SizedBox(height: 10.h),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 44.h,
                decoration: BoxDecoration(
                  color:        const Color(0xFF797979),
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
          SizedBox(width: 300.w),
          Expanded(child: Container()),
        ],
      ),
    ],
  );
}