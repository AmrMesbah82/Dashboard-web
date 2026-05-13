// ******************* FILE INFO *******************
// File Name: our_teams_preview_page.dart
// Preview page for "Our Teams" section.
// Figma: "Meet Our Teams" — rows of cards (3-col, 2-col, 1-col)
// Each card: icon (circle), team name green badge, description, deliverables chips
// Rows labeled: First Row, Second Row, Third Row…

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/career/our_teams_cubit.dart';
import 'package:web_app_admin/controller/career/our_teams_state.dart';

import 'package:web_app_admin/model/our_teams_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

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

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
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
    String titleEn = '',
    String titleAr = '',
    String descEn = '',
    String descAr = '',
    List<_DeliverableEdit>? deliverables,
  }) : icon = icon ?? const _PickedImage(),
       headingEn = TextEditingController(text: headingEn),
       headingAr = TextEditingController(text: headingAr),
       titleEn = TextEditingController(text: titleEn),
       titleAr = TextEditingController(text: titleAr),
       descEn = TextEditingController(text: descEn),
       descAr = TextEditingController(text: descAr),
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

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF1F2ED);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color remove = Color(0xFFE53935);
  static const Color discard = Color(0xFF797979);
  static const Color preview = Color(0xFF608570);
}

// ═══════════════════════════════════════════════════════════════════════════════
class OurTeamsPreviewPage extends StatelessWidget {
  const OurTeamsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OurTeamsCubit, OurTeamsState>(
      builder: (context, state) {
        OurTeamsModel? data;
        if (state is OurTeamsLoaded) data = state.data;
        if (state is OurTeamsSaved) data = state.data;

        return Scaffold(
          backgroundColor: _C.sectionBg,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 5),
                  SizedBox(height: 20.h),

                  Container(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Back + title ───────────────────────────────────
                        Row(
                          children: [
                            Text(
                              'Our Teams — Preview',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // ── "View" accordion ───────────────────────────────
                        _ViewSection(data: data),
                        SizedBox(height: 40.h),
                      ],
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// Preview accordion + rows
// ═══════════════════════════════════════════════════════════════════════════════
class _ViewSection extends StatefulWidget {
  final OurTeamsModel? data;
  const _ViewSection({this.data});

  @override
  State<_ViewSection> createState() => _ViewSectionState();
}

class _ViewSectionState extends State<_ViewSection> {
  bool _open = true;
  bool _isSaving = false;
  bool _submitted = false;
  // Figma uses fixed row sizes: First Row = 3 cards, Second Row = 2, Third = 1.
  // We chunk items into rows of 3.
  static const int _perRow = 3;
  final List<_TeamItemEdit> _items = [];
  @override
  Widget build(BuildContext context) {
    final items = widget.data?.items ?? [];
    final cubit = context.read<OurTeamsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Green accordion header ─────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: _open
                  ? BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r),
                    )
                  : BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'View',
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),

        if (_open) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(6.r),
                bottomRight: Radius.circular(6.r),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section title ────────────────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Meet ',
                          style: StyleText.fontSize24Weight600.copyWith(
                            fontSize: 22.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Our Teams',
                          style: StyleText.fontSize24Weight600.copyWith(
                            fontSize: 22.sp,
                            color: _C.primary,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.w),
                      child: Text(
                        'No teams added yet.',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: _C.hintText,
                        ),
                      ),
                    ),
                  )
                else
                  ..._buildRows(items),

                SizedBox(height: 15.sp),
                _bottomButtons(cubit),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _save(OurTeamsCubit cubit) async {
    setState(() {
      _submitted = true;
      _isSaving = true;
    });
    try {
      // Sync item count in cubit
      while (cubit.current.items.length < _items.length) cubit.addItem();
      while (cubit.current.items.length > _items.length) {
        cubit.removeItem(cubit.current.items.last.id);
      }

      for (var i = 0; i < _items.length; i++) {
        final local = _items[i];
        final cubitItem = cubit.current.items[i];

        cubit.updateHeading(
          cubitItem.id,
          en: local.headingEn.text,
          ar: local.headingAr.text,
        );
        cubit.updateTitle(
          cubitItem.id,
          en: local.titleEn.text,
          ar: local.titleAr.text,
        );
        cubit.updateDescription(
          cubitItem.id,
          en: local.descEn.text,
          ar: local.descAr.text,
        );

        // Sync deliverables
        // Remove all then re-add from local state
        for (final d in List.from(cubit.current.items[i].deliverableItems)) {
          cubit.removeDeliverable(cubitItem.id, d.id);
        }
        for (final d in local.deliverables) {
          cubit.addDeliverable(cubitItem.id);
          final newId = cubit.current.items[i].deliverableItems.last.id;
          cubit.updateDeliverable(
            cubitItem.id,
            newId,
            BilingualText(en: d.enCtrl.text, ar: d.arCtrl.text),
          );
        }

        // Upload icon if newly picked
        if (local.icon.bytes != null) {
          await cubit.uploadIcon(cubitItem.id, local.icon.bytes!);
        }
      }

      await cubit.save();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _bottomButtons(OurTeamsCubit cubit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _C.discard,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Discard',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: _isSaving ? null : () => _save(cubit),
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save',
                            style: StyleText.fontSize14Weight600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Build chunked rows ──────────────────────────────────────────────────────
  List<Widget> _buildRows(List<OurTeamItem> items) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i += _perRow) {
      final rowIndex = i ~/ _perRow;
      final chunk = items.sublist(i, (i + _perRow).clamp(0, items.length));

      widgets.add(
        _RowSection(rowIndex: rowIndex, items: chunk, totalPerRow: _perRow),
      );

      if (i + _perRow < items.length) widgets.add(SizedBox(height: 14.h));
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// A labeled row (First Row, Second Row …) with card count selector header
// ═══════════════════════════════════════════════════════════════════════════════
class _RowSection extends StatelessWidget {
  final int rowIndex;
  final List<OurTeamItem> items;
  final int totalPerRow;

  const _RowSection({
    required this.rowIndex,
    required this.items,
    required this.totalPerRow,
  });

  String get _rowLabel {
    const labels = [
      'First Row',
      'Second Row',
      'Third Row',
      'Fourth Row',
      'Fifth Row',
      'Sixth Row',
      'Seventh Row',
    ];
    return rowIndex < labels.length
        ? labels[rowIndex]
        : '${rowIndex + 1}th Row';
  }

  @override
  Widget build(BuildContext context) {
    // Row header: label left, card count right
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row label bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_handle_rounded,
                    color: _C.labelText,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _rowLabel,
                    style: StyleText.fontSize13Weight600.copyWith(
                      color: _C.labelText,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${items.length} Card',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: _C.labelText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Cards
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...items
                    .asMap()
                    .entries
                    .map((e) {
                      final Widget card = Expanded(
                        child: _TeamCard(item: e.value),
                      );
                      if (e.key < items.length - 1) {
                        return [card, SizedBox(width: 14.w)];
                      }
                      return [card];
                    })
                    .expand((w) => w),

                // Fill remaining slots with empty Expanded
                ...List.generate(
                  totalPerRow - items.length,
                  (_) => [
                    SizedBox(width: 14.w),
                    const Expanded(child: SizedBox()),
                  ],
                ).expand((w) => w),




              ],
            ),
          ),


        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Individual Team Card  — matches Figma card design
// ═══════════════════════════════════════════════════════════════════════════════
class _TeamCard extends StatefulWidget {
  final OurTeamItem item;
  const _TeamCard({required this.item});

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Delete / drag icon row ───────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: _C.hintText,
                    size: 18.sp,
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // ── Icon ────────────────────────────────────────────────────
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: item.iconUrl.isNotEmpty
                      ? Colors.white
                      : const Color(0xFFE8F5EE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _C.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: item.iconUrl.isNotEmpty
                    ? ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(14.r),
                          child: SvgPicture.network(
                            item.iconUrl,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => const SizedBox(),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.groups_rounded,
                          color: _C.primary,
                          size: 26.sp,
                        ),
                      ),
              ),
              SizedBox(height: 12.h),

              // ── Team title badge ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Text(
                    item.title.en.isEmpty
                        ? 'Strategy & Planning Team'
                        : item.title.en,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize13Weight600.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // ── Description ─────────────────────────────────────────────
              Text(
                item.description.en.isEmpty
                    ? 'Conduct market analysis, establish KPIs, and set '
                          'timelines for deliverables. Ensure every project is '
                          'mapped to measurable business outcomes.'
                    : item.description.en,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: Colors.black54,
                  fontSize: 11.sp,
                  height: 1.5,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),

              // ── Deliverables ─────────────────────────────────────────────
              if (item.deliverableItems.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Deliverables:',
                    style: StyleText.fontSize12Weight600.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: item.deliverableItems
                      .map((d) => _chip(d.label.en))
                      .toList(),
                ),
              ] else ...[
                // Placeholder chips to match Figma skeleton
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Deliverables:',
                    style: StyleText.fontSize12Weight600.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: List.generate(
                    8,
                    (_) => _chip('Inactive', inactive: true),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, {bool inactive = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: inactive ? const Color(0xFFF5F5F5) : _C.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text.isEmpty ? 'Inactive' : text,
        style: StyleText.fontSize10Weight700.copyWith(
          fontSize: 10.sp,
          color: inactive ? _C.hintText : _C.primary,
        ),
      ),
    );
  }
}
