/// ******************* FILE INFO *******************
/// File Name: home_main_page_master.dart
/// Updated: AppNavbar now receives [onItemTap] so clicking a nav item in the
///          admin shell never routes to the public site.
/// Pages 1–3 — Read-only overview (Figma screens 1, 2, 3)
/// Sub-navbar: Main(active) | Home | Services | About Us | Contact Us | Careers
/// Status tabs: Published | Scheduled | Draft
/// FIXED: Tabs now show real content filtered by publishStatus
/// FIXED: Scheduled tab shows scheduled date info
/// FIXED: Draft tab shows draft content with "last saved" info
/// ADDED: Read-only "Headings" accordion (Title EN/AR + Short Desc EN/AR)
/// ADDED: Read-only "Navigation Button" accordion (button list with name/route/status)
/// FIXED: Handle HomeCmsDraftSaved / HomeCmsDraftDeleted states ✅
/// FIXED: Re-load data on initState to get fresh state after navigation ✅

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/widget/navigator.dart';



import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../../services/presentation/ui/pages/services_main/services_main.dart';
import '../../../data/model/home_model.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import 'home_edit.dart';
import 'home_preview.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color scheduled = Color(0xFFFF8F00);
}

/// Available route labels for display in the read-only view
const Map<String, String> _kRouteLabelMap = {
  '/':         'Home',
  '/services': 'Services',
  '/about':    'About',
  '/contact':  'Contact Us',
  '/careers':  'Careers',
};

// ─────────────────────────────────────────────────────────────────────────────
class HomeMainPageMaster extends StatefulWidget {
  const HomeMainPageMaster({super.key});
  @override
  State<HomeMainPageMaster> createState() => _HomeMainPageMasterState();
}

