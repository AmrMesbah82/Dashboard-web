part of '../../pages/careers_preview.dart';

class _StatCard extends StatelessWidget {
  final CareerStatItem stat;
  final bool isAr, compact;

  const _StatCard({
    required this.stat,
    required this.isAr,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final String title     = isAr ? stat.title.ar     : stat.title.en;
    final String shortDesc = isAr
        ? stat.shortDescription.ar
        : stat.shortDescription.en;

    final double titleFz = compact ? 20 : 24;
    final double descFz  = compact ? 10 : 11;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        _kSurface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: _kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat number / title (e.g. "82%", "1,200+", "6")
          if (title.isNotEmpty)
            Text(
              title,
              style: StyleText.fontSize22Weight700.copyWith(
                fontSize: titleFz,
                color:    _kGreen,
                height:   1.1,
              ),
            ),
          if (shortDesc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              shortDesc,
              style: StyleText.fontSize11Weight400.copyWith(
                fontSize: descFz,
                height:   1.55,
                color:    const Color(0xFF555555),
              ),
            ),
          ],
          // Fallback icon if no image
          if (title.isEmpty && stat.iconUrl.isEmpty)
            Icon(Icons.bar_chart, size: compact ? 20 : 26, color: _kGreen),
          if (title.isEmpty && stat.iconUrl.isNotEmpty)
            _netImg(
              url:    stat.iconUrl,
              width:  compact ? 28 : 36,
              height: compact ? 28 : 36,
              fit:    BoxFit.contain,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
