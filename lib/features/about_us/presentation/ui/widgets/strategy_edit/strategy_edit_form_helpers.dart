// ******************* FILE INFO *******************
// File Name: strategy_edit_form_helpers.dart
// Description: Device upload row widget for Strategy edit
// Ported from beauty_admin (device_upload_row.dart)

part of '../../pages/strategy_page/strategy_edit.dart';

// ignore: unused_element
class _DeviceUploadRow extends StatelessWidget {
  final String title;
  final bool hasImage;
  final String? errorText;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  const _DeviceUploadRow({
    required this.title,
    required this.hasImage,
    this.errorText,
    required this.onUpload,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: hasImage ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasImage) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Uploaded',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            customButtonWithImage(
              title: hasImage ? 'Replace SVG' : 'Upload SVG',
              function: onUpload,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white
              ),
              height: 38.h,
              space: 8.sp,
              width: 160.w,
              radius: 8.r,
              color: ColorPick.primary,
              image: "",
              widthImage: 16.w,
              heightImage: 16.h,
              colorBorder: Colors.transparent,
            ),
            if (hasImage && onRemove != null) ...[
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: const Color(0xFFD32F2F), size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ],
      ],
    );
  }
}
