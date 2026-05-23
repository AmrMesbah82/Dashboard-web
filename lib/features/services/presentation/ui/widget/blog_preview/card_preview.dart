part of '../../pages/blog_services/blog_preview.dart';

class _CardPreview extends StatelessWidget {
  final BlogPostModel post;
  final Uint8List? imageBytes;
  final bool isPickedSvg;

  const _CardPreview({
    required this.post,
    this.imageBytes,
    this.isPickedSvg = false,
  });

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = post.buttonLabel.en.isNotEmpty
        ? post.buttonLabel.en
        : 'Read More';

    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: ColorPick.white,
        borderRadius: BorderRadius.circular(10.r),

      ),
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.question.en.isNotEmpty
                        ? post.question.en
                        : 'Question text',
                    style: StyleText.fontSize13Weight500.copyWith(
                        color: ColorPick.primary, fontWeight: FontWeight.w600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _buildImage(
                    width:  100.w,
                    height: 70.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Short Description ────────────────────────────────────────
            if (post.shortDescription.en.isNotEmpty)
              Text(
                post.shortDescription.en,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Text(_fmtDate(post.createdAt),
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText)),
                Spacer(),

                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                      color:        ColorPick.primary,
                      borderRadius: BorderRadius.circular(6.r)),
                  child: Text(buttonLabel,
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({required double width, required double height}) {
    // 🟢 Priority 1: Picked bytes (new/changed image)
    if (imageBytes != null) {
      if (isPickedSvg) {
        return Container(
          width: width,
          height: height,
          color: ColorPick.background,
          child: Center(
            child: SvgPicture.memory(
              imageBytes!,
              width:  width * 0.5,
              height: height * 0.5,
              fit: BoxFit.scaleDown,
            ),
          ),
        );
      } else {
        return Image.memory(
          imageBytes!,
          width:  width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, error, ___) {
            return _imagePlaceholder(width, height);
          },
        );
      }
    }

    // 🟢 Priority 2: Existing URL (editing an existing post)
    if (post.imageUrl.isNotEmpty) {
      return _XhrImage(
        url:    post.imageUrl,
        width:  width,
        height: height,
      );
    }

    // 🟡 Fallback: placeholder
    return _imagePlaceholder(width, height);
  }

  Widget _imagePlaceholder(double width, double height) {
    return Container(
      width:  width,
      height: height,
      color:  ColorPick.white,
      child: Icon(Icons.image_outlined,
          size: 24.sp, color: AppColors.secondaryText),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// READ MORE PREVIEW  (full article — matches Figma desktop layout)
// ══════════════════════════════════════════════════════════════════════════════
