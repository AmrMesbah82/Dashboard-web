// ******************* FILE INFO *******************
// File Name: blog_detail_page.dart
// Updated: All blog data now sourced from Firebase via BlogCubit / BlogPostModel.
//          Branding colors still come from HomeCmsCubit.
//          Supports bilingual (EN / AR), all block types (paragraph,
//          numbering, bulletPoint), Read More / Read Less, responsive
//          Mobile + Desktop layouts.
//          BLOG IMAGE: SVG-only — no Image.network fallback ✅

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/theme/app_theme.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';

// ── Fallback colors ───────────────────────────────────────────────────────────
const Color _kFallbackPrimary   = Color(0xFF2D8C4E);
const Color _kFallbackSecondary = Color(0xFFE8F5EE);
const Color _kDivider           = Color(0xFFDDE8DD);
const Color _kSurface           = Color(0xFFFFFFFF);

Color _parseColor(String hex, {Color fallback = _kFallbackPrimary}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

class _BP {
  static const double mobile = 600;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _tb(BlogBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

String _monthName(int m) => const [
  '',
  'January', 'February', 'March',     'April',   'May',      'June',
  'July',    'August',   'September', 'October',  'November', 'December',
][m];

String _monthNameAr(int m) => const [
  '',
  'يناير', 'فبراير', 'مارس',   'أبريل', 'مايو',   'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر','نوفمبر', 'ديسمبر',
][m];

String _formatDate(DateTime? dt, bool isRtl) {
  if (dt == null) return '';
  return isRtl
      ? '${_monthNameAr(dt.month)} ${dt.day} ${dt.year}'
      : '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class BlogDetailPage extends StatefulWidget {
  /// Pass a post id to open a specific post directly.
  /// If null, the first published post is shown.
  final String? initialPostId;

  const BlogDetailPage({super.key, this.initialPostId});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  String? _selectedPostId;
  bool    _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedPostId = widget.initialPostId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogCubit>().load();
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final Color primary = switch (homeState) {
          HomeCmsLoaded(:final data) =>
              _parseColor(data.branding.primaryColor),
          HomeCmsSaved(:final data) =>
              _parseColor(data.branding.primaryColor),
          _ => _kFallbackPrimary,
        };

        final Color secondary = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kFallbackSecondary),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kFallbackSecondary),
          _ => _kFallbackSecondary,
        };

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: BlocBuilder<BlogCubit, BlogState>(
                builder: (context, blogState) {
                  // ── Loading ─────────────────────────────────────────
                  if (blogState is BlogLoading) {
                    return Scaffold(
                      backgroundColor: AppColors.background,
                      body: Center(
                        child: CircularProgressIndicator(color: primary),
                      ),
                    );
                  }

                  // ── Error ───────────────────────────────────────────
                  if (blogState is BlogError) {
                    return Scaffold(
                      backgroundColor: AppColors.background,
                      body: Center(
                        child: Text(
                          blogState.message,
                          style: const TextStyle(
                              fontFamily: 'Cairo', color: Colors.red),
                        ),
                      ),
                    );
                  }

                  // ── Data ready ──────────────────────────────────────
                  final List<BlogPostModel> posts =
                  blogState is BlogLoaded
                      ? blogState.posts
                      .where((p) => p.status == 'published')
                      .toList()
                      : [];

                  if (posts.isEmpty) {
                    return Scaffold(
                      backgroundColor: AppColors.background,
                      body: Center(
                        child: Text(
                          isRtl
                              ? 'لا توجد مقالات منشورة.'
                              : 'No published posts.',
                          style: const TextStyle(
                              fontFamily: 'Cairo', color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  // Resolve selected post
                  final BlogPostModel selectedPost = posts.firstWhere(
                        (p) => p.id == _selectedPostId,
                    orElse: () => posts.first,
                  );

                  final double w       = MediaQuery.of(context).size.width;
                  final bool   isMobile = w < _BP.mobile;

                  return Scaffold(
                    backgroundColor: AppColors.background,
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppNavbar(currentRoute: '/services'),

                          isMobile
                              ? _MobileBody(
                            posts:     posts,
                            selected:  selectedPost,
                            expanded:  _expanded,
                            isRtl:     isRtl,
                            primary:   primary,
                            secondary: secondary,
                            onTabChange: (id) => setState(() {
                              _selectedPostId = id;
                              _expanded       = false;
                            }),
                            onToggleExpand: () => setState(
                                    () => _expanded = !_expanded),
                          )
                              : _DesktopBody(
                            posts:     posts,
                            selected:  selectedPost,
                            expanded:  _expanded,
                            isRtl:     isRtl,
                            primary:   primary,
                            secondary: secondary,
                            onTabChange: (id) => setState(() {
                              _selectedPostId = id;
                              _expanded       = false;
                            }),
                            onToggleExpand: () => setState(
                                    () => _expanded = !_expanded),
                          ),

                          const AppFooter(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileBody extends StatelessWidget {
  final List<BlogPostModel>  posts;
  final BlogPostModel        selected;
  final bool                 expanded;
  final bool                 isRtl;
  final Color                primary;
  final Color                secondary;
  final ValueChanged<String> onTabChange;
  final VoidCallback         onToggleExpand;

  const _MobileBody({
    required this.posts,
    required this.selected,
    required this.expanded,
    required this.isRtl,
    required this.primary,
    required this.secondary,
    required this.onTabChange,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ── Horizontal scrollable tab buttons ─────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: posts.asMap().entries.map((e) {
                final bool isLast = e.key == posts.length - 1;
                return Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                  child: _BlogNavButton(
                    label: _tb(e.value.buttonLabel, isRtl).isNotEmpty
                        ? _tb(e.value.buttonLabel, isRtl)
                        : _tb(e.value.question, isRtl),
                    isSelected: selected.id == e.value.id,
                    onTap:      () => onTabChange(e.value.id),
                    isMobile:   true,
                    primary:    primary,
                    secondary:  secondary,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── Title (question) ──────────────────────────────────────────
          Text(
            _tb(selected.question, isRtl),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   18,
              fontWeight: FontWeight.w700,
              color:      primary,
            ),
          ),
          const SizedBox(height: 16),

          // ── icon + heading + date LEFT, image RIGHT ───────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width:  36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:        secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.bar_chart_rounded,
                            color: primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _tb(selected.descriptionTitle, isRtl),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                        color:      Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(selected.createdAt, isRtl),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   12,
                        color:      Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ✅ SVG-only image
              _BlogImage(
                url:           selected.imageUrl,
                width:         130,
                height:        110,
                radius:        10,
                fallbackColor: secondary,
                primaryColor:  primary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Short description ─────────────────────────────────────────
          Text(
            _tb(selected.shortDescription, isRtl),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize:   13,
              height:     1.7,
              color:      Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

          // ── Read More / Read Less ─────────────────────────────────────
          GestureDetector(
            onTap: onToggleExpand,
            child: Text(
              expanded
                  ? (isRtl ? 'اقرأ أقل'    : 'Read Less')
                  : (isRtl ? 'اقرأ المزيد' : 'Read More'),
              style: TextStyle(
                fontFamily:      'Cairo',
                fontSize:        13,
                fontWeight:      FontWeight.w600,
                color:           primary,
                decoration:      TextDecoration.underline,
                decorationColor: primary,
              ),
            ),
          ),

          // ── Expandable: blocks ────────────────────────────────────────
          if (expanded) ...[
            const SizedBox(height: 20),
            _BlockList(
              blocks:   selected.blocks,
              isRtl:    isRtl,
              fontSize: 13,
              isMobile: true,
              primary:  primary,
            ),
            const SizedBox(height: 32),
          ] else
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopBody extends StatelessWidget {
  final List<BlogPostModel>  posts;
  final BlogPostModel        selected;
  final bool                 expanded;
  final bool                 isRtl;
  final Color                primary;
  final Color                secondary;
  final ValueChanged<String> onTabChange;
  final VoidCallback         onToggleExpand;

  const _DesktopBody({
    required this.posts,
    required this.selected,
    required this.expanded,
    required this.isRtl,
    required this.primary,
    required this.secondary,
    required this.onTabChange,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final double pageW = (450.w * 3) + (12.w * 2);

    return SizedBox(
      width: 1000.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 32.h),

          // ── Tab buttons ────────────────────────────────────────────────
          Center(
            child: SizedBox(
              width: pageW,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: posts.asMap().entries.map((e) {
                  final bool isLast = e.key == posts.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
                    child: _BlogNavButton(
                      label: _tb(e.value.buttonLabel, isRtl).isNotEmpty
                          ? _tb(e.value.buttonLabel, isRtl)
                          : _tb(e.value.question, isRtl),
                      isSelected: selected.id == e.value.id,
                      onTap:      () => onTabChange(e.value.id),
                      isMobile:   false,
                      primary:    primary,
                      secondary:  secondary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // ── Article body ───────────────────────────────────────────────
          Center(
            child: SizedBox(
              width: pageW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question as page title
                  Text(
                    _tb(selected.question, isRtl),
                    style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                      fontSize:   28.sp,
                      fontWeight: FontWeight.w700,
                      color:      primary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Intro row: text left, image right ──────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // descriptionTitle
                            Text(
                              _tb(selected.descriptionTitle, isRtl),
                              style: AppTextStyles.font14BlackCairo.copyWith(
                                fontSize:   15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            // shortDescription
                            Text(
                              _tb(selected.shortDescription, isRtl),
                              style: AppTextStyles.font12BlackCairoRegular
                                  .copyWith(
                                fontSize: 13.sp,
                                height:   1.7,
                                color:    AppColors.secondaryBlack,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            // date
                            Text(
                              _formatDate(selected.createdAt, isRtl),
                              style: AppTextStyles.font10BlackCairoRegular
                                  .copyWith(
                                fontSize: 12.sp,
                                color:    AppColors.secondaryBlack,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Read More / Less
                            GestureDetector(
                              onTap: onToggleExpand,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  expanded
                                      ? (isRtl ? 'اقرأ أقل'    : 'Read Less')
                                      : (isRtl ? 'اقرأ المزيد' : 'Read More'),
                                  style: AppTextStyles.font12BlackCairoRegular
                                      .copyWith(
                                    fontSize:        13.sp,
                                    fontWeight:      FontWeight.w600,
                                    color:           primary,
                                    decoration:      TextDecoration.underline,
                                    decorationColor: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32.w),

                      // ✅ SVG-only image
                      _BlogImage(
                        url:           selected.imageUrl,
                        width:         240.w,
                        height:        190.h,
                        radius:        12.r,
                        fallbackColor: secondary,
                        primaryColor:  primary,
                      ),
                    ],
                  ),

                  // ── Expandable: blocks ─────────────────────────────────
                  if (expanded) ...[
                    SizedBox(height: 28.h),
                    _BlockList(
                      blocks:   selected.blocks,
                      isRtl:    isRtl,
                      fontSize: 13.sp,
                      isMobile: false,
                      primary:  primary,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 48.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOCK LIST — renders all BlogDescriptionBlocks
// ═══════════════════════════════════════════════════════════════════════════════

class _BlockList extends StatelessWidget {
  final List<BlogDescriptionBlock> blocks;
  final bool   isRtl;
  final double fontSize;
  final bool   isMobile;
  final Color  primary; // ✅ passed in so bullet uses CMS color

  const _BlockList({
    required this.blocks,
    required this.isRtl,
    required this.fontSize,
    required this.isMobile,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    int numberingCounter = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        final String text = _tb(block.content, isRtl);

        switch (block.type) {

        // ── Paragraph ───────────────────────────────────────────────
          case BlogBlockType.paragraph:
            numberingCounter = 0;
            return Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 10 : 10.h),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   fontSize,
                  height:     1.7,
                  color:      AppColors.secondaryBlack,
                ),
              ),
            );

        // ── Numbered list item ───────────────────────────────────────
          case BlogBlockType.numbering:
            numberingCounter++;
            final int idx = numberingCounter;
            return Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 10 : 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$idx.  ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   fontSize,
                      height:     1.7,
                      fontWeight: FontWeight.w600,
                      color:      Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   fontSize,
                        height:     1.7,
                        color:      AppColors.secondaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            );

        // ── Bullet point ─────────────────────────────────────────────
          case BlogBlockType.bulletPoint:
            numberingCounter = 0;
            return Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 10 : 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top:   isMobile ? 6.0 : 6.h,
                      right: isRtl ? 0 : (isMobile ? 8.0 : 8.w),
                      left:  isRtl ? (isMobile ? 8.0 : 8.w) : 0,
                    ),
                    child: Container(
                      width:  isMobile ? 6.0 : 6.w,
                      height: isMobile ? 6.0 : 6.w,
                      decoration: BoxDecoration(
                        color: primary, // ✅ uses CMS primary color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   fontSize,
                        height:     1.7,
                        color:      AppColors.secondaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            );
        }
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOG IMAGE — ✅ SVG-only, no Image.network fallback
// ═══════════════════════════════════════════════════════════════════════════════

class _BlogImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;
  final Color  fallbackColor;
  final Color  primaryColor;

  const _BlogImage({
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
    required this.fallbackColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width:  width,
        height: height,
        child: url.isNotEmpty
            ? SvgPicture.network(
          url,
          width:  width,
          height: height,
          fit:    BoxFit.cover,
          placeholderBuilder: (_) => Container(
            width:  width,
            height: height,
            color:  fallbackColor,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color:       primaryColor,
              ),
            ),
          ),
        )
            : Container(
          color: fallbackColor,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: primaryColor,
              size:  width * 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOG NAV BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _BlogNavButton extends StatefulWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;
  final bool         isMobile;
  final Color        primary;
  final Color        secondary;

  const _BlogNavButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isMobile,
    required this.primary,
    required this.secondary,
  });

  @override
  State<_BlogNavButton> createState() => _BlogNavButtonState();
}

class _BlogNavButtonState extends State<_BlogNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected || _hovered;

    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.isMobile
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primary
                : (active ? widget.secondary : Colors.white),
            borderRadius:
            BorderRadius.circular(widget.isMobile ? 10 : 10.r),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   widget.isMobile ? 12 : 13.sp,
              fontWeight: FontWeight.w600,
              color:      widget.isSelected ? Colors.white : widget.primary,
            ),
          ),
        ),
      ),
    );
  }
}