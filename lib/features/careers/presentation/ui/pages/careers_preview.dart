// ******************* FILE INFO *******************
// File Name: careers_preview.dart
// Created by: Amr Mesbah
// Screen: 1.3 — Preview of Careers "Main" section (Desktop / Tablet / Mobile)
//               Mirrors about_us_preview.dart architecture exactly.
//               Publish confirm dialog → BlocListener navigates to CareersMainPageMaster.
//
// CHANGES (Figma sync):
//   • Added _SiteNavBar inside _PreviewContent (mirrors live site header)
//   • Added green "View" collapsible bar above browser chrome
//   • Hero section now renders rich description with bullet paragraphs
//   • Hero tagline + Apply Now button row at bottom of hero
//   • Stats rendered as number-headline cards (82%, 93%, 6, 75%, 1,200+, 6)
//   • Bottom action row: "Discard" (grey) + spacer + "Save" (green)

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/two_tab.dart';
import '../../../data/models/careers_model.dart';
import '../../controller/careers_cubit.dart';
import '../../controller/careers_state.dart';
import 'careers_main_page.dart'; // CareersMainPageMaster

part '../widgets/careers_preview/a_c.dart';
part '../widgets/careers_preview/desktop_frame.dart';
part '../widgets/careers_preview/tablet_frame.dart';
part '../widgets/careers_preview/mobile_frame.dart';
part '../widgets/careers_preview/view_bar.dart';
part '../widgets/careers_preview/preview_content.dart';
part '../widgets/careers_preview/site_nav_bar.dart';
part '../widgets/careers_preview/bullet_text.dart';
part '../widgets/careers_preview/stat_card.dart';
part '../widgets/careers_preview/browser_chrome.dart';

// ── Admin-shell colors ────────────────────────────────────────────────────────

class CareersPreviewPage extends StatefulWidget {
  const CareersPreviewPage({super.key});
  @override
  State<CareersPreviewPage> createState() => _CareersPreviewPageState();
}

class _CareersPreviewPageState extends State<CareersPreviewPage> {
  _PreviewDevice _device       = _PreviewDevice.desktop;
  bool           _isAr         = false;
  bool           _isPublishing = false;

  void _onBack() => Navigator.pop(context);

  void _onSave(CareersCmsModel data) {
    showPublishConfirmDialog(
      context: context,
      title: 'PUBLISH CAREERS PAGE',
      subtitle:
      'Do you want to publish the changes made to this Careers page?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: () async {
        if (!mounted) return;
        setState(() => _isPublishing = true);
        try {
          await context.read<CareersCmsCubit>().save(data);
        } finally {
          if (mounted) setState(() => _isPublishing = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CareersCmsCubit, CareersCmsState>(
      listener: (context, state) {
        if (state is CareersCmsSaved) {
          // Defer navigation OUT of the frame (fixes mouse_tracker
          // !_debugDuringDeviceUpdate assertion on Flutter web debug).
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const CareersMainPageMaster()),
                    (route) => false,
              );
            }
          });
        }
        if (state is CareersCmsError) {
          if (mounted) setState(() => _isPublishing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _AC.red,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: _AC.back,
            body: BlocBuilder<CareersCmsCubit, CareersCmsState>(
              builder: (context, state) {
                CareersCmsModel? data;
                if (state is CareersCmsLoaded) data = state.data;
                if (state is CareersCmsSaved)  data = state.data;
                data ??= context.read<CareersCmsCubit>().current;

                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          AdminSubNavBar(activeIndex: 5),
                          SizedBox(height: 16.h),

                          // ── Page title ──────────────────────────────────
                          Text(
                            'Preview Main Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color:      ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Device tabs + Language toggle ───────────────
                          Row(
                            children: [
                              _tab('Desktop', _PreviewDevice.desktop),
                              SizedBox(width: 24.w),
                              _tab('Tablet',  _PreviewDevice.tablet),
                              SizedBox(width: 24.w),
                              _tab('Mobile',  _PreviewDevice.mobile),
                              const Spacer(),
                              SizedBox(
                                width: 95.w,
                                height: 36.h,
                                child: CustomSegmentedTabs(
                                  tabs: const ['ENG', 'AR'],
                                  selectedIndex: _isAr ? 1 : 0,
                                  onTabSelected: (i) =>
                                      setState(() => _isAr = i == 1),
                                  selectedColor:       ColorPick.primary,
                                  unselectedColor:     Colors.white,
                                  selectedTextColor:   Colors.white,
                                  unselectedTextColor: AppColors.text,
                                  equalWidth: false,
                                  containerPadding: EdgeInsets.symmetric(
                                    horizontal: 8.sp,
                                    vertical:   4.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Scaled device frame ─────────────────────────
                          LayoutBuilder(
                            builder: (ctx, box) =>
                                _buildFrame(box.maxWidth, data!),
                          ),

                          SizedBox(height: 24.h),

                          // ── Discard + Save buttons ──────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _onBack,
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color:        ColorPick.discard,
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isPublishing
                                      ? null
                                      : () => _onSave(data!),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _isPublishing
                                          ? ColorPick.primary.withValues(alpha: 0.5)
                                          : ColorPick.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: _isPublishing
                                          ? SizedBox(
                                        width:  18.w,
                                        height: 18.h,
                                        child: const CircularProgressIndicator(
                                          color:       Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        'Save',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Full-screen publishing overlay ─────────────────────────────
          if (_isPublishing)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(color: ColorPick.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ── Device tab pill ────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
    final bool active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label,
              style: StyleText.fontSize15Weight500.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color:      active ? ColorPick.primary : AppColors.secondaryText,
              ),
            ),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? ColorPick.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame builder ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, CareersCmsModel data) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW, data: data, isAr: _isAr);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE FRAMES
// ═══════════════════════════════════════════════════════════════════════════════

// ── Desktop ───────────────────────────────────────────────────────────────────
