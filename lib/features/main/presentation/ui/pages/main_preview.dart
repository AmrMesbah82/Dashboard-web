/// ******************* FILE INFO *******************
/// File Name: main_preview.dart
/// UPDATED: Language toggle now drives LanguageCubit (same source AppNavbar uses).
///          Removed local _langIndex — isRtl is read from LanguageCubit state.
///          Navbar + footer truly full-width in preview frame.
///          OverflowBox + Transform.scale anchored to topLeft.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/custom_dialog.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/two_tab.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import 'main_main.dart';

part '../widgets/main_preview/preview_content.dart';
part '../widgets/main_preview/mobile_phone_shell.dart';

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color border    = Color(0xFFE0E0E0);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
//   static const Color back      = Color(0xFFF1F2ED);
// }

enum _PreviewDevice { desktop, tablet, mobile }

// ── Phone shell constants ─────────────────────────────────────────────────────
const double _kPhoneShellW = 300.0;
const double _kFakeMobileW = 375.0;
const double _kFakeMobileH = 812.0;

// ── Desktop / Tablet fake viewport ───────────────────────────────────────────
const double _kFakeDesktopW = 1366.0;
const double _kFakeDesktopH =  768.0;

class MainPreviewPage extends StatefulWidget {
  const MainPreviewPage({super.key});
  @override
  State<MainPreviewPage> createState() => _MainPreviewPageState();
}

class _MainPreviewPageState extends State<MainPreviewPage> {
  _PreviewDevice _device   = _PreviewDevice.desktop;
  // ✅ REMOVED: int _langIndex — now read from LanguageCubit
  bool           _isSaving = false;

  Future<void> _publish(HomeCmsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save(publishStatus: 'published');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        // ✅ Wrap entire scaffold in BlocBuilder<LanguageCubit> so every
        //    widget below reacts to language changes automatically.
        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: ColorPick.background,
                  body: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 1000.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppAdminNavbar(
                                  activeLabel:    'web page',
                                  homePage:       CareersMainPageDashboard(),
                                  webPage:        MainMainPage(),
                                  jobListingPage: JobListingMainPage(),
                                ),

                                SizedBox(height: 20.h),
                                AdminSubNavBar(activeIndex: 0),
                                SizedBox(height: 16.h),

                                // ── Page title ──────────────────────────────
                                Text(
                                  'Preview Main Details',
                                  style: StyleText.fontSize45Weight600.copyWith(
                                    color: ColorPick.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // ── Device tabs + language toggle ────────────
                                Row(
                                  children: [
                                    _deviceTab('Desktop', _PreviewDevice.desktop),
                                    SizedBox(width: 20.w),
                                    _deviceTab('Tablet',  _PreviewDevice.tablet),
                                    SizedBox(width: 20.w),
                                    _deviceTab('Mobile',  _PreviewDevice.mobile),
                                    const Spacer(),

                                    // ✅ Toggle now calls LanguageCubit,
                                    //    selectedIndex read from langState.
                                    CustomSegmentedTabs(
                                      tabs: ['ENG', 'AR'],
                                      selectedIndex: isRtl ? 1 : 0,
                                      onTabSelected: (i) {
                                        context
                                            .read<LanguageCubit>()
                                            .setLanguage(i == 1 ? 'ar' : 'en');
                                      },
                                      selectedColor:       ColorPick.primary,
                                      unselectedColor:     Colors.transparent,
                                      selectedTextColor:   Colors.white,
                                      unselectedTextColor: AppColors.text,
                                      containerColor:
                                      ColorPick.white.withValues(alpha: 0.45),
                                      equalWidth: false,
                                      containerPadding: EdgeInsets.symmetric(
                                          horizontal: 8.sp, vertical: 4.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),

                                // ── Preview frame ────────────────────────────
                                // ✅ isRtl now comes from LanguageCubit — same
                                //    source AppNavbar uses internally.
                                LayoutBuilder(
                                  builder: (ctx, constraints) => _previewFrame(
                                    constraints.maxWidth,
                                    isRtl: isRtl,
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // ── Back + Publish ───────────────────────────
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => context.pop(),
                                        child: Container(
                                          height: 44.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            borderRadius:
                                            BorderRadius.circular(6.r),
                                          ),
                                          child: Center(
                                            child: Text('Back',
                                                style: StyleText
                                                    .fontSize14Weight600
                                                    .copyWith(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 400.w),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _isSaving
                                            ? null
                                            : () => showPublishConfirmDialog(
                                          context: context,
                                          onConfirm: () =>
                                              _publish(cubit),
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          height: 44.h,
                                          decoration: BoxDecoration(
                                            color: _isSaving
                                                ? ColorPick.primary.withValues(alpha: 0.5)
                                                : ColorPick.primary,
                                            borderRadius:
                                            BorderRadius.circular(6.r),
                                          ),
                                          child: Center(
                                            child: _isSaving
                                                ? SizedBox(
                                              width:  18.w,
                                              height: 18.h,
                                              child:
                                              const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2),
                                            )
                                                : Text('Publish',
                                                style: StyleText
                                                    .fontSize14Weight600
                                                    .copyWith(
                                                    color:
                                                    Colors.white)),
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
                        ],
                      ),
                    ),
                  ),
                ),

                if (_isSaving)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                        child: CircularProgressIndicator(color: ColorPick.primary)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Device tab ──────────────────────────────────────────────────────────────
  Widget _deviceTab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Text(
        label,
        style: active
            ? StyleText.fontSize14Weight600.copyWith(
          color:           ColorPick.primary,
          decoration:      TextDecoration.underline,
          decorationColor: ColorPick.primary,
        )
            : StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      ),
    );
  }

  // ── Preview frame dispatcher ────────────────────────────────────────────────
  Widget _previewFrame(double containerWidth, {required bool isRtl}) {
    if (_device == _PreviewDevice.mobile) {
      return _MobilePhoneShell(
          containerWidth: containerWidth, isRtl: isRtl);
    }

    final double scale  = _safeScale(containerWidth / _kFakeDesktopW);
    final double outerH = _kFakeDesktopH * scale;

    return SizedBox(
      width:  double.infinity,
      height: outerH,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth:  _kFakeDesktopW,
          maxHeight: _kFakeDesktopH,
          child: Transform.scale(
            scale:     scale,
            alignment: Alignment.topLeft,
            child: _PreviewContent(
              fakeWidth:  _kFakeDesktopW,
              fakeHeight: _kFakeDesktopH,
              isRtl:      isRtl,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Safe scale helper ─────────────────────────────────────────────────────────
double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ── Shared preview content ────────────────────────────────────────────────────
