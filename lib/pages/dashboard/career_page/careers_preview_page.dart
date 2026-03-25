// ******************* FILE INFO *******************
// File Name: careers_preview_page.dart
// Created by: Amr Mesbah
// Screen: 1.3 — Preview of Careers "Main" section (Desktop / Tablet / Mobile)
//               with confirmation dialog on Save.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';


import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart' show AdminSubNavBar;
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
}

// ── Breakpoints ───────────────────────────────────────────────────────────────
const double _kMobile = 600;
const double _kTablet = 1024;

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class CareersPreviewPage extends StatefulWidget {
  const CareersPreviewPage({super.key});
  @override
  State<CareersPreviewPage> createState() => _CareersPreviewPageState();
}

class _CareersPreviewPageState extends State<CareersPreviewPage> {
  // 0 = Desktop, 1 = Tablet, 2 = Mobile
  int  _previewTab = 0;
  bool _viewOpen   = true;
  bool _saving     = false;

  // ── Save with confirmation dialog ─────────────────────────────────────────
  Future<void> _trySave(CareersCmsModel data) async {
    final confirmed = await _showConfirmDialog();
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    await context.read<CareersCmsCubit>().save(data);
    if (mounted) {
      setState(() => _saving = false);
      // Pop back to main page
      context.pop();
      context.pop();
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ConfirmDialog(),
    ) ??
        false;
  }

