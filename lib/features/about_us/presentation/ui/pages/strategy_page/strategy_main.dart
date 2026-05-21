// ******************* FILE INFO *******************
// File Name: strategy_main.dart
// Screen 1 of 3 — Our Strategy CMS: Main view (read-only accordions)
// UPDATED: Added Strategic House ENG + ARB accordions

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../../../../../core/constant/color.dart';
import '../../../../../../core/custom_svg.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../../core/widget/navigator.dart';
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';
import 'strategy_edit.dart';

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
// }

// ── XHR image cache ───────────────────────────────────────────────────────────

final Map<String, Future<Uint8List>> _strategyUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _strategyUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header =
  String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ColorFilter? colorFilter,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final bool hintSvg = _isSvgUrl(url);
  return FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: hintSvg),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SizedBox(width: width, height: height);
      }
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            colorFilter: colorFilter,
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return Icon(Icons.broken_image,
          color: Colors.grey[400],
          size: (width ?? height ?? 24).toDouble());
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class StrategyMainView extends StatefulWidget {
  const StrategyMainView({super.key});

  @override
  State<StrategyMainView> createState() => _StrategyMainViewState();
}

class _StrategyMainViewState extends State<StrategyMainView> {
  final Map<String, bool> _open = {
    'navigationLabel':  true,
    'strategicHouseEn': true,
    'strategicHouseAr': true,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StrategyCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyCubit, StrategyState>(
      builder: (context, state) {
        if (state is StrategyLoading || state is StrategyInitial) {
          return const Center(
              child: CircularProgressIndicator(color: ColorPick.primary));
        }

        final OurStrategyModel? model = switch (state) {
          StrategyLoaded s => s.data,
          StrategySaved  s => s.data,
          _                => null,
        };

        if (model == null) {
          return Center(
              child: Text('No data found',
                  style: StyleText.fontSize13Weight400
                      .copyWith(color: AppColors.secondaryText)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lastUpdatedRow(
              lastUpdated: model.lastUpdatedAt,    // ← ADD this
              onEdit: () => navigateTo(
                context,
                BlocProvider.value(
                  value: context.read<StrategyCubit>(),
                  child: const StrategyEditPage(),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ① Navigation Label
            _accordion(
              key: 'navigationLabel',
              title: 'Navigation Label',
              children: [
                SizedBox(height: 20.h),
                _iconPreviewCircle(
                    label: 'Icon',
                    url: model.navigationLabel.iconUrl),
                SizedBox(height: 12.h),
                Row(children: [
                  Expanded(
                      child: _readField(
                          'Title',
                          model.navigationLabel.title.en.isEmpty
                              ? 'Text Here'
                              : model.navigationLabel.title.en)),
                  SizedBox(width: 16.w),
                  Expanded(
                      child: _readFieldRtl(
                          'العنوان',
                          model.navigationLabel.title.ar)),
                ]),
                SizedBox(height: 16.h),
              ],
            ),
            SizedBox(height: 12.h),

            // ② Strategic House — ENG
            _accordion(
              key: 'strategicHouseEn',
              title: 'Strategic House - ENG',
              children: [
                SizedBox(height: 20.h),
                _imagePreviewBox(
                  label: 'Image (English)',
                  url: model.strategicHouseEnUrl,
                ),
                SizedBox(height: 16.h),
              ],
            ),
            SizedBox(height: 12.h),

            // ③ Strategic House — ARB
            _accordion(
              key: 'strategicHouseAr',
              title: 'Strategic House - ARB',
              children: [
                SizedBox(height: 20.h),
                _imagePreviewBox(
                  label: 'Image (Arabic)',
                  url: model.strategicHouseArUrl,
                ),
                SizedBox(height: 16.h),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }

// ── Last Updated + Edit Details ───────────────────────────────────────────
  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,           // ← ADD this parameter
  }) {
    // ── Date formatter ──
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
              color: ColorPick.white,
              borderRadius: BorderRadius.circular(4.r)),
          child: Text(
            'Last Updated On ${fmtDate(lastUpdated)}',   // ← dynamic
            style: StyleText.fontSize13Weight500
                .copyWith(color: ColorPick.primary),
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
                        .copyWith(color: ColorPick.primary)),
                SizedBox(width: 6.w),
                CustomSvg(
                    assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w, height: 20.h,
                    fit: BoxFit.scaleDown, color: ColorPick.primary),
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
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
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
                    size: 25.sp),
              ]),
            ),
          ),
          if (isOpen)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(

              ),
              // padding: EdgeInsets.symmetric(vertical: 16.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
        ],
      ),
    );
  }

  // ── Image preview box (for Strategic House sections) ──────────────────────
  Widget _imagePreviewBox({required String label, required String url}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.text)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: url.isEmpty
              ? Center(
              child: Icon(Icons.image_outlined,
                  color: Colors.grey[400], size: 48.sp))
              : ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _netImg(
              url: url,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // ── Icon preview circle — XHR safe ───────────────────────────────────────
  Widget _iconPreviewCircle({
    required String label,
    required String url,
    bool isSvg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEEEEE)),
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
              child: _netImg(
                url: url,
                width: 28.w,
                height: 28.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Read-only LTR ─────────────────────────────────────────────────────────
  Widget _readField(String label, String value,
      {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: height > 36 ? 8.h : 0),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r)),
            alignment: height > 36
                ? Alignment.topLeft
                : Alignment.centerLeft,
            child: Text(value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                maxLines: height > 36 ? 8 : 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // ── Read-only RTL ─────────────────────────────────────────────────────────
  Widget _readFieldRtl(String label, String value,
      {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: height.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: height > 36 ? 8.h : 0),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4.r)),
              alignment: height > 36
                  ? Alignment.topRight
                  : Alignment.centerRight,
              child: Text(
                  value.isEmpty ? 'أكتب هنا' : value,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                  textDirection: TextDirection.rtl,
                  maxLines: height > 36 ? 8 : 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}