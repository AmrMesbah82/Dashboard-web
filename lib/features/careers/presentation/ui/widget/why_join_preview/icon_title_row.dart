part of '../../pages/why_join_preview.dart';

class _IconTitleRow extends StatelessWidget {
  final String iconUrl;
  final String svgUrl;
  final String title;
  final double iconSz;
  final bool   isAr;

  const _IconTitleRow({
    required this.iconUrl,
    required this.svgUrl,
    required this.title,
    required this.iconSz,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final String displayUrl = iconUrl.isNotEmpty ? iconUrl : svgUrl;

    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize:  MainAxisSize.min,
      children: [
        Container(
          width:  iconSz + 8,
          height: iconSz + 8,
          decoration: const BoxDecoration(
            color: Color(0xFF008037),
            shape: BoxShape.circle,
          ),
          child: displayUrl.isNotEmpty
              ? ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.network(
                displayUrl,
                fit:         BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
                placeholderBuilder: (_) => const SizedBox(),
              ),
            ),
          )
              : Icon(Icons.work_outline,
              color: Colors.white, size: iconSz * 0.6),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w600,
              color:      Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
