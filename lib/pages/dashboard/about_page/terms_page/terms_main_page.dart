// ******************* FILE INFO *******************
// File Name: terms_main_page.dart
// Screen 1 of 3 — Terms of Service CMS: Main view (read-only accordions)
// Used as _tabIndex == 2 body in AboutMainPageMasterDashboard

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';

import '../../../../core/custom_svg.dart';
import 'terms_edit_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
}

// ─────────────────────────────────────────────────────────────────────────────

class TermsMainView extends StatefulWidget {
  const TermsMainView({super.key});

  @override
  State<TermsMainView> createState() => _TermsMainViewState();
}

class _TermsMainViewState extends State<TermsMainView> {
  final Map<String, bool> _open = {
    'navigationLabel': true,
    'terms':           true,
    'privacy':         true,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermsCubit, TermsState>(
      builder: (context, state) {
        if (state is TermsLoading || state is TermsInitial) {
          return const Center(
              child: CircularProgressIndicator(color: _C.primary));
        }

        final TermsOfServiceModel? model = switch (state) {
          TermsLoaded s => s.data,
          TermsSaved  s => s.data,
          _             => null,
        };

        if (model == null) {
          return Center(
              child: Text('No data found',
                  style: StyleText.fontSize13Weight400
                      .copyWith(color: _C.hintText)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lastUpdatedRow(
              onEdit: () => navigateTo(
                context,
                BlocProvider.value(
                  value: context.read<TermsCubit>(),
                  child: const TermsEditPage(),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // // ① Navigation Label
            // _accordion(
            //   key: 'navigationLabel',
            //   title: 'Navigation Label',
            //   children: [
            //     _iconPreviewCircle(
            //         label: 'Icon', url: model.navigationLabel.iconUrl),
            //     SizedBox(height: 12.h),
            //     Row(children: [
            //       Expanded(
            //           child: _readField(
            //               'Title',
            //               model.navigationLabel.title.en.isEmpty
            //                   ? 'Text Here'
            //                   : model.navigationLabel.title.en)),
            //       SizedBox(width: 16.w),
            //       Expanded(
            //           child: _readFieldRtl(
            //               'العنوان', model.navigationLabel.title.ar)),
            //     ]),
            //   ],
            // ),
            // SizedBox(height: 12.h),

            // ② Terms and Conditions
            _accordion(
              key: 'terms',
              title: 'Terms and Conditions',
              children: [
                SizedBox(height: 15.h),
                _iconPreviewCircle(
                    label: 'SVG',
                    url: model.termsAndConditions.svgUrl,
                    isSvg: true),
                SizedBox(height: 12.h),
                _readField(
                    'Description',
                    model.termsAndConditions.description.en.isEmpty
                        ? 'Text Here'
                        : model.termsAndConditions.description.en,
                    height: 100),
                SizedBox(height: 8.h),
                _readFieldRtl(
                    'الوصف', model.termsAndConditions.description.ar,
                    height: 100),
                SizedBox(height: 12.h),
                Row(children: [
                  Expanded(
                      child: _attachField(
                          'Attach Eng Document',
                          model.termsAndConditions.attachEnUrl)),
                  SizedBox(width: 16.w),
                  Expanded(
                      child: _attachField(
                          'Attach Ar Document',
                          model.termsAndConditions.attachArUrl)),
                ]),
              ],
            ),
            SizedBox(height: 12.h),

            // ③ Privacy Policy
            _accordion(
              key: 'privacy',
              title: 'Privacy Policy',
              children: [
                SizedBox(height: 15.h),
                _iconPreviewCircle(
                    label: 'SVG',
                    url: model.privacyPolicy.svgUrl,
                    isSvg: true),
                SizedBox(height: 12.h),
                _readField(
                    'Description',
                    model.privacyPolicy.description.en.isEmpty
                        ? 'Text Here'
                        : model.privacyPolicy.description.en,
                    height: 100),
                SizedBox(height: 8.h),
                _readFieldRtl(
                    'الوصف', model.privacyPolicy.description.ar,
                    height: 100),
                SizedBox(height: 12.h),
                Row(children: [
                  Expanded(
                      child: _attachField(
                          'Attach Eng Document',
                          model.privacyPolicy.attachEnUrl)),
                  SizedBox(width: 16.w),
                  Expanded(
                      child: _attachField(
                          'Attach Ar Document',
                          model.privacyPolicy.attachArUrl)),
                ]),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }

  // ── Last Updated + Edit Details ───────────────────────────────────────────
  Widget _lastUpdatedRow({required VoidCallback onEdit}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
          child: Text('Last Updated On 12 Jul 2026',
              style:
              StyleText.fontSize13Weight500.copyWith(color: _C.primary)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w, height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Edit Details',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: _C.primary)),
                SizedBox(width: 6.w),
                CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w, height: 20.h,
                    fit: BoxFit.scaleDown, color: _C.primary),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r)),
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
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
              ]),
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

  // ── Icon preview circle ───────────────────────────────────────────────────
  Widget _iconPreviewCircle({
    required String label,
    required String url,
    bool isSvg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        Container(
          width: 56.w, height: 56.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEEEEE),
          ),
          child: url.isEmpty
              ? Icon(
              isSvg
                  ? Icons.description_outlined
                  : Icons.image_outlined,
              color: Colors.grey[500],
              size: 24.sp)
              : ClipOval(
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: isSvg
                  ? SvgPicture.network(url, fit: BoxFit.contain)
                  : Image.network(url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image,
                      color: Colors.red[300],
                      size: 24.sp)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Attached document field ───────────────────────────────────────────────
  Widget _attachField(String label, String url) {
    final hasFile = url.isNotEmpty;
    final fileName = hasFile ? url.split('/').last.split('?').first : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: hasFile
              ? () => launchUrl(Uri.parse(url),
              mode: LaunchMode.externalApplication)
              : null,
          child: Container(
            width: double.infinity,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                color: hasFile
                    ? const Color(0xFFE8F5EE)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Icon(
                    hasFile ? Icons.picture_as_pdf : Icons.attach_file,
                    size: 16.sp,
                    color: hasFile ? _C.primary : _C.hintText),
                SizedBox(width: 8.w),
                Expanded(
                    child: Text(
                        hasFile
                            ? (fileName.isEmpty ? 'View Document' : fileName)
                            : 'No document attached',
                        style: StyleText.fontSize12Weight400.copyWith(
                            color: hasFile ? _C.primary : _C.hintText),
                        overflow: TextOverflow.ellipsis)),
                if (hasFile)
                  Icon(Icons.open_in_new,
                      size: 14.sp, color: _C.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Read-only LTR ─────────────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: _C.labelText)),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r)),
            alignment:
            height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.hintText),
                maxLines: height > 36 ? 8 : 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // ── Read-only RTL ─────────────────────────────────────────────────────────
  Widget _readFieldRtl(String label, String value, {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: height.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4.r)),
              alignment:
              height > 36 ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                  value.isEmpty ? 'أكتب هنا' : value,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText),
                  textDirection: TextDirection.rtl,
                  maxLines: height > 36 ? 8 : 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}