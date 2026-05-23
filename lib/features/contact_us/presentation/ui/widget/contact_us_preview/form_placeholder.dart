part of '../../pages/contact_us_preview.dart';

class _FormPlaceholder extends StatelessWidget {
  final bool isMobile;

  const _FormPlaceholder({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final double pad = isMobile ? 20 : 25.r;
    final double rad = isMobile ? 14 : 15.r;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rad),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GET IN TOUCH',
            style: StyleText.fontSize22Weight700.copyWith(
              fontSize: isMobile ? 22 : 26.sp,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: isMobile ? 16.0 : 20.h),

          Text('This is a preview. Form inputs are not functional.',
              style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
          SizedBox(height: isMobile ? 16.0 : 20.h),

          _placeholderField('Full Name'),
          _placeholderField('Email'),
          _placeholderField('Phone Number'),
          _placeholderField('Subject'),
          _placeholderFieldLarge('Message'),

          SizedBox(height: 8.h),

          SizedBox(
            width: double.infinity,
            height: isMobile ? 52.0 : 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPick.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Send',
                style: StyleText.fontSize16Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _placeholderFieldLarge(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
        const SizedBox(height: 6),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Office Card (Desktop) ────────────────────────────────────────────────────
