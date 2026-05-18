// ******************* FILE INFO *******************
// File Name: segmented_score_bar_widget.dart
// Created by: Amr Mesbah
// Purpose: Segmented horizontal bar for Candidate Score Distribution

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScoreSegment {
  final String label;
  final int value;
  final Color color;

  const ScoreSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SegmentedScoreBarWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final List<ScoreSegment> segments;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double barHeight;
  final bool lightMode;

  const SegmentedScoreBarWidget({
    Key? key,
    required this.title,
    required this.segments,
    this.iconAsset,
    this.height,
    this.width,
    this.backgroundColor,
    this.barHeight = 30,
    required this.lightMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;
    final totalValue =
    segments.fold<int>(0, (sum, s) => sum + s.value);

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
          SizedBox(height: 20.sp),

          // ── Labels row with values ──────────────────────
          Row(
            children: segments.map((seg) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      seg.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      seg.value.toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.sp),

          // ── Segmented bar ───────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: barHeight.sp,
              child: Row(
                children: segments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final seg = entry.value;
                  final double fraction = totalValue > 0
                      ? seg.value / totalValue
                      : 1.0 / segments.length;

                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Container(
                      margin: EdgeInsets.only(
                        right:
                        index < segments.length - 1 ? 2.w : 0,
                      ),
                      decoration: BoxDecoration(
                        color: seg.color,
                        borderRadius: BorderRadius.horizontal(
                          left: index == 0
                              ? Radius.circular(6.r)
                              : Radius.zero,
                          right: index == segments.length - 1
                              ? Radius.circular(6.r)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}