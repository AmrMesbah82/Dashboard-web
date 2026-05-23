part of '../../pages/contact_us_preview.dart';

class _InfoCard extends StatelessWidget {
  final ContactUsCmsModel data;

  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.subDescription.en,
            style: StyleText.fontSize18Weight500.copyWith(
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 32.h),

          Text('Email', style: StyleText.fontSize16Weight600.copyWith(color: ColorPick.primary)),
          SizedBox(height: 6.h),
          Text(data.email, style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
          SizedBox(height: 28.h),

          Text('Follow Us', style: StyleText.fontSize16Weight600.copyWith(color: ColorPick.primary)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: data.socialIcons.where((s) => s.iconUrl.isNotEmpty).map((s) {
              return _SocialIconScaled(iconUrl: s.iconUrl);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card (Mobile) ───────────────────────────────────────────────────────
