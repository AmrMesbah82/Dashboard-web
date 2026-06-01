part of '../../pages/careers_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth, fakeHeight;
  final CareersCmsModel data;
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


                // ── Hero / Overview section ────────────────────────────
                _buildOverviewSection(),

                // ── Statistics section ─────────────────────────────────
                if (data.statistics.isNotEmpty) _buildStatisticsSection(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Overview (hero) ────────────────────────────────────────────────────────
  Widget _buildOverviewSection() {
    final desc   = isAr
        ? data.overview.description.ar
        : data.overview.description.en;
    final btnLbl = isAr
        ? data.overview.actionButtonLabel.ar
        : data.overview.actionButtonLabel.en;

    final double titleFz   = _isDesktop ? 28 : (_isMobView ? 18 : 22);
    final double descFz    = _isDesktop ? 13 : (_isMobView ? 10 : 12);
    final double taglineFz = _isDesktop ? 12 : (_isMobView ? 10 : 11);
    final double btnFz     = _isDesktop ? 13 : (_isMobView ? 10 : 11);

    // Hero headline — either from CMS or Figma static fallback
    final String headline = isAr
        ? 'انضم إلى فريق يقود الابتكار ويقدّرك'
        : 'Join a Team That Drives Innovation and Values You';

    // Tagline
    final String tagline = isAr
        ? 'انضم إلى بيانات — حيث يبدأ مستقبلك'
        : 'Join Bayanatz—where your future begins';

    return Container(
      width:   double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 36),
      color:   _kBodyBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero headline
          Text(
            headline,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   titleFz,
              fontWeight: FontWeight.w700,
              color:      const Color(0xFF1A1A1A),
              height:     1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Bullet 1
          _BulletText(
            text: isAr
                ? 'في بيانات، نحن في طليعة الابتكار — نتحدى الوضع الراهن باستمرار. بانضمامك إلينا، ستساهم في مشاريع رائدة ذات أثر حقيقي.'
                : 'At Bayanatz, we are at the forefront of innovation—constantly pushing boundaries and challenging the status quo. By joining us, you\'ll contribute to groundbreaking projects that create meaningful impact across industries and society.',
            fontSize: descFz,
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 1
          Text(
            isAr
                ? 'نفخر ببيئة ديناميكية وشاملة تعترف بمواهبك وترعاها. ثقافتنا تعزز النمو المستمر والتطوير الشخصي والتميز المهني.'
                : 'We take pride in fostering a dynamic and inclusive environment where your talents are not only recognized, but also nurtured. Our culture promotes continuous growth, personal development, and professional excellence.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 2
          Text(
            isAr
                ? 'نؤمن بالتوازن. لهذا نولي أهمية لرفاهية الموظف، ونوفر بيئة عمل داعمة ومرنة تمكّنك من الازدهار مهنياً وشخصياً.'
                : 'We believe in balance. That\'s why we prioritize employee well-being, offering a supportive and flexible work environment that empowers you to thrive—both professionally and personally.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
          SizedBox(height: descFz * 0.8),

          // Bullet 2
          _BulletText(
            text: isAr
                ? 'التنوع والشمول في صميم كل ما نفعله. نحتفل بوجهات النظر والخلفيات والتجارب الفريدة لكل عضو في الفريق.'
                : 'At Bayanatz, diversity and inclusion are at the heart of everything we do. We celebrate the unique perspectives, backgrounds, and experiences each team member brings.',
            fontSize: descFz,
          ),
          SizedBox(height: descFz * 0.8),

          // Paragraph 3
          Text(
            isAr
                ? 'كن جزءاً من بيئة عمل مبنية على الإبداع والتعاون والابتكار الجريء.'
                : 'Be a part of a workplace built on creativity, collaboration, and bold innovation.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   descFz,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),

          // Description from CMS (if any)
          if (desc.isNotEmpty) ...[
            SizedBox(height: descFz * 0.8),
            Text(
              desc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   descFz,
                height:     1.7,
                color:      const Color(0xFF444444),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Tagline + CTA row
          if (_isMobView) ...[
            Text(
              tagline,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   taglineFz,
                color:      const Color(0xFF555555),
                fontStyle:  FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            if (btnLbl.isNotEmpty) _buildActionButton(btnLbl, btnFz),
          ] else
            Row(
              children: [
                Text(
                  tagline,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   taglineFz,
                    color:      const Color(0xFF555555),
                    fontStyle:  FontStyle.italic,
                  ),
                ),
                const Spacer(),
                if (btnLbl.isNotEmpty) _buildActionButton(btnLbl, btnFz),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color:        _kGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize:   fontSize,
          fontWeight: FontWeight.w600,
          color:      Colors.white,
        ),
      ),
    );
  }

  // ── Statistics section ─────────────────────────────────────────────────────
  Widget _buildStatisticsSection() {
    return Container(
      width:   double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 24),
      color:   Colors.white,
      child: _isMobView
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.statistics
            .map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _StatCard(stat: s, isAr: isAr, compact: true),
        ))
            .toList(),
      )
          : Wrap(
        spacing:    14,
        runSpacing: 14,
        children: data.statistics
            .map((s) => SizedBox(
          width: _isDesktop ? 220 : 180,
          child: _StatCard(stat: s, isAr: isAr, compact: false),
        ))
            .toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SITE NAVBAR  (mirrors live Bayanatz careers page header)
// ═══════════════════════════════════════════════════════════════════════════════
