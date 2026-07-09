part of '../../pages/home_main.dart';

extension _HomeMainBuilders on _HomeMainPageMasterState {
  Widget _subNavBar() => Container(
    width: 1000.w,
    decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_subNavLabels.length, (i) {
        final active = _subNavIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => _subNavIndex = i);
            switch (i) {
              case 0: context.go('/admin/dashboard');
              case 1: break;
              case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesMainPageMaster()));
              case 3: context.go('/admin/about-cms');
              case 4: context.go('/admin/contact-cms');
              case 5: context.go('/admin/careers-cms');
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: active ? ColorPick.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(_subNavLabels[i],
                style: StyleText.fontSize14Weight500.copyWith(color: active ? Colors.white : AppColors.text)),
          ),
        );
      }),
    ),
  );

  Widget _body(HomePageModel data) {
    final primary = _hexColor(data.branding.primaryColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetIndex = _statusIndexFromModel(data.publishStatus);
      if (_tabController.index != targetIndex && !_tabController.indexIsChanging) {
        _tabController.animateTo(targetIndex);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Home', style: StyleText.fontSize45Weight600.copyWith(color: primary, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomePreviewPageMaster()),
              child: Container(
                width: 165.w, height: 45.h,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(6.r)),
                child: Center(child: Text('Preview Screen',
                    style: StyleText.fontSize14Weight500.copyWith(color: Colors.white))),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Container(
          height: 40.h,
          child: Row(
            children: List.generate(_statusLabels.length, (i) {
              final isActive = _tabController.index == i;
              return Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: GestureDetector(
                  onTap: () { _tabController.animateTo(i); setState(() {}); },
                  child: IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.h),
                      child: Text(_statusLabels[i], style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? ColorPick.primary : AppColors.secondaryText,
                      )),
                    ),
                    Container(height: 2, color: isActive ? ColorPick.primary : Colors.transparent),
                  ])),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_buildLastUpdatedText(data),
                    style: StyleText.fontSize13Weight500.copyWith(color: primary)),
              ]),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomeEditPageMaster()),
              child: Container(
                width: 130.w, height: 36.h,
                decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
                child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Edit Details', style: StyleText.fontSize14Weight500.copyWith(color: Colors.black)),
                  SizedBox(width: 6.w),
                  CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                      width: 20.w, height: 20.h, fit: BoxFit.scaleDown, color: ColorPick.primary),
                ])),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 900.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusContent(data, 'published'),
              _buildStatusContent(data, 'scheduled'),
              _buildStatusContent(data, 'draft'),
            ],
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  int _statusIndexFromModel(String status) {
    switch (status) {
      case 'published': return 0;
      case 'scheduled': return 1;
      case 'draft':     return 2;
      default:          return 0;
    }
  }

  String _buildLastUpdatedText(HomePageModel data) {
    if (data.lastUpdatedAt != null) {
      final d = data.lastUpdatedAt!;
      final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return 'Last Updated On ${d.day} ${months[d.month]} ${d.year}';
    }
    return 'Last Updated On —';
  }

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    switch (status) {
      case 'published':
        bgColor = ColorPick.primary.withValues(alpha: 0.15);
        textColor = ColorPick.primary;
        label = 'Published';
        break;
      case 'scheduled':
        bgColor = ColorPick.scheduled.withValues(alpha: 0.15);
        textColor = ColorPick.scheduled;
        label = 'Scheduled';
        break;
      case 'draft':
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = 'Draft';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4.r)),
      child: Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildStatusContent(HomePageModel data, String targetStatus) {
    final isCurrentStatus = data.publishStatus == targetStatus;

    if (!isCurrentStatus) {
      String message, subMessage;
      IconData icon;
      switch (targetStatus) {
        case 'published':
          message = 'No published version yet';
          subMessage = 'Click "Edit Details" → "Publish" to publish your home page.';
          icon = Icons.public;
          break;
        case 'scheduled':
          message = 'No scheduled version';
          subMessage = 'Set a publish date in the editor and click "Schedule" to schedule.';
          icon = Icons.schedule;
          break;
        case 'draft':
        default:
          message = 'No draft saved';
          subMessage = 'Click "Edit Details" → "Save For Later" to save a draft.';
          icon = Icons.drafts_outlined;
          break;
      }
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48.sp, color: AppColors.secondaryText),
        SizedBox(height: 16.h),
        Text(message, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
        SizedBox(height: 8.h),
        Text(subMessage, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center),
      ]));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (targetStatus == 'scheduled' && data.scheduledPublishDate != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ColorPick.scheduled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: ColorPick.scheduled.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.schedule, color: ColorPick.scheduled, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Scheduled to publish on ${data.scheduledPublishDate!.day}/${data.scheduledPublishDate!.month}/${data.scheduledPublishDate!.year}',
                  style: StyleText.fontSize13Weight500.copyWith(color: ColorPick.scheduled),
                ),
              ]),
            ),
            SizedBox(height: 12.h),
          ],
          if (targetStatus == 'draft') ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(children: [
                Icon(Icons.drafts_outlined, color: Colors.grey.shade600, size: 18.sp),
                SizedBox(width: 8.w),
                Text('This is a saved draft — not yet visible to the public.',
                    style: StyleText.fontSize13Weight500.copyWith(color: Colors.grey.shade700)),
              ]),
            ),
            SizedBox(height: 12.h),
          ],
          _accordion(key: 'headings', title: 'Headings', children: [
            SizedBox(height: 15.h), _headingsReadOnly(data),
          ]),
          SizedBox(height: 10.h),
          _accordion(key: 'navButtons', title: 'Navigation Button', children: [
            SizedBox(height: 15.h), _navButtonsReadOnly(data),
          ]),
          SizedBox(height: 10.h),
          _accordion(key: 's1', title: 'Section 1 - Left', children: [SizedBox(height: 15.h), _sectionView(data, 0)]),
          SizedBox(height: 10.h),
          _accordion(key: 's2', title: 'Section 2 - Left Corner', children: [SizedBox(height: 15.h), _sectionView(data, 1)]),
          SizedBox(height: 10.h),
          _accordion(key: 's3', title: 'Section 3 - Right', children: [SizedBox(height: 15.h), _sectionView(data, 2)]),
          SizedBox(height: 10.h),
          _accordion(key: 's4', title: 'Section 4 - Right Corner', children: [SizedBox(height: 15.h), _sectionView(data, 3)]),
        ],
      ),
    );
  }
}
