// ******************* FILE INFO *******************
// File Name: services_main_edit_page.dart
// Screen 2 — Services CMS: Edit "Headings" (title + description, AR + EN)
// Navigates to: ServicesMainPreviewPage (screen 3)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_preview_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF1A1A1A);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color back = Color(0xFFF1F2ED);
}

class ServicesMainEditPage extends StatefulWidget {
  final ServicePageModel model;
  const ServicesMainEditPage({super.key, required this.model});

  @override
  State<ServicesMainEditPage> createState() => _ServicesMainEditPageState();
}

class _ServicesMainEditPageState extends State<ServicesMainEditPage> {
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleArCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descArCtrl;

  bool _headingsOpen = true;
  bool _submitted    = false;

  @override
  void initState() {
    super.initState();
    _titleEnCtrl = TextEditingController(text: widget.model.title.en);
    _titleArCtrl = TextEditingController(text: widget.model.title.ar);
    _descEnCtrl  = TextEditingController(text: widget.model.shortDescription.en);
    _descArCtrl  = TextEditingController(text: widget.model.shortDescription.ar);
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    super.dispose();
  }

  ServicePageModel get _edited => widget.model.copyWith(
    title:            BilingualText(en: _titleEnCtrl.text, ar: _titleArCtrl.text),
    shortDescription: BilingualText(en: _descEnCtrl.text, ar: _descArCtrl.text),
  );

  void _onPreview() {
    setState(() => _submitted = true);
    if (_titleEnCtrl.text.trim().isEmpty || _titleArCtrl.text.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceCmsCubit>(),
          child: ServicesMainPreviewPage(model: _edited),
        ),
      ),
    );
  }

  void _onSave() {
    setState(() => _submitted = true);
    if (_titleEnCtrl.text.trim().isEmpty || _titleArCtrl.text.trim().isEmpty) return;
    context.read<ServiceCmsCubit>().updateTitle(
        en: _titleEnCtrl.text, ar: _titleArCtrl.text);
    context.read<ServiceCmsCubit>().updateShortDescription(
        en: _descEnCtrl.text, ar: _descArCtrl.text);
    context.read<ServiceCmsCubit>().save(publishStatus: 'published');
    Navigator.pop(context);
  }

  void _onDiscard() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<ServiceCmsCubit, ServiceCmsState>(
        listener: (context, state) {
          if (state is ServiceCmsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved successfully')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                AdminSubNavBar(activeIndex: 2),
                SizedBox(height: 20.h),
                Container(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),

                      // ── Large green title ──────────────────────────────
                      Text(
                        'Editing Services Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Headings accordion ─────────────────────────────
                      _headingsAccordion(),
                      SizedBox(height: 24.h),

                      // ── Action buttons ─────────────────────────────────
                      _actionButtons(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _headingsAccordion() {
    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _headingsOpen = !_headingsOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _headingsOpen
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(child: Text('Headings',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
                Icon(
                  _headingsOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp,
                ),
              ]),
            ),
          ),
          if (_headingsOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // ── Title: EN + AR side by side ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Title',    style: _labelStyle()),
                    Text('العنوان', style: _labelStyle()),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(children: [
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      controller:    _titleEnCtrl,
                      hint:          'Text Here',
                      submitted:     _submitted,
                      primaryColor:  _C.primary,

                      textDirection: TextDirection.ltr,
                      height:        36,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      controller:    _titleArCtrl,
                      hint:          'أدخل النص هنا',
                      submitted:     _submitted,
                      primaryColor:  _C.primary,

                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      height:        36,
                    ),
                  ),
                ]),


                // ── Description EN full width ────────────────────────
                Text('Description', style: _labelStyle()),
                SizedBox(height: 6.h),
                CustomValidatedTextFieldMaster(
                  controller:    _descEnCtrl,
                  hint:          'Text Here',
                  submitted:     false, // not required
                  primaryColor:  _C.primary,

                  textDirection: TextDirection.ltr,
                  maxLines:      4,
                  height:        100,
                  maxLength:     900,
                ),

                // ── Description AR full width RTL ────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('وصف', style: _labelStyle()),
                ),
                SizedBox(height: 6.h),
                CustomValidatedTextFieldMaster(
                  controller:    _descArCtrl,
                  hint:          'أدخل النص هنا',
                  submitted:     false, // not required
                  primaryColor:  _C.primary,

                  textDirection: TextDirection.rtl,
                  textAlign:     TextAlign.right,
                  maxLines:      4,
                  height:        100,
                  maxLength:     900,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(
      children: [
        // Preview — half width left
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _onPreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(child: const SizedBox()),
        ]),
        SizedBox(height: 10.h),

        // Discard | Save
        Row(children: [
          Expanded(
            child: customButton(
              title: 'Discard',
              function: _onDiscard,
              height: 44.h,
              color: Color(0xFF797979),
              textColor: Colors.white,
              textStyle: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              radius: 8.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Save',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: _C.labelText);
}