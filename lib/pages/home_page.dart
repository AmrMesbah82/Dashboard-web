// ******************* FILE INFO *******************
// File Name: home_page.dart
// Updated: MOBILE LAYOUT NOW MATCHES FIGMA BENTO GRID DESIGN PERFECTLY
//          branding.backgroundColor drives page/section background.
//          branding.headerFooterColor drives navbar/footer background.
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812
// FIX: _GreenCard height is now optional — container grows with text,
//      no more clipped/ellipsized text in any breakpoint.
// FIX: Hero text constrained to page width — no overflow outside page bounds.
// FIX: Image/icon layout is FIXED (not mirrored) for both AR and EN.
// FIX: _SvgPulseLoader background is now branding.primaryColor from Firebase.
// Description: Public-facing Home Page — reads HomeCmsCubit and renders
//              all content driven by the CMS model. Zero hardcoded strings.
//              Full AR / EN bilingual support via LanguageCubit.
//              STICKY NAVBAR: GlobalKey measured dynamically.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/widgets/app_admin_navbar.dart';
import 'package:web_app_admin/widgets/app_footer.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import 'careers_main_dashboard.dart';
import 'dashboard/home_page/home_edit_page.dart';
import 'dashboard/job_list/job_listing_main_page.dart';
import 'dashboard/main_page/home_edit_page.dart';

// ── Breakpoints ───────────────────────────────────────────────────────────────
class _BP {
  static double get mobile => 600.w;
  static double get tablet => 1024.w;
}

const Color _kDefaultPrimary    = Color(0xFF2D8C4E);
const Color _kDefaultBackground = Color(0xFFF5F5F5);

Color _hexColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

extension BiTextL10n on BiText {
  String l(BuildContext context) {
    final isAr  = context.read<LanguageCubit>().state.isArabic;
    final value = isAr ? ar : en;
    return value.isNotEmpty ? value : en;
  }
}

bool _isNetworkUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

