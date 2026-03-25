// ******************* FILE INFO *******************
// File Name: services_page.dart
// Updated: All sizes normalized to match main.dart ScreenUtil design sizes:
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812
// UPDATED: Full AR / EN bilingual support.
//          PRIMARY COLOR now dynamic from CMS branding.
//          BACKGROUND COLOR now dynamic from CMS branding.headerFooterColor ✅
//          ANIMATION: Scroll-triggered reveal animations on all sections.
//          STICKY NAVBAR: measured dynamically via GlobalKey — content never
//          hides under the navbar.
//          BLOG CARD IMAGE: SVG-only — no Image.network / asset fallback ✅
// FIX: _SvgPulseLoader backgroundColor now uses branding.primaryColor from
//      Firebase. Shows neutral background before Firebase responds, then
//      switches to real primaryColor once HomeCmsLoaded fires.
// FIX: Desktop layout now fully responsive — Flexible wrappers prevent
//      overflow when window is resized/minimized.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/blog/blog_cubit.dart';
import 'package:web_app_admin/controller/blog/blog_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/blog_model.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/pages/blog_control/blog_list_page.dart';
import 'package:web_app_admin/theme/app_theme.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import 'blog_detail_Page.dart';
import 'dashboard/services_page/services_main/services_main_page.dart';
import 'services_control/preview_services.dart';

// Default colors (fallback if CMS data unavailable)
const Color _kDefaultGreen = Color(0xFF2D8C4E);
const Color _kGreenLight   = Color(0xFFE8F5EE);
const Color _kSurface      = Color(0xFFFFFFFF);
const Color _kDivider      = Color(0xFFDDE8DD);

// Neutral loader background shown before Firebase responds
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

