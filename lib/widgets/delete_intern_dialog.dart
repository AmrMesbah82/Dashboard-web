// ******************* FILE INFO *******************
// File Name: delete_intern_dialog.dart
// Figma: DELETE INTERN DETAILS dialog
// Usage: showDialog(context: context, builder: (_) => DeleteInternDialog(...))

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';

class DeleteInternDialog extends StatelessWidget {
  final String   internName;
  final VoidCallback onDelete;

  const DeleteInternDialog({
    super.key,
    required this.internName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.h),
      child: Container(
        width: 600.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Illustration ──────────────────────────────────────────────
            SvgPicture.asset(
              'assets/images/edit_main_page_dialog.svg',
              width:  180.w,
              height: 180.h,
              fit:    BoxFit.contain,
            ),
            SizedBox(height: 24.h),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'DELETE INTERN DETAILS',
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight600.copyWith(
                color:      const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
                fontSize:   17.sp,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: 12.h),

            // ── Description ───────────────────────────────────────────────
            Text(
              'Are you sure you want to permanently delete this job post? '
                  'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color:  const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // ── Back / Delete buttons ─────────────────────────────────────
            Row(
              children: [
                // Back
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color:        const Color(0xFF9E9E9E),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'Back',
                          style: StyleText.fontSize16Weight600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),

                // Delete
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                      onDelete();
                    },
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color:        const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: StyleText.fontSize16Weight600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}