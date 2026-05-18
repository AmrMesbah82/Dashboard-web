// ******************* FILE INFO *******************
// File Name: funnel_chart_widget.dart
// Created by: Amr Mesbah
// Purpose: Green gradient funnel/pyramid chart for Hiring Stages

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FunnelChartItem {
  final String label;
  final int value;

  const FunnelChartItem({required this.label, required this.value});
}

class FunnelChartWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final List<FunnelChartItem> items;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final bool lightMode;

  /// Gradient from top (widest) to bottom (narrowest)
  final List<Color> gradientColors;

  const FunnelChartWidget({
    Key? key,
    required this.title,
    required this.items,
    this.iconAsset,
    this.height,
    this.width,
    this.backgroundColor,
    required this.lightMode,
    this.gradientColors = const [
      Color(0xFF1B5E20), // dark green (top)
      Color(0xFF2E7D32),
      Color(0xFF388E3C),
      Color(0xFF43A047),
      Color(0xFF66BB6A), // light green (bottom)
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;

    return Container(
      width: width?.w,
      height: height?.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              if (iconAsset != null) ...[
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF008037),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sp),

          // ── Labels + Funnel ─────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Left labels column
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) {
                      return Row(
                        children: [
                          Container(
                            width: 10.sp,
                            height: 10.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorForIndex(items.indexOf(item)),
                            ),
                          ),
                          SizedBox(width: 6.sp),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10.sp),

                // Funnel visual
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(
                            constraints.maxWidth, constraints.maxHeight),
                        painter: _FunnelPainter(
                          items: items,
                          colors: gradientColors,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    if (index < gradientColors.length) return gradientColors[index];
    return gradientColors.last;
  }
}

// ── Custom Painter for Funnel ─────────────────────────────────────────────────

class _FunnelPainter extends CustomPainter {
  final List<FunnelChartItem> items;
  final List<Color> colors;

  _FunnelPainter({required this.items, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final int count = items.length;
    final double totalHeight = size.height;
    final double sectionHeight = totalHeight / count;
    final double maxWidth = size.width * 0.95;
    final double minWidth = size.width * 0.25;
    final double centerX = size.width / 2;

    for (int i = 0; i < count; i++) {
      // Top width of this section
      final double topWidth =
          maxWidth - (maxWidth - minWidth) * (i / count);
      // Bottom width of this section
      final double bottomWidth =
          maxWidth - (maxWidth - minWidth) * ((i + 1) / count);

      final double topY = i * sectionHeight;
      final double bottomY = (i + 1) * sectionHeight;

      final Color color =
      i < colors.length ? colors[i] : colors.last;

      final path = Path()
        ..moveTo(centerX - topWidth / 2, topY)
        ..lineTo(centerX + topWidth / 2, topY)
        ..lineTo(centerX + bottomWidth / 2, bottomY)
        ..lineTo(centerX - bottomWidth / 2, bottomY)
        ..close();

      canvas.drawPath(path, Paint()..color = color);

      // Draw value text centered in section
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          topY + (sectionHeight - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FunnelPainter oldDelegate) =>
      oldDelegate.items != items || oldDelegate.colors != colors;
}