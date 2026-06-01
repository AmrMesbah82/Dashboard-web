part of '../../pages/our_teams_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OurTeamsModel? data;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth,
        required this.data,
        required this.isAr});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width:  containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset:     const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _BrowserChrome(),
          SizedBox(
            width:  containerWidth,
            height: frameH,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth:  _kDesktopW,
                maxHeight: _kDesktopH,
                child: Transform.scale(
                  scale:     scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width:  _kDesktopW,
                    height: _kDesktopH,
                    child: _PreviewContent(
                      fakeWidth:  _kDesktopW,
                      fakeHeight: _kDesktopH,
                      data: data,
                      isAr: isAr,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
