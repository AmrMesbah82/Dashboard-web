part of '../../pages/about_us_preview.dart';

class _ValuesGrid extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl, compact;
  final Color primary, secondary;
  const _ValuesGrid({
    required this.values, required this.isRtl,
    required this.primary, required this.secondary, required this.compact,
  });
  @override State<_ValuesGrid> createState() => _ValuesGridState();
}
class _ValuesGridState extends State<_ValuesGrid> {
  int _sel = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _kSurface, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text('No additional values.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                color: Colors.grey[500]))),
      );

    final int idx = _sel.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    final double cardW  = widget.compact ? 88 : 100;
    final double iconSz = widget.compact ? 18 : 22;
    final double fontSz = widget.compact ? 8  : 9;
    final double pad    = widget.compact ? 9  : 10;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            widget.primary.withOpacity(.06),
            widget.primary.withOpacity(.25),
            widget.primary.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 8,
                children: List.generate(widget.values.length, (i) {
                  final v = widget.values[i];
                  return _ValueCard(
                    title: _ab(v.title, widget.isRtl),
                    iconUrl: v.iconUrl, isSelected: i == idx,
                    primary: widget.primary, width: cardW,
                    iconSize: iconSz, fontSize: fontSz, padding: pad,
                    onTap: () => setState(() => _sel = i),
                  );
                })),
            const SizedBox(height: 12),
            _ValueDetail(value: selected, isRtl: widget.isRtl,
                primary: widget.primary, secondary: widget.secondary),
          ]),
    );
  }
}

// ── Value card ────────────────────────────────────────────────────────────────