  void _discard() => context.pop();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersCmsCubit, CareersCmsState>(
      builder: (context, state) {
        CareersCmsModel? data;
        if (state is CareersCmsLoaded) data = state.data;
        if (state is CareersCmsSaved)  data = state.data;
        data ??= context.read<CareersCmsCubit>().current;

        return Scaffold(
          backgroundColor: _C.sectionBg,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 1000.w,
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 20.h),
                        Container(
                          width:   1000.w,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                'Preview Main Details',
                                style: StyleText.fontSize45Weight600.copyWith(
                                  color:      _C.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // ── Desktop / Tablet / Mobile tabs ────────────────────
                              Row(
                                children: [
                                  ..._buildPreviewTabs(),
                                  const Spacer(),
                                  // EN / AR toggle (cosmetic — preview pulls from model)
                                  _langToggle(),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── View accordion ────────────────────────────────────
                              _viewAccordion(data),
                              SizedBox(height: 24.h),

                              // ── Discard + Save ────────────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: _btn(
                                      label: 'Discard',
                                      color: Colors.grey.shade400,
                                      onTap: _discard,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _btn(
                                      label:   'Save',
                                      color:   _C.primary,
                                      onTap:   _saving ? null : () => _trySave(data!),
                                      loading: _saving,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
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

  // ── Preview tabs ───────────────────────────────────────────────────────────
  List<Widget> _buildPreviewTabs() {
    const labels = ['Desktop', 'Tablet', 'Mobile'];
    return List.generate(labels.length, (i) {
      final active = _previewTab == i;
      return GestureDetector(
        onTap: () => setState(() => _previewTab = i),
        child: Container(
          margin: EdgeInsets.only(right: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? _C.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            labels[i],
            style: StyleText.fontSize13Weight500.copyWith(
              color:      active ? _C.primary : _C.labelText,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  // ── Language toggle (cosmetic) ─────────────────────────────────────────────
  Widget _langToggle() {
    return Container(
      decoration: BoxDecoration(
        color:        _C.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['EN', 'AR'].map((l) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: l == 'EN' ? _C.primary : Colors.white,
              borderRadius: BorderRadius.circular(4.r),

            ),
            child: Text(
              l,
              style: StyleText.fontSize12Weight500.copyWith(
                color: l == 'EN' ? Colors.white : _C.labelText,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── View accordion ─────────────────────────────────────────────────────────
  Widget _viewAccordion(CareersCmsModel data) {
    return Container(
      decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _viewOpen = !_viewOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _viewOpen
                    ? BorderRadius.only(
                    topLeft:  Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('View',
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _viewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_viewOpen)
            _previewContent(data),
        ],
      ),
    );
  }

  // ── Preview content scaled by tab ─────────────────────────────────────────
  Widget _previewContent(CareersCmsModel data) {
    final double maxW = switch (_previewTab) {
      1 => 768,
      2 => 390,
      _ => double.infinity,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          width:  double.infinity,
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 15.h),
              // ── Careers Overview preview ─────────────────────────────────
              if (data.overview.description.en.isNotEmpty) ...[
                Text(
                  'Join a Team That Drives Innovation and Values You',
                  style: StyleText.fontSize14Weight600.copyWith(
                      fontSize: _previewTab == 2 ? 12.sp : 14.sp,
                      color:    Colors.black87),
                ),
                SizedBox(height: 8.h),
                Text(
                  data.overview.description.en,
                  style: StyleText.fontSize13Weight400.copyWith(
                      fontSize: _previewTab == 2 ? 10.sp : 12.sp,
                      height:   1.65,
                      color:    Colors.black54),
                ),
                SizedBox(height: 12.h),
              ],

              // Action Button preview
              if (data.overview.actionButtonLabel.en.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Join Bayanatz—where your future begins',
                      style: StyleText.fontSize12Weight400.copyWith(
                          fontSize: _previewTab == 2 ? 9.sp : 11.sp,
                          color: Colors.black45),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _previewTab == 2 ? 12.w : 16.w,
                          vertical:   _previewTab == 2 ? 6.h  : 8.h),
                      decoration: BoxDecoration(
                        color:        _C.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        data.overview.actionButtonLabel.en,
                        style: StyleText.fontSize12Weight600.copyWith(
                            fontSize: _previewTab == 2 ? 9.sp : 11.sp,
                            color:    Colors.white),
                      ),
                    ),
                  ],
                ),

              if (data.statistics.isNotEmpty) ...[
                SizedBox(height: 20.h),
                // Statistics row / column based on breakpoint
                _previewTab == 2
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.statistics
                      .map((s) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _statPreviewItem(s, small: true),
                  ))
                      .toList(),
                )
                    : Wrap(
                  spacing:    16.w,
                  runSpacing: 12.h,
                  children: data.statistics
                      .map((s) => SizedBox(
                    width: _previewTab == 1
                        ? 160.w
                        : 180.w,
                    child: _statPreviewItem(s),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPreviewItem(CareerStatItem s, {bool small = false}) {
    final double valFz  = small ? 18.sp : 22.sp;
    final double descFz = small ? 9.sp  : 10.sp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.summaryValue.isNotEmpty ? s.summaryValue : s.title.en,
          style: StyleText.fontSize24Weight600.copyWith(
              fontSize:   valFz,
              fontWeight: FontWeight.w700,
              color:      _C.primary),
        ),
        SizedBox(height: 3.h),
        Text(
          s.shortDescription.en.isNotEmpty
              ? s.shortDescription.en
              : s.title.en,
          style: StyleText.fontSize10Weight400.copyWith(
              fontSize: descFz, height: 1.5, color: Colors.black54),
        ),
      ],
    );
  }

  // ── Button helper ──────────────────────────────────────────────────────────
  Widget _btn({
    required String    label,
    required Color     color,
    VoidCallback?      onTap,
    bool               loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 44.h,
        decoration: BoxDecoration(
          color:        onTap == null ? color.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : Text(label,
            style: StyleText.fontSize14Weight600
                .copyWith(color: Colors.white)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRMATION DIALOG  (screen 1.3 right side)
// ═══════════════════════════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width:   360.w,
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration placeholder
            Container(
              width:  90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color:        const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.task_alt_rounded,
                  color: const Color(0xFF008037), size: 44.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'EDITING CAREERS DETAILS',
              style: StyleText.fontSize14Weight600.copyWith(
                  color: Colors.black87, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Do you want to save the changes made to this Careers?',
              style: StyleText.fontSize13Weight400.copyWith(
                  color: Colors.black54, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color:        Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('Back',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.black87)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color:        const Color(0xFF008037),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('Submit',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}