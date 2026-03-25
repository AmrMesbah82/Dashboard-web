// ******************* FILE INFO *******************
// File Name: blog_list_page.dart
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/pages/blog_control/blog_edit_page.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

class _C {
  static const Color primary = Color(0xFF008037);
  static const Color green   = Color(0xFF2D8C4E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color bg      = Color(0xFFF5F5F5);
  static const Color border  = Color(0xFFE0E0E0);
  static const Color label   = Color(0xFF333333);
  static const Color hint    = Color(0xFFAAAAAA);
  static const Color draft   = Color(0xFF9E9E9E);
}

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});
  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  String _filter    = 'all'; // 'all' | 'published' | 'draft'
  String _search    = '';
  final  _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BlogPostModel> _filtered(List<BlogPostModel> all) {
    var list = all;
    if (_filter == 'published') list = list.where((p) => p.status == 'published').toList();
    if (_filter == 'draft')     list = list.where((p) => p.status == 'draft').toList();
    if (_search.isNotEmpty) {
      list = list.where((p) =>
      p.question.en.toLowerCase().contains(_search.toLowerCase()) ||
          p.question.ar.contains(_search),
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlogCubit, BlogState>(
      listener: (context, state) {
        if (state is BlogPostDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted'),
              backgroundColor: _C.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        // ── resolve post list from state (not cubit getter) ──────────────
        final List<BlogPostModel> all = switch (state) {
          BlogLoaded s        => s.posts,
          _                   => [],
        };

        final posts      = _filtered(all);
        final pubCount   = all.where((p) => p.status == 'published').length;
        final draftCount = all.where((p) => p.status == 'draft').length;
        final isLoading  = state is BlogLoading || state is BlogInitial;

        return Scaffold(
          backgroundColor: _C.bg,
          body: Column(
            children: [
              AppNavbar(currentRoute: '/blog-list'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Title + Add button ──────────────────────────────
                      Row(
                        children: [
                          Text(
                            'Important Reads',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: _C.green,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BlogEditPage()),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Add New Read',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // ── Search row ──────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _C.surface,
                                borderRadius: BorderRadius.circular(8.r),
                              //  border: Border.all(color: _C.border),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 12.w),
                                  Icon(Icons.search, size: 18.sp, color: _C.hint),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onChanged: (v) => setState(() => _search = v),
                                      decoration: InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13.sp,
                                          color: _C.hint,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        color: _C.label,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () => setState(() {}),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // ── Filter tabs — just the chips, no extra container ─
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(10.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _filter == 'all',
                                count: all.length,
                                onTap: () => setState(() => _filter = 'all'),
                              ),
                              SizedBox(width: 8.w),
                              _FilterChip(
                                label: 'Post',
                                selected: _filter == 'published',
                                count: pubCount,
                                onTap: () => setState(() => _filter = 'published'),
                              ),
                              SizedBox(width: 8.w),
                              _FilterChip(
                                label: 'Draft',
                                selected: _filter == 'draft',
                                count: draftCount,
                                onTap: () => setState(() => _filter = 'draft'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Cards grid ──────────────────────────────────────
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: _C.primary),
                          ),
                        )
                      else if (posts.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60.h),
                            child: Text(
                              'No posts found.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14.sp,
                                color: _C.hint,
                              ),
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const int cols = 3;
                            final double gap   = 12.w;
                            final double cardW =
                                (constraints.maxWidth - gap * (cols - 1)) / cols;

                            final rows = <List<BlogPostModel>>[];
                            for (int i = 0; i < posts.length; i += cols) {
                              rows.add(posts.skip(i).take(cols).toList());
                            }

                            return Column(
                              children: rows.asMap().entries.map((entry) {
                                final bool isLastRow =
                                    entry.key == rows.length - 1;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: isLastRow ? 0 : gap),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: entry.value
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        final bool isLast =
                                            e.key == entry.value.length - 1;
                                        return SizedBox(
                                          width: cardW,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: isLast ? 0 : gap),
                                            child: Stack(
                                              children: [
                                                _BlogCard(
                                                  post: e.value,
                                                  onEdit: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => BlogEditPage(
                                                        postId: e.value.id,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final int          count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(

        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? _C.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
         // border: Border.all(color: selected ? _C.primary : _C.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.25)
                    : _C.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _C.label,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ── Blog card ─────────────────────────────────────────────────────────────────

class _BlogCard extends StatelessWidget {
  final BlogPostModel post;
  final VoidCallback  onEdit;

  const _BlogCard({required this.post, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final bool   isDraft = post.status == 'draft';
    final String dateStr = post.createdAt != null
        ? 'Posted: ${DateFormat('dd MMM yyyy').format(post.createdAt!)}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F2ED), width: 1.5),
      ),
      padding: EdgeInsets.all(16.w),
      child: Stack(
        children: [
          // ── Main row: text left, image right ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Draft badge
                    if (isDraft) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _C.draft,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Draft',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    // Date
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: _C.hint,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    // Title
                    Text(
                      post.question.en.isNotEmpty ? post.question.en : '—',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.green,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Dots divider
                    Text(
                      '• • • • • • • •',
                      style: TextStyle(
                        color: const Color(0xFFDDE8DD),
                        fontSize: 9.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Read More
                    _ReadMoreBtn(onTap: () {}),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Right: image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: post.imageUrl.isNotEmpty
                    ? Image.network(
                  post.imageUrl,
                  width: 100.w,
                  height: 110.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ],
          ),



        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 100.w,
    height: 110.h,
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Icon(Icons.image_outlined, size: 32, color: _C.hint),
  );
}

// ── Read More button ──────────────────────────────────────────────────────────

class _ReadMoreBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _ReadMoreBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'Read More',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}