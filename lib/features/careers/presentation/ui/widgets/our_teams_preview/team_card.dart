part of '../../pages/our_teams_preview.dart';

class _TeamCard extends StatelessWidget {
  final OurTeamItem item;
  final bool isAr;
  const _TeamCard({required this.item, required this.isAr});

  static const Color _primary  = Color(0xFF008037);
  static const Color _hintText = Color(0xFFAAAAAA);

  String _t(BilingualText b) {
    final v = isAr ? b.ar : b.en;
    return v.isNotEmpty ? v : b.en;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset:     const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Remove / drag icon row ──────────────────────────────────
          Row(
            children: [
              Container(
                width:  24,
                height: 24,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.remove,
                    color: Colors.white, size: 14),
              ),
              const Spacer(),
              const Icon(Icons.drag_indicator_rounded,
                  color: _hintText, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // ── Icon circle ─────────────────────────────────────────────
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color: item.iconUrl.isNotEmpty
                  ? Colors.white
                  : const Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _netImg(
                    url:    item.iconUrl,
                    width:  28,
                    height: 28,
                    fit:    BoxFit.contain),
              ),
            )
                : const Center(
                child: Icon(Icons.groups_rounded,
                    color: _primary, size: 26)),
          ),
          const SizedBox(height: 12),

          // ── Title badge ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:        _primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _t(item.title).isEmpty
                    ? 'Strategy & Planning Team'
                    : _t(item.title),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Description ─────────────────────────────────────────────
          Text(
            _t(item.description).isEmpty
                ? 'Conduct market analysis, establish KPIs, and set '
                'timelines for deliverables. Ensure every project '
                'is mapped to measurable business outcomes.'
                : _t(item.description),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize:   11,
              color:      Colors.black54,
              height:     1.5,
            ),
            maxLines:  5,
            overflow:  TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // ── Deliverables ─────────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isAr ? 'المخرجات:' : 'Deliverables:',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize:   11,
                fontWeight: FontWeight.w700,
                color:      Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing:    4,
            runSpacing: 4,
            children: item.deliverableItems.isNotEmpty
                ? item.deliverableItems
                .map((d) => _chip(_t(d.label), inactive: false))
                .toList()
                : List.generate(
                8, (_) => _chip('Inactive', inactive: true)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {required bool inactive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: inactive
            ? const Color(0xFFF5F5F5)
            : _primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.isEmpty ? 'Inactive' : text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize:   10,
          fontWeight: FontWeight.w700,
          color:      inactive ? _hintText : _primary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
