// ═══════════════════════════════════════════════════════════════════
// FILE 7: about_company_edit_page.dart  (Edit Page) — UPDATED
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/about_company/AboutCompanyCubit.dart';
import 'package:web_app_admin/controller/about_company/about_company_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_company_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';

import '../../careers_main_dashboard.dart';
import '../job_list/job_listing_main_page.dart';
import 'about_company_main_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

class AboutCompanyEditPage extends StatefulWidget {
  const AboutCompanyEditPage({super.key});

  @override
  State<AboutCompanyEditPage> createState() => _AboutCompanyEditPageState();
}

class _AboutCompanyEditPageState extends State<AboutCompanyEditPage> {
  final Map<String, bool> _open = {
    'company_info': true,
  };

  final TextEditingController _aboutEnController = TextEditingController();
  final TextEditingController _aboutArController = TextEditingController();

  bool _submitted = false;
  bool _isSaving  = false;
  bool _didLoad   = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final cubit = context.read<AboutCompanyCubit>();
    final cached = cubit.cachedData;
    if (cached != null) {
      _aboutEnController.text = cached.aboutEn;
      _aboutArController.text = cached.aboutAr;
    }
  }

  @override
  void dispose() {
    _aboutEnController.dispose();
    _aboutArController.dispose();
    super.dispose();
  }

  void _onDiscard() {
    Navigator.pop(context);
  }

  Future<void> _onSave() async {
    setState(() => _submitted = true);

    if (_aboutEnController.text.trim().isEmpty ||
        _aboutArController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<AboutCompanyCubit>().saveAboutCompany(
        aboutEn: _aboutEnController.text.trim(),
        aboutAr: _aboutArController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AppAdminNavbar(
                    activeLabel:    'Home',
                    homePage:       CareersMainPageDashboard(),
                    webPage:        const AboutCompanyEditPage(),
                    jobListingPage: JobListingMainPage(),
                  ),

                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 20.h),
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ──────────────────────────────────
                          Text(
                            'Editing About Company',
                            style:
                            StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Company Information Accordion ──────────
                          _accordion(
                            key: 'company_info',
                            title: 'Company Information',
                            children: [_editableCompanyInfoSection()],
                          ),

                          SizedBox(height: 24.h),

                          // ── Discard / Save ─────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _onDiscard,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF797979),
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Discard',
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isSaving ? null : _onSave,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: _C.primary,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isSaving
                                        ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child:
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Text(
                                      'Save',
                                      style: StyleText
                                          .fontSize14Weight600
                                          .copyWith(
                                          color:
                                          Colors.white),
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
                ],
              ),
            ),
          ),

          // ── Saving overlay ──
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child:
                CircularProgressIndicator(color: _C.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  // ── Editable Company Info ──────────────────────────────────────────────────
  Widget _editableCompanyInfoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(6.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // ── English ──
          CustomValidatedTextFieldMaster(
            label: 'About This Position',
            hint: 'Text Here',
            controller: _aboutEnController,
            height: 80,
            maxLines: 4,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            showCharCount: true,
            maxLength: 800,
            minLength: 0,
            submitted: _submitted,
            primaryColor: _C.primary,
            fillColor: _C.cardBg,
            textStyle: StyleText.fontSize12Weight400
                .copyWith(color: _C.labelText),
            hintStyle: StyleText.fontSize12Weight400
                .copyWith(color: _C.hintText),
          ),

          SizedBox(height: 16.h),

          // ── Arabic ──
          CustomValidatedTextFieldMaster(
            label: 'عن هذا المنصب',
            hint: 'ادخل النص هنا',
            controller: _aboutArController,
            height: 80,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.start,
            showCharCount: true,
            maxLength: 800,
            minLength: 0,
            submitted: _submitted,
            primaryColor: _C.primary,
            fillColor: _C.cardBg,
            textStyle: StyleText.fontSize12Weight400
                .copyWith(color: _C.labelText),
            hintStyle: StyleText.fontSize12Weight400
                .copyWith(color: _C.hintText),
          ),
        ],
      ),
    );
  }
}