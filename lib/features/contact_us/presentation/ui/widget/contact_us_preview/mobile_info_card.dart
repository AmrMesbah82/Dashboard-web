part of '../../pages/contact_us_preview.dart';

class _MobileInfoCard extends StatelessWidget {
  final ContactUsCmsModel data;

  const _MobileInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.subDescription.en,
            style: StyleText.fontSize12Weight600.copyWith(
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 22),

          Text('Email', style: StyleText.fontSize15Weight600.copyWith(color: ColorPick.primary)),
          const SizedBox(height: 4),
          Text(data.email, style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
          const SizedBox(height: 20),

          Text('Follow Us', style: StyleText.fontSize15Weight600.copyWith(color: ColorPick.primary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.socialIcons.where((s) => s.iconUrl.isNotEmpty).map((s) {
              return _SocialIconRaw(iconUrl: s.iconUrl);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Form Placeholder ─────────────────────────────────────────────────────────
