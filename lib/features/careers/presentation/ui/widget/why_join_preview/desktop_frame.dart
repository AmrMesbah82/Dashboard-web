part of '../../pages/why_join_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final CareersSectionModel? data;
  final bool isAr;
  const _DesktopFrame(
      {required this.containerWidth, required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width: containerWidth,
      // color: ColorPick.white,
      child: Column(
        children: [
          const _ViewBar(),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
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
                          width: _kDesktopW,
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
          ),
        ],
      ),
    );
  }
}

// ── Tablet ────────────────────────────────────────────────────────────────────
