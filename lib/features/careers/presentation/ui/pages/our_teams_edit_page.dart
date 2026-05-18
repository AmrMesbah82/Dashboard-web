// ******************* FILE INFO *******************
// File Name: our_teams_edit_page.dart
// Edit page for "Our Teams" section.
// Figma: "Editing Our Teams Details"
// Features:
//   • Green accordion "Our Team"
//   • Per-item: Heading EN/AR, Icon (SVG upload), Title EN/AR,
//               Description EN/AR, Deliverables EN/AR, + Deliverables chips,
//               Remove button per item
//   • "Add Team" button (top-right, green)
//   • Preview / Save / Discard bottom buttons
// UPDATED: Added validation, SVG-only restriction, publish confirmation dialog,
//          and _isDirty flag to prevent re-seeding from cubit on local edits

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';


import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../data/model/our_teams_model.dart';
import '../../controller/our_teams_cubit.dart';
import '../../controller/our_teams_state.dart';
import 'our_teams_preview_page.dart';


class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color remove    = Color(0xFFE53935);
  static const Color discard   = Color(0xFF797979);
  static const Color preview   = Color(0xFF608570);
  static const Color errorRed  = Color(0xFFD32F2F);
}

// ── Local editable model ─────────────────────────────────────────────────────

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
  bool get hasImage => !isEmpty;
}

class _DeliverableEdit {
  final String id;
  final TextEditingController enCtrl;
  final TextEditingController arCtrl;

  _DeliverableEdit({required this.id, String en = '', String ar = ''})
      : enCtrl = TextEditingController(text: en),
        arCtrl = TextEditingController(text: ar);

  void dispose() {
    enCtrl.dispose();
    arCtrl.dispose();
  }
}

class _TeamItemEdit {
  final String id;
  _PickedImage icon;
  final TextEditingController headingEn;
  final TextEditingController headingAr;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  final List<_DeliverableEdit> deliverables;

  _TeamItemEdit({
    required this.id,
    _PickedImage? icon,
    String headingEn = '',
    String headingAr = '',
    String titleEn   = '',
    String titleAr   = '',
    String descEn    = '',
    String descAr    = '',
    List<_DeliverableEdit>? deliverables,
  })  : icon       = icon ?? const _PickedImage(),
        headingEn  = TextEditingController(text: headingEn),
        headingAr  = TextEditingController(text: headingAr),
        titleEn    = TextEditingController(text: titleEn),
        titleAr    = TextEditingController(text: titleAr),
        descEn     = TextEditingController(text: descEn),
        descAr     = TextEditingController(text: descAr),
        deliverables = deliverables ?? [];

