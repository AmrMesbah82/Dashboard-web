part of '../../pages/digital_services/services_digital_edit.dart';

class _JourneyMiniCard extends StatelessWidget {
  final JourneyItemModel item;
  const _JourneyMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color:        const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border:       Border.all(color: const Color(0xFFDDE8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width:  28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color:        const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: NetworkImageView(
                url:    item.iconUrl,
                width:  18.w,
                height: 18.w,
                fit:    BoxFit.contain,
              ),
            )
                : Icon(Icons.miscellaneous_services_outlined,
                size: 16.sp, color: ColorPick.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   11.sp,
                fontWeight: FontWeight.w600,
                color:      const Color(0xFF1A1A1A)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            item.description.en.isNotEmpty
                ? item.description.en
                : 'Description',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   10.sp,
                color:      AppColors.secondaryBlack,
                height:     1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
