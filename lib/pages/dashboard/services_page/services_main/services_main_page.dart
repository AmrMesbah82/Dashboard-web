// ******************* FILE INFO *******************
// File Name: services_main_page_master.dart
// Screen 1 — Services CMS: Main tab list page
// Status tabs: Main | Cards | Important Reads
// Main tab            → Headings accordion
// Cards tab           → DJ accordion with subtitle + journey items grid
// Important Reads tab → Blog posts card grid with filter tabs + search

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Flutter Web only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/core/widget/svg_image.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/pages/dashboard/services_page/blog_services/blog_create_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/degital_services/services_digital_journey_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/services_page/services_main/services_main_preview_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

import '../degital_services/services_digital_journey_preview_page.dart';

class _C {
  static const Color primary    = Color(0xFF008037);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFDDE8DD);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color greenLight = Color(0xFFE8F5EE);
  static const Color back       = Color(0xFFF1F2ED);

  // status badge colors
  static const Color activeColor   = Color(0xFF008037);
  static const Color inactiveColor = Color(0xFFFF8C00);
  static const Color draftColor    = Color(0xFF666666);
  static const Color removedColor  = Color(0xFFCC0000);
}

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
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCmsCubit>().load();
      context.read<BlogCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCmsCubit, ServiceCmsState>(
      builder: (context, state) {
        if (state is ServiceCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final ServicePageModel model = switch (state) {
          ServiceCmsLoaded s => s.data,
          ServiceCmsSaved  s => s.data,
          _                  => ServicePageModel.empty(),
        };

        return Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                color: _C.primary, fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
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
                } else if (_statusIndex == 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a post to preview')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Preview Screen',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Status tabs ──────────────────────────────────────────────────
        Row(
          children: List.generate(_statusLabels.length, (i) {
            final active = _statusIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _statusIndex = i),
              child: Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: Text(_statusLabels[i],
                  style: active
                      ? StyleText.fontSize16Weight600.copyWith(
                    color:           _C.primary,
                    decoration:      TextDecoration.underline,
                    decorationColor: _C.primary,
                  )
                      : StyleText.fontSize14Weight400
                      .copyWith(color: _C.hintText),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 12.h),

        // ── Tab content ──────────────────────────────────────────────────
        if (_statusIndex == 0) _mainTab(model),
        if (_statusIndex == 1) _digitalJourneyTab(model),
        if (_statusIndex == 2) _readMoreTab(),

        SizedBox(height: 40.h),
      ],
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
            SizedBox(height: 10.h),
            _readField('Description',
                model.shortDescription.en.isEmpty
                    ? 'Text Here' : model.shortDescription.en,
                height: 100),
            SizedBox(height: 10.h),
            _readFieldRtl('وصف', model.shortDescription.ar, height: 100),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 — Cards (Digital Journey)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _digitalJourneyTab(ServicePageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lastUpdatedRow(
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
          key:   'digitalJourney',
          title: 'Digital Journey',
          children: [
            Row(children: [
              Expanded(
                child: _readField(
                  'SubTitle',
                  model.shortDescription.en.isEmpty
                      ? 'Text Here'
                      : model.shortDescription.en,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _readFieldRtl(
                  'العنوان',
                  model.shortDescription.ar,
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
                          .copyWith(color: _C.hintText)),
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
    return BlocBuilder<BlogCubit, BlogState>(
      builder: (context, blogState) {
        if (blogState is BlogLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: _C.primary),
            ),
          );
        }

        final List<BlogPostModel> allPosts = switch (blogState) {
          BlogLoaded(:final posts) => posts,
          _                       => [],
        };

        int _count(_PostStatus s) => s == _PostStatus.all
            ? allPosts.length
            : allPosts.where((p) => p.status == s.statusKey).length;

        List<BlogPostModel> filtered = _activeFilter == _PostStatus.all
            ? allPosts
            : allPosts.where((p) => p.status == _activeFilter.statusKey).toList();

        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((p) =>
          p.question.en.toLowerCase().contains(_searchQuery) ||
              p.question.ar.toLowerCase().contains(_searchQuery) ||
              p.shortDescription.en.toLowerCase().contains(_searchQuery)
          ).toList();
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
                              controller: _searchCtrl,
                              style: StyleText.fontSize13Weight400
                                  .copyWith(color: _C.labelText),
                              decoration: InputDecoration(
                                hintText:       'Search',
                                hintStyle:      StyleText.fontSize13Weight400
                                    .copyWith(color: _C.hintText),
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
                    onTap: () {},
                    outlined: false,
                  ),
                  SizedBox(width: 10.w),
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
                      onTap: () => setState(() => _activeFilter = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isActive ? _C.primary : AppColors.card,
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
                                      : _C.primary,
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
                                color: isActive ? Colors.white : _C.labelText,
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
                        size: 40.sp, color: _C.hintText),
                    SizedBox(height: 8.h),
                    Text('No posts found.',
                        style: StyleText.fontSize13Weight400
                            .copyWith(color: _C.hintText)),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: const BlogCreateEditPage(),
        ),
      ),
    ).then((_) => context.read<BlogCubit>().load());
  }

  void _navigateToEdit(BlogPostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BlogCubit>(),
          child: BlogCreateEditPage(existing: post),
        ),
      ),
    ).then((_) => context.read<BlogCubit>().load());
  }

  Future<void> _confirmDelete(BlogPostModel post) async {
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
      await context.read<BlogCubit>().deletePost(post.id);
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
          color: outlined ? _C.cardBg : _C.primary,
          borderRadius: BorderRadius.circular(6.r),
          border: outlined ? Border.all(color: _C.primary) : null,
        ),
        child: Center(
          child: Text(label,
            style: StyleText.fontSize13Weight500.copyWith(
              color: outlined ? _C.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared: Last Updated + Edit Details row ───────────────────────────────
  Widget _lastUpdatedRow({required VoidCallback onEdit}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text('Last Updated On 12 Jul 2026',
              style: StyleText.fontSize13Weight500.copyWith(color: _C.primary)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w, height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Edit Details',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: _C.primary)),
                SizedBox(width: 6.w),
                CustomSvg(assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w, height: 20.h,
                    fit: BoxFit.scaleDown, color: _C.primary),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
        );
      }).toList(),
    );
  }

  Widget _journeyMiniCard(JourneyItemModel item) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w, height: 28.w,
            decoration: BoxDecoration(
              color: _C.greenLight,
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
                size: 16.sp, color: _C.primary),
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
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft:  Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
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
          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
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
          style:    StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
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
                    .copyWith(color: _C.labelText)),
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
                    .copyWith(color: _C.hintText),
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
    'published' => _C.activeColor,
    'inactive'  => _C.inactiveColor,
    'draft'     => _C.draftColor,
    'removed'   => _C.removedColor,
    _           => _C.draftColor,
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

    return Container(
      padding: EdgeInsets.all(16.w),
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
            children: [
              Expanded(
                child: Text(
                  '$_datePrefix ${_fmtDate(post.createdAt)}',
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: _C.hintText),
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
                        color: _C.primary,
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
                          .copyWith(color: _C.hintText),
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

              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: _C.primary,
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
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 100.w, height: 80.h,
    decoration: BoxDecoration(
      color: _C.sectionBg,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Icon(Icons.image_outlined, size: 24.sp, color: _C.hintText),
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
          color: _C.sectionBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.broken_image_outlined,
            size: 24.sp, color: _C.hintText),
      );
    }

    // Loading
    if (_svgString == null && _rasterBytes == null) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _C.primary),
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
          color: _C.sectionBg,
          child: Icon(Icons.broken_image_outlined,
              size: 24.sp, color: _C.hintText),
        ),
      );
    }

    // Fallback
    return Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.image_outlined, size: 24.sp, color: _C.hintText),
    );
  }
}