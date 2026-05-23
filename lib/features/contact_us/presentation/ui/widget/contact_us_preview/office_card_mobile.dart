part of '../../pages/contact_us_preview.dart';

class _OfficeCardMobile extends StatelessWidget {
  final ContactOfficeLocation location;

  const _OfficeCardMobile({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (location.iconUrl.isNotEmpty)
            Image.network(
              location.iconUrl,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.location_on, size: 120, color: ColorPick.primary),
            )
          else
            const Icon(Icons.location_on, size: 120, color: ColorPick.primary),
          const SizedBox(height: 16),

          Text(
            location.locationName.en,
            style: StyleText.fontSize16Weight700.copyWith(color: ColorPick.primary),
          ),
          const SizedBox(height: 6),

          if (location.text1.en.isNotEmpty)
            Text(
              location.text1.en,
              style: StyleText.fontSize13Weight400.copyWith(color: Colors.black45),
            ),
          if (location.text2.en.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                location.text2.en,
                style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Social Icons ─────────────────────────────────────────────────────────────