  void dispose() {
    headingEn.dispose();
    headingAr.dispose();
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
    for (final d in deliverables) d.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
class OurTeamsEditPage extends StatefulWidget {
  const OurTeamsEditPage({super.key});

  @override
  State<OurTeamsEditPage> createState() => _OurTeamsEditPageState();
}

class _OurTeamsEditPageState extends State<OurTeamsEditPage> {
  bool _submitted     = false;
  bool _isSaving      = false;
  bool _accordionOpen = true;
  bool _isDirty       = false; // ← prevents cubit re-seeding on local edits
  int? _seededHash;

  final List<_TeamItemEdit> _items = [];

  // ── Seed from model ─────────────────────────────────────────────────────────
  void _seedFromModel(OurTeamsModel data) {
    // If the user has made local structural changes (add/remove items or
    // deliverables), don't let the cubit wipe those changes on rebuild.
    if (_isDirty) return;

    final hash = Object.hashAll([
      data.items.length,
      ...data.items.map((i) =>
      '${i.id}${i.iconUrl}${i.heading.en}${i.title.en}${i.description.en}'),
    ]);
    if (_seededHash == hash) return;
    _seededHash = hash;

    for (final item in _items) item.dispose();
    _items.clear();

    for (final item in data.items) {
      _items.add(_TeamItemEdit(
        id:          item.id,
        icon:        item.iconUrl.isNotEmpty
            ? _PickedImage(url: item.iconUrl)
            : const _PickedImage(),
        headingEn:   item.heading.en,
        headingAr:   item.heading.ar,
        titleEn:     item.title.en,
        titleAr:     item.title.ar,
        descEn:      item.description.en,
        descAr:      item.description.ar,
        deliverables: item.deliverableItems
            .map((d) => _DeliverableEdit(
          id: d.id,
          en: d.label.en,
          ar: d.label.ar,
        ))
            .toList(),
      ));
    }
  }

  // ── Validation ──────────────────────────────────────────────────────────────
  bool _validateAllFields() {
    if (_items.isEmpty) return false;

    for (final item in _items) {
      if (item.headingEn.text.trim().isEmpty) return false;
      if (item.headingAr.text.trim().isEmpty) return false;
      if (item.titleEn.text.trim().isEmpty) return false;
      if (item.titleAr.text.trim().isEmpty) return false;
      if (item.descEn.text.trim().isEmpty) return false;
      if (item.descAr.text.trim().isEmpty) return false;
      if (!item.icon.hasImage) return false;

      for (final d in item.deliverables) {
        if (d.enCtrl.text.trim().isEmpty) return false;
        if (d.arCtrl.text.trim().isEmpty) return false;
      }
    }

    return true;
  }

  // ── Pick SVG (SVG only) ─────────────────────────────────────────────────────
  Future<_PickedImage?> _pickSvg() async {
    final completer  = Completer<_PickedImage?>();
    bool  completed  = false;
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:         const Text('Only SVG files are allowed'),
              backgroundColor: Colors.red,
              behavior:        SnackBarBehavior.floating,
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
            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
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
  Future<void> _performSave(OurTeamsCubit cubit) async {
    setState(() => _isSaving = true);

    try {
      // Sync item count in cubit
      while (cubit.current.items.length < _items.length) cubit.addItem();
      while (cubit.current.items.length > _items.length) {
        cubit.removeItem(cubit.current.items.last.id);
      }

      for (var i = 0; i < _items.length; i++) {
        final local     = _items[i];
        final cubitItem = cubit.current.items[i];

        cubit.updateHeading(cubitItem.id,
            en: local.headingEn.text.trim(),
            ar: local.headingAr.text.trim());
        cubit.updateTitle(cubitItem.id,
            en: local.titleEn.text.trim(),
            ar: local.titleAr.text.trim());
        cubit.updateDescription(cubitItem.id,
            en: local.descEn.text.trim(),
            ar: local.descAr.text.trim());

        // Sync deliverables
        for (final d in List.from(cubit.current.items[i].deliverableItems)) {
          cubit.removeDeliverable(cubitItem.id, d.id);
        }
        for (final d in local.deliverables) {
          cubit.addDeliverable(cubitItem.id);
          final newId = cubit.current.items[i].deliverableItems.last.id;
          cubit.updateDeliverable(
            cubitItem.id,
            newId,
            BilingualText(en: d.enCtrl.text.trim(), ar: d.arCtrl.text.trim()),
          );
        }

        // Upload icon if newly picked
        if (local.icon.bytes != null) {
          await cubit.uploadIcon(cubitItem.id, local.icon.bytes!);
        }
      }

      await cubit.save();

      if (mounted) {
        setState(() {
          _isSaving    = false;
          _seededHash  = null;
          _isDirty     = false; // ← reset so fresh data re-seeds after save
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Our Teams saved!',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white)),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r)),
        ));

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Handle Publish with confirmation dialog ─────────────────────────────────
  Future<void> _handlePublish(OurTeamsCubit cubit) async {
    setState(() => _submitted = true);

    if (!_validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields and upload icons',
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

    await showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH OUR TEAMS',
      subtitle: 'Do you want to publish the changes made to Our Teams?',
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

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OurTeamsCubit, OurTeamsState>(
      listener: (context, state) {
        if (state is OurTeamsError) {
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
        if (state is OurTeamsLoaded) _seedFromModel(state.data);
        if (state is OurTeamsSaved)  _seedFromModel(state.data);

        if (state is OurTeamsInitial || state is OurTeamsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final cubit = context.read<OurTeamsCubit>();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.sectionBg,
              body: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(height: 20.h),

                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Page title + Add Team ───────────────────────
                            Row(
                              children: [
                                Text(
                                  'Editing Our Teams Details',
                                  style: StyleText.fontSize45Weight600.copyWith(
                                    color:      _C.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    final newId = const Uuid().v4();
                                    setState(() {
                                      _isDirty = true; // ← mark dirty
                                      _items.add(_TeamItemEdit(id: newId));
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color:        _C.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'Add Team',
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // ── Accordion ───────────────────────────────────
                            _accordion(
                              title: 'Our Team',
                              children: [
                                ..._items.asMap().entries.map(
                                      (e) => _itemWidget(e.key, e.value),
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

            // ── Saving overlay ──────────────────────────────────────────────
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
                            color:      Colors.black.withOpacity(.15),
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

  // ── Single item edit widget ─────────────────────────────────────────────────
  Widget _itemWidget(int index, _TeamItemEdit item) {
    final iconHasError = _submitted && !item.icon.hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          Divider(color: const Color(0xFFE8E8E8), height: 1),
          SizedBox(height: 12.h),
        ] else
          SizedBox(height: 12.h),

        // ── Heading EN / AR ─────────────────────────────────────────────────
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label:         'Heading',
              hint:          'Text Here',
              controller:    item.headingEn,
              height:        36,
              fillColor:     Colors.white,
              submitted:     _submitted,
              textDirection: TextDirection.ltr,
              textAlign:     TextAlign.left,
              primaryColor:  _C.primary,
              isRequired:    true,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label:         'العنوان',
                hint:          'أدخل النص هنا',
                controller:    item.headingAr,
                height:        36,
                fillColor:     Colors.white,
                submitted:     _submitted,
                textDirection: TextDirection.rtl,
                textAlign:     TextAlign.right,
                primaryColor:  _C.primary,
                isRequired:    true,
              ),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        // ── Icon + Remove row ────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Icon',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _C.labelText)),
                    Text(' *',
                        style: TextStyle(
                          color:      Colors.red,
                          fontSize:   12.sp,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                SizedBox(height: 6.h),
                _imgBox(
                  picked:   item.icon,
                  hasError: iconHasError,
                  onPick: () async {
                    final p = await _pickSvg();
                    if (p != null) {
                      setState(() {
                        _isDirty   = true; // ← mark dirty on icon change
                        item.icon  = p;
                      });
                    }
                  },
                ),
                if (iconHasError) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Icon (SVG) is required',
                    style: TextStyle(fontSize: 11.sp, color: _C.errorRed),
                  ),
                ],
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDirty = true; // ← mark dirty on remove
                  _items.removeAt(index);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color:        _C.remove,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Remove',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Title EN / AR ────────────────────────────────────────────────────
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label:         'Title',
              hint:          'Text Here',
              controller:    item.titleEn,
              height:        36,
              fillColor:     Colors.white,
              submitted:     _submitted,
              textDirection: TextDirection.ltr,
              textAlign:     TextAlign.left,
              primaryColor:  _C.primary,
              isRequired:    true,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label:         'العنوان',
                hint:          'أدخل النص هنا',
                controller:    item.titleAr,
                height:        36,
                fillColor:     Colors.white,
                submitted:     _submitted,
                textDirection: TextDirection.rtl,
                textAlign:     TextAlign.right,
                primaryColor:  _C.primary,
                isRequired:    true,
              ),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        // ── Description EN ───────────────────────────────────────────────────
        CustomValidatedTextFieldMaster(
          label:         'Description',
          hint:          'Text Here',
          controller:    item.descEn,
          height:        80,
          maxLines:      3,
          fillColor:     Colors.white,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.left,
          primaryColor:  _C.primary,
          isRequired:    true,
        ),
        SizedBox(height: 8.h),

        // ── الوصف AR ─────────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label:         'الوصف',
            hint:          'أدخل النص هنا',
            controller:    item.descAr,
            height:        80,
            maxLines:      3,
            fillColor:     Colors.white,
            submitted:     _submitted,
            textDirection: TextDirection.rtl,
            textAlign:     TextAlign.right,
            primaryColor:  _C.primary,
            isRequired:    true,
          ),
        ),
        SizedBox(height: 14.h),

        // ── Deliverables list ────────────────────────────────────────────────
        ...item.deliverables.asMap().entries.map(
              (e) => _deliverableRow(e.key, e.value, item),
        ),
        SizedBox(height: 8.h),

        // ── + Deliverables button ────────────────────────────────────────────
        GestureDetector(
          onTap: () {
            setState(() {
              _isDirty = true; // ← mark dirty on add deliverable
              item.deliverables.add(_DeliverableEdit(id: const Uuid().v4()));
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color:        const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Deliverables',
                  style: StyleText.fontSize13Weight500
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ── Deliverable row ─────────────────────────────────────────────────────────
  Widget _deliverableRow(
      int index, _DeliverableEdit d, _TeamItemEdit item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label:         index == 0 ? 'Deliverable' : '',
              hint:          'Text Here',
              controller:    d.enCtrl,
              height:        36,
              fillColor:     Colors.white,
              submitted:     _submitted,
              textDirection: TextDirection.ltr,
              textAlign:     TextAlign.left,
              primaryColor:  _C.primary,
              isRequired:    true,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label:         index == 0 ? 'المخرجات' : '',
                hint:          'أدخل النص هنا',
                controller:    d.arCtrl,
                height:        36,
                fillColor:     Colors.white,
                submitted:     _submitted,
                textDirection: TextDirection.rtl,
                textAlign:     TextAlign.right,
                primaryColor:  _C.primary,
                isRequired:    true,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => setState(() {
              _isDirty = true; // ← mark dirty on remove deliverable
              item.deliverables.removeAt(index);
            }),
            child: Container(
              width:  20.w,
              height: 20.h,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image box ───────────────────────────────────────────────────────────────
  Widget _imgBox({
    required _PickedImage picked,
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
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(
              picked.bytes!,
              width:  30.w,
              height: 30.h,
              fit:    BoxFit.contain,
            ),
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
            child: SvgPicture.network(
              picked.url!,
              width:              30.w,
              height:             30.h,
              fit:                BoxFit.contain,
              placeholderBuilder: (_) => const CircularProgressIndicator(
                  strokeWidth: 2),
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: hasError
              ? _C.errorRed.withOpacity(0.08)
              : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: hasError ? _C.errorRed : Colors.grey,
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
          right:  0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width:  25.w,
              height: 25.h,
              decoration: BoxDecoration(
                color: _C.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: 'assets/control/camera.svg',
                  width:  10.w,
                  height: 10.h,
                  fit:    BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ───────────────────────────────────────────────────────────────
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
                color:        _C.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Icon(
                    _accordionOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20.sp,
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

  // ── Bottom buttons ──────────────────────────────────────────────────────────
  Widget _bottomButtons(OurTeamsCubit cubit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const OurTeamsPreviewPage(),
                    ),
                  ),
                ),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color:        _C.preview,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Preview',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
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
                      width:  18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      'Publish',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
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
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color:        _C.discard,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Discard',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(child: const SizedBox()),
          ],
        ),
      ],
    );
  }
}