part of '../../pages/home_preview.dart';

extension _HomePreviewCards on _HomePreviewPageMasterState {
  Widget _buildTabletCards(HomePageModel data, bool isAr) {
    const Color sectionBg = Color(0xFFF2F6EF);
    final Color primary = context.primaryBrandColor;
    final double cardW = 130.w;
    final double imageH = 150.h;
    final double textH = 110.h;
    final sec = data.sections;

    String secDesc(int i) => i < sec.length
        ? (isAr ? (sec[i].description.ar.isNotEmpty ? sec[i].description.ar : sec[i].description.en) : sec[i].description.en)
        : '';

    return Container(
      color: sectionBg,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: cardW, child: Align(alignment: Alignment.centerRight,
                    child: _buildCircleIcon(sec.isNotEmpty ? sec[0].iconUrl : ''))),
                SizedBox(height: 6.h),
                _buildSectionImage(sec.isNotEmpty ? sec[0].imageUrl : '', cardW, imageH),
              ]),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(height: 36.w + 6.h),
                ...data.navButtons.take(2).toList().asMap().entries.map((e) {
                  final btn = e.value;
                  final label = isAr ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en) : btn.name.en;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                      child: Center(child: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: primary))),
                    ),
                  );
                }),
              ])),
              SizedBox(width: 10.w),
              Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: cardW, child: Align(alignment: Alignment.centerLeft,
                    child: _buildCircleIcon(sec.length > 3 ? sec[3].iconUrl : ''))),
                SizedBox(height: 6.h),
                _buildSectionImage(sec.length > 3 ? sec[3].imageUrl : '', cardW, imageH),
              ]),
            ],
          ),
          SizedBox(height: 10.h),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildGreenCard(width: cardW, height: textH, text: secDesc(0), color: primary, fontSize: 11.sp, isRtl: isAr),
            SizedBox(width: 10.w),
            Expanded(child: Column(children: [
              _buildCircleIcon(sec.length > 1 ? sec[1].iconUrl : ''),
              SizedBox(height: 6.h),
              _buildSectionImage(sec.length > 1 ? sec[1].imageUrl : '', double.infinity, imageH * 0.6),
              SizedBox(height: 6.h),
              _buildGreenCard(height: textH, text: secDesc(1), color: primary, fontSize: 11.sp, isRtl: isAr),
            ])),
            SizedBox(width: 10.w),
            Expanded(child: Column(children: [
              _buildCircleIcon(sec.length > 2 ? sec[2].iconUrl : ''),
              SizedBox(height: 6.h),
              _buildSectionImage(sec.length > 2 ? sec[2].imageUrl : '', double.infinity, imageH * 0.6),
              SizedBox(height: 6.h),
              _buildGreenCard(height: textH, text: secDesc(2), color: primary, fontSize: 11.sp, isRtl: isAr),
            ])),
            SizedBox(width: 10.w),
            _buildGreenCard(width: cardW, height: textH, text: secDesc(3), color: primary, fontSize: 11.sp, isRtl: isAr),
          ]),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildMobileCards(HomePageModel data, bool isAr) {
    const Color sectionBg = Color(0xFFF2F6EF);
    final Color primary = context.primaryBrandColor;
    final sec = data.sections;

    String secDesc(int i) => i < sec.length
        ? (isAr ? (sec[i].description.ar.isNotEmpty ? sec[i].description.ar : sec[i].description.en) : sec[i].description.en)
        : '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sw = constraints.maxWidth;
        final double hPad = 16.w;
        final double gap = 8.w;
        final double col = (sw - hPad * 2 - gap) / 2;

        final double rowAH = col * 1.1;
        final double rowBH = col * 1.05;
        final double rowCH = col * 0.72;
        final double rowDH = col * 0.55;

        Widget imageBox(double w, double h, String url) => _buildSectionImage(url, w, h, radius: 12.r);

        Widget green(double w, double h, String text, Color color) => Container(
          width: w, height: h,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.r)),
          child: Text(text,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
          ),
        );

        Widget solidGreen(double w, double h) => Container(
          width: w, height: h,
          decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12.r)),
        );

        return Container(
          color: sectionBg,
          padding: EdgeInsets.fromLTRB(hPad, 0.h, hPad, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...data.navButtons.take(2).toList().asMap().entries.map((e) {
                final btn = e.value;
                final label = isAr ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en) : btn.name.en;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(child: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: primary))),
                  ),
                );
              }),
              SizedBox(height: 6.h),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                imageBox(col, rowAH, sec.isNotEmpty ? sec[0].imageUrl : ''),
                SizedBox(width: gap),
                green(col, rowAH, secDesc(0), primary),
              ]),
              SizedBox(height: gap),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                green(col, rowBH, secDesc(1), primary),
                SizedBox(width: gap),
                imageBox(col, rowBH, sec.length > 1 ? sec[1].imageUrl : ''),
              ]),
              SizedBox(height: gap),
              Row(children: [
                imageBox(col, rowCH, sec.length > 2 ? sec[2].imageUrl : ''),
                SizedBox(width: gap),
                solidGreen(col, rowCH),
              ]),
              SizedBox(height: gap),
              green(sw - hPad * 2, rowDH, secDesc(2), primary),
            ],
          ),
        );
      },
    );
  }
}
