// ******************* FILE INFO *******************
// File Name: service_preview_page.dart
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary    = Color(0xFF008037);
  static const Color green      = Color(0xFF2D8C4E);
  static const Color greenLight = Color(0xFFE8F5EE);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color bg         = Color(0xFFF5F5F5);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color headerBg   = Color(0xFF008037);
}

class ServicePreviewPage extends StatefulWidget {
  const ServicePreviewPage({super.key});
  @override
  State<ServicePreviewPage> createState() => _ServicePreviewPageState();
}

class _ServicePreviewPageState extends State<ServicePreviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCmsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCmsCubit, ServiceCmsState>(
      builder: (context, state) {
        final ServicePageModel model = switch (state) {
          ServiceCmsLoaded s => s.data,
          ServiceCmsSaved  s => s.data,
          _                  => ServicePageModel.empty(),
        };
        final bool isLoading = state is ServiceCmsInitial || state is ServiceCmsLoading;

        return Scaffold(
          backgroundColor: _C.bg,
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: _C.primary))
              : Column(children: [
            AppNavbar(currentRoute: '/services'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          model.title.en.isNotEmpty ? model.title.en : 'Service',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 48.sp,
                              fontWeight: FontWeight.w700, color: _C.green),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.goNamed('service-editor'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: _C.surface,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: _C.border),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('Edit Details',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
                                      fontWeight: FontWeight.w500, color: _C.labelText)),
                              SizedBox(width: 6.w),
                              Icon(Icons.open_in_new, size: 14.sp, color: _C.labelText),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _PreviewAccordion(title: 'Headings', child: _HeadingsPreview(model: model)),
                    SizedBox(height: 10.h),
                    _PreviewAccordion(title: 'Digital Journey', child: _JourneyPreview(model: model)),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _PreviewAccordion extends StatefulWidget {
  final String title;
  final Widget child;
  const _PreviewAccordion({required this.title, required this.child});
  @override State<_PreviewAccordion> createState() => _PreviewAccordionState();
}

class _PreviewAccordionState extends State<_PreviewAccordion> {
  bool _open = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _C.surface,
          borderRadius: BorderRadius.circular(6.r),

      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.headerBg,
              borderRadius: _open
                  ? BorderRadius.only(topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(child: Text(widget.title,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp,
                      fontWeight: FontWeight.w600, color: Colors.white))),
              Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (_open) Padding(padding: EdgeInsets.all(16.w), child: widget.child),
      ]),
    );
  }
}

class _HeadingsPreview extends StatelessWidget {
  final ServicePageModel model;
  const _HeadingsPreview({required this.model});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _PreviewField(label: 'Title', value: model.title.en)),
        SizedBox(width: 16.w),
        Expanded(child: _PreviewField(label: 'العنوان', value: model.title.ar, rtl: true)),
      ]),
      SizedBox(height: 14.h),
      _PreviewField(label: 'Short Description', value: model.shortDescription.en, maxLines: 3),
      SizedBox(height: 10.h),
      _PreviewField(label: 'وصف مختصر', value: model.shortDescription.ar, maxLines: 3, rtl: true),
    ]);
  }
}

class _JourneyPreview extends StatelessWidget {
  final ServicePageModel model;
  const _JourneyPreview({required this.model});
  @override
  Widget build(BuildContext context) {
    if (model.journeyItems.isEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text('No journey items yet.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: _C.hintText)),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _PreviewField(label: 'SubTitle', value: model.journeyItems.first.subTitle.en)),
        SizedBox(width: 16.w),
        Expanded(child: _PreviewField(label: 'العنوان', value: model.journeyItems.first.subTitle.ar, rtl: true)),
      ]),
      SizedBox(height: 16.h),
      LayoutBuilder(builder: (context, constraints) {
        final double cardW = (constraints.maxWidth - 12.w * 3) / 4;
        return Wrap(
          spacing: 12.w, runSpacing: 12.h,
          children: model.journeyItems.map((item) =>
              SizedBox(width: cardW, child: _ServiceCardPreview(item: item))).toList(),
        );
      }),
    ]);
  }
}

class _ServiceCardPreview extends StatelessWidget {
  final JourneyItemModel item;
  const _ServiceCardPreview({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: _C.bg,
          borderRadius: BorderRadius.circular(10.r),),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40.w, height: 40.h,
          decoration: BoxDecoration(color: _C.greenLight, borderRadius: BorderRadius.circular(8.r)),
          child: item.iconUrl.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(8.r),
              child: Image.network(item.iconUrl, width: 40.w, height: 40.h, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.miscellaneous_services_outlined, size: 22.sp, color: _C.green)))
              : Icon(Icons.miscellaneous_services_outlined, size: 22.sp, color: _C.green),
        ),
        SizedBox(height: 10.h),
        Text(item.title.en.isNotEmpty ? item.title.en : '—',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
                fontWeight: FontWeight.w600, color: _C.labelText)),
        SizedBox(height: 6.h),
        Text(item.description.en.isNotEmpty ? item.description.en : '—',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp,
                color: const Color(0xFF666666), height: 1.6)),
      ]),
    );
  }
}

class _PreviewField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final bool rtl;
  const _PreviewField({required this.label, required this.value,
    this.maxLines = 1, this.rtl = false});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
            fontWeight: FontWeight.w500, color: _C.labelText)),
        SizedBox(height: 5.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          constraints: BoxConstraints(minHeight: maxLines > 1 ? 80.h : 36.h),
          decoration: BoxDecoration(color: _C.bg,
              borderRadius: BorderRadius.circular(4.r)),
          child: Text(value.isNotEmpty ? value : '',
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                  color: value.isNotEmpty ? _C.labelText : _C.hintText)),
        ),
      ]),
    );
  }
}