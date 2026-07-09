part of '../../pages/why_join_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth, fakeHeight;
  final CareersSectionModel? data;
  final bool isAr, isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.data,
    required this.isAr,
    this.isMobile = false,
  });

  bool get _isDesktop => fakeWidth >= _kDesktopW;
  bool get _isMobView => isMobile || fakeWidth < 600;
  double get _hPad    => _isDesktop ? 48 : (_isMobView ? 16 : 24);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(fakeWidth, fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Material(
          color: _kBodyBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Section content ──────────────────────────────────────
                if (data == null || data!.items.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'No items to preview.',
                        style: TextStyle(
                          fontSize: 14,
                          color:    const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  )
                else
                  _buildItems(data!),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(CareersSectionModel data) {
    final double svgW   = _isMobView ? 160 : (_isDesktop ? 220 : 160);
    final double svgH   = _isMobView ? 140 : (_isDesktop ? 180 : 140);
    final double textFz = _isMobView ? 11  : (_isDesktop ? 13  : 12);
    final double gap    = _isMobView ? 12  : (_isDesktop ? 40  : 20);
    final double rowGap = _isMobView ? 24  : (_isDesktop ? 40  : 32);

    return Container(
      color: Color(0xFFF1F2ED),
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.items.asMap().entries.map((entry) {
          final int   i       = entry.key;
          final item          = entry.value;
          final bool  imgLeft = i.isOdd;

          final String desc = isAr
              ? (item.description.ar.isNotEmpty
              ? item.description.ar
              : item.description.en)
              : item.description.en;

          // ── Mobile: stacked ────────────────────────────────────────────
          if (_isMobView) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _svgWidget(item.svgUrl, svgW, svgH, centered: true),
                  const SizedBox(height: 14),
                  Text(
                    desc,
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize:   textFz,
                      fontWeight: FontWeight.w400,
                      color:      const Color(0xFF555555),
                      height:     1.75,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Desktop / Tablet: alternating left / right ─────────────────
          final Widget textWidget = Expanded(
            flex: 5,
            child: Text(
              desc,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize:   textFz,
                fontWeight: FontWeight.w400,
                color:      const Color(0xFF555555),
                height:     1.75,
              ),
            ),
          );

          final Widget imageWidget = Expanded(
            flex: 4,
            child: _svgWidget(item.svgUrl, svgW, svgH),
          );

          // even (0,2,4…) → text | SVG   odd (1,3,5…) → SVG | text
          final List<Widget> row = imgLeft
              ? [imageWidget, SizedBox(width: gap), textWidget]
              : [textWidget,  SizedBox(width: gap), imageWidget];

          return Padding(
            padding: EdgeInsets.only(bottom: rowGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: row,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _svgWidget(String url, double w, double h,
      {bool centered = false}) {
    final Widget child = url.isNotEmpty
        ? NetworkImageView(
      url:    url,
      width:  w,
      height: h,
      fit:    BoxFit.contain,
    )
        : Container(
      width:  w,
      height: h,
      decoration: BoxDecoration(
        color:        const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
      ),
    );

    return centered ? Center(child: child) : child;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON + TITLE ROW  (utility — kept for backward compat / other callers)
// ═══════════════════════════════════════════════════════════════════════════════
