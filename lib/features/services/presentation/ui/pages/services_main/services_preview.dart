// ******************* FILE INFO *******************
// File Name: services_preview.dart
// Screen 3 — Services CMS: Preview "Main" section (Desktop/Tablet/Mobile)
// UPDATED: Added responsive sizing and CENTER alignment for all content
// Save button shows confirm dialog before persisting.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constant/color.dart';
import '../../../../../../core/custom_dialog.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../../core/two_tab.dart';
import '../../../../../main/presentation/ui/pages/main_main.dart';
import '../../../../data/models/services_model.dart';
import '../../../controller/services_cubit.dart';
import '../../../controller/services_state.dart';
import '../services_main/services_main.dart'; // ← same import as edit page

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color border    = Color(0xFFE0E0E0);
//   static const Color grey      = Color(0xFF9E9E9E);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFF797979);
// }

enum _Device { desktop, tablet, mobile }

class ServicesMainPreviewPage extends StatefulWidget {
  final ServicePageModel model;
  const ServicesMainPreviewPage({super.key, required this.model});

  @override
  State<ServicesMainPreviewPage> createState() => _ServicesMainPreviewPageState();
}

class _ServicesMainPreviewPageState extends State<ServicesMainPreviewPage> {
  _Device _device   = _Device.desktop;
  bool    _isAr     = false;
  bool    _viewOpen = true;

  // ── Responsive container width ─────────────────────────────────────────────
  double get _containerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600)  return screenWidth * 0.9;
    if (screenWidth < 1024) return screenWidth * 0.85;
    return 1000.w;
  }

  Future<void> _save() async {
    final cubit = context.read<ServiceCmsCubit>();

    // 1. Push edited values into cubit
    cubit.updateTitle(
      en: widget.model.title.en,
      ar: widget.model.title.ar,
    );
    cubit.updateShortDescription(
      en: widget.model.shortDescription.en,
      ar: widget.model.shortDescription.ar,
    );

    // 2. Persist
    await cubit.save(publishStatus: 'published');

    // 3. Navigate AFTER the dialog closes itself (dialog pops in finally block)
    //    Use addPostFrameCallback so the navigator stack is stable
    if (mounted) {
      // Defer navigation OUT of the frame (fixes mouse_tracker
          // !_debugDuringDeviceUpdate assertion on Flutter web debug).
          Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ServicesMainPageMaster(),
            ),
                (route) => false,
          );
        }
      });
    }
  }

  // ── Triggered by Save button ───────────────────────────────────────────────
  void _onSave() {
    showPublishConfirmDialog(
      context: context,
      title: 'EDITING SERVICE DETAILS',
      subtitle: 'Do you want to save the changes made to this Service Details?',
      confirmLabel: 'Confirm',
      backLabel: 'Back',
      onConfirm: _save, // async — dialog shows loader while saving
    );
  }

  void _onBack() => Navigator.pop(context);

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPick.white,
      body: BlocListener<ServiceCmsCubit, ServiceCmsState>(
        listener: (context, state) {
          // Error feedback (save can fail inside the dialog too)
          if (state is ServiceCmsError) {
            showConfirmDialog(
              context: context,
              title: 'Error',
              subtitle: state.message,
              confirmLabel: 'OK',
              cancelLabel: '',
              onConfirm: () {},
              iconWidget: Container(
                width: 60.r,
                height: 60.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: _containerWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAdminNavbar(
                    activeLabel:    'Web Page',
                    homePage:       MainMainPage(),
                    webPage:        MainMainPage(),
                    jobListingPage: MainMainPage(),
                  ),
                  SizedBox(height: 20.h),

                  AppNavbar(currentRoute: '/services'),
                  SizedBox(height: 8.h),

                  Text(
                    'Preview Services Details',
                    style: StyleText.fontSize45Weight600.copyWith(
                      color: ColorPick.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: _getResponsiveTitleSize(),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _buildTopControls(),
                  SizedBox(height: 12.h),

                  _viewAccordion(),
                  SizedBox(height: 24.h),

                  _buildActionButtons(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  double _getResponsiveTitleSize() {
    final w = MediaQuery.of(context).size.width;
    if (w < 600)  return 28.sp;
    if (w < 1024) return 36.sp;
    return 45.sp;
  }

  Widget _buildTopControls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final langToggle = CustomSegmentedTabs(
      tabs: ['ENG', 'AR'],
      selectedIndex: _isAr ? 1 : 0,
      onTabSelected: (i) => setState(() => _isAr = i == 1),
      selectedColor:       ColorPick.primary,
      unselectedColor:     Colors.transparent,
      selectedTextColor:   Colors.white,
      unselectedTextColor: AppColors.text,
      containerColor:      ColorPick.white.withValues(alpha: 0.45),
      equalWidth: false,
      containerPadding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceTabBar(),
          SizedBox(height: 12.h),
          langToggle,
        ],
      );
    }

    return Row(
      children: [
        _buildDeviceTabBar(),
        const Spacer(),
        langToggle,
      ],
    );
  }

  Widget _buildActionButtons() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPick.back,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Back',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 12.w : 300.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPick.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Save',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTabBar() {
    final tabs = [_Device.desktop, _Device.tablet, _Device.mobile];
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth < 600 ? 16.w : 24.w;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tabs.length, (i) {
        final d        = tabs[i];
        final isActive = _device == d;
        final label    = d.name[0].toUpperCase() + d.name.substring(1);
        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: GestureDetector(
            onTap: () => setState(() => _device = d),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize:   screenWidth < 600 ? 13.sp : 15.sp,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color:      isActive ? ColorPick.primary : AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: isActive ? ColorPick.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _viewAccordion() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _viewOpen = !_viewOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                  child: Text('View',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white)),
                ),
                Icon(
                  _viewOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ]),
            ),
          ),
          if (_viewOpen)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.w),
              child: Center(child: _previewContent()),
            ),
        ],
      ),
    );
  }

  Widget _previewContent() {
    final double maxW = switch (_device) {
      _Device.desktop => double.infinity,
      _Device.tablet  => 600.w,
      _Device.mobile  => 320.w,
    };

    final String title = _isAr
        ? (widget.model.title.ar.isNotEmpty
        ? widget.model.title.ar
        : 'الخدمات')
        : (widget.model.title.en.isNotEmpty
        ? widget.model.title.en
        : 'Services');

    final String desc = _isAr
        ? (widget.model.shortDescription.ar.isNotEmpty
        ? widget.model.shortDescription.ar
        : 'تقدم بياناتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي.')
        : (widget.model.shortDescription.en.isNotEmpty
        ? widget.model.shortDescription.en
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: StyleText.fontSize45Weight600.copyWith(
                color:    ColorPick.primary,
                fontSize: _device == _Device.mobile ? 22.sp : 28.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              desc,
              style: StyleText.fontSize14Weight400.copyWith(
                color:    AppColors.secondaryText,
                fontSize: _device == _Device.mobile ? 12.sp : 14.sp,
                height:   1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}