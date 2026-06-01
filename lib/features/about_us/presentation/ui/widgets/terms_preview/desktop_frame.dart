part of '../../pages/terms_page/terms_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final bool isAr;
  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.imageUploads,
    required this.isAr,
  });
  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;
    return Container(
      width: containerWidth,
      height: frameH + 28,
      color: _AC.back,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _TermsPreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        imageUploads: imageUploads,
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
    );
  }
}
