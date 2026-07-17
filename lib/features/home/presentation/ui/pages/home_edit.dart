/// ******************* FILE INFO *******************
/// File Name: home_edit_page_master.dart
/// FIXED: _navRoutes undefined → use _navBtns[i].route directly
/// FIXED: link.icon / link.text → access _links[i] via map keys
/// FIXED: dart:html deprecated → replaced with package:web + dart:js_interop
/// UPDATED: Validation gate — Publish dimmed + blocked until all required fields filled
/// UPDATED: showPublishConfirmDialog only — navigation via BlocConsumer (HomeCmsSaved)
/// UPDATED: Navigate to HomeMainPageMaster (pushAndRemoveUntil) after HomeCmsSaved
/// ADDED: Navigation Button accordion UI (add/remove/edit name EN+AR/route dropdown/status toggle)
///
///  ✅ DUAL-DOCUMENT ARCHITECTURE:
///     - "Publish" (no schedule date)  → saves to published doc, deletes draft
///     - "Publish" (with future date)  → saves to draft doc with status='scheduled'
///     - "Save For Later"              → saves to draft doc ONLY (published untouched)
///     - "Discard" (editing draft)     → deletes the draft doc
///     - Schedule mode                 → saves to draft doc with status='scheduled'
/// Last Update: 20/04/2026
/// UPDATED: Dual-document draft system ✅

import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:ui' as ui;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/network_image_view.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/widget/branding_helper.dart';
import '../../../../../core/custom/image_upload_circle.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/custom_dropdwon.dart';
import '../../../../../core/widget/custom_dropdown_new.dart';
import '../../../../../core/widget/custom_field.dart';
import '../../../../../core/widget/date_pic.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/home_model.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import 'home_main.dart';
import 'home_preview.dart';

part '../widgets/home_edit/picked_image.dart';
part '../widgets/home_edit/nav_btn_item.dart';
part '../widgets/home_edit/section_item.dart';
part '../widgets/home_edit/color_picker_field.dart';
part '../widgets/home_edit/color_wheel_overlay.dart';
part '../widgets/home_edit/home_edit_helpers.dart';
part '../widgets/home_edit/home_edit_builders.dart';
part '../widgets/home_edit/home_edit_actions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

// class _C {
//   static const Color primary = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color border = Color(0xFFE0E0E0);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText = Color(0xFFAAAAAA);
//   static const Color back = Color(0xFFF1F2ED);
//   static const Color scheduled = Color(0xFFFF8F00);
//   static const Color error = Color(0xFFE53935);
//   static const Color draftBadge = Color(0xFFF59E0B);
// }

const List<String> _kSectionTitles = [
  'Section 1 - Left',
  'Section 2 - Left Corner',
  'Section 3 - Right',
  'Section 4 - Right Corner',
];

const List<Map<String, String>> _kNavRouteOptions = [
  {'label': 'Services', 'route': '/services'},
  {'label': 'About Us', 'route': '/about'},
  {'label': 'Contact Us', 'route': '/contact'},
  {'label': 'Careers', 'route': '/careers'},
  {'label': 'Our Strategy', 'route': '/about?tab=our-strategy'},
  {'label': 'Terms & Conditions', 'route': '/about?tab=terms-and-conditions'},
  {'label': 'Privacy Policy', 'route': '/about?tab=privacy-policy'},
  {'label': 'Vision', 'route': '/about?tab=vision'},
  {'label': 'Mission', 'route': '/about?tab=mission'},
  {'label': 'Values', 'route': '/about?tab=values'},
  {'label': 'Why Join Our Team', 'route': '/careers?tab=why-join-our-team'},
  {'label': 'Our Interns', 'route': '/careers?tab=interns'},
  {'label': 'Our Team', 'route': '/careers?tab=our-team'},

];

// ── Fixed "Navigate To" destinations — mirrors main_edit's _kLabelDestinations
//    so the home nav-button dropdown offers the same choices as the Main page.
const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  {'key': '/careers?tab=why-join-our-team',      'value': 'Why Join Our Team'},
  {'key': '/careers?tab=interns',                'value': 'Our Interns'},
  {'key': '/careers?tab=our-team',               'value': 'Our Team'},
  {'key': '/contact',                            'value': 'Contact Form'},
];

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class HomeEditPageMaster extends StatefulWidget {
  const HomeEditPageMaster({super.key});
  @override
  State<HomeEditPageMaster> createState() => _HomeEditPageMasterState();
}

class _HomeEditPageMasterState extends State<HomeEditPageMaster> {
  bool _submitted = false;
  bool _isSaving = false;

  /// Whether the data currently loaded came from a draft document.
  bool _isEditingDraft = false;

