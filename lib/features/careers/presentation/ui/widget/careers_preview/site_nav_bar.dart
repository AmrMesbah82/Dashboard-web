part of '../../pages/careers_preview.dart';

class _SiteNavBar extends StatelessWidget {
  final bool isMobile, isAr;
  const _SiteNavBar({required this.isMobile, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final links = isAr
        ? ['الرئيسية', 'الوظائف', 'الطلبات', 'الاستفسارات']
        : ['Home', 'Job Listing', 'Applications', 'Inquiries'];
    final ctaLabel = isAr ? 'صفحة الويب' : 'Web Page';

    return Container(
      width:  double.infinity,
      height: isMobile ? 44 : 52,
      color:  Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
      child: Row(
        children: [
          // Logo
          Container(
            width:  isMobile ? 28 : 36,
            height: isMobile ? 28 : 36,
            decoration: BoxDecoration(
              color:        _kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   16,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            ...links.map(
                  (l) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  l,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   13,
                    color:      Color(0xFF333333),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // CTA button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 14,
              vertical:   isMobile ? 4  : 6,
            ),
            decoration: BoxDecoration(
              color:        _kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ctaLabel,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
                color:      Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BULLET TEXT helper
// ═══════════════════════════════════════════════════════════════════════════════
