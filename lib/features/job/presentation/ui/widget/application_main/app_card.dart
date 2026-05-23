part of '../../pages/application_main.dart';

class _AppCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  const _AppCard({required this.app, this.onTap, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final dateStr = app.applicationDate != null
        ? '${app.applicationDate!.day} ${_month(app.applicationDate!.month)} ${app.applicationDate!.year}'
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tags row ──
            Row(
              children: [
                if (app.tag.isNotEmpty) _tag(app.tag, ColorPick.primary),
                SizedBox(width: 6.w),
                _tag(app.status.label, ColorPick.primary),
                const Spacer(),
                GestureDetector(
                  onTap: onDownload,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: ColorPick.primary,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('Download Files', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Job Title (was Department) ──
            Row(
              children: [
                BlocBuilder<HomeCmsCubit, HomeCmsState>(
                  builder: (context, cmsState) {
                    final String logoUrl = switch (cmsState) {
                      HomeCmsLoaded(:final data) => data.branding.logoUrl,
                      HomeCmsSaved(:final data)  => data.branding.logoUrl,
                      _                          => '',
                    };

                    if (logoUrl.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: SvgPicture.network(
                          logoUrl,
                          width: 18.sp,
                          height: 18.sp,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => Icon(
                            Icons.work_outline_rounded,
                            size: 18.sp,
                            color: ColorPick.primary,
                          ),
                        ),
                      );
                    }

                    return Icon(
                      Icons.work_outline_rounded,
                      size: 18.sp,
                      color: ColorPick.primary,
                    );
                  },
                ),                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle.isEmpty ? 'Untitled Job' : app.jobTitle,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Job Title', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Info rows ──
            _infoRow('Candidate:', app.fullName),
            SizedBox(height: 4.h),
            _infoRow('Email:', app.email),
            SizedBox(height: 4.h),
            _infoRow('Phone Number:', '${app.countryCode}${app.phone}'),
            SizedBox(height: 4.h),
            _infoRow('Application Date:', dateStr),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: ColorPick.primary)),
        SizedBox(width: 4.w),
        Expanded(child: Text(value, style: TextStyle(fontSize: 11.sp, color: AppColors.text), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}
