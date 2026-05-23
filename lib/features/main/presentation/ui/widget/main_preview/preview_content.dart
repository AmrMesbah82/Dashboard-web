part of '../../pages/main_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final bool   isRtl;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
      ),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SizedBox(
          width:  fakeWidth,
          height: fakeHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppNavbar(currentRoute: '/'),
              const Expanded(
                child: ColoredBox(
                  color: Colors.transparent,
                  child: SizedBox.expand(),
                ),
              ),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile phone shell ────────────────────────────────────────────────────────
