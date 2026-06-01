part of '../../pages/our_teams_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW =
    (containerWidth * 0.35).clamp(200.0, 280.0);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    return Center(
      child: Container(
        width:  displayW + 4,
        height: displayH + 24 + 12 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color:        Colors.white,
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset:     const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Notch bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width:  displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                      color:        const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            SizedBox(
              width:  displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth:  _kMobileW,
                  maxHeight: _kMobileH,
                  child: Transform.scale(
                    scale:     scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth:  _kMobileW,
                      fakeHeight: _kMobileH,
                      data:       data,
                      isAr:       isAr,
                      isMobile:   true,
                    ),
                  ),
                ),
              ),
            ),
            // Home indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width:  displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                      color:        const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT — the scaled "Meet Our Teams" page rendered inside the frame
// ═══════════════════════════════════════════════════════════════════════════════
