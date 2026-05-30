// ******************* FILE INFO *******************
// File Name: our_teams_edit.dart
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

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../data/models/our_teams_model.dart';
import '../../controller/our_teams_cubit.dart';
import '../../controller/our_teams_state.dart';
import 'our_teams_preview.dart';

part '../widget/our_teams_edit/picked_image.dart';
part '../widget/our_teams_edit/deliverable_edit.dart';
part '../widget/our_teams_edit/team_item_edit.dart';
part '../widget/our_teams_edit/our_teams_edit_ui.dart';

// ── Local editable model ─────────────────────────────────────────────────────

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
          backgroundColor: ColorPick.primary,
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
            backgroundColor: ColorPick.white,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        final cubit = context.read<OurTeamsCubit>();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: ColorPick.white,
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
                                    color:      ColorPick.primary,
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
                                      color:        ColorPick.primary,
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
                        const CircularProgressIndicator(color: ColorPick.primary),
                        SizedBox(height: 20.h),
                        Text('Saving...',
                            style: StyleText.fontSize14Weight600
                                .copyWith(color: ColorPick.primary)),
                        SizedBox(height: 6.h),
                        Text('Uploading images & saving data',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.secondaryText)),
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
}
