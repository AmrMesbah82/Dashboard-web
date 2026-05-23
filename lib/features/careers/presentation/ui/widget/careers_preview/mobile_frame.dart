part of '../../pages/careers_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final CareersCmsModel data;
  final bool isAr;
  const _MobileFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    return Center(
      child: Column(
        children: [
          _ViewBar(width: displayW + 4),
          Container(
            width:  displayW + 4,
            height: displayH + 24 + 12 + 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              border: Border.all(color: ColorPick.white, width: 2),
              color:  Colors.white,
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // top notch bar
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color:        ColorPick.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
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
                          data:     data,
                          isAr:     isAr,
                          isMobile: true,
                        ),
                      ),
                    ),
                  ),
                ),
                // bottom home bar
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 4,
                      decoration: BoxDecoration(
                        color:        ColorPick.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GREEN "VIEW" COLLAPSIBLE BAR  (Figma header above browser frame)
// ═══════════════════════════════════════════════════════════════════════════════
