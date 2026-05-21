// ******************* FILE INFO *******************
// File Name: services_main_page_master.dart
// Screen 1 — Services CMS: Main tab list page
// Status tabs: Main | Cards | Important Reads
// Main tab            → Headings accordion
// Cards tab           → DJ accordion with subtitle + journey items grid
// Important Reads tab → Blog posts card grid with filter tabs + search
// FIXED: _lastUpdatedRow now shows dynamic date from model (not static)
// FIXED: Preview Screen button hidden on Important Reads tab
// FIXED: Tab bar restyled to match job_listing_detail_page pattern
// DEBUG: Added comprehensive logging for blog post loading/filtering

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Flutter Web only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/core/constant/color.dart';
import 'package:web_app_admin/features/services/presentation/ui/pages/services_main/services_edit.dart';
import 'package:web_app_admin/features/services/presentation/ui/pages/services_main/services_preview.dart';


import '../../../../../../core/custom_svg.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../../main/presentation/ui/pages/main_main.dart';
import '../../../../data/model/blog_model.dart';
import '../../../../data/model/services_model.dart';
import '../../../controller/blog_cubit.dart';
import '../../../controller/blog_state.dart';
import '../../../controller/services_cubit.dart';
import '../../../controller/services_state.dart';
import '../blog_services/blog_edit.dart';
import '../degital_services/services_digital_main.dart';
import '../degital_services/services_digital_preview.dart';

// 🔵 DEBUG: Helper for consistent logging
void _log(String message, {String level = '🔵'}) {
  debugPrint('$level [ServicesMainPageMaster] $message');
}

// class _C {
//   static const Color primary    = Color(0xFF008037);
//   static const Color sectionBg  = Color(0xFFF5F5F5);
//   static const Color cardBg     = Color(0xFFFFFFFF);
//   static const Color border     = Color(0xFFDDE8DD);
//   static const Color labelText  = Color(0xFF333333);
//   static const Color hintText   = Color(0xFFAAAAAA);
//   static const Color greenLight = Color(0xFFE8F5EE);
//   static const Color back       = Color(0xFFF1F2ED);
//
//   // status badge colors
//   static const Color activeColor   = Color(0xFF008037);
//   static const Color inactiveColor = Color(0xFFFF8C00);
//   static const Color draftColor    = Color(0xFF666666);
//   static const Color removedColor  = Color(0xFFCC0000);
// }

// ── Blog status enum ──────────────────────────────────────────────────────────
enum _PostStatus { all, posted, inactive, draft, removed }

extension _PostStatusLabel on _PostStatus {
  String get label => switch (this) {
    _PostStatus.all      => 'All',
    _PostStatus.posted   => 'Posted',
    _PostStatus.inactive => 'Inactive',
    _PostStatus.draft    => 'Draft',
    _PostStatus.removed  => 'Removed',
  };

