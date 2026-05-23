part of '../../pages/contact_us_preview.dart';

class _OfficeCard extends StatelessWidget {
  final ContactOfficeLocation location;

  const _OfficeCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 267.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (location.iconUrl.isNotEmpty)
            Image.network(
              location.iconUrl,
              width: 100.w,
              height: 100.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.location_on, size: 100.w, color: ColorPick.primary),
            )
          else
            Icon(Icons.location_on, size: 100.w, color: ColorPick.primary),
          SizedBox(height: 16.h),

          Text(
            location.locationName.en,
            style: StyleText.fontSize16Weight700.copyWith(color: ColorPick.primary),
          ),
          SizedBox(height: 6.h),

          if (location.text1.en.isNotEmpty)
            Text(
              location.text1.en,
              style: StyleText.fontSize13Weight400.copyWith(color: Colors.black45),
            ),
          if (location.text2.en.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
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

// ─── Office Card (Mobile) ─────────────────────────────────────────────────────
