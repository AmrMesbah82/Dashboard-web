part of '../../pages/our_teams_preview.dart';

class _RowSection extends StatelessWidget {
  final int           rowIndex;
  final List<OurTeamItem> items;
  final int           totalPerRow;
  final bool          isAr, isMobile;

  const _RowSection({
    required this.rowIndex,
    required this.items,
    required this.totalPerRow,
    required this.isAr,
    required this.isMobile,
  });

  static const Color _primary   = Color(0xFF008037);
  static const Color _labelText = Color(0xFF333333);

  String get _rowLabel {
    const labels = [
      'First Row', 'Second Row', 'Third Row', 'Fourth Row',
      'Fifth Row', 'Sixth Row', 'Seventh Row',
    ];
    return rowIndex < labels.length
        ? labels[rowIndex]
        : '${rowIndex + 1}th Row';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row label bar ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.drag_handle_rounded,
                  color: _labelText, size: 16),
              const SizedBox(width: 6),
              Text(
                _rowLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      _labelText,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} Card',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   12,
                    color:      _labelText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Cards ──────────────────────────────────────────────────────
        isMobile
            ? Column(
          children: items
              .map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TeamCard(item: item, isAr: isAr),
          ))
              .toList(),
        )
            : IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...items.asMap().entries.expand((e) {
                final widgets = <Widget>[];
                if (e.key > 0)
                  widgets.add(const SizedBox(width: 14));
                widgets.add(
                  Expanded(
                      child: _TeamCard(
                          item: e.value, isAr: isAr)),
                );
                return widgets;
              }),
              // Fill remaining empty slots
              ...List.generate(
                totalPerRow - items.length,
                    (_) => const Expanded(child: SizedBox()),
              ).expand((w) => [const SizedBox(width: 14), w]),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEAM CARD  — matches Figma card design
// ═══════════════════════════════════════════════════════════════════════════════
