part of '../../pages/contact_us_preview.dart';

class _SocialIconRaw extends StatelessWidget {
  final String iconUrl;

  const _SocialIconRaw({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: ColorPick.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.network(
          iconUrl,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.link, size: 18, color: ColorPick.primary),
        ),
      ),
    );
  }
}