class _HomeMainPageMasterState extends State<HomeMainPageMaster>
    with SingleTickerProviderStateMixin {
  int _subNavIndex = 1; // "Home" tab is active
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // rebuild to update tab underline styles
      }
    });

    // ✅ Re-load data when this page is created (e.g. after navigating back
    //    from edit page). This ensures we always show the latest state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, bool> _open = {
    'headings':   true,
    'navButtons': true,
    'navBtn':     true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  Color _hexColor(String hex) {
    try {
      final c = hex.replaceAll('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ✅ Extract data from ALL possible data-carrying states
        HomePageModel? data;
        if (state is HomeCmsLoaded)       data = state.data;
        if (state is HomeCmsSaved)        data = state.data;
        if (state is HomeCmsDraftSaved)   data = state.data;
        if (state is HomeCmsSaving)       data = state.data;

        // ✅ For HomeCmsDraftDeleted, re-load to get the published data
        if (state is HomeCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HomeCmsCubit>().load();
          });
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ✅ For HomeCmsError, try to use lastData
        if (state is HomeCmsError) {
          data = state.lastData;
        }

        // ✅ Fallback: use cubit's current model
        data ??= context.read<HomeCmsCubit>().current;

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel:    'Web Page',
                    homePage:       CareersMainPageDashboard(),
                    webPage:        HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),

                  SizedBox(height: 20.h),
                  AdminSubNavBar(
                    activeIndex: 1,
                    homeCubit: context.read<HomeCmsCubit>(),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 1000.w,
                    child: _body(data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _subNavBar() => Container(
    width: 1000.w,
    decoration: BoxDecoration(
        color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_subNavLabels.length, (i) {
        final active = _subNavIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => _subNavIndex = i);
            switch (i) {
              case 0:
                context.go('/admin/dashboard');
              case 1:
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ServicesMainPageMaster()),
                );
              case 3:
                context.go('/admin/about-cms');
              case 4:
                context.go('/admin/contact-cms');
              case 5:
                context.go('/admin/careers-cms');
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:        active ? _C.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              _subNavLabels[i],
              style: StyleText.fontSize14Weight500.copyWith(
                color: active ? Colors.white : _C.labelText,
              ),
            ),
          ),
        );
      }),
    ),
  );

  Widget _body(HomePageModel data) {
    final primary = _hexColor(data.branding.primaryColor);

    // ✅ Auto-select the tab matching the current publishStatus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetIndex = _statusIndexFromModel(data.publishStatus);
      if (_tabController.index != targetIndex && !_tabController.indexIsChanging) {
        _tabController.animateTo(targetIndex);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview Screen button ────────────────────────────────────
        Row(
          children: [
            Text('Home',
              style: StyleText.fontSize45Weight600.copyWith(
                color: primary, fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomePreviewPageMaster()),
              child: Container(
                width: 165.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color:        primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Text('Preview Screen',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Published / Scheduled / Draft tabs ───────────────────────────────
        Container(
          height: 40.h,
          child: Row(
            children: List.generate(_statusLabels.length, (i) {
              final isActive = _tabController.index == i;
              return Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: GestureDetector(
                  onTap: () {
                    _tabController.animateTo(i);
                    setState(() {});
                  },
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 0.h),
                          child: Text(
                            _statusLabels[i],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? _C.primary : _C.hintText,
                            ),
                          ),
                        ),
                        Container(
                          height: 2,
                          color: isActive ? _C.primary : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),

        // ── Last Updated + Edit Home View ────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:        _C.cardBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _buildLastUpdatedText(data),
                    style: StyleText.fontSize13Weight500.copyWith(color: primary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => navigateTo(context, HomeEditPageMaster()),
              child: Container(
                width: 205.w, height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Edit Home Page',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black)),
                    SizedBox(width: 6.w),
                    CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                        width: 20.w, height: 20.h,
                        fit: BoxFit.scaleDown, color: _C.primary),
                  ]),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ── TabBarView for content ───────────────────────────────────────────
        SizedBox(
          height: 900.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              // ✅ Published content
              _buildStatusContent(data, 'published'),
              // ✅ Scheduled content
              _buildStatusContent(data, 'scheduled'),
              // ✅ Draft content
              _buildStatusContent(data, 'draft'),
            ],
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Maps publishStatus string to tab index
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
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return 'Last Updated On ${d.day} ${months[d.month]} ${d.year}';
    }
    return 'Last Updated On —';
  }

  /// Small colored badge for publish status
  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'published':
        bgColor = _C.primary.withOpacity(0.15);
        textColor = _C.primary;
        label = 'Published';
        break;
      case 'scheduled':
        bgColor = _C.scheduled.withOpacity(0.15);
        textColor = _C.scheduled;
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// ✅ Shows real content when the model's status matches the tab,
  ///    otherwise shows a helpful placeholder message
  Widget _buildStatusContent(HomePageModel data, String targetStatus) {
    final isCurrentStatus = data.publishStatus == targetStatus;

    if (!isCurrentStatus) {
      String message;
      String subMessage;
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

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.sp, color: _C.hintText),
            SizedBox(height: 16.h),
            Text(
              message,
              style: StyleText.fontSize16Weight600.copyWith(
                color: _C.labelText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subMessage,
              style: StyleText.fontSize12Weight400.copyWith(
                color: _C.hintText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ✅ Show real content — this status matches the model
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ If scheduled, show the scheduled date at the top
          if (targetStatus == 'scheduled' && data.scheduledPublishDate != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _C.scheduled.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: _C.scheduled.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: _C.scheduled, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Scheduled to publish on '
                        '${data.scheduledPublishDate!.day}/'
                        '${data.scheduledPublishDate!.month}/'
                        '${data.scheduledPublishDate!.year}',
                    style: StyleText.fontSize13Weight500.copyWith(
                      color: _C.scheduled,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // ✅ If draft, show a small info bar
          if (targetStatus == 'draft') ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.drafts_outlined, color: Colors.grey.shade600, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'This is a saved draft — not yet visible to the public.',
                    style: StyleText.fontSize13Weight500.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // ── Headings accordion (read-only) ─────────────────────────────
          _accordion(
            key: 'headings',
            title: 'Headings',
            children: [
              SizedBox(height: 15.h),
              _headingsReadOnly(data),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Navigation Button accordion (read-only) ────────────────────
          _accordion(
            key: 'navButtons',
            title: 'Navigation Button',
            children: [
              SizedBox(height: 15.h),
              _navButtonsReadOnly(data),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Sections 1–4 ───────────────────────────────────────────────
          _accordion(
            key: 's1',
            title: 'Section 1 - Left',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 0),
            ],
          ),
          SizedBox(height: 10.h),
          _accordion(
            key: 's2',
            title: 'Section 2 - Left Corner',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 1),
            ],
          ),
          SizedBox(height: 10.h),
          _accordion(
            key: 's3',
            title: 'Section 3 - Right',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 2),
            ],
          ),
          SizedBox(height: 10.h),
          _accordion(
            key: 's4',
            title: 'Section 4 - Right Corner',
            children: [
              SizedBox(height: 15.h),
              _sectionView(data, 3),
            ],
          ),
        ],
      ),
    );
  }

  // ── Headings read-only section ────────────────────────────────────────────
  Widget _headingsReadOnly(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _readField('Title', data.title.en.isNotEmpty ? data.title.en : 'Text Here')),
          SizedBox(width: 16.w),
          Expanded(child: _readFieldRtl('العنوان', data.title.ar)),
        ]),
        SizedBox(height: 16.h),
        _readField('Short Description',
            data.shortDescription.en.isNotEmpty ? data.shortDescription.en : 'Text Here',
            height: 80),
        SizedBox(height: 16.h),
        _readFieldRtl('وصف مختصر', data.shortDescription.ar, height: 80),
      ],
    );
  }

  // ── Navigation Button read-only section ───────────────────────────────────
  Widget _navButtonsReadOnly(HomePageModel data) {
    if (data.navButtons.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No navigation buttons configured',
            style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(data.navButtons.length, (i) {
          final btn = data.navButtons[i];
          final routeLabel = _kRouteLabelMap[btn.route] ?? btn.route;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${_ordinal(i + 1)} Button',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: _C.labelText),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: btn.status
                          ? _C.primary.withOpacity(0.12)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      btn.status ? 'Active' : 'Hidden',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: btn.status ? _C.primary : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(child: _readField('Button Name',
                    btn.name.en.isNotEmpty ? btn.name.en : 'Text Here')),
                SizedBox(width: 16.w),
                Expanded(child: _readFieldRtl('عنوان الزر', btn.name.ar)),
              ]),
              SizedBox(height: 10.h),
              _readField('Button Navigation',
                  routeLabel.isNotEmpty ? routeLabel : 'Not set'),
              if (i < data.navButtons.length - 1) ...[
                SizedBox(height: 14.h),
                Divider(color: _C.border, thickness: 1),
                SizedBox(height: 10.h),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _sectionView(HomePageModel data, int index) {
    final sec = index < data.sections.length ? data.sections[index] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Image',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgCircle(sec?.imageUrl ?? ''),
          ]),
          SizedBox(width: 24.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Icon',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            _imgCircle(sec?.iconUrl ?? '', isAdd: true),
          ]),
          const Spacer(),
          if (sec != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: sec.visibility
                        ? _C.primary.withOpacity(0.12)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sec.visibility ? Icons.visibility : Icons.visibility_off,
                        size: 12.sp,
                        color: sec.visibility ? _C.primary : Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        sec.visibility ? 'Visible' : 'Hidden',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: sec.visibility ? _C.primary : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ]),
        SizedBox(height: 14.h),
        _readField('Description', sec?.description.en ?? 'Text Here',
            height: 80),
        SizedBox(height: 10.h),
        _readFieldRtl('الوصف', sec?.description.ar ?? '', height: 80),
      ],
    );
  }

  Widget _imgCircle(String url, {bool isAdd = false}) {
    return Container(
      width:  60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: url.isNotEmpty ? Colors.white : const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: url.isNotEmpty
          ? ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(
              url,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const SizedBox(),
            ),
          ))
          : Center(
          child: Icon(
            isAdd ? Icons.add : Icons.image_outlined,
            color: Colors.grey,
            size:  20.sp,
          )),
    );
  }

  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size:  20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  Widget _readField(String label, String value,
      {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: _C.labelText)),
          SizedBox(height: 4.h),
          Container(
            width:  double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical:   height > 36 ? 8.h : 0,
            ),
            decoration: BoxDecoration(
              color:        AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment:
            height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(value,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText),
              maxLines: height > 36 ? 4 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _readFieldRtl(String label, String value,
      {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(height: 4.h),
            Container(
              width:  double.infinity,
              height: height.h,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical:   height > 36 ? 8.h : 0,
              ),
              decoration: BoxDecoration(
                color:        AppColors.card,
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment: height > 36
                  ? Alignment.topRight
                  : Alignment.centerRight,
              child: Text(
                value.isEmpty ? 'أكتب هنا' : value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.hintText),
                textDirection: TextDirection.rtl,
                maxLines:      height > 36 ? 4 : 1,
                overflow:      TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}