double _desktopContentWidth(BuildContext context) {
  final double screen  = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

String _monthName(int m) => const [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
][m];

String _monthNameAr(int m) => const [
  '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
][m];

String _t(BilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

String _tb(BlogBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

extension BilingualTextL10n on BilingualText {
  String l(BuildContext context) {
    final isAr  = context.read<LanguageCubit>().state.isArabic;
    final value = isAr ? ar : en;
    return value.isNotEmpty ? value : en;
  }
}

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PRELOADER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadSvgImages(List<String> urls) async {
  final validUrls = urls
      .where((url) =>
  url.isNotEmpty &&
      (url.startsWith('http://') || url.startsWith('https://')))
      .toSet()
      .toList();

  await Future.wait(
    validUrls.map((url) async {
      try {
        final loader = SvgNetworkLoader(url);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
              () => loader.loadBytes(null),
        );
      } catch (_) {}
    }),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class _RevealCoordinator extends InheritedWidget {
  final _RevealCoordinatorState state;
  const _RevealCoordinator({required this.state, required super.child});

  static _RevealCoordinatorState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealCoordinator>()?.state;

  @override
  bool updateShouldNotify(_RevealCoordinator old) => false;
}

class _RevealCoordinatorWidget extends StatefulWidget {
  final Widget child;
  const _RevealCoordinatorWidget({required this.child});

  @override
  State<_RevealCoordinatorWidget> createState() => _RevealCoordinatorState();
}

class _RevealCoordinatorState extends State<_RevealCoordinatorWidget> {
  final List<_RevealState> _items = [];

  void register(_RevealState item)   => _items.add(item);
  void unregister(_RevealState item) => _items.remove(item);

  void notifyScroll() {
    for (final item in List.of(_items)) {
      item.onScroll();
    }
  }

  @override
  Widget build(BuildContext context) => _RevealCoordinator(
    state: this,
    child: NotificationListener<ScrollNotification>(
      onNotification: (_) {
        notifyScroll();
        return false;
      },
      child: widget.child,
    ),
  );
}

class _Reveal extends StatefulWidget {
  final Widget          child;
  final Duration        delay;
  final Duration        duration;
  final _SlideDirection direction;

  const _Reveal({
    required this.child,
    this.delay     = Duration.zero,
    this.duration  = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  late final Animation<Offset>   _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop    => const Offset(0, -0.18),
      _SlideDirection.fromLeft   => const Offset(-0.18, 0),
      _SlideDirection.fromRight  => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _RevealCoordinator.of(context)?.register(this);
  }

  @override
  void dispose() {
    _RevealCoordinator.of(context)?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos     = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PULSE LOADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color   backgroundColor;
  const _SvgPulseLoader({
    this.logoUrl,
    required this.backgroundColor,
  });

  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl =
    (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null) {
      setState(() => _resolvedUrl = widget.logoUrl);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SvgPicture.network(
            _resolvedUrl!,
            width:  88.w,
            height: 88.w,
            fit:    BoxFit.contain,
            placeholderBuilder: (_) =>
                SizedBox(width: 88.w, height: 88.w),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ServicesPage extends StatefulWidget {
  final String? scrollTo;
  const ServicesPage({super.key, this.scrollTo});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool _showLoader     = true;
  bool _preloadStarted = false;

  final GlobalKey _navbarKey    = GlobalKey();
  double          _navbarHeight = 80;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCmsCubit>().load();
      context.read<BlogCubit>().load();
      context.read<HomeCmsCubit>().load();
      _measureNavbar();
    });
  }

  void _measureNavbar() {
    final box =
    _navbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final h = box.size.height;
      if (h > 0 && h != _navbarHeight) setState(() => _navbarHeight = h);
    }
  }

  Future<void> _preloadAndReveal(List<String> urls) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    await _preloadSvgImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() => _showLoader = false);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _measureNavbar());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {

        // ── backgroundColor from CMS branding ─────────────────────────────
        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => AppColors.background,
        };

        final Color secondaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kGreenLight),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kGreenLight),
          _ => _kGreenLight,
        };

        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };

        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.primaryColor,
              fallback: _kDefaultGreen),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.primaryColor,
              fallback: _kDefaultGreen),
          _ => _kDefaultGreen,
        };

        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        return BlocBuilder<ServiceCmsCubit, ServiceCmsState>(
          builder: (context, serviceState) {
            final ServicePageModel model = switch (serviceState) {
              ServiceCmsLoaded s => s.data,
              ServiceCmsSaved  s => s.data,
              _                  => ServicePageModel.empty(),
            };

            final bool servicesReady = serviceState is ServiceCmsLoaded ||
                serviceState is ServiceCmsSaved;

            return BlocBuilder<BlogCubit, BlogState>(
              builder: (context, blogState) {
                final bool blogReady =
                    blogState is BlogLoaded || blogState is BlogError;

                final bool allDataReady =
                    homeReady && servicesReady && blogReady;

                if (allDataReady && !_preloadStarted) {
                  final List<String> allUrls = [
                    if (logoUrl.isNotEmpty) logoUrl,
                    ...model.journeyItems.map((e) => e.iconUrl),
                    if (blogState is BlogLoaded)
                      ...blogState.posts
                          .where((p) => p.status == 'published')
                          .take(3)
                          .map((p) => p.imageUrl),
                  ];
                  _preloadAndReveal(allUrls);
                }

                if (!homeReady) {
                  return Scaffold(backgroundColor: AppColors.background);
                }

                if (_showLoader || !allDataReady) {
                  return _SvgPulseLoader(
                    logoUrl:         logoUrl.isEmpty ? null : logoUrl,
                    backgroundColor: homeReady
                        ? _parseColor(
                        context.read<HomeCmsCubit>().current.branding.backgroundColor,
                        fallback: AppColors.background)
                        : AppColors.background,
                  );
                }

                final List<BlogPostModel> blogs = blogState is BlogLoaded
                    ? blogState.posts
                    .where((p) => p.status == 'published')
                    .take(3)
                    .toList()
                    : [];

                return BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    final bool   isRtl = langState.isArabic;
                    final double w     = MediaQuery.of(context).size.width;

                    return Directionality(
                      textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Scaffold(
                        backgroundColor: backgroundColor,
                        body: _RevealCoordinatorWidget(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: _navbarHeight),

                                    _Reveal(
                                      delay:     const Duration(
                                          milliseconds: 80),
                                      direction:
                                      _SlideDirection.fromLeft,
                                      duration: const Duration(
                                          milliseconds: 650),
                                      child: w < _BP.mobile
                                          ? _ServicesHeaderMobile(
                                          model:        model,
                                          isRtl:        isRtl,
                                          primaryColor: primaryColor)
                                          : _ServicesHeaderDesktop(
                                          model:        model,
                                          isRtl:        isRtl,
                                          primaryColor: primaryColor),
                                    ),

                                    _ServicesBody(
                                      model:          model,
                                      blogs:          blogs,
                                      isRtl:          isRtl,
                                      primaryColor:   primaryColor,
                                      secondaryColor: secondaryColor,
                                    ),

                                    _Reveal(
                                      delay:     const Duration(
                                          milliseconds: 100),
                                      direction:
                                      _SlideDirection.fromBottom,
                                      duration: const Duration(
                                          milliseconds: 600),
                                      child: const AppFooter(),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top:   0,
                                left:  0,
                                right: 0,
                                child: Material(
                                  color:     backgroundColor,
                                  elevation: 0,
                                  child: AppNavbar(
                                    key:          _navbarKey,
                                    currentRoute: '/services',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Header Desktop ───────────────────────────────────────────────────────────

class _ServicesHeaderDesktop extends StatelessWidget {
  final ServicePageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _ServicesHeaderDesktop(
      {required this.model,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(16.0, double.infinity); // ← was 36.0

    final String title = _t(model.title, isRtl).isNotEmpty
        ? _t(model.title, isRtl)
        : (isRtl ? 'الخدمات' : 'Services');
    final String desc = _t(model.shortDescription, isRtl).isNotEmpty
        ? _t(model.shortDescription, isRtl)
        : (isRtl
        ? 'تقدم بيانتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي في مؤسستك.'
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                  fontSize:   48.sp,
                  fontWeight: FontWeight.w900,
                  color:      primaryColor)),
          SizedBox(height: 12.h),
          Text(desc,
              style: AppTextStyles.font14BlackRegularCairo.copyWith(
                  fontSize:   16.sp,
                  height:     1.7,
                  fontWeight: FontWeight.w500,
                  color:      AppColors.secondaryBlack)),
        ],
      ),
    );
  }
}

// ─── Header Mobile ────────────────────────────────────────────────────────────

class _ServicesHeaderMobile extends StatelessWidget {
  final ServicePageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _ServicesHeaderMobile(
      {required this.model,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String title = _t(model.title, isRtl).isNotEmpty
        ? _t(model.title, isRtl)
        : (isRtl ? 'الخدمات' : 'Services');
    final String desc = _t(model.shortDescription, isRtl).isNotEmpty
        ? _t(model.shortDescription, isRtl)
        : (isRtl
        ? 'تقدم بيانتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي في مؤسستك.'
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                  fontSize:   28.sp,
                  fontWeight: FontWeight.w900,
                  color:      primaryColor)),
          SizedBox(height: 10.h),
          Text(desc,
              style: AppTextStyles.font14BlackRegularCairo.copyWith(
                  fontSize:   13.sp,
                  height:     1.7,
                  fontWeight: FontWeight.w500,
                  color:      AppColors.secondaryBlack)),
        ],
      ),
    );
  }
}

// ─── Body dispatcher ──────────────────────────────────────────────────────────

class _ServicesBody extends StatelessWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBody({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    if (w >= _BP.tablet)
      return _ServicesBodyDesktop(
          model:          model,
          blogs:          blogs,
          isRtl:          isRtl,
          primaryColor:   primaryColor,
          secondaryColor: secondaryColor);
    if (w >= _BP.mobile)
      return _ServicesBodyTablet(
          model:          model,
          blogs:          blogs,
          isRtl:          isRtl,
          primaryColor:   primaryColor,
          secondaryColor: secondaryColor);
    return _ServicesBodyMobile(
        model:          model,
        blogs:          blogs,
        isRtl:          isRtl,
        primaryColor:   primaryColor,
        secondaryColor: secondaryColor);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _ServicesBodyDesktop extends StatefulWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyDesktop({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ServicesBodyDesktop> createState() => _ServicesBodyDesktopState();
}

class _ServicesBodyDesktopState extends State<_ServicesBodyDesktop> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(16.0, double.infinity); // ← was 36.0
    final double gap = 10.w;

    final String sectionTitle =
    _t(widget.model.journeyTitle, widget.isRtl).isNotEmpty
        ? _t(widget.model.journeyTitle, widget.isRtl)
        : (widget.isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    widget.isRtl ? 'قراءات مهمة' : 'Important Reads';

    final bool hasMore = widget.model.journeyItems.length > 4;
    final List<JourneyItemModel> visibleItems =
    hasMore && !_showAll
        ? widget.model.journeyItems.take(4).toList()
        : widget.model.journeyItems;

    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < visibleItems.length; i += 4) {
      rows.add(visibleItems.skip(i).take(4).toList());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // ── Title row ──────────────────────────────────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(sectionTitle,
                      style: StyleText.fontSize22Weight700.copyWith(
                          fontSize:   30.sp,
                          color:      widget.primaryColor,
                          fontWeight: AppFontWeights.extraBold)),
                ),
                if (hasMore)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showAll = !_showAll),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color:        widget.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: widget.primaryColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _showAll
                                  ? (widget.isRtl ? 'عرض أقل' : 'See Less')
                                  : (widget.isRtl ? 'عرض المزيد' : 'See More'),
                              style: StyleText.fontSize13Weight600.copyWith(
                                color:    Colors.white,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            AnimatedRotation(
                              turns:    _showAll ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size:  18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Service cards ──────────────────────────────────────────────
          widget.model.journeyItems.isEmpty
              ? _Reveal(
            delay:     const Duration(milliseconds: 150),
            direction: _SlideDirection.fromBottom,
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(
                  color:        _kSurface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _kDivider)),
              child: Center(
                child: Text(
                    widget.isRtl
                        ? 'لم تتم إضافة خدمات بعد.'
                        : 'No services added yet.',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   12.sp,
                        color:      _kDivider)),
              ),
            ),
          )
              : AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve:    Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows.asMap().entries.map((rowEntry) {
                final int  rowIdx    = rowEntry.key;
                final bool isLastRow = rowIdx == rows.length - 1;
                return Padding(
                    padding: EdgeInsets.only(bottom: isLastRow ? 0 : gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize:       MainAxisSize.max,
                    children: rowEntry.value
                        .asMap()
                        .entries
                        .map((e) {
                      final int  cardIdx = e.key;
                      final bool isLast  = cardIdx == rowEntry.value.length - 1;
                      final int  delayMs = 120 + rowIdx * 60 + cardIdx * 80;
                      return Flexible( // ← was no Flexible
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                              end: isLast ? 0 : gap),
                          child: _Reveal(
                            delay:     Duration(milliseconds: delayMs),
                            direction: _SlideDirection.fromBottom,
                            duration:  const Duration(milliseconds: 650),
                            child: SizedBox(
                              width: double.infinity, // ← was cardW
                              child: _ServiceCardDesktop(
                                  item:           e.value,
                                  isRtl:          widget.isRtl,
                                  primaryColor:   widget.primaryColor,
                                  secondaryColor: widget.secondaryColor),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ));
              }).toList(),
            ),
          ),
          SizedBox(height: 36.h),

          // ── Blog section title ─────────────────────────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Text(importantReads,
                style: StyleText.fontSize22Weight700.copyWith(
                    fontSize:   30.sp,
                    color:      widget.primaryColor,
                    fontWeight: AppFontWeights.extraBold)),
          ),
          SizedBox(height: 14.h),

          // ── Blog cards ─────────────────────────────────────────────────
          // ── Blog cards ─────────────────────────────────────────────────────────
          if (widget.blogs.isNotEmpty)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize:       MainAxisSize.min,  // ← restore to min
                children: widget.blogs.asMap().entries.map((e) {
                  final int  i      = e.key;
                  final bool isLast = i == widget.blogs.length - 1;
                  final _SlideDirection dir = i == 0
                      ? _SlideDirection.fromLeft
                      : i == widget.blogs.length - 1
                      ? _SlideDirection.fromRight
                      : _SlideDirection.fromBottom;
                  final double blogCardW = (contentW - gap * 2) / 3; // ← restore fixed width
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: isLast ? 0 : gap),
                    child: _Reveal(
                      delay:     Duration(milliseconds: 100 + i * 120),
                      direction: dir,
                      duration:  const Duration(milliseconds: 700),
                      child: SizedBox(
                        width: blogCardW,  // ← restore fixed width
                        child: _BlogCardDesktop(
                            post:         e.value,
                            isRtl:        widget.isRtl,
                            primaryColor: widget.primaryColor),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 36.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _ServicesBodyTablet extends StatelessWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyTablet({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double hPad    = 16.w;
    final double gap     = 10.w;
    final double cardW   = (screenW - hPad * 2 - gap) / 2;

    final String sectionTitle =
    _t(model.journeyTitle, isRtl).isNotEmpty
        ? _t(model.journeyTitle, isRtl)
        : (isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    isRtl ? 'قراءات مهمة' : 'Important Reads';

    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < model.journeyItems.length; i += 2) {
      rows.add(model.journeyItems.skip(i).take(2).toList());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            child: Text(sectionTitle,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   16.sp,
                    fontWeight: FontWeight.w800,
                    color:      primaryColor,
                    height:     1.4)),
          ),
          SizedBox(height: 14.h),

          ...rows.asMap().entries.map((rowEntry) {
            final int  rowIdx    = rowEntry.key;
            final bool isLastRow = rowIdx == rows.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLastRow ? 0 : gap),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize:       MainAxisSize.max,
                children: rowEntry.value.asMap().entries.map((e) {
                  final int  cardIdx = e.key;
                  final bool isLast  = cardIdx == rowEntry.value.length - 1;
                  final int  delayMs = 100 + rowIdx * 60 + cardIdx * 90;
                  return Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: isLast ? 0 : gap),
                      child: _Reveal(
                        delay:     Duration(milliseconds: delayMs),
                        direction: _SlideDirection.fromBottom,
                        duration:  const Duration(milliseconds: 650),
                        child: SizedBox(
                          width: double.infinity,
                          child: _ServiceCardMobile(
                              item:           e.value,
                              isRtl:          isRtl,
                              primaryColor:   primaryColor,
                              secondaryColor: secondaryColor),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ));
          }),
          SizedBox(height: 30.h),

          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            child: Text(importantReads,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   18.sp,
                    fontWeight: FontWeight.w800,
                    color:      primaryColor,
                    height:     1.4)),
          ),
          SizedBox(height: 14.h),

          Wrap(
            spacing:    gap,
            runSpacing: gap,
            children: blogs.asMap().entries.map((e) => _Reveal(
              delay:     Duration(milliseconds: 100 + e.key * 110),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 650),
              child: SizedBox(
                width: cardW,
                child: _BlogCardMobile(
                    post:         e.value,
                    isRtl:        isRtl,
                    primaryColor: primaryColor),
              ),
            )).toList(),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _ServicesBodyMobile extends StatelessWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyMobile({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String sectionTitle =
    _t(model.journeyTitle, isRtl).isNotEmpty
        ? _t(model.journeyTitle, isRtl)
        : (isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    isRtl ? 'قراءات مهمة' : 'Important Reads';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            child: Text(sectionTitle,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w800,
                    color:      primaryColor,
                    height:     1.4)),
          ),
          SizedBox(height: 14.h),

          ...model.journeyItems.asMap().entries.map((e) => _Reveal(
            delay:     Duration(milliseconds: 100 + e.key * 90),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _ServiceCardMobile(
                  item:           e.value,
                  isRtl:          isRtl,
                  primaryColor:   primaryColor,
                  secondaryColor: secondaryColor),
            ),
          )),
          SizedBox(height: 24.h),

          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            child: Text(importantReads,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   18.sp,
                    fontWeight: FontWeight.w800,
                    color:      primaryColor,
                    height:     1.4)),
          ),
          SizedBox(height: 14.h),

          ...blogs.asMap().entries.map((e) => _Reveal(
            delay:     Duration(milliseconds: 100 + e.key * 120),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _BlogCardMobile(
                  post:         e.value,
                  isRtl:        isRtl,
                  primaryColor: primaryColor),
            ),
          )),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

Widget _svgIconBox({
  required String url,
  required double size,
  required double radius,
  required Color  primaryColor,
  Color secondaryColor = _kGreenLight,
}) {
  return Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(
        color:        secondaryColor,
        borderRadius: BorderRadius.circular(radius)),
    child: Center(
      child: url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SvgPicture.network(
          url,
          width:  size * 0.6,
          height: size * 0.6,
          fit:    BoxFit.contain,
          colorFilter: ColorFilter.mode(
            primaryColor,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (_) => SizedBox(
            width:  size * 0.5,
            height: size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color:       primaryColor,
            ),
          ),
        ),
      )
          : Icon(Icons.miscellaneous_services_outlined,
          size: size * 0.5, color: AppColors.textButton),
    ),
  );
}