  /// Maps to the BlogPostModel.status string values
  String? get statusKey => switch (this) {
    _PostStatus.all      => null,
    _PostStatus.posted   => 'published',
    _PostStatus.inactive => 'inactive',
    _PostStatus.draft    => 'draft',
    _PostStatus.removed  => 'removed',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
class ServicesMainPageMaster extends StatefulWidget {
  const ServicesMainPageMaster({super.key});

  @override
  State<ServicesMainPageMaster> createState() => _ServicesMainPageMasterState();
}

class _ServicesMainPageMasterState extends State<ServicesMainPageMaster> {
  // ── Status tabs ────────────────────────────────────────────────────────────
  int _statusIndex = 0;
  final List<String> _statusLabels = ['Main', 'Cards', 'Important Reads'];

  // ── Accordion open state ────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'headings':       true,
    'digitalJourney': true,
  };

  // ── Important Reads sub-state ──────────────────────────────────────────────
  _PostStatus                _activeFilter = _PostStatus.all;
  final TextEditingController _searchCtrl  = TextEditingController();
  String                     _searchQuery  = '';

  @override
  void initState() {
    super.initState();
    _log('Page initialized');
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('Loading ServiceCmsCubit and BlogCubit...');
      context.read<ServiceCmsCubit>().load();
      context.read<BlogCubit>().load();
    });
  }

  @override
  void dispose() {
    _log('Page disposed');
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Date formatter ─────────────────────────────────────────────────────────
  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCmsCubit, ServiceCmsState>(
      builder: (context, state) {
        if (state is ServiceCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        final ServicePageModel model = switch (state) {
          ServiceCmsLoaded s => s.data,
          ServiceCmsSaved  s => s.data,
          _                  => ServicePageModel.empty(),
        };

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel:     'Web Page',
                    homePage:       CareersMainPageDashboard(),
                    webPage:        HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 2),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 1000.w,
                    child: _body(model),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Page body ──────────────────────────────────────────────────────────────
  Widget _body(ServicePageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview Screen ───────────────────────────────────────
        Row(
          children: [
            Text('Services',
              style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary, fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // ✅ FIX 2: Hide Preview Screen button on Important Reads tab
            if (_statusIndex != 2)
              GestureDetector(
                onTap: () {
                  if (_statusIndex == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ServiceCmsCubit>(),
                          child: ServicesMainPreviewPage(model: model),
                        ),
                      ),
                    );
                  } else if (_statusIndex == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ServiceCmsCubit>(),
                          child: ServicesDigitalJourneyPreviewPage(model: model),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 165.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text('Preview Screen',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── ✅ FIX 3: Tab bar — job_listing_detail_page style ────────────
        _buildTabBar(),
        SizedBox(height: 12.h),

        // ── Tab content ──────────────────────────────────────────────────
        if (_statusIndex == 0) _mainTab(model),
        if (_statusIndex == 1) _digitalJourneyTab(model),
        if (_statusIndex == 2) _readMoreTab(),

        SizedBox(height: 40.h),
      ],
    );
  }

  // ── ✅ FIX 3: Tab bar widget — matches job_listing_detail_page pattern ──
  Widget _buildTabBar() {
    return Row(
      children: List.generate(_statusLabels.length, (i) {
        final isActive = _statusIndex == i;
        return Padding(
          padding: EdgeInsets.only(right: 24.w),
          child: GestureDetector(
            onTap: () {
              _log('Tab switched to: ${_statusLabels[i]}');
              setState(() => _statusIndex = i);
            },
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      _statusLabels[i],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? ColorPick.primary : AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: isActive ? ColorPick.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0 — Main
  // ══════════════════════════════════════════════════════════════════════════
  Widget _mainTab(ServicePageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lastUpdatedRow(
          // ✅ FIX 1: Pass dynamic date from model
          lastUpdated: model.lastUpdatedAt,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ServiceCmsCubit>(),
                child: ServicesMainEditPage(model: model),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _accordion(
          key:   'headings',
          title: 'Headings',
          children: [
            SizedBox(height: 16.w),
            Row(children: [
              Expanded(child: _readField('Title',
                  model.title.en.isEmpty ? 'Text Here' : model.title.en)),
              SizedBox(width: 16.w),
              Expanded(child: _readFieldRtl('العنوان', model.title.ar)),
            ]),

            _readField('Description',
                model.shortDescription.en.isEmpty
                    ? 'Text Here' : model.shortDescription.en,
                height: 100),

            _readFieldRtl('وصف', model.shortDescription.ar, height: 100),
          ],
        ),
      ],
    );
  }

  Widget _digitalJourneyTab(ServicePageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lastUpdatedRow(
          lastUpdated: model.lastUpdatedAt,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ServiceCmsCubit>(),
                child: ServicesDigitalJourneyEditPage(model: model),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _accordion(
          key: 'digitalJourney',
          title: 'Digital Journey',
          children: [
            Row(children: [
              Expanded(
                child: _readField(
                  'Section Title',
                  model.journeyTitle.en.isEmpty
                      ? 'Text Here'
                      : model.journeyTitle.en,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _readFieldRtl(
                  'عنوان القسم',
                  model.journeyTitle.ar,
                ),
              ),
            ]),
            SizedBox(height: 14.h),
            if (model.journeyItems.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text('No journey items yet.',
                      style: StyleText.fontSize13Weight400
                          .copyWith(color: AppColors.secondaryText)),
                ),
              )
            else
              _journeyGrid(model.journeyItems),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2 — Important Reads
  // ══════════════════════════════════════════════════════════════════════════
  Widget _readMoreTab() {
    _log('Building Important Reads tab');

    return BlocBuilder<BlogCubit, BlogState>(
      builder: (context, blogState) {
        _log('BlogCubit state: ${blogState.runtimeType}');

        if (blogState is BlogLoading) {
          _log('  State: Loading...', level: '🟡');
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: ColorPick.primary),
            ),
          );
        }

        final List<BlogPostModel> allPosts = switch (blogState) {
          BlogLoaded(:final posts) => posts,
          BlogError() => (() {
            _log('  State: Error', level: '🔴');
            return <BlogPostModel>[];
          })(),
          _ => (() {
            _log('  State: Unknown/Empty', level: '🟡');
            return <BlogPostModel>[];
          })(),
        };

        _log('  Total posts loaded: ${allPosts.length}');

        // Log status breakdown
        final statusCounts = <String, int>{};
        for (final p in allPosts) {
        statusCounts[p.status] = (statusCounts[p.status] ?? 0) + 1;
        }
        _log('  Status breakdown: $statusCounts');

        int _count(_PostStatus s) => s == _PostStatus.all
        ? allPosts.length
            : allPosts.where((p) => p.status == s.statusKey).length;

        List<BlogPostModel> filtered = _activeFilter == _PostStatus.all
        ? allPosts
            : allPosts.where((p) => p.status == _activeFilter.statusKey).toList();

        _log('  Active filter: ${_activeFilter.label} (${_activeFilter.statusKey ?? "all"})');
        _log('  Posts after status filter: ${filtered.length}');

        if (_searchQuery.isNotEmpty) {
        final beforeSearch = filtered.length;
        filtered = filtered.where((p) =>
        p.question.en.toLowerCase().contains(_searchQuery) ||
        p.question.ar.toLowerCase().contains(_searchQuery) ||
        p.shortDescription.en.toLowerCase().contains(_searchQuery)
        ).toList();
        _log('  Search query: "$_searchQuery" -> filtered from $beforeSearch to ${filtered.length}');
        }

        return Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Search + action buttons row ────────────────────────────
        Row(
        children: [
        Expanded(
        child: Container(
        height: 40.h,
        decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
        children: [
        SizedBox(width: 10.w),
        CustomSvg(assetPath: "assets/searchIcon.svg",
        width: 20.w, height: 20.h, fit: BoxFit.fill),
        SizedBox(width: 8.w),
        Expanded(
        child: TextField(
          cursorColor: Color(0xFF008037),
        controller: _searchCtrl,
        style: StyleText.fontSize13Weight400
            .copyWith(color: AppColors.text),
        decoration: InputDecoration(
        hintText:       'Search',
        hintStyle:      StyleText.fontSize13Weight400
            .copyWith(color: AppColors.secondaryText),
        border:         InputBorder.none,
        isDense:        true,
        contentPadding: EdgeInsets.zero,
        ),
        ),
        ),
        SizedBox(width: 8.w),
        ],
        ),
        ),
        ),
        SizedBox(width: 12.w),
          _actionBtn(
            label: 'Time Frame',
            onTap: (){},
            outlined: false,
          ),
          SizedBox(width: 12.w),
        _actionBtn(
        label: 'Add New Read',
        onTap: _navigateToCreate,
        outlined: false,
        ),
        ],
        ),
        SizedBox(height: 16.h),

        // ── Filter chips row ───────────────────────────────────────
        Row(
        children: _PostStatus.values.map((s) {
        final isActive = _activeFilter == s;
        final int cnt  = _count(s);
        return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: GestureDetector(
        onTap: () {
        _log('Filter chip clicked: ${s.label}');
        setState(() => _activeFilter = s);
        },
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
        horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
        color: isActive ? ColorPick.primary : AppColors.card,
        borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        if (s != _PostStatus.all) ...[
        Container(
        width: 18.w, height: 18.w,
        decoration: BoxDecoration(
        color: isActive
        ? Colors.white.withOpacity(0.25)
            : ColorPick.primary,
        shape: BoxShape.circle,
        ),
        child: Center(
        child: Text('$cnt',
        style: TextStyle(
        fontFamily: 'Cairo',
        fontSize:   10.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        ),
        ),
        ),
        ),
        SizedBox(width: 6.w),
        ],
        Text(s.label,
        style: StyleText.fontSize13Weight500.copyWith(
        color: isActive ? Colors.white : AppColors.text,
        ),
        ),
        ],
        ),
        ),
        ),
        );
        }).toList(),
        ),
        SizedBox(height: 20.h),

        // ── Cards grid ────────────────────────────────────────────
        filtered.isEmpty
        ? Center(
        child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(children: [
        Icon(Icons.article_outlined,
        size: 40.sp, color: AppColors.secondaryText),
        SizedBox(height: 8.h),
        Text('No posts found.',
        style: StyleText.fontSize13Weight400
            .copyWith(color: AppColors.secondaryText)),
        ]),
        ),
        )
            : _blogCardGrid(filtered),
        ],
        ),
        );
      },
    );
  }

  // ── 3-column card grid ────────────────────────────────────────────────────
  Widget _blogCardGrid(List<BlogPostModel> posts) {
    final List<List<BlogPostModel>> rows = [];
    for (int i = 0; i < posts.length; i += 3) {
      rows.add(posts.skip(i).take(3).toList());
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...row.map((post) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _BlogCard(
                    post:     post,
                    onEdit:   () => _navigateToEdit(post),
                    onDelete: () => _confirmDelete(post),
                  ),
                ),
              )),
              ...List.generate(
                  3 - row.length,
                      (_) => const Expanded(child: SizedBox())),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Navigate helpers ──────────────────────────────────────────────────────
  void _navigateToCreate() {
    _log('Navigating to CREATE blog post');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: const BlogCreateEditPage(),
        ),
      ),
    ).then((_) {
      _log('Returned from CREATE page, reloading BlogCubit...');
      context.read<BlogCubit>().load();
    });
  }

  void _navigateToEdit(BlogPostModel post) {
    _log('Navigating to EDIT blog post: ${post.id} (status: ${post.status})');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: BlogCreateEditPage(existing: post),
        ),
      ),
    ).then((_) {
      _log('Returned from EDIT page, reloading BlogCubit...');
      context.read<BlogCubit>().load();
    });
  }

  Future<void> _confirmDelete(BlogPostModel post) async {
    _log('Confirming delete for post: ${post.id}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text(
            'Delete "${post.question.en.isNotEmpty ? post.question.en : 'this post'}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _log('User confirmed delete, calling cubit.deletePost()');
      await context.read<BlogCubit>().deletePost(post.id);
      _log('Delete completed, cubit state should refresh automatically');
    } else {
      _log('Delete cancelled');
    }
  }

  // ── Action button (filled / outlined) ─────────────────────────────────────
  Widget _actionBtn({
    required String       label,
    required VoidCallback onTap,
    required bool         outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: outlined ? ColorPick.background : ColorPick.primary,
          borderRadius: BorderRadius.circular(6.r),
          border: outlined ? Border.all(color: ColorPick.primary) : null,
        ),
        child: Center(
          child: Text(label,
            style: StyleText.fontSize13Weight500.copyWith(
              color: outlined ? ColorPick.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── ✅ FIX 1: Last Updated + Edit Details row — now dynamic date ──────────
  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: ColorPick.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: ColorPick.primary),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 205.w, height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Edit Details',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.black)),
                SizedBox(width: 6.w),
                CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w, height: 20.h,
                    fit: BoxFit.scaleDown, color: ColorPick.primary),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Journey grid ──────────────────────────────────────────────────────────
  Widget _journeyGrid(List<JourneyItemModel> items) {
    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...row.map((item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _journeyMiniCard(item),
                  ),
                )),
                ...List.generate(
                    4 - row.length, (_) => const Expanded(child: SizedBox())),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _journeyMiniCard(JourneyItemModel item) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w, height: 28.w,
            decoration: BoxDecoration(
              color: ColorPick.preview,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.all(7.r),
                child: SvgPicture.network(
                  item.iconUrl,
                  width: 14.w, height: 14.w,
                  fit: BoxFit.contain,
                ),
              ),
            )
                : Icon(Icons.miscellaneous_services_outlined,
                size: 16.sp, color: ColorPick.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: StyleText.fontSize12Weight600
                .copyWith(color: const Color(0xFF1A1A1A)),
          ),
          SizedBox(height: 4.h),
          Text(
            item.description.en.isNotEmpty
                ? item.description.en
                : 'Description',
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6.r)
              ),
              child: Row(children: [
                Expanded(child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
                Icon(isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp),
              ]),
            ),
          ),
          if (isOpen)
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  // ── Read-only field LTR ────────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 20.h),
      Text(label,
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity, height: height.h,
        padding: EdgeInsets.symmetric(
            horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
        child: Text(value,
          style:    StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
          maxLines: height > 36 ? 4 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  // ── Read-only field RTL ────────────────────────────────────────────────────
  Widget _readFieldRtl(String label, String value, {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity, height: height.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment:
              height > 36 ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                value.isEmpty ? 'أكتب هنا' : value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                textDirection: TextDirection.rtl,
                maxLines:      height > 36 ? 4 : 1,
                overflow:      TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// BLOG CARD  (matches Figma card in the grid)
// ══════════════════════════════════════════════════════════════════════════════
class _BlogCard extends StatelessWidget {
  final BlogPostModel post;
  final VoidCallback  onEdit;
  final VoidCallback  onDelete;

  const _BlogCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor => switch (post.status) {
    'published' => ColorPick.activeColor,
    'inactive'  => ColorPick.inactiveColor,
    'draft'     => ColorPick.draftColor,
    'removed'   => ColorPick.removedColor,
    _           => ColorPick.draftColor,
  };

  String get _statusLabel => switch (post.status) {
    'published' => 'Active',
    'inactive'  => 'Inactive',
    'draft'     => 'Draft',
    'removed'   => 'Removed',
    _           => 'Draft',
  };

  String get _datePrefix => switch (post.status) {
    'published' => 'Posted:',
    'inactive'  => 'Inactive Since',
    'draft'     => 'Started Since',
    'removed'   => 'Removed On',
    _           => '',
  };

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String cleanUrl = post.imageUrl.trim();
    final bool hasImage   = cleanUrl.isNotEmpty;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: date + status badge ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$_datePrefix ${_fmtDate(post.createdAt)}',
                    style: StyleText.fontSize11Weight400
                        .copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _statusLabel,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: _statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Row 2: text (left) + image (right) ────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.question.en.isNotEmpty
                            ? post.question.en
                            : 'Untitled',
                        style: StyleText.fontSize13Weight600.copyWith(
                          color: ColorPick.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        post.shortDescription.en.isNotEmpty
                            ? post.shortDescription.en
                            : 'Short Description...',
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Image — auto-detects SVG vs raster via XHR ─────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: hasImage
                      ? _XhrImage(
                    url:    cleanUrl,
                    width:  100.w,
                    height: 80.h,
                  )
                      : _imgPlaceholder(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Row 3: edit/delete icons + Read More button ───────────────
            Row(
              children: [
                // // Edit icon
                // GestureDetector(
                //   onTap: onEdit,
                //   child: Container(
                //     padding: EdgeInsets.all(6.r),
                //     decoration: BoxDecoration(
                //       color: ColorPick.background,
                //       borderRadius: BorderRadius.circular(4.r),
                //     ),
                //     child: Icon(Icons.edit_outlined,
                //         size: 16.sp, color: AppColors.text),
                //   ),
                // ),
                // SizedBox(width: 8.w),
                // // Delete icon
                // GestureDetector(
                //   onTap: onDelete,
                //   child: Container(
                //     padding: EdgeInsets.all(6.r),
                //     decoration: BoxDecoration(
                //       color: ColorPick.background,
                //       borderRadius: BorderRadius.circular(4.r),
                //     ),
                //     child: Icon(Icons.delete_outline,
                //         size: 16.sp, color: Colors.red),
                //   ),
                // ),
                const Spacer(),
                GestureDetector(
                  onTap: (){},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: ColorPick.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Read More',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 100.w, height: 80.h,
    decoration: BoxDecoration(
      color: ColorPick.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Icon(Icons.image_outlined, size: 24.sp, color: AppColors.secondaryText),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR image loader — auto-detects SVG vs raster (PNG/JPG/WebP)
// Works on Flutter Web, bypasses CORS for Firebase Storage
// ══════════════════════════════════════════════════════════════════════════════
class _XhrImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const _XhrImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<_XhrImage> createState() => _XhrImageState();
}

class _XhrImageState extends State<_XhrImage> {
  String?   _svgString;
  Uint8List? _rasterBytes;
  bool _isSvg  = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _XhrImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _svgString   = null;
      _rasterBytes = null;
      _isSvg  = false;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final xhr = html.HttpRequest();
      xhr.open('GET', widget.url, async: true);
      xhr.responseType = 'arraybuffer';

      final completer = Completer<Uint8List>();

      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          final buf = xhr.response as ByteBuffer;
          completer.complete(buf.asUint8List());
        } else {
          completer.completeError('HTTP ${xhr.status}');
        }
      });
      xhr.onError.listen((_) => completer.completeError('XHR error'));
      xhr.send();

      final bytes = await completer.future;

      // Detect format by inspecting first bytes
      final header = String.fromCharCodes(bytes.take(20));

      if (header.trimLeft().startsWith('<svg') ||
          header.trimLeft().startsWith('<?xml')) {
        // ── SVG ──
        final svgStr = String.fromCharCodes(bytes);
        if (mounted) {
          setState(() {
            _svgString = svgStr;
            _isSvg = true;
          });
        }
      } else {
        // ── Raster (PNG / JPG / WebP) ──
        if (mounted) {
          setState(() {
            _rasterBytes = bytes;
            _isSvg = false;
          });
        }
      }
    } catch (e) {
      debugPrint('_XhrImage load error: $e | url: ${widget.url}');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Error
    if (_failed) {
      return Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          color: ColorPick.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.broken_image_outlined,
            size: 24.sp, color: AppColors.secondaryText),
      );
    }

    // Loading
    if (_svgString == null && _rasterBytes == null) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: ColorPick.primary),
        ),
      );
    }

    // SVG
    if (_isSvg && _svgString != null) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: SvgPicture.string(
          _svgString!,
          width:  widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    // Raster
    if (_rasterBytes != null) {
      return Image.memory(
        _rasterBytes!,
        width:  widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: widget.width, height: widget.height,
          color: ColorPick.background,
          child: Icon(Icons.broken_image_outlined,
              size: 24.sp, color: AppColors.secondaryText),
        ),
      );
    }

    // Fallback
    return Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
        color: ColorPick.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.image_outlined, size: 24.sp, color: AppColors.secondaryText),
    );
  }
}