  final _titleEn = TextEditingController();
  final _titleAr = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();
  final List<_NavBtnItem> _navBtns = [];
  final List<_SectionItem> _sections = List.generate(4, (_) => _SectionItem());
  // NOTE: footer columns, social links and branding/logo are edited on the
  // MAIN page (MainCmsCubit) — they no longer belong to the Home CMS.
  final _copyRightEn = TextEditingController(
    text: 'COPYRIGHT © 2025 BAYANATZ. ALL-RIGHT RESERVED',
  );
  final _copyRightAr = TextEditingController();
  DateTime? _publishDate;

  final Map<String, bool> _open = {
    'headings': true,
    'navButtons': true,
    's0': true,
    's1': true,
    's2': true,
    's3': true,
    'links': true,
    'schedule': true,
  };

  int? _seededModelHash;

  Color get _resolvedPrimary => context.primaryBrandColor;

  bool get _isFormValid {
    if (_titleEn.text.trim().isEmpty || _titleAr.text.trim().isEmpty)
      return false;
    if (_shortDescEn.text.trim().isEmpty || _shortDescAr.text.trim().isEmpty)
      return false;
    // NOTE: No language validation - every field accepts Arabic AND English.
    for (final sec in _sections) {
      if (sec.descEn.text.trim().isEmpty || sec.descAr.text.trim().isEmpty)
        return false;
      if (sec.image.isEmpty || sec.icon.isEmpty) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    for (final ctrl in [_titleEn, _titleAr, _shortDescEn, _shortDescAr])
      ctrl.addListener(_onFieldChanged);
    for (final sec in _sections) {
      sec.descEn.addListener(_onFieldChanged);
      sec.descAr.addListener(_onFieldChanged);
    }
  }
  @override
  void dispose() {
    for (final ctrl in [_titleEn, _titleAr, _shortDescEn, _shortDescAr]) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final nb in _navBtns) nb.dispose();
    for (final s in _sections) {
      s.descEn.removeListener(_onFieldChanged);
      s.descAr.removeListener(_onFieldChanged);
      s.dispose();
    }
    _copyRightEn.dispose();
    _copyRightAr.dispose();
    super.dispose();
  }
  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {

        // ── Published successfully ──────────────────────────────────────
        if (state is HomeCmsSaved) {
          // Defer navigation OUT of the frame (fixes mouse_tracker
          // !_debugDuringDeviceUpdate assertion on Flutter web debug).
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        // ── Draft saved successfully ────────────────────────────────────
        if (state is HomeCmsDraftSaved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.data.publishStatus == 'scheduled'
                      ? 'Scheduled draft saved! Published version is still live.'
                      : 'Draft saved! Published version is still live.',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: ColorPick.discard,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          // Defer navigation OUT of the frame (fixes mouse_tracker
          // !_debugDuringDeviceUpdate assertion on Flutter web debug).
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        // ── Draft deleted (discard) ─────────────────────────────────────
        if (state is HomeCmsDraftDeleted) {
          // Defer navigation OUT of the frame (fixes mouse_tracker
          // !_debugDuringDeviceUpdate assertion on Flutter web debug).
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                (route) => false,
              );
            }
          });
        }

        if (state is HomeCmsError) {
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
      builder: (context, state) {
        if (state is HomeCmsLoaded)
          _seedFromModel(state.data, isFromDraft: state.isFromDraft);
        if (state is HomeCmsSaved) _seedFromModel(state.data);

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.white,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel: 'Web Page',
                    homePage: CareersMainPageDashboard(),
                    webPage: MainMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 1),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        // ── Title row with draft badge ─────────────────────
                        Row(
                          children: [
                            Text(
                              'Editing Home',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: ColorPick.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_isEditingDraft) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPick.scheduled,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'EDITING DRAFT',
                                  style: StyleText.fontSize12Weight600.copyWith(
                                    color: ColorPick.discard,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_isEditingDraft)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'You are editing a saved draft. The published version is still live.',
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),

                        _accordion(
                          key: 'headings',
                          title: 'Headings',
                          children: [
                            _headingsSection(),
                          ],
                        ),
                        _accordion(
                          key: 'navButtons',
                          title: 'Navigation Button',
                          children: [
                            _navButtonsSection(),
                          ],
                        ),
                        ...List.generate(
                          4,
                          (i) => Column(
                            children: [
                              _accordion(
                                key: 's$i',
                                title: _kSectionTitles[i],
                                children: [_sectionEdit(i)],
                              ),
                            ],
                          ),
                        ),
                        _accordion(
                          key: 'schedule',
                          title: 'Publish Schedule',
                          children: [_publishScheduleSection()],
                        ),
                        _bottomButtons(cubit),
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
