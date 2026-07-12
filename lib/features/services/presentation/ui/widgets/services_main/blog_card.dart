part of '../../pages/services_main/services_main.dart';

class _BlogCard extends StatelessWidget {
  final BlogPostModel post;
  final VoidCallback  onEdit;
  final VoidCallback  onDelete;

  const _BlogCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor => switch (post.status) {
    'published' => ColorPick.activeColor,
    'inactive'  => ColorPick.inactiveColor,
    'draft'     => ColorPick.draftColor,
    'removed'   => ColorPick.removedColor,
    _           => ColorPick.draftColor,
  };

  String get _statusLabel => switch (post.status) {
    'published' => 'Active',
    'inactive'  => 'Inactive',
    'draft'     => 'Draft',
    'removed'   => 'Removed',
    _           => 'Draft',
  };

  String get _datePrefix => switch (post.status) {
    'published' => 'Posted:',
    'inactive'  => 'Inactive Since',
    'draft'     => 'Started Since',
    'removed'   => 'Removed On',
    _           => '',
  };

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String cleanUrl = post.imageUrl.trim();
    final bool hasImage   = cleanUrl.isNotEmpty;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: date + status badge ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '$_datePrefix ',
                        style: StyleText.fontSize11Weight400
                            .copyWith(color: AppColors.secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('${_fmtDate(post.createdAt)}' ,   style: StyleText.fontSize11Weight400
                          .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,)
                    ],
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _statusLabel,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: _statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Row 2: text (left) + image (right) ────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.question.en.isNotEmpty
                            ? FormatHelper.capitalize(post.question.en)
                            : 'Untitled',
                        style: StyleText.fontSize13Weight600.copyWith(
                          color: ColorPick.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        post.shortDescription.en.isNotEmpty
                            ? FormatHelper.capitalize(post.shortDescription.en)
                            : 'Short Description...',
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Image — auto-detects SVG vs raster via XHR ─────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: hasImage
                      ? _XhrImage(
                    url:    cleanUrl,
                    width:  100.w,
                    height: 80.h,
                  )
                      : _imgPlaceholder(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Row 3: edit/delete icons + Read More button ───────────────
            Row(
              children: [
                // // Edit icon
                // GestureDetector(
                //   onTap: onEdit,
                //   child: Container(
                //     padding: EdgeInsets.all(6.r),
                //     decoration: BoxDecoration(
                //       color: ColorPick.background,
                //       borderRadius: BorderRadius.circular(4.r),
                //     ),
                //     child: Icon(Icons.edit_outlined,
                //         size: 16.sp, color: AppColors.text),
                //   ),
                // ),
                // SizedBox(width: 8.w),
                // // Delete icon
                // GestureDetector(
                //   onTap: onDelete,
                //   child: Container(
                //     padding: EdgeInsets.all(6.r),
                //     decoration: BoxDecoration(
                //       color: ColorPick.background,
                //       borderRadius: BorderRadius.circular(4.r),
                //     ),
                //     child: Icon(Icons.delete_outline,
                //         size: 16.sp, color: Colors.red),
                //   ),
                // ),
                const Spacer(),
                GestureDetector(
                  onTap: (){},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: ColorPick.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Read More',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: Colors.white),
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

  Widget _imgPlaceholder() => Container(
    width: 100.w, height: 80.h,
    decoration: BoxDecoration(
      color: ColorPick.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Icon(Icons.image_outlined, size: 24.sp, color: AppColors.secondaryText),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR image loader — auto-detects SVG vs raster (PNG/JPG/WebP)
// Works on Flutter Web, bypasses CORS for Firebase Storage
// ══════════════════════════════════════════════════════════════════════════════