Widget _svgBlogImage({
  required String url,
  required double width,
  required double height,
  required double radius,
  Color primaryColor = _kDefaultGreen,
}) {
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
          color: _kGreenLight,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color:       primaryColor,
            ),
          ),
        ),
      )
          : Container(color: _kGreenLight),
    ),
  );
}

// ─── Service Card – Mobile / Tablet ──────────────────────────────────────────

class _ServiceCardMobile extends StatelessWidget {
  final JourneyItemModel item;
  final bool             isRtl;
  final Color            primaryColor;
  final Color            secondaryColor;
  const _ServiceCardMobile({
    required this.item,
    this.isRtl = false,
    required this.primaryColor,
    this.secondaryColor = _kGreenLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color:        _kSurface,
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _svgIconBox(
                  url:            item.iconUrl,
                  size:           36.w,
                  radius:         8.r,
                  primaryColor:   primaryColor,
                  secondaryColor: secondaryColor),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(_t(item.title, isRtl),
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w600,
                        color:      const Color(0xFF1A1A1A))),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(_t(item.description, isRtl),
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12.sp,
                  fontWeight: FontWeight.w400,
                  color:      AppColors.secondaryBlack,
                  height:     1.6)),
        ],
      ),
    );
  }
}

// ─── Service Card – Desktop ───────────────────────────────────────────────────

