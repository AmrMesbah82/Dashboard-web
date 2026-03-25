/// ******************* FILE INFO *******************
/// File Name: home_preview_page.dart
/// Page 3 — "Preview Main Details" (Figma screen 6)
/// Shows Desktop / Tablet / Mobile tabs with a live preview of the real
/// AppNavbar + AppFooter widgets (no simulated components).
///
/// LAYOUT LOGIC:
/// • Desktop / Tablet → fakeWidth=1366, scaled to fill the 1000.w container.
/// • Mobile           → fakeWidth=375, rendered inside a centred phone shell.
///
/// FIXED: Footer now pinned to bottom (Column with Expanded spacer).
///        Overflow stripe removed (clipBehavior + no content wider than shell).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';
import 'package:web_app_admin/widgets/app_footer.dart';
import 'package:web_app_admin/core/custom_dialog.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

enum _PreviewDevice { desktop, tablet, mobile }

// ── Phone shell constants ─────────────────────────────────────────────────────
const double _kPhoneShellW = 300.0; // rendered shell width  (logical px)
const double _kFakeMobileW = 375.0; // faked viewport width  (matches AppNavbar mobile BP)
const double _kFakeMobileH = 812.0; // faked viewport height

// ── Desktop / Tablet fake viewport ───────────────────────────────────────────
const double _kFakeDesktopW = 1366.0;
const double _kFakeDesktopH =  768.0;

class HomePreviewPage extends StatefulWidget {
  const HomePreviewPage({super.key});
  @override
  State<HomePreviewPage> createState() => _HomePreviewPageState();
}

class _HomePreviewPageState extends State<HomePreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isSaving = false;

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
      listener: (context, state) {
        if (state is HomeCmsSaved) {}
        if (state is HomeCmsError) {}
      },
      builder: (context, state) {
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.back,
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
                            SizedBox(height: 20.h),
                            AdminSubNavBar(activeIndex: 0),
                            SizedBox(height: 16.h),

                            // ── Page title ──────────────────────────────────
                            Text(
                              'Preview Main Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Device tabs ─────────────────────────────────
                            Row(
                              children: [
                                _deviceTab('Desktop', _PreviewDevice.desktop),
                                SizedBox(width: 20.w),
                                _deviceTab('Tablet',  _PreviewDevice.tablet),
                                SizedBox(width: 20.w),
                                _deviceTab('Mobile',  _PreviewDevice.mobile),
                                const Spacer(),
                                _langChip('ENG', active: true),
                                SizedBox(width: 6.w),
                                _langChip('AR',  active: false),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Preview frame ────────────────────────────────
                            LayoutBuilder(
                              builder: (ctx, constraints) =>
                                  _previewFrame(constraints.maxWidth),
                            ),

                            SizedBox(height: 24.h),

                            // ── Back + Publish ──────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: Text('Back',
                                            style: StyleText.fontSize14Weight600
                                                .copyWith(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSaving
                                        ? null
                                        : () => showPublishConfirmDialog(
                                      context: context,
                                      onConfirm: () => _publish(cubit),
                                    ),
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
                                          width: 18.w,
                                          height: 18.h,
                                          child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                            : Text('Publish',
                                            style: StyleText.fontSize14Weight600
                                                .copyWith(color: Colors.white)),
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

            // ── Saving overlay ──────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: _C.primary)),
              ),
          ],
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
          color: _C.primary,
          decoration: TextDecoration.underline,
          decorationColor: _C.primary,
        )
            : StyleText.fontSize14Weight400.copyWith(color: _C.hintText),
      ),
    );
  }

  Widget _langChip(String label, {required bool active}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: active ? _C.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(4.r),
    ),
    child: Text(label,
        style: StyleText.fontSize11Weight400
            .copyWith(color: active ? Colors.white : _C.labelText)),
  );

  // ── Preview frame dispatcher ────────────────────────────────────────────────
  Widget _previewFrame(double containerWidth) {
    if (_device == _PreviewDevice.mobile) {
      return _MobilePhoneShell(containerWidth: containerWidth);
    }

    // Desktop / Tablet — scale 1366-wide content to fill containerWidth
    final double scale     = _safeScale(containerWidth / _kFakeDesktopW);
    final double outerH    = _kFakeDesktopH * scale;

    return SizedBox(
      width:  double.infinity,
      height: outerH,
      child: Container(
        decoration: BoxDecoration(
          color:        _C.cardBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,        // ← kills any overflow stripe
        child: Transform.scale(
          scale:     scale,
          alignment: Alignment.topCenter,
          child: _PreviewContent(
            fakeWidth:  _kFakeDesktopW,
            fakeHeight: _kFakeDesktopH,
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
// Uses a fixed-height SizedBox so the Column knows its total height.
// Navbar sits at top, footer is pinned at bottom, body fills the space between.
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
      ),
      child: SizedBox(
        width:  fakeWidth,
        height: fakeHeight,   // ← explicit height so Expanded works correctly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Real AppNavbar ──────────────────────────────────────────
            AppNavbar(currentRoute: '/'),

            // ── Body spacer — pushes footer to the bottom ───────────────
            const Expanded(
              child: ColoredBox(color: Colors.white),
            ),

            // ── Real AppFooter — always at the bottom ───────────────────
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Mobile phone shell ────────────────────────────────────────────────────────
//
// Shell is _kPhoneShellW (300px) wide.
// Content is faked at _kFakeMobileW (375px) and scaled DOWN:
//   scale = 300 / 375 = 0.8
// so the real mobile navbar/footer (breakpoint < 768px) renders correctly
// and is shrunk to fit the shell.
class _MobilePhoneShell extends StatelessWidget {
  final double containerWidth;
  const _MobilePhoneShell({required this.containerWidth});

  @override
  Widget build(BuildContext context) {
    final double scale = _safeScale(_kPhoneShellW / _kFakeMobileW); // 0.8
    final double shellH = _kFakeMobileH * scale;                    // 649.6

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        _C.back,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: SizedBox(
          width:  _kPhoneShellW,
          height: shellH,
          child: Container(
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _C.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            // ← clips everything — no yellow/black overflow stripe
            clipBehavior: Clip.antiAlias,
            child: Transform.scale(
              scale:     scale,
              alignment: Alignment.topCenter,
              child: _PreviewContent(
                fakeWidth:  _kFakeMobileW,
                fakeHeight: _kFakeMobileH,
              ),
            ),
          ),
        ),
      ),
    );
  }
}