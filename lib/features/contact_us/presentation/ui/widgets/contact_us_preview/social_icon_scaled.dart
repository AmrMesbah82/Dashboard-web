part of '../../pages/contact_us_preview.dart';

class _SocialIconScaled extends StatelessWidget {
  final String iconUrl;

  const _SocialIconScaled({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        border: Border.all(color: ColorPick.primary),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Image.network(
          iconUrl,
          width: 18.w,
          height: 18.h,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.link, size: 18.w, color: ColorPick.primary),
        ),
      ),
    );
  }
}