class _ServiceCardDesktop extends StatefulWidget {
  final JourneyItemModel item;
  final bool             isRtl;
  final Color            primaryColor;
  final Color            secondaryColor;
  const _ServiceCardDesktop({
    required this.item,
    this.isRtl = false,
    required this.primaryColor,
    this.secondaryColor = _kGreenLight,
  });
  @override
  State<_ServiceCardDesktop> createState() => _ServiceCardDesktopState();
}

class _ServiceCardDesktopState extends State<_ServiceCardDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:    double.infinity,
        padding:  EdgeInsets.all(14.r),
        decoration: BoxDecoration(
            color:        _kSurface,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _svgIconBox(
                url:            widget.item.iconUrl,
                size:           30.w,
                radius:         7.r,
                primaryColor:   widget.primaryColor,
                secondaryColor: widget.secondaryColor),
            SizedBox(height: 10.h),
            Text(_t(widget.item.title, widget.isRtl),
                style: StyleText.fontSize14Weight400
                    .copyWith(fontSize: 13.sp)),
            SizedBox(height: 6.h),
            Text(_t(widget.item.description, widget.isRtl),
                style: StyleText.fontSize12Weight500.copyWith(
                    color:    AppColors.secondaryBlack,
                    fontSize: 11.sp,
                    height:   1.6)),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Card – Mobile ───────────────────────────────────────────────────────

class _BlogCardMobile extends StatelessWidget {
  final BlogPostModel post;
  final bool          isRtl;
  final Color         primaryColor;
  const _BlogCardMobile({
    required this.post,
    this.isRtl = false,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String dateStr = post.createdAt != null
        ? isRtl
        ? '${post.createdAt!.day} ${_monthNameAr(post.createdAt!.month)} ${post.createdAt!.year}'
        : '${post.createdAt!.day} ${_monthName(post.createdAt!.month)} ${post.createdAt!.year}'
        : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color:        _kSurface,
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width:  double.infinity,
                height: 80.h,
                child: post.imageUrl.isNotEmpty
                    ? SvgPicture.network(
                  post.imageUrl,
                  width:  double.infinity,
                  height: 80.h,
                  fit:    BoxFit.cover,
                  placeholderBuilder: (_) => Container(
                    color: _kGreenLight,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color:       primaryColor,
                      ),
                    ),
                  ),
                )
                    : Container(color: _kGreenLight),
              ),
            ),
            SizedBox(height: 12.h),
            Text(_tb(post.question, isRtl),
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w600,
                    color:      primaryColor,
                    height:     1.4)),
            SizedBox(height: 8.h),
            Text('• • • • • • • • • • • • • • • • •',
                style: TextStyle(
                    color:         _kDivider,
                    fontSize:      8.sp,
                    letterSpacing: 1.5)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(dateStr,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   12.sp,
                        color:      AppColors.secondaryBlack)),
                const Spacer(),
                _ReadMoreBtnMobile(
                  label:        isRtl ? 'اقرأ المزيد' : 'Read More',
                  onTap:        () => context.goNamed('blog-list'),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Card – Desktop ──────────────────────────────────────────────────────

class _BlogCardDesktop extends StatefulWidget {
  final BlogPostModel post;
  final bool          isRtl;
  final Color         primaryColor;
  const _BlogCardDesktop({
    required this.post,
    this.isRtl = false,
    required this.primaryColor,
  });
  @override
  State<_BlogCardDesktop> createState() => _BlogCardDesktopState();
}

class _BlogCardDesktopState extends State<_BlogCardDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final String dateStr = widget.post.createdAt != null
        ? widget.isRtl
        ? '${_monthNameAr(widget.post.createdAt!.month)} ${widget.post.createdAt!.day} ${widget.post.createdAt!.year}'
        : '${_monthName(widget.post.createdAt!.month)} ${widget.post.createdAt!.day} ${widget.post.createdAt!.year}'
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 200),
        decoration: BoxDecoration(
            color:        _kSurface,
            borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:       MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:       MainAxisSize.max,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_tb(widget.post.question, widget.isRtl),
                            style: StyleText.fontSize12Weight500
                                .copyWith(
                                fontSize:   15.sp,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 10.h),
                        Text('• • • • • • • • • • •',
                            style: TextStyle(
                                color:         _kDivider,
                                fontSize:      9.sp,
                                letterSpacing: 2)),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _svgBlogImage(
                      url:          widget.post.imageUrl,
                      width:        80.w,
                      height:       96.h,
                      radius:       10.r,
                      primaryColor: widget.primaryColor),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Text(dateStr,
                      style: AppTextStyles.font14BlackCairoRegular
                          .copyWith(
                          color:    AppColors.secondaryBlack,
                          fontSize: 12.sp)),
                  const Spacer(),
                  _ReadMoreBtnDesktop(
                      isRtl:        widget.isRtl,
                      primaryColor: widget.primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Read-more buttons ────────────────────────────────────────────────────────

class _ReadMoreBtnMobile extends StatelessWidget {
  final VoidCallback onTap;
  final String       label;
  final Color        primaryColor;
  const _ReadMoreBtnMobile({
    required this.onTap,
    this.label = 'Read More',
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
            color:        primaryColor,
            borderRadius: BorderRadius.circular(7.r)),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   12.sp,
                fontWeight: FontWeight.w600,
                color:      Colors.white)),
      ),
    );
  }
}

class _ReadMoreBtnDesktop extends StatefulWidget {
  final bool  isRtl;
  final Color primaryColor;
  const _ReadMoreBtnDesktop({
    this.isRtl = false,
    required this.primaryColor,
  });
  @override
  State<_ReadMoreBtnDesktop> createState() => _ReadMoreBtnDesktopState();
}

class _ReadMoreBtnDesktopState extends State<_ReadMoreBtnDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverColor =
    Color.lerp(widget.primaryColor, Colors.black, 0.2)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor:  SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => BlogDetailPage())),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:    88.w,
          height:   28.h,
          decoration: BoxDecoration(
              color:        _hovered ? hoverColor : widget.primaryColor,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
            child: Text(
                widget.isRtl ? 'اقرأ المزيد' : 'Read More',
                style: AppTextStyles.font12WhiteCairo.copyWith(
                    fontSize:   12.sp,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}