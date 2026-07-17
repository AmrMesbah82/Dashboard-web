part of '../../pages/blog_services/blog_preview.dart';

class _ReadMorePreview extends StatelessWidget {
  final BlogPostModel post;
  final Uint8List? imageBytes;
  final bool isPickedSvg;

  const _ReadMorePreview({
    required this.post,
    this.imageBytes,
    this.isPickedSvg = false,
  });

  MarkdownStyleSheet _mdStyle() {
    return MarkdownStyleSheet(
      p: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text, height: 1.7),
      strong: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text, fontWeight: FontWeight.w700, height: 1.7),
      em: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text, fontStyle: FontStyle.italic, height: 1.7),
      h1: StyleText.fontSize22Weight700.copyWith(
          color: AppColors.text),
      h2: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.text, fontSize: 18.sp),
      h3: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.text),
      a: StyleText.fontSize13Weight400.copyWith(
          color: ColorPick.primary, decoration: TextDecoration.underline),
      listBullet: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text, height: 1.7),
      blockquoteDecoration: BoxDecoration(
        color: ColorPick.background,
        border: Border(
          left: BorderSide(color: ColorPick.primary, width: 3.w),
        ),
      ),
      blockquotePadding: EdgeInsets.symmetric(
          horizontal: 12.w, vertical: 8.h),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6.r),
      ),
      codeblockPadding: EdgeInsets.all(12.w),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize:   12.sp,
        color:      AppColors.text,
        backgroundColor: const Color(0xFFF0F0F0),
      ),
      tableBorder: TableBorder.all(color: ColorPick.white, width: 1),
      tableHead: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text, fontWeight: FontWeight.w700),
      tableBody: StyleText.fontSize13Weight400.copyWith(
          color: AppColors.text),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorPick.white, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = post.question.en.isNotEmpty
        ? post.question.en
        : 'Question text';
    final String sectionHead = post.descriptionTitle.en;
    final String intro = post.shortDescription.en;
    final String dateStr = _fmtDate(post.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: StyleText.fontSize22Weight700.copyWith(
                  color:      ColorPick.primary,
                  fontSize:   22.sp,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sectionHead.isNotEmpty) ...[
                        Text(sectionHead,
                            style: StyleText.fontSize14Weight600.copyWith(
                                color:      AppColors.text,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 8.h),
                      ],
                      if (intro.isNotEmpty) ...[
                        Text(intro,
                            style: StyleText.fontSize13Weight400.copyWith(
                                color: AppColors.text, height: 1.7)),
                        SizedBox(height: 8.h),
                      ],
                      Text(dateStr,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: _buildImage(
                    width:  200.w,
                    height: 150.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            ..._buildBlockWidgets(post.blocks),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({required double width, required double height}) {
    // 🟢 Priority 1: Picked bytes
    if (imageBytes != null) {
      if (isPickedSvg) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:        ColorPick.background,
            borderRadius: BorderRadius.circular(10.r),
          ),
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

    // 🟢 Priority 2: Existing URL
    if (post.imageUrl.isNotEmpty) {
      return _XhrImage(
        url:    post.imageUrl,
        width:  width,
        height: height,
      );
    }

    // 🟡 Fallback
    return _imagePlaceholder(width, height);
  }

  Widget _imagePlaceholder(double width, double height) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        color:        ColorPick.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.image_outlined,
          size: 40.sp, color: AppColors.secondaryText),
    );
  }

  // Builds the description blocks. Numbering/bullet blocks are split on line
  // breaks so a multi-line paste (a list copied from Word, etc.) renders one
  // numbered/bulleted line per row instead of a single prefix + mashed text.
  // Numbering continues across consecutive numbering blocks and resets on a
  // paragraph or bullet block.
  List<Widget> _buildBlockWidgets(List<BlogDescriptionBlock> blocks) {
    final widgets = <Widget>[];
    var counter = 0; // running number for numbering rows

    for (final block in blocks) {
      final text = block.content.en.isNotEmpty ? block.content.en : '';

      switch (block.type) {
        case BlogBlockType.paragraph:
          counter = 0;
          if (text.trim().isEmpty) break;
          widgets.add(Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: MarkdownBody(
              data:       text,
              selectable: true,
              styleSheet: _mdStyle(),
              shrinkWrap: true,
            ),
          ));

        case BlogBlockType.numbering:
          for (final line in _lines(text)) {
            counter++;
            widgets.add(_listRow(
              prefix: '$counter.  ',
              prefixColor: AppColors.text,
              text: line,
            ));
          }

        case BlogBlockType.bulletPoint:
          counter = 0;
          for (final line in _lines(text)) {
            widgets.add(_listRow(
              prefix: '•  ',
              prefixColor: ColorPick.primary,
              text: line,
            ));
          }
      }
    }
    return widgets;
  }

  // Splits block text into non-empty trimmed lines.
  List<String> _lines(String text) => text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  Widget _listRow({
    required String prefix,
    required Color prefixColor,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prefix,
              style: StyleText.fontSize13Weight500.copyWith(
                  color: prefixColor, fontWeight: FontWeight.w600)),
          Expanded(
            child: MarkdownBody(
              data:       text,
              selectable: true,
              styleSheet: _mdStyle(),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR image loader — auto-detects SVG vs raster (PNG/JPG/WebP)
// Works on Flutter Web, bypasses CORS for Firebase Storage
// ══════════════════════════════════════════════════════════════════════════════
