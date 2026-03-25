// ******************* FILE INFO *******************
// File Name: about_preview_page.dart
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);
const Color _kDivider    = Color(0xFFDDE8DD);

class AboutPreviewPage extends StatelessWidget {
  const AboutPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        if (state is AboutInitial || state is AboutLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _kGreenSolid)),
          );
        }

        final AboutPageModel model = switch (state) {
          AboutLoaded s => s.data,
          AboutSaved  s => s.data,
          _             => AboutPageModel.empty(),
        };

        return Scaffold(
          backgroundColor: _kBg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppNavbar(currentRoute: '/about-us'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page title + Edit button ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('About Us',
                              style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                                  fontSize: 36.sp, color: _kGreen,
                                  fontWeight: FontWeight.w700)),
                          GestureDetector(
                            onTap: () => context.goNamed('about-edit'),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                  color: _kSurface,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Row(
                                children: [
                                  Text('Edit Details',
                                      style: TextStyle(fontFamily: 'Cairo',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87)),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.edit_outlined,
                                      size: 16.sp, color: _kGreenSolid),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // ── Headings accordion ──
                      _PreviewAccordion(
                        title: 'Headings',
                        child: _HeadingsPreview(model: model),
                      ),
                      SizedBox(height: 16.h),

                      // ── Vision accordion ──
                      _PreviewAccordion(
                        title: 'Vision',
                        child: _SectionPreview(section: model.vision),
                      ),
                      SizedBox(height: 16.h),

                      // ── Mission accordion ──
                      _PreviewAccordion(
                        title: 'Mission',
                        child: _SectionPreview(section: model.mission),
                      ),
                      SizedBox(height: 16.h),

                      // ── Values accordion ──
                      _PreviewAccordion(
                        title: 'Values',
                        child: model.values.isEmpty
                            ? Text('No values added yet.',
                            style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 13.sp, color: Colors.grey))
                            : Column(
                          children: model.values
                              .map((v) => _ValuePreviewCard(value: v))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Headings Preview ──────────────────────────────────────────────────────────

class _HeadingsPreview extends StatefulWidget {
  final AboutPageModel model;
  const _HeadingsPreview({required this.model});

  @override
  State<_HeadingsPreview> createState() => _HeadingsPreviewState();
}

class _HeadingsPreviewState extends State<_HeadingsPreview> {
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleArCtrl;

  @override
  void initState() {
    super.initState();
    _titleEnCtrl = TextEditingController(text: widget.model.title.en);
    _titleArCtrl = TextEditingController(text: widget.model.title.ar);
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Title EN + AR side-by-side (as in Figma)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Title'),
              SizedBox(height: 6.h),
              CustomValidatedTextFieldMaster(
                hint: 'Text Here',
                controller: _titleEnCtrl,
                enabled: false,
                height: 44,
                textDirection: TextDirection.ltr,
                submitted: false,
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _FieldLabel('العنوان', rtl: true),
              SizedBox(height: 6.h),
              CustomValidatedTextFieldMaster(
                hint: 'أدخل النص هنا',
                controller: _titleArCtrl,
                enabled: false,
                height: 44,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                submitted: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section Preview (Vision / Mission) ───────────────────────────────────────

class _SectionPreview extends StatefulWidget {
  final AboutSection section;
  const _SectionPreview({required this.section});

  @override
  State<_SectionPreview> createState() => _SectionPreviewState();
}

class _SectionPreviewState extends State<_SectionPreview> {
  late final TextEditingController _subDescEnCtrl;
  late final TextEditingController _subDescArCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descArCtrl;

  @override
  void initState() {
    super.initState();
    _subDescEnCtrl = TextEditingController(text: widget.section.subDescription.en);
    _subDescArCtrl = TextEditingController(text: widget.section.subDescription.ar);
    _descEnCtrl    = TextEditingController(text: widget.section.description.en);
    _descArCtrl    = TextEditingController(text: widget.section.description.ar);
  }

  @override
  void dispose() {
    _subDescEnCtrl.dispose();
    _subDescArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon & SVG circles
        Row(
          children: [
            _IconCircle(url: widget.section.iconUrl, label: 'Icon'),
            SizedBox(width: 24.w),
            _IconCircle(url: widget.section.svgUrl, label: 'SVG'),
          ],
        ),
        SizedBox(height: 16.h),

        // Sub description EN — multiline 0/150
        _FieldLabel('Sub description'),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: _subDescEnCtrl,
          enabled: false,
          height: 80,
          maxLines: 4,
          maxLength: 150,
          showCharCount: true,
          textDirection: TextDirection.ltr,
          submitted: false,
        ),
        SizedBox(height: 10.h),

        // Sub description AR — multiline 0/150
        Align(
          alignment: Alignment.centerRight,
          child: _FieldLabel('وصف فرعي', rtl: true),
        ),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: _subDescArCtrl,
          enabled: false,
          height: 80,
          maxLines: 4,
          maxLength: 150,
          showCharCount: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          submitted: false,
        ),
        SizedBox(height: 10.h),

        // Description EN — multiline 0/500
        _FieldLabel('Description'),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: _descEnCtrl,
          enabled: false,
          height: 120,
          maxLines: 6,
          maxLength: 500,
          showCharCount: true,
          textDirection: TextDirection.ltr,
          submitted: false,
        ),
        SizedBox(height: 10.h),

        // Description AR — multiline 0/500
        Align(
          alignment: Alignment.centerRight,
          child: _FieldLabel('الوصف', rtl: true),
        ),
        SizedBox(height: 6.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: _descArCtrl,
          enabled: false,
          height: 120,
          maxLines: 6,
          maxLength: 500,
          showCharCount: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          submitted: false,
        ),
      ],
    );
  }
}

// ── Value Preview Card ────────────────────────────────────────────────────────

class _ValuePreviewCard extends StatefulWidget {
  final AboutValueItem value;
  const _ValuePreviewCard({required this.value});

  @override
  State<_ValuePreviewCard> createState() => _ValuePreviewCardState();
}

class _ValuePreviewCardState extends State<_ValuePreviewCard> {
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleArCtrl;
  late final TextEditingController _shortDescEnCtrl;
  late final TextEditingController _shortDescArCtrl;

  @override
  void initState() {
    super.initState();
    _titleEnCtrl     = TextEditingController(text: widget.value.title.en);
    _titleArCtrl     = TextEditingController(text: widget.value.title.ar);
    _shortDescEnCtrl = TextEditingController(text: widget.value.shortDescription.en);
    _shortDescArCtrl = TextEditingController(text: widget.value.shortDescription.ar);
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _shortDescEnCtrl.dispose();
    _shortDescArCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon label + circle (no SVG on values)
          _FieldLabel('Icon'),
          SizedBox(height: 8.h),
          _IconCircle(url: widget.value.iconUrl, label: ''),
          SizedBox(height: 12.h),

          // Title EN + AR side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Title'),
                    SizedBox(height: 6.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'Text Here',
                      controller: _titleEnCtrl,
                      enabled: false,
                      height: 44,
                      textDirection: TextDirection.ltr,
                      submitted: false,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _FieldLabel('العنوان', rtl: true),
                    SizedBox(height: 6.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'أدخل النص هنا',
                      controller: _titleArCtrl,
                      enabled: false,
                      height: 44,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      submitted: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Short Description EN — multiline
          _FieldLabel('Short Description'),
          SizedBox(height: 6.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: _shortDescEnCtrl,
            enabled: false,
            height: 80,
            maxLines: 4,
            maxLength: 150,
            showCharCount: true,
            textDirection: TextDirection.ltr,
            submitted: false,
          ),
          SizedBox(height: 10.h),

          // Short Description AR — multiline
          Align(
            alignment: Alignment.centerRight,
            child: _FieldLabel('وصف مختصر', rtl: true),
          ),
          SizedBox(height: 6.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: _shortDescArCtrl,
            enabled: false,
            height: 80,
            maxLines: 4,
            maxLength: 150,
            showCharCount: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            submitted: false,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ── Shared label widget ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool rtl;
  const _FieldLabel(this.text, {this.rtl = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// ── Icon Circle ───────────────────────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  final String url;
  final String label;
  const _IconCircle({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                  fontWeight: FontWeight.w600, color: Colors.black54)),
          SizedBox(height: 6.h),
        ],
        Container(
          width: 64.w, height: 64.h,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _kGreenLight),
          child: url.isNotEmpty
              ? ClipOval(
              child: Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.broken_image, color: Colors.grey, size: 24.sp)))
              : Icon(Icons.add, color: _kGreenSolid, size: 28.sp),
        ),
      ],
    );
  }
}

// ── Preview Accordion ─────────────────────────────────────────────────────────

class _PreviewAccordion extends StatefulWidget {
  final String title;
  final Widget child;
  const _PreviewAccordion({required this.title, required this.child});

  @override
  State<_PreviewAccordion> createState() => _PreviewAccordionState();
}

class _PreviewAccordionState extends State<_PreviewAccordion> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _kGreenSolid,
              borderRadius: _open
                  ? BorderRadius.vertical(top: Radius.circular(12.r))
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white, size: 22.sp),
              ],
            ),
          ),
        ),
        if (_open)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            padding: EdgeInsets.all(20.w),
            child: widget.child,
          ),
      ],
    );
  }
}