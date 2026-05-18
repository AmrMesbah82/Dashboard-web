// ******************* FILE INFO *******************
// File Name: strategy_preview.dart
// Screen 3 of 3 — Our Strategy CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)
// UPDATED: Added SVG support for Strategic House images

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../data/model/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';



class _C {
  static const Color primary  = Color(0xFF008037);
  static const Color cardBg   = Color(0xFFFFFFFF);
  static const Color grey     = Color(0xFF9E9E9E);
  static const Color hintText = Color(0xFF797979);
  static const Color back     = Color(0xFFF1F2ED);
}

enum _PreviewMode { desktop, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyPreviewPage extends StatefulWidget {
  final OurStrategyModel model;
  final Map<String, Uint8List> imageUploads;

  const StrategyPreviewPage({
    super.key,
    required this.model,
    this.imageUploads = const {},
  });

  @override
  State<StrategyPreviewPage> createState() => _StrategyPreviewPageState();
}

class _StrategyPreviewPageState extends State<StrategyPreviewPage> {
  _PreviewMode _mode = _PreviewMode.desktop;

  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  // In-memory bytes (freshly picked, not yet uploaded)
  Uint8List? get _strategicHouseEnBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/en'];
  Uint8List? get _strategicHouseArBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/ar'];

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() async {
    final ok = await _confirm(context);
    if (ok == true && mounted) {
      context.read<StrategyCubit>().save(
        model: widget.model,
        imageUploads:
        widget.imageUploads.isEmpty ? null : widget.imageUploads,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<StrategyCubit, StrategyState>(
        listener: (context, state) {
          if (state is StrategySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Our Strategy saved!')),
            );
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is StrategyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 1000.w,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 3),
                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25.h),

                            Text(
                              'Preview Our Strategy Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Mode tabs ──────────────────────────────────
                            Row(
                              children: _PreviewMode.values.map((m) {
                                final sel = m == _mode;
                                final label = switch (m) {
                                  _PreviewMode.desktop => 'Desktop',
                                  _PreviewMode.tablet  => 'Tablet',
                                  _PreviewMode.mobile  => 'Mobile',
                                };
                                return GestureDetector(
                                  onTap: () => setState(() => _mode = m),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 24.w),
                                    child: Text(
                                      label,
                                      style: sel
                                          ? StyleText.fontSize14Weight600
                                          .copyWith(
                                        color: _C.primary,
                                        decoration:
                                        TextDecoration.underline,
                                        decorationColor: _C.primary,
                                      )
                                          : StyleText.fontSize14Weight400
                                          .copyWith(color: _C.hintText),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16.h),

                            // ── Strategic House — ENG accordion ────────────
                            _previewAccordion(
                              title: 'Strategic House - ENG',
                              isOpen: _strategicHouseEnOpen,
                              onToggle: () => setState(() =>
                              _strategicHouseEnOpen =
                              !_strategicHouseEnOpen),
                              child: _strategicHousePreviewBody(
                                bytes: _strategicHouseEnBytes,
                                url: widget.model.strategicHouseEnUrl,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Strategic House — ARB accordion ────────────
                            _previewAccordion(
                              title: 'Strategic House - ARB',
                              isOpen: _strategicHouseArOpen,
                              onToggle: () => setState(() =>
                              _strategicHouseArOpen =
                              !_strategicHouseArOpen),
                              child: _strategicHousePreviewBody(
                                bytes: _strategicHouseArBytes,
                                url: widget.model.strategicHouseArUrl,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Back | Save ────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44.h,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Text('Back',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
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
                                          borderRadius:
                                          BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Text('Save',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
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

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
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
          if (isOpen) child,
        ],
      ),
    );
  }

  // ── Preview body for a Strategic House section ────────────────────────────
  Widget _strategicHousePreviewBody({
    required Uint8List? bytes,
    required String url,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    // Responsive container width
    final double containerWidth = switch (_mode) {
      _PreviewMode.desktop => 960.w,
      _PreviewMode.tablet  => 680.w,
      _PreviewMode.mobile  => 360.w,
    };

    final double imageHeight = switch (_mode) {
      _PreviewMode.desktop => 300.h,
      _PreviewMode.tablet  => 240.h,
      _PreviewMode.mobile  => 180.h,
    };

    return Container(
      width: double.infinity,
      color: _C.cardBg,
      padding: EdgeInsets.all(16.r),
      child: Center(
        child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: hasImage
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _buildImageWidget(
              bytes: bytes,
              url: url,
              height: imageHeight,
            ),
          )
              : SizedBox(
            height: imageHeight,
            child: Center(
              child: Icon(Icons.image_outlined,
                  color: Colors.grey[400], size: 48.sp),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Image widget helper with SVG support ───────────────────────────────────────
Widget _buildImageWidget({
  required Uint8List? bytes,
  required String url,
  required double height,
}) {
  // Helper to check if bytes contain SVG
  bool _isSvgBytes(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final header = bytes.sublist(0, bytes.length > 5 ? 5 : bytes.length);
    final headerStr = String.fromCharCodes(header);
    return headerStr.contains('<svg') || headerStr.contains('<?xml');
  }

  // Helper to check if URL points to SVG
  bool _isSvgUrl(String url) {
    final decoded = Uri.decodeFull(url).toLowerCase();
    return decoded.contains('.svg') ||
        decoded.contains('/svg?') ||
        decoded.contains('/svg/') ||
        decoded.endsWith('/svg');
  }

  // Handle uploaded bytes (new upload)
  if (bytes != null && bytes.isNotEmpty) {
    final isSvg = _isSvgBytes(bytes);
    if (isSvg) {
      return SvgPicture.memory(
        bytes,
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF008037),
            strokeWidth: 2,
          ),
        ),
      );
    } else {
      return Image.memory(
        bytes,
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: Icon(Icons.broken_image,
              color: Colors.grey[400], size: 48),
        ),
      );
    }
  }

  // Handle existing URL (from database)
  if (url.isNotEmpty) {
    final isSvg = _isSvgUrl(url);
    if (isSvg) {
      // For SVG URLs, fetch and display
      return FutureBuilder<Uint8List>(
        future: _loadSvgBytes(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF008037),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return SvgPicture.memory(
              snapshot.data!,
              width: double.infinity,
              height: height,
              fit: BoxFit.contain,
            );
          }
          if (snapshot.hasError) {
            print('Error loading SVG: ${snapshot.error}');
            return SizedBox(
              height: height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        color: Colors.grey[400], size: 48),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      // For raster images
      return Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF008037),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image,
                    color: Colors.grey[400], size: 48),
                SizedBox(height: 8.h),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // No image
  return SizedBox(
    height: height,
    child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 48),
  );
}

// ── Load SVG bytes from URL ────────────────────────────────────────────────────
Future<Uint8List> _loadSvgBytes(String url) async {
  try {
    print('🔵 Loading SVG from URL: $url');
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      responseType: 'arraybuffer',
    );
    if (response.status != 200) {
      throw Exception('Failed to load SVG: ${response.status}');
    }
    final bytes = (response.response as ByteBuffer).asUint8List();
    print('🟢 SVG loaded successfully, size: ${bytes.length} bytes');
    return bytes;
  } catch (e) {
    print('🔴 Error loading SVG: $e');
    rethrow;
  }
}

// ── Confirm Dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r)),
    contentPadding: EdgeInsets.all(24.r),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(Icons.edit_note,
              size: 40.sp, color: const Color(0xFF008037)),
        ),
        SizedBox(height: 16.h),
        Text(
          'EDITING OUR STRATEGY DETAILS',
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight600
              .copyWith(color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: 8.h),
        Text(
          'Do you want to save the changes made to this Our Strategy?',
          textAlign: TextAlign.center,
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Back',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Confirm',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);