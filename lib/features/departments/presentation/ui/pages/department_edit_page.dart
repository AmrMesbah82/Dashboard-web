// ═══════════════════════════════════════════════════════════════════
// department_edit_page.dart  (Edit Page)
// Path: lib/pages/dashboard/department/department_edit_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main_dashboard.dart';
import '../../../../job/presentation/ui/pages/job_listing_main_page.dart';
import '../../../../main/presentation/ui/pages/home_main_page.dart';
import '../../../data/model/department_model.dart';
import '../../controller/department_cubit.dart';
import '../../controller/department_state.dart';


class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color grey      = Color(0xFF797979);
  static const Color red       = Color(0xFFD32F2F);
}

class DepartmentEditPage extends StatefulWidget {
  final DepartmentModel department;

  const DepartmentEditPage({super.key, required this.department});

  @override
  State<DepartmentEditPage> createState() => _DepartmentEditPageState();
}

class _DepartmentEditPageState extends State<DepartmentEditPage> {
  final Map<String, bool> _open = {'dept_info': true};

  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;

  bool _submitted = false;
  bool _isSaving  = false;

  @override
  void initState() {
    super.initState();
    _nameEnController =
        TextEditingController(text: widget.department.nameEn);
    _nameArController =
        TextEditingController(text: widget.department.nameAr);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  // ── Discard ───────────────────────────────────────────────────────────────
  void _onDiscard() => Navigator.pop(context);

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() {
    setState(() => _submitted = true);

    if (_nameEnController.text.trim().isEmpty ||
        _nameArController.text.trim().isEmpty) return;

    _showConfirmDialog(
      title:        'EDITING DEPARTMENT DETAILS',
      message:      'Do you want to save the changes made to this Department information?',
      confirmLabel: 'Confirm',
      confirmColor: _C.primary,
      onConfirm: () async {
        Navigator.of(context).pop(); // close dialog
        setState(() => _isSaving = true);

        await context.read<DepartmentCubit>().updateDepartment(
          id:     widget.department.id,
          nameEn: _nameEnController.text.trim(),
          nameAr: _nameArController.text.trim(),
        );
      },
    );
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  void _onRemove() {
    _showConfirmDialog(
      title:        'DELETE DEPARTMENT',
      message:
      'Are you sure you want to permanently delete this Department? This action cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: _C.red,
      onConfirm: () async {
        Navigator.of(context).pop(); // close dialog
        setState(() => _isSaving = true);

        await context
            .read<DepartmentCubit>()
            .deleteDepartment(id: widget.department.id);
      },
    );
  }

  // ── Dialog ────────────────────────────────────────────────────────────────
  void _showConfirmDialog({
    required String        title,
    required String        message,
    required String        confirmLabel,
    required Color         confirmColor,
    required VoidCallback  onConfirm,
  }) {
    showDialog(
      context:           context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width:   450.w,
          padding: EdgeInsets.all(30.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/department_icon.svg',
                height: 120.h,
                fit:    BoxFit.contain,
              ),
              SizedBox(height: 20.h),

              Text(
                title,
                style: TextStyle(
                    fontSize:   18.sp,
                    fontWeight: FontWeight.w700,
                    color:      _C.labelText),
              ),
              SizedBox(height: 12.h),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp, color: _C.hintText, height: 1.5),
              ),
              SizedBox(height: 24.h),

              Row(children: [
                // Back
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:        _C.grey,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('Back',
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Confirm / Delete
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:        confirmColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(confirmLabel,
                          style: TextStyle(
                              fontSize:   14.sp,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white)),
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is DepartmentUpdated || state is DepartmentDeleted) {
          setState(() => _isSaving = false);
          // pop twice: edit page → detail page → main page
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
          context.read<DepartmentCubit>().loadDepartments();
        }
      },
      child: Scaffold(
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
                      webPage:        HomeMainPage(),
                      jobListingPage: JobListingMainPage(),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Title ──
                            Text(
                              'Editing Department Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color:      _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: _onRemove,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color:        _C.red,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text('Remove',
                                        style: TextStyle(
                                            fontSize:   12.sp,
                                            fontWeight: FontWeight.w600,
                                            color:      Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),

                            // ── Accordion ──
                            _accordion(
                              key:      'dept_info',
                              title:    'Department Information',
                              children: [_editableSection()],
                            ),

                            SizedBox(height: 10.h),

                            // ── Discard / Save ──
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _onDiscard,
                                    child: Container(
                                      height:    48.h,
                                      decoration: BoxDecoration(
                                        color:        _C.grey,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Discard',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSaving ? null : _onSave,
                                    child: Container(
                                      height:    48.h,
                                      decoration: BoxDecoration(
                                        color:        _C.primary,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: _isSaving
                                          ? SizedBox(
                                        width:  20.w,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                            color:       Colors.white,
                                            strokeWidth: 2),
                                      )
                                          : Text('Save',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(color: Colors.white)),
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

            // ── Loading overlay ──
            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       key,
    required String       title,
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
              width:   double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft:  Radius.circular(6.r),
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
                  // ── Remove button ──────────────────────────────────────

                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20.sp,
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

  // ── Editable Section ───────────────────────────────────────────────────────
  Widget _editableSection() {
    return Container(
      width:   double.infinity,

      decoration: BoxDecoration(

        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(6.r),
          bottomRight: Radius.circular(6.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 20.h),
          // ── Icon placeholder ──
          Container(
            width:  70.w,
            height: 70.h,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: CustomSvg(
                    assetPath: 'assets/control/image.svg',
                    width:  35.w,
                    height: 35.h,
                    fit:    BoxFit.scaleDown,
                    color:  Colors.black,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right:  0,
                  child: Container(
                    width:  20.sp,
                    height: 20.sp,
                    decoration: const BoxDecoration(
                        color: _C.primary, shape: BoxShape.circle),
                    child: Center(
                      child: CustomSvg(
                        assetPath: 'assets/control/camera.svg',
                        width:  10.sp,
                        height: 10.sp,
                        fit:    BoxFit.scaleDown,
                        color:  Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── Name EN / AR ──
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label:          'Department Name',
                  hint:           'Text Here',
                  controller:     _nameEnController,
                  height:         36,
                  maxLines:       1,
                  textDirection:  TextDirection.ltr,
                  textAlign:      TextAlign.start,
                  showCharCount:  false,
                  maxLength:      200,
                  minLength:      0,
                  submitted:      _submitted,
                  primaryColor:   _C.primary,
                  fillColor:      _C.cardBg,
                  textStyle: StyleText.fontSize12Weight400
                      .copyWith(color: _C.labelText),
                  hintStyle: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label:         'اسم القسم',
                    hint:          'ادخل النص هنا',
                    controller:    _nameArController,
                    height:        36,
                    maxLines:      1,
                    textDirection: TextDirection.rtl,
                    textAlign:     TextAlign.start,
                    showCharCount: false,
                    maxLength:     200,
                    minLength:     0,
                    submitted:     _submitted,
                    primaryColor:  _C.primary,
                    fillColor:     _C.cardBg,
                    textStyle: StyleText.fontSize12Weight400
                        .copyWith(color: _C.labelText),
                    hintStyle: StyleText.fontSize12Weight400
                        .copyWith(color: _C.hintText),
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