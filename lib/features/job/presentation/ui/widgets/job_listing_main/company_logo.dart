part of '../../pages/job_listing_main.dart';

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;
  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final double sz = 30.sp;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: logoUrl.isNotEmpty
            ? NetworkImageView(
          url: logoUrl,
          width: sz,
          height: sz,
          fit: BoxFit.scaleDown,
          placeholder: _fallbackIcon(sz),
        )
            : _fallbackIcon(sz),
      ),
    );
  }

  Widget _fallbackIcon(double sz) {
    return Container(
      width: sz,
      height: sz,
      color: const Color(0xFFF0F0F0),
      child: Icon(Icons.business_rounded, size: 20.sp, color: const Color(0xFFBBBBBB)),
    );
  }
}
