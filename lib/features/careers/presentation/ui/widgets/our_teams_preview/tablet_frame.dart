part of '../../pages/our_teams_preview.dart';

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _TabletFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final double displayW =
    (containerWidth * 0.55).clamp(280.0, 500.0);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;
    return Center(
      child: Container(
        width:           displayW + 4,
        height:          displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
            const _BrowserChrome(compact: true),
            SizedBox(
              width:  displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth:  _kTabletW,
                  maxHeight: _kTabletH,
                  child: Transform.scale(
                    scale:     scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth:  _kTabletW,
                      fakeHeight: _kTabletH,
                      data: data,
                      isAr: isAr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
