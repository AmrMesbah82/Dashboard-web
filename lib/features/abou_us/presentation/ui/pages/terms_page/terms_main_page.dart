// ******************* FILE INFO *******************
// File Name: terms_main_page.dart
// Screen 1 of 3 — Terms of Service CMS: Main view (read-only accordions)
// UPDATED: Navigation Label accordion restored (was commented out)

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../../../../core/custom_svg.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../../core/widget/navigator.dart';
import '../../../../data/model/about_us.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';
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
              lastUpdated: model.lastUpdatedAt,
              onEdit: () => navigateTo(
                context,
                BlocProvider.value(
                  value: context.read<TermsCubit>(),
                  child: const TermsEditPage(),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ① Navigation Label
            _accordion(
              key: 'navigationLabel',
              title: 'Navigation Label',
              children: [
                SizedBox(height: 15.h),
                _iconPreviewCircle(
                  label: 'Icon',
                  url: model.navigationLabel.iconUrl,
                  isSvg: true,
                ),
                SizedBox(height: 12.h),
                Row(children: [
                  Expanded(
                    child: _readField(
                      'Title',
                      model.navigationLabel.title.en.isEmpty
                          ? 'Text Here'
                          : model.navigationLabel.title.en,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _readFieldRtl(
                      'العنوان',
                      model.navigationLabel.title.ar,
                    ),
                  ),
                ]),
                SizedBox(height: 12.h),
              ],
            ),
            SizedBox(height: 12.h),

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
                SizedBox(height: 12.h),
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
                SizedBox(height: 12.h),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }

  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    String fmtDate(DateTime? d) {
      if (d == null) return '—';
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
          child: Text(
            'Last Updated On ${fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
          ),
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
                        .copyWith(color: Colors.black)),
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
                borderRadius: BorderRadius.circular(6.r),
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
                    size: 26.sp),
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: url.isEmpty
              ? Icon(
              isSvg
                  ? Icons.description_outlined
                  : Icons.image_outlined,
              color: Colors.grey,
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

  Widget _attachField(String label, String url) {
    final hasFile = url.isNotEmpty;

    String fileName = '';
    if (hasFile) {
      final decoded = Uri.decodeFull(url);
      final segments = decoded.split('/');
      final raw = segments.last.split('?').first;
      fileName = raw.replaceAll(RegExp(r'^.*%2F'), '');
      if (fileName.isEmpty) fileName = 'Document';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: hasFile
              ? () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
              : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/pdf 1.svg',
                  width: 28.w,
                  height: 28.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasFile ? fileName : 'No document attached',
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: hasFile ? _C.labelText : _C.hintText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (hasFile) ...[
                        SizedBox(height: 2.h),
                        FutureBuilder<String>(
                          future: _fetchFileSize(url),
                          builder: (context, snapshot) {
                            final sizeLabel = snapshot.data ?? '...';
                            return Text(
                              sizeLabel,
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: _C.hintText,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _fetchFileSize(String url) async {
    try {
      final xhr = html.HttpRequest();
      xhr.open('HEAD', url, async: true);

      final completer = Completer<String>();

      xhr.onLoad.listen((_) {
        final contentLength = xhr.getResponseHeader('content-length');
        if (contentLength != null) {
          final bytes = int.tryParse(contentLength);
          if (bytes != null) {
            completer.complete(_formatBytes(bytes));
            return;
          }
        }
        completer.complete('');
      });

      xhr.onError.listen((_) => completer.complete(''));
      xhr.send();

      return completer.future;
    } catch (_) {
      return '';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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