part of '../../pages/job_listing_main.dart';

class _JobCard extends StatelessWidget {
  final JobPostModel job;
  final String logoUrl;
  final VoidCallback? onTap;

  const _JobCard({required this.job, required this.logoUrl, this.onTap});

  Color get _statusTextColor {
    switch (job.status) {
      case JobStatus.active:    return const Color(0xFF008037);
      case JobStatus.inactive:  return const Color(0xFFFF9800);
      case JobStatus.ended:     return const Color(0xFFD32F2F);
      case JobStatus.scheduled: return const Color(0xFFFF9800);
      case JobStatus.drafted:   return const Color(0xFF757575);
      case JobStatus.removed:   return const Color(0xFFD32F2F);
    }
  }

  Color get _bottomBarColor {
    switch (job.status) {
      case JobStatus.active:    return const Color(0xFF008037);
      case JobStatus.ended:     return const Color(0xFFD32F2F);
      case JobStatus.removed:   return const Color(0xFFD32F2F);
      case JobStatus.scheduled: return const Color(0xFF008037);
      case JobStatus.drafted:   return const Color(0xFF008037);
      case JobStatus.inactive:  return const Color(0xFF008037);
    }
  }

  String get _bottomSvg {
    switch (job.status) {
      case JobStatus.active:    return _Svg.posted;
      case JobStatus.ended:     return _Svg.endedOn;
      case JobStatus.removed:   return _Svg.removed;
      case JobStatus.scheduled: return _Svg.scheduled;
      case JobStatus.drafted:   return _Svg.started;
      case JobStatus.inactive:  return _Svg.inactive;
    }
  }

  String get _bottomText {
    switch (job.status) {
      case JobStatus.active:
        final days = DateTime.now().difference(job.postedDate ?? DateTime.now()).inDays;
        return 'Posted $days Days ago';
      case JobStatus.ended:
        return 'Ended On ${_formatDate(job.endedDate)}';
      case JobStatus.removed:
        return 'Removed Since ${_formatDate(job.endedDate)}';
      case JobStatus.scheduled:
        return 'Scheduled At ${_formatDate(job.postedDate)}';
      case JobStatus.drafted:
        return 'Draft — not published yet';
      case JobStatus.inactive:
        return 'Inactive Since ${_formatDate(job.endedDate)}';
    }
  }

  String get _bottomRightText {
    if (job.totalApplications > 0) return 'Total Application:${job.totalApplications}';
    return '';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _workTypeSvg() {
    switch (job.workType) {
      case WorkType.remote: return _Svg.remote;
      case WorkType.onSite: return _Svg.office;
      case WorkType.hybrid: return _Svg.office;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Logo + Title ──────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CompanyLogo(logoUrl: logoUrl),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          job.title.en.isEmpty ? 'Untitled' : job.title.en,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // ── Tags with SVG icons ───────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _svgTag(_Svg.calendar, 'Egypt'),
                      _svgTag(_workTypeSvg(), job.workType.label),
                      _svgTag(
                        _Svg.yearsExp,
                        job.employmentDurationText.isNotEmpty
                            ? job.employmentDurationText
                            : job.experienceLevel.label,
                      ),
                      if (job.salaryMax > 0)
                        _svgTag(
                          _Svg.calendar,
                          '${job.salaryMin.toInt()} - ${job.salaryMax.toInt()}',
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Requirements link ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12.sp, color: AppColors.text),
                      children: [
                        const TextSpan(text: 'Requirements.....'),
                        TextSpan(
                          text: 'View',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ColorPick.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: ColorPick.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ── Bottom bar with SVG icon ──────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _bottomBarColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        _bottomSvg,
                        width: 18.sp,
                        height: 18.sp,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _bottomText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_bottomRightText.isNotEmpty)
                        Text(
                          _bottomRightText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Status badge (top-right) ──────────────────────────
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: Text(
                    job.status.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _svgTag(String svgAsset, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorPick.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 14.sp,
            height: 14.sp,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  COMPANY LOGO — from Firebase via HomeCmsCubit
// ═════════════════════════════════════════════════════════════════════════════
