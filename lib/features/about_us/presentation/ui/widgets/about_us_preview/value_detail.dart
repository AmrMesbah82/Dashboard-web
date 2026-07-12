part of '../../pages/about_us_preview.dart';

class _ValueDetail extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primary, secondary;
  const _ValueDetail({
    required this.value, required this.isRtl,
    required this.primary, required this.secondary,
  });
  @override
  Widget build(BuildContext context) {
    final String title     = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: secondary, borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: value.iconUrl.isNotEmpty
                ? _netImg(url: value.iconUrl, width: 30, height: 30,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn))
                : Icon(Icons.star_outline, size: 20, color: primary),
          ),
        ),
        const SizedBox(height: 10),
        if (title.isNotEmpty) ...[
          Text(title,
              style: StyleText.fontSize14Weight700.copyWith(
                  fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
        ],
        if (shortDesc.isNotEmpty)
          Text(shortDesc,
              style: StyleText.fontSize12Weight500.copyWith(
                  fontSize: 12,
                  color: AppColors.secondaryBlack,
                  height: 1.6)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
