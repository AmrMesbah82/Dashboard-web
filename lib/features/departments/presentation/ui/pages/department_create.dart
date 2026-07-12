// ═══════════════════════════════════════════════════════════════════
// FILE 7: department_create.dart (Create Page)
// Path: lib/features/departments/presentation/ui/pages/department_create.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom/image_upload_circle.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../controller/department_cubit.dart';
import '../../controller/department_state.dart';



// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color border    = Color(0xFFE0E0E0);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
// }

class DepartmentCreatePage extends StatefulWidget {
  const DepartmentCreatePage({super.key});

  @override
  State<DepartmentCreatePage> createState() => _DepartmentCreatePageState();
}

class _DepartmentCreatePageState extends State<DepartmentCreatePage> {
  final Map<String, bool> _open = {'dept_info': true};

  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();

  bool _submitted = false;
  bool _isSaving  = false;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  void _onDiscard() {
    Navigator.pop(context);
  }

  void _onCreate() {
    setState(() => _submitted = true);

    if (_nameEnController.text.trim().isEmpty ||
        _nameArController.text.trim().isEmpty) {
      return;
    }

    _showConfirmDialog(
      title: 'NEW DEPARTMENT',
      message:
      'You are about to publish a new Department. Please ensure all details are accurate before confirming.',
      confirmLabel: 'Submit',
      imagePath: 'assets/images/dashboard_image.svg',
      onConfirm: () async {
        Navigator.of(context).pop(); // close dialog
        setState(() => _isSaving = true);

        await context.read<DepartmentCubit>().createDepartment(
          nameEn: _nameEnController.text.trim(),
          nameAr: _nameArController.text.trim(),
        );

        // DepartmentMainPage's BlocListener handles pop + reload
      },
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required String imagePath,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: 450.w,
          padding: EdgeInsets.all(30.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/department_icon.svg",
                  height: 120.h, fit: BoxFit.contain),
              SizedBox(height: 20.h),
              Text(
                title,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.secondaryText, height: 1.5),
              ),
              SizedBox(height: 24.h),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF797979),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          'Back',
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: Colors.white
                          )
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: ColorPick.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DepartmentCubit, DepartmentState>(
      listener: (context, state) {
        if (state is DepartmentError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is DepartmentCreated) {
          setState(() => _isSaving = false);
          // Pop handled by DepartmentMainPage BlocListener
        }
      },
      child: Scaffold(
        backgroundColor: ColorPick.background,
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
                      webPage:        MainMainPage(),
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
                            // ── Title ──
                            Text(
                              'Create New Department',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: ColorPick.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Accordion ──
                            _accordion(
                              key: 'dept_info',
                              title: 'Department Information',
                              children: [_editableSection()],
                            ),

                            SizedBox(height: 10.h),

                            // ── Discard / Create ──
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
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSaving ? null : _onCreate,
                                    child: Container(
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        color: ColorPick.primary,
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
                                        'Create',
                                        style: StyleText
                                            .fontSize14Weight600
                                            .copyWith(
                                            color: Colors.white),
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

            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: ColorPick.primary),
                ),
              ),
          ],
        ),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
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

  // ── Editable Section ──────────────────────────────────────────────────────
  Widget _editableSection() {
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

          // ── Icon placeholder (shared image-upload circle) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              imageUploadCircleBare(bytes: null, url: '', onTap: () {}),
            ],
          ),
          SizedBox(height: 20.h),


          // ── Department Name EN ──
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Department Name',
                  hint: 'Text Here',
                  controller: _nameEnController,
                  height: 36,
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  showCharCount: false,
                  maxLength: 200,
                  minLength: 0,
                  submitted: _submitted,
                  primaryColor: ColorPick.primary,
                  fillColor: ColorPick.white,
                  textStyle: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  hintStyle: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ),

              SizedBox(width: 15.h),

              // ── Department Name AR ──
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'اسم القسم',
                    hint: 'ادخل النص هنا',
                    controller: _nameArController,
                    height: 36,
                    maxLines: 1,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    showCharCount: false,
                    maxLength: 200,
                    minLength: 0,
                    submitted: _submitted,
                    primaryColor: ColorPick.primary,
                    fillColor: ColorPick.white,
                    textStyle: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
                    hintStyle: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}