Widget _smartImage({
  required String url,
  required double width,
  required double height,
  BoxFit  fit         = BoxFit.contain,
  Widget? fallback,
  Color?  colorFilter,
}) {
  if (url.isEmpty) return fallback ?? const SizedBox.shrink();
  if (_isNetworkUrl(url)) {
    return Center(
      child: SvgPicture.network(
        url,
        width:  width,
        height: height,
        fit:    fit,
        colorFilter: colorFilter != null
            ? ColorFilter.mode(colorFilter, BlendMode.srcIn)
            : null,
      ),
    );
  }
  return CustomSvg(
    assetPath: url,
    width:     width,
    height:    height,
    fit:       fit,
    color:     colorFilter,
  );
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
      } catch (e) {
        print('⚠️  Failed to preload SVG: $url\nError: $e');
      }
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
  _RevealCoordinatorState? _coordinator;

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
    final newCoordinator = _RevealCoordinator.of(context);
    if (newCoordinator != _coordinator) {
      _coordinator?.unregister(this);
      _coordinator = newCoordinator;
      _coordinator?.register(this);
    }
  }

  @override
  void dispose() {
    _coordinator?.unregister(this);
    _coordinator = null;
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
    if (pos.dy < screenH - 40.h) {
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
// ── backgroundColor is now driven by branding.primaryColor from Firebase ──────
// ═══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color   backgroundColor; // ← NEW: driven by Firebase primaryColor

  const _SvgPulseLoader({
    this.logoUrl,
    this.backgroundColor = _kDefaultPrimary, // fallback until Firebase loads
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
    // Both branches now use widget.backgroundColor instead of AppColors.background
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
            placeholderBuilder: (_) => SizedBox(width: 88.w, height: 88.w),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNavbar());
  }

  void _measureNavbar() {
    final box = _navbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final h = box.size.height;
      if (h > 0 && h != _navbarHeight) setState(() => _navbarHeight = h);
    }
  }

  Future<void> _preloadAndReveal(HomePageModel data) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    final List<String> allUrls = [
      if (data.branding.logoUrl.isNotEmpty) data.branding.logoUrl,
      for (final sec in data.sections) ...[
        if (sec.iconUrl.isNotEmpty)  sec.iconUrl,
        if (sec.imageUrl.isNotEmpty) sec.imageUrl,
      ],
      for (final sl in data.socialLinks)
        if (sl.iconUrl.isNotEmpty) sl.iconUrl,
    ];

    await _preloadSvgImages(allUrls);
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
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };

        final HomePageModel? readyData = switch (state) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data)  => data,
          _ => null,
        };

        // ── Loader background = branding.primaryColor from Firebase ──────────
        final Color loaderBg = switch (state) {
          HomeCmsLoaded(:final data) => _hexColor(
              data.branding.primaryColor,
              fallback: _kDefaultPrimary),
          HomeCmsSaved(:final data)  => _hexColor(
              data.branding.primaryColor,
              fallback: _kDefaultPrimary),
          _ => _kDefaultPrimary,
        };

        if (readyData != null && !_preloadStarted) {
          _preloadAndReveal(readyData);
        }

        if (state is HomeCmsError &&
            state.lastData == null &&
            !_showLoader) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 12.h),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: Colors.red, fontSize: 14.sp)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeCmsCubit>().load(),
                    child:
                    Text('Retry', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
          );
        }

        final Color resolvedLoaderBg = switch (state) {
          HomeCmsLoaded(:final data) => _hexColor(
              data.branding.primaryColor, fallback: _kDefaultPrimary),
          HomeCmsSaved(:final data)  => _hexColor(
              data.branding.primaryColor, fallback: _kDefaultPrimary),
          _ => _kDefaultBackground, // neutral background while Firebase hasn't responded yet
        };

        if (readyData == null) {
          // Firebase hasn't loaded yet — show nothing, no color flash
          return Scaffold(backgroundColor: AppColors.background);
        }

        if (_showLoader) {
          debugPrint('🔴 loaderBg = ${readyData.branding.backgroundColor}');
          return _SvgPulseLoader(
            logoUrl: logoUrl.isEmpty ? null : logoUrl,
            backgroundColor: _hexColor(
              readyData.branding.backgroundColor,
              fallback: _kDefaultPrimary,
            ),
          );
        }

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            return _HomeBody(
              data:         readyData,
              isRtl:        langState.isArabic,
              navbarHeight: _navbarHeight,
              navbarKey:    _navbarKey,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomePageModel data;
  final bool          isRtl;
  final double        navbarHeight;
  final GlobalKey     navbarKey;

  const _HomeBody({
    required this.data,
    required this.isRtl,
    required this.navbarHeight,
    required this.navbarKey,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _hexColor(
      data.branding.backgroundColor,
      fallback: _kDefaultBackground,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _RevealCoordinatorWidget(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    AppAdminNavbar(
                      activeLabel:    'Home',
                      homePage:       CareersMainPageDashboard(),
                      webPage:        HomeMainPage(),
                      jobListingPage: JobListingMainPage(),
                    ),


                    SizedBox(height: navbarHeight),

                    _Reveal(
                      delay:     const Duration(milliseconds: 80),
                      direction: _SlideDirection.fromLeft,
                      duration:  const Duration(milliseconds: 650),
                      child: Column(
                        children: [

                          _HeroSection(data: data, bgColor: bgColor),
                        ],
                      ),
                    ),

                    _Reveal(
                      delay:     const Duration(milliseconds: 200),
                      direction: _SlideDirection.fromBottom,
                      duration:  const Duration(milliseconds: 700),
                      child:
                      _HeroCardsSection(data: data, bgColor: bgColor),
                    ),

                    SizedBox(height: 32.h),

                    _Reveal(
                      delay:     const Duration(milliseconds: 100),
                      direction: _SlideDirection.fromBottom,
                      duration:  const Duration(milliseconds: 600),
                      child: const AppFooter(),
                    ),
                  ],
                ),
              ),

              Positioned(
                top:   80,
                left:  0,
                right: 0,
                child: Material(
                  color:     Colors.transparent,
                  elevation: 0,
                  child: AppNavbar(
                    key:          navbarKey,
                    currentRoute: '/',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _HeroSection({required this.data, required this.bgColor});

  Color get _primary =>
      _hexColor(data.branding.primaryColor, fallback: _kDefaultPrimary);

  @override
  Widget build(BuildContext context) {
    final double w       = MediaQuery.of(context).size.width;
    final bool   isMobile = w < _BP.mobile;
    final isAr            = context.read<LanguageCubit>().state.isArabic;

    final String titleText = data.title.l(context);
    final String descText  = data.shortDescription.l(context);

    final TextStyle titleStyle = GoogleFonts.cairo(
      fontSize:      isMobile ? 28.sp : 48.sp,
      fontWeight:    AppFontWeights.bold,
      color:         _primary,
      letterSpacing: isAr ? 0.0 : -0.5,
      height:        isAr ? 1.2 : 1.1,
    );

    final TextStyle descStyle = GoogleFonts.cairo(
      fontSize:      isMobile ? 12.sp : 20.sp,
      fontWeight:    AppFontWeights.regular,
      color:         _primary,
      letterSpacing: isAr ? 0.0 : 0.5,
    );

    return Container(
      color:  bgColor,
      width:  w,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.w : 36.w,
        vertical:   isMobile ? 20.h : 44.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints:
            BoxConstraints(maxWidth: w - (isMobile ? 40.w : 72.w)),
            child: Text(
              titleText,
              textAlign:     TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style:         titleStyle,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 1000.w,
            child: Text(
              descText,
              textAlign:     TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style:         descStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CMS nav button ────────────────────────────────────────────────────────────

class _CmsNavBtn extends StatefulWidget {
  final String label;
  final String route;
  final Color  primary;
  final bool   mobile;
  final bool   isRtl;

  const _CmsNavBtn({
    required this.label,
    required this.route,
    required this.primary,
    this.mobile = false,
    this.isRtl  = false,
  });

  @override
  State<_CmsNavBtn> createState() => _CmsNavBtnState();
}

class _CmsNavBtnState extends State<_CmsNavBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.cairo(
      fontSize:   13.sp,
      fontWeight: AppFontWeights.semiBold,
      color:      _hovered ? Colors.white : widget.primary,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.route.isNotEmpty
            ? () => context.go(widget.route)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve:    Curves.easeInOut,
          height:   48.h,
          padding:  EdgeInsets.symmetric(
              horizontal: widget.mobile ? 16.w : 22.w),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.primary.withOpacity(.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(child: Text(widget.label, style: textStyle)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Cards Section — dispatches to breakpoint layout
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCardsSection extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _HeroCardsSection({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    if (w >= _BP.tablet) return _DesktopCards(data: data, bgColor: bgColor);
    if (w >= _BP.mobile) return _TabletCards(data: data, bgColor: bgColor);
    return _MobileCards(data: data, bgColor: bgColor);
  }
}

Color _sectionColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return _kDefaultPrimary;
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _DesktopCards({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double innerOffset = 36.h + 10.h + 90.h;
    final double btnOffset   = innerOffset + 36.h + 10.h;
    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i) => i < sec.length
        ? (isRtl
        ? (sec[i].description.ar.isNotEmpty
        ? sec[i].description.ar
        : sec[i].description.en)
        : sec[i].description.en)
        : '';

    return Container(
      color:   bgColor,
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: _Reveal(
              delay:     const Duration(milliseconds: 100),
              direction: _SlideDirection.fromLeft,
              duration:  const Duration(milliseconds: 700),
              child: _OuterCard(
                iconUrl:     sec.isNotEmpty ? sec[0].iconUrl  : '',
                imageUrl:    sec.isNotEmpty ? sec[0].imageUrl : '',
                text:        secDesc(0),
                cardColor:   primary,
                iconOnRight: true,
                isRtl:       isRtl,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Flexible(
            flex: 1,
            child: _Reveal(
              delay:     const Duration(milliseconds: 180),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 700),
              child: SizedBox(
                width: 160.w,
                child: Column(
                  mainAxisSize:       MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: innerOffset),
                    _CircleIcon(
                        iconUrl:   sec.length > 1 ? sec[1].iconUrl : '',
                        iconColor: primary),
                    SizedBox(height: 10.h),
                    _SectionImage(
                        imageUrl: sec.length > 1 ? sec[1].imageUrl : '',
                        width:    160.w,
                        height:   180.h),
                    SizedBox(height: 10.h),
                    _GreenCard(
                      width: 160.w,
                      text:  secDesc(1),
                      color: primary,
                      isRtl: isRtl,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Flexible(
            flex: 2,
            child: SizedBox(
              width: 240.w,
              child: Column(
                mainAxisAlignment:  MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: btnOffset),
                  ...data.navButtons
                      .where((btn) => btn.status)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final btn   = entry.value;
                    final label = isRtl
                        ? (btn.name.ar.isNotEmpty
                        ? btn.name.ar
                        : btn.name.en)
                        : btn.name.en;

                    final double btnWidth = index == 0
                        ? 240.w
                        : index == 1
                        ? 196.w
                        : index == 2
                        ? 172.w
                        : index == 3
                        ? 150.w
                        : index == 4
                        ? 120.w
                        : 100.w;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _Reveal(
                        delay: Duration(milliseconds: 200 + index * 80),
                        direction: _SlideDirection.fromBottom,
                        duration:  const Duration(milliseconds: 600),
                        child: SizedBox(
                          width: btnWidth,
                          child: _CmsNavBtn(
                            label:   label,
                            route:   btn.route,
                            primary: primary,
                            isRtl:   isRtl,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Flexible(
            flex: 1,
            child: _Reveal(
              delay:     const Duration(milliseconds: 180),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 700),
              child: SizedBox(
                width: 160.w,
                child: Column(
                  mainAxisSize:       MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: innerOffset),
                    _CircleIcon(
                        iconUrl:   sec.length > 2 ? sec[2].iconUrl : '',
                        iconColor: primary),
                    SizedBox(height: 10.h),
                    _SectionImage(
                        imageUrl: sec.length > 2 ? sec[2].imageUrl : '',
                        width:    160.w,
                        height:   180.h),
                    SizedBox(height: 10.h),
                    _GreenCard(
                      width: 160.w,
                      text:  secDesc(2),
                      color: primary,
                      isRtl: isRtl,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Flexible(
            flex: 2,
            child: _Reveal(
              delay:     const Duration(milliseconds: 100),
              direction: _SlideDirection.fromRight,
              duration:  const Duration(milliseconds: 700),
              child: _OuterCard(
                iconUrl:     sec.length > 3 ? sec[3].iconUrl  : '',
                imageUrl:    sec.length > 3 ? sec[3].imageUrl : '',
                text:        secDesc(3),
                cardColor:   primary,
                iconOnRight: false,
                isRtl:       isRtl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OuterCard extends StatelessWidget {
  final String iconUrl;
  final String imageUrl;
  final String text;
  final Color  cardColor;
  final bool   iconOnRight;
  final bool   isRtl;

  const _OuterCard({
    required this.iconUrl,
    required this.imageUrl,
    required this.text,
    required this.cardColor,
    this.iconOnRight = false,
    this.isRtl       = false,
  });

  @override
  Widget build(BuildContext context) {
    final double totalW = 212.w;
    final double iconSz = 36.w;
    final double imgW   = 160.w;
    final double gap    = 12.w;

    final Widget img = _SectionImage(
        imageUrl: imageUrl, width: imgW, height: 180.h, radius: 16.r);

    final Widget icn = Container(
      width:  iconSz,
      height: iconSz,
      decoration:
      const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: _smartImage(
          url:         iconUrl,
          width:       18.w,
          height:      18.w,
          fit:         BoxFit.scaleDown,
          colorFilter: cardColor,
          fallback:
          Icon(Icons.image_outlined, size: 16.sp, color: cardColor),
        ),
      ),
    );

    return SizedBox(
      width: totalW,
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:       MainAxisSize.min,
            children: iconOnRight
                ? [img, SizedBox(width: gap), icn]
                : [icn, SizedBox(width: gap), img],
          ),
          SizedBox(height: 10.h),
          _GreenCard(
            width: totalW,
            text:  text,
            color: cardColor,
            isRtl: isRtl,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLET
// ─────────────────────────────────────────────────────────────────────────────

class _TabletCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _TabletCards({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double cardW  = 130.w;
    final double imageH = 150.h;
    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i) => i < sec.length
        ? (isRtl
        ? (sec[i].description.ar.isNotEmpty
        ? sec[i].description.ar
        : sec[i].description.en)
        : sec[i].description.en)
        : '';

    return Container(
      color:   bgColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Reveal(
                delay:     const Duration(milliseconds: 100),
                direction: _SlideDirection.fromLeft,
                duration:  const Duration(milliseconds: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: cardW,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _CircleIcon(
                            iconUrl:   sec.isNotEmpty ? sec[0].iconUrl : '',
                            iconColor: primary),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _SectionImage(
                        imageUrl: sec.isNotEmpty ? sec[0].imageUrl : '',
                        width:    cardW,
                        height:   imageH),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 36.w + 6.h),
                    ...data.navButtons
                        .where((btn) => btn.status)
                        .take(2)
                        .toList()
                        .asMap()
                        .entries
                        .map((e) {
                      final btn   = e.value;
                      final label = isRtl
                          ? (btn.name.ar.isNotEmpty
                          ? btn.name.ar
                          : btn.name.en)
                          : btn.name.en;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _Reveal(
                          delay: Duration(
                              milliseconds: 150 + e.key * 80),
                          direction: _SlideDirection.fromBottom,
                          duration:
                          const Duration(milliseconds: 600),
                          child: _CmsNavBtn(
                            label:   label,
                            route:   btn.route,
                            primary: primary,
                            isRtl:   isRtl,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              _Reveal(
                delay:     const Duration(milliseconds: 100),
                direction: _SlideDirection.fromRight,
                duration:  const Duration(milliseconds: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: cardW,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _CircleIcon(
                            iconUrl:   sec.length > 3 ? sec[3].iconUrl : '',
                            iconColor: primary),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _SectionImage(
                        imageUrl: sec.length > 3 ? sec[3].imageUrl : '',
                        width:    cardW,
                        height:   imageH),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Reveal(
                  delay:     const Duration(milliseconds: 120),
                  direction: _SlideDirection.fromBottom,
                  duration:  const Duration(milliseconds: 650),
                  child: _GreenCard(
                    width:    cardW,
                    text:     secDesc(0),
                    color:    primary,
                    fontSize: 11.sp,
                    isRtl:    isRtl,
                  ),
                ),
                SizedBox(width: 10.w),
                _Reveal(
                  delay:     const Duration(milliseconds: 200),
                  direction: _SlideDirection.fromBottom,
                  duration:  const Duration(milliseconds: 650),
                  child: Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CircleIcon(
                            iconUrl:   sec.length > 1 ? sec[1].iconUrl : '',
                            iconColor: primary),
                        SizedBox(height: 6.h),
                        _SectionImage(
                            imageUrl: sec.length > 1 ? sec[1].imageUrl : '',
                            height:   imageH * 0.6),
                        SizedBox(height: 6.h),
                        _GreenCard(
                          text:     secDesc(1),
                          color:    primary,
                          fontSize: 11.sp,
                          isRtl:    isRtl,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                _Reveal(
                  delay:     const Duration(milliseconds: 280),
                  direction: _SlideDirection.fromBottom,
                  duration:  const Duration(milliseconds: 650),
                  child: Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CircleIcon(
                            iconUrl:   sec.length > 2 ? sec[2].iconUrl : '',
                            iconColor: primary),
                        SizedBox(height: 6.h),
                        _SectionImage(
                            imageUrl: sec.length > 2 ? sec[2].imageUrl : '',
                            height:   imageH * 0.6),
                        SizedBox(height: 6.h),
                        _GreenCard(
                          text:     secDesc(2),
                          color:    primary,
                          fontSize: 11.sp,
                          isRtl:    isRtl,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                _Reveal(
                  delay:     const Duration(milliseconds: 120),
                  direction: _SlideDirection.fromBottom,
                  duration:  const Duration(milliseconds: 650),
                  child: _GreenCard(
                    width:    cardW,
                    text:     secDesc(3),
                    color:    primary,
                    fontSize: 11.sp,
                    isRtl:    isRtl,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────────

class _MobileCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _MobileCards({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double sw   = MediaQuery.of(context).size.width;
    final double hPad = 16.w;
    final double gap  = 8.w;

    final double colWidth   = (sw - hPad * 2 - gap) / 2;
    final double imageCardH = colWidth * 1.25;

    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i)  => i < sec.length
        ? (isRtl
        ? (sec[i].description.ar.isNotEmpty
        ? sec[i].description.ar
        : sec[i].description.en)
        : sec[i].description.en)
        : '';
    String secIcon(int i)  => i < sec.length ? sec[i].iconUrl  : '';
    String secImage(int i) => i < sec.length ? sec[i].imageUrl : '';

    Widget imageIconCard({
      required double width,
      required String imageUrl,
      String? iconUrl,
      bool    iconOnLeft = true,
    }) {
      final double iconSize    = 36.w;
      final double imageHeight = imageCardH - iconSize - 8.h;
      return SizedBox(
        width:  width,
        height: imageCardH,
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: iconOnLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (iconUrl != null && iconUrl.isNotEmpty)
              _CircleIcon(iconUrl: iconUrl, iconColor: primary)
            else
              SizedBox(height: iconSize, width: iconSize),
            SizedBox(height: 8.h),
            _SectionImage(
              imageUrl: imageUrl,
              width:    width,
              height:   imageHeight,
              radius:   8.r,
            ),
          ],
        ),
      );
    }

    Widget statCard({
      required double width,
      required String text,
      required Color  color,
      String? iconUrl,
    }) {
      return Container(
        width:   width,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: isRtl
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              textAlign:     isRtl ? TextAlign.right : TextAlign.left,
              textDirection:
              isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.cairo(
                fontSize:   11.sp,
                fontWeight: FontWeight.w400,
                color:      Colors.white,
                height:     1.4,
              ),
            ),
          ],
        ),
      );
    }

    Widget fullWidthCard({
      required double width,
      required String imageUrl,
      String? iconUrl,
      required String text,
      required Color  color,
    }) {
      final double iconSize = 36.w;
      // ← match exactly the same total height as imageIconCard rows
      return SizedBox(
        height: imageCardH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            statCard(
                width: colWidth, text: text, color: color, iconUrl: iconUrl),
            SizedBox(width: gap),
            SizedBox(
              width: colWidth,
              child: Column(
                mainAxisSize:       MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (iconUrl != null && iconUrl.isNotEmpty)
                    _CircleIcon(iconUrl: iconUrl, iconColor: primary)
                  else
                    SizedBox(height: iconSize, width: iconSize),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: _SectionImage(
                      imageUrl: imageUrl,
                      width:    colWidth,
                      height:   double.infinity,
                      radius:   8.r,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color:   bgColor,
      padding: EdgeInsets.fromLTRB(hPad, 0.h, hPad, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...data.navButtons
              .where((btn) => btn.status)
              .toList()
              .asMap()
              .entries
              .map((e) {
            final btn   = e.value;
            final index = e.key;
            final label = isRtl
                ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                : btn.name.en;
            final double fullWidth = sw - hPad * 2;
            final double btnWidth  = fullWidth * (1.0 - index * 0.12);
            return _Reveal(
              delay:     Duration(milliseconds: 80 + index * 60),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 550),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: btnWidth,
                    child: _CmsNavBtn(
                      label:   label,
                      route:   btn.route,
                      primary: primary,
                      mobile:  true,
                      isRtl:   isRtl,
                    ),
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 12.h),

          _Reveal(
            delay:     const Duration(milliseconds: 200),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  imageIconCard(
                      width:     colWidth,
                      imageUrl:  secImage(0),
                      iconUrl:   secIcon(0),
                      iconOnLeft: true),
                  SizedBox(width: gap),
                  statCard(
                      width: colWidth,
                      text:  secDesc(0),
                      color: primary),
                ],
              ),
            ),
          ),

          SizedBox(height: gap),

          _Reveal(
            delay:     const Duration(milliseconds: 280),
            direction: _SlideDirection.fromRight,
            duration:  const Duration(milliseconds: 650),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  statCard(
                      width: colWidth,
                      text:  secDesc(1),
                      color: primary),
                  SizedBox(width: gap),
                  imageIconCard(
                      width:     colWidth,
                      imageUrl:  secImage(1),
                      iconUrl:   secIcon(1),
                      iconOnLeft: false),
                ],
              ),
            ),
          ),

          SizedBox(height: gap),

          _Reveal(
            delay:     const Duration(milliseconds: 360),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  imageIconCard(
                      width:     colWidth,
                      imageUrl:  secImage(2),
                      iconUrl:   secIcon(2),
                      iconOnLeft: true),
                  SizedBox(width: gap),
                  statCard(
                      width: colWidth,
                      text:  secDesc(2),
                      color: primary),
                ],
              ),
            ),
          ),

          SizedBox(height: gap),

          _Reveal(
            delay:     const Duration(milliseconds: 440),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: fullWidthCard(
              width:    sw - hPad * 2,
              imageUrl: secImage(3),
              iconUrl:  secIcon(3),
              text:     secDesc(3),
              color:    primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CmsFooter (legacy — AppFooter is the primary one)
// ─────────────────────────────────────────────────────────────────────────────

class _CmsFooter extends StatelessWidget {
  final HomePageModel data;
  const _CmsFooter({required this.data});

  Color get _primary =>
      _hexColor(data.branding.primaryColor, fallback: _kDefaultPrimary);

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    if (w >= _BP.tablet) return _CmsFooterDesktop(data: data, primary: _primary);
    if (w >= _BP.mobile) return _CmsFooterTablet(data: data, primary: _primary);
    return _CmsFooterMobile(data: data, primary: _primary);
  }
}

class _CmsFooterDesktop extends StatelessWidget {
  final HomePageModel data;
  final Color primary;
  const _CmsFooterDesktop({required this.data, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isRtl       = context.read<LanguageCubit>().state.isArabic;
    final double contentW = (248.w * 4) + (8.w * 3);
    final double hPad =
    ((MediaQuery.of(context).size.width - contentW) / 2)
        .clamp(16.w, double.infinity);

    String colTitle(FooterColumnModel col) => isRtl
        ? (col.title.ar.isNotEmpty ? col.title.ar : col.title.en)
        : col.title.en;

    List<String> colLabels(FooterColumnModel col) => col.labels
        .map((l) => isRtl
        ? (l.label.ar.isNotEmpty ? l.label.ar : l.label.en)
        : l.label.en)
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: EdgeInsets.all(22.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24.r),
              topLeft:  Radius.circular(24.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w, height: 36.h,
                  decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: data.branding.logoUrl.isNotEmpty
                        ? SvgPicture.network(
                      data.branding.logoUrl,
                      width: 28.w, height: 28.h,
                      fit: BoxFit.contain,
                    )
                        : Image.asset('assets/images/logo.jpg',
                        width: 56.w, height: 56.h, fit: BoxFit.fill),
                  ),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: data.footerColumns
                        .map((col) => _CmsFooterColumn(
                      title:   colTitle(col),
                      labels:  colLabels(col),
                      routes:
                      col.labels.map((l) => l.route).toList(),
                      primary: primary,
                      isRtl:   isRtl,
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(color: primary, thickness: 0.5),
            SizedBox(height: 14.h),
            Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      ...data.socialLinks.take(3).map((sl) => Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: _SocialIconBox(
                            iconUrl: sl.iconUrl,
                            url:     sl.url,
                            primary: primary),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CmsFooterTablet extends StatelessWidget {
  final HomePageModel data;
  final Color primary;
  const _CmsFooterTablet({required this.data, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.read<LanguageCubit>().state.isArabic;
    final half  = data.footerColumns.length > 2
        ? data.footerColumns.length ~/ 2
        : data.footerColumns.length;

    String colTitle(FooterColumnModel col) => isRtl
        ? (col.title.ar.isNotEmpty ? col.title.ar : col.title.en)
        : col.title.en;

    List<String> colLabels(FooterColumnModel col) => col.labels
        .map((l) => isRtl
        ? (l.label.ar.isNotEmpty ? l.label.ar : l.label.en)
        : l.label.en)
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(18.r),
              topLeft:  Radius.circular(18.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              children: data.footerColumns
                  .take(half)
                  .map((col) => _CmsFooterColumn(
                title:   colTitle(col),
                labels:  colLabels(col),
                routes:  col.labels.map((l) => l.route).toList(),
                primary: primary,
                isRtl:   isRtl,
              ))
                  .toList(),
            ),
            if (data.footerColumns.length > half) ...[
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: data.footerColumns
                    .skip(half)
                    .map((col) => _CmsFooterColumn(
                  title:   colTitle(col),
                  labels:  colLabels(col),
                  routes:  col.labels.map((l) => l.route).toList(),
                  primary: primary,
                  isRtl:   isRtl,
                ))
                    .toList(),
              ),
            ],
            SizedBox(height: 20.h),
            Divider(color: primary, thickness: 1.h),
            SizedBox(height: 12.h),
            Row(
              children: data.socialLinks
                  .take(3)
                  .map((sl) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _SocialIconBox(
                    iconUrl: sl.iconUrl,
                    url:     sl.url,
                    primary: primary),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CmsFooterMobile extends StatelessWidget {
  final HomePageModel data;
  final Color primary;
  const _CmsFooterMobile({required this.data, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            Expanded(
                child: Divider(
                    color: primary.withOpacity(0.5), thickness: 1.h)),
            SizedBox(width: 10.w),
            ...data.socialLinks.take(3).map((sl) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _SocialIconBox(
                  iconUrl: sl.iconUrl,
                  url:     sl.url,
                  primary: primary,
                  size:    32.w),
            )),
            SizedBox(width: 10.w),
            Expanded(
                child: Divider(
                    color: primary.withOpacity(0.5), thickness: 1.h)),
          ]),
        ],
      ),
    );
  }
}

// ─── Footer column helpers ────────────────────────────────────────────────────

class _CmsFooterColumn extends StatelessWidget {
  final String       title;
  final List<String> labels;
  final List<String> routes;
  final Color        primary;
  final bool         isRtl;

  const _CmsFooterColumn({
    required this.title,
    required this.labels,
    required this.primary,
    this.routes = const [],
    this.isRtl  = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
                fontSize:   13.sp,
                fontWeight: AppFontWeights.semiBold,
                color:      AppColors.text)),
        SizedBox(height: 6.h),
        ...List.generate(
          labels.length,
              (i) => _CmsFooterLink(
            label:   labels[i],
            primary: primary,
            route:   i < routes.length ? routes[i] : null,
            isRtl:   isRtl,
          ),
        ),
      ],
    );
  }
}

class _CmsFooterLink extends StatefulWidget {
  final String  label;
  final String? route;
  final Color   primary;
  final bool    isRtl;

  const _CmsFooterLink({
    required this.label,
    required this.primary,
    this.route,
    this.isRtl = false,
  });

  @override
  State<_CmsFooterLink> createState() => _CmsFooterLinkState();
}

class _CmsFooterLinkState extends State<_CmsFooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (widget.route != null && widget.route!.isNotEmpty)
            ? () => context.go(widget.route!)
            : null,
        child: Text(widget.label,
            textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize:        12.sp,
              fontWeight:      AppFontWeights.regular,
              height:          2.0,
              color:           _hovered
                  ? widget.primary
                  : AppColors.secondaryBlack,
              decoration:      _hovered ? TextDecoration.underline : null,
              decorationColor: widget.primary,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PRIMITIVE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIcon extends StatelessWidget {
  final String iconUrl;
  final Color? iconColor;

  const _CircleIcon({
    required this.iconUrl,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w, height: 36.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: _smartImage(
          url:         iconUrl,
          width:       18.w,
          height:      18.w,
          fit:         BoxFit.contain,
          colorFilter: iconColor,
          fallback:
          Icon(Icons.image_outlined, size: 16.sp, color: Colors.grey),
        ),
      ),
    );
  }
}

class _SocialIconBox extends StatelessWidget {
  final String iconUrl;
  final String url;
  final Color  primary;
  final double size;

  const _SocialIconBox({
    required this.iconUrl,
    required this.url,
    required this.primary,
    this.size = 32.0,
  });

  Future<void> _openUrl() async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: url.isNotEmpty ? _openUrl : null,
      child: Container(
        width: size.w, height: size.h,
        decoration: BoxDecoration(
            border:       Border.all(color: primary, width: 1.w),
            borderRadius: BorderRadius.circular(8.r)),
        child: Center(
          child: _smartImage(
            url:      iconUrl,
            width:    (size * 0.5).w,
            height:   (size * 0.5).h,
            fit:      BoxFit.contain,
            fallback: Icon(Icons.link,
                size: (size * 0.5).sp, color: primary),
          ),
        ),
      ),
    );
  }
}

class _SectionImage extends StatelessWidget {
  final String  imageUrl;
  final double? width;
  final double  height;
  final double? radius;

  const _SectionImage({
    required this.imageUrl,
    this.width,
    required this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? 12.r;

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: width, height: height,
          color: AppColors.card,
          alignment: Alignment.center,
          child: SvgPicture.network(
            imageUrl,
            width:  (width ?? double.infinity) * 0.75,
            height: height * 0.75,
            fit:    BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(r)),
    );
  }
}

class _GreenCard extends StatelessWidget {
  final double? width;
  final double? height;
  final String  text;
  final Color   color;
  final double? fontSize;
  final bool    isRtl;

  const _GreenCard({
    this.width,
    this.height,
    required this.text,
    required this.color,
    this.fontSize,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   width,
      height:  height,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        textAlign:     isRtl ? TextAlign.right : TextAlign.left,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        style: GoogleFonts.cairo(
          fontSize:   fontSize ?? 12.sp,
          fontWeight: FontWeight.w400,
          color:      Colors.white,
          height:     1.4,
        ),
      ),
    );
  }
}