// ******************* FILE INFO *******************
// File Name: about_page.dart
// UPDATED: backgroundColor now dynamic from CMS branding.backgroundColor ✅
// UPDATED: Deep-link support — reads ?tab=<key> from GoRouter query params
// UPDATED: All SvgPicture.network / Image.network replaced with XHR loader
// UPDATED: Source.server used in repo for fresh Firestore data
// UPDATED: _tabDesc now uses subDescription for left tab card preview
// UPDATED: Values grid fully dynamic from Firestore (no more _kStaticValues)
// UPDATED: _ValueDetailPanel shows shortDescription + description from Firestore
// UPDATED: Tab 1 Our Strategy loads SVG from StrategyCubit (not AboutPageModel)
// UPDATED: Values grid — first value (Main Icon) shown only in left tab,
//          remaining values shown in right panel grid

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/pages/about_us_control/about_us_preview.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import '../model/home_model.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../controller/about_us/about_us_cubit.dart';
import '../controller/about_us/about_us_state.dart';
import '../model/about_us.dart';

const Color _kDefaultGreen = Color(0xFF2D8C4E);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

double _desktopContentWidth(BuildContext context) {
  final double screen = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

({int topTab, int subTab}) _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'our-strategy':
      return (topTab: 1, subTab: 0);
    case 'terms-and-conditions':
      return (topTab: 2, subTab: 0);
    case 'privacy-policy':
      return (topTab: 3, subTab: 0);
    case 'vision':
      return (topTab: 0, subTab: 0);
    case 'mission':
      return (topTab: 0, subTab: 1);
    case 'values':
      return (topTab: 0, subTab: 2);
    case 'our-team':
    case 'why-join-our-team':
    case 'about-us':
    default:
      return (topTab: 0, subTab: 0);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR Image Cache
// ══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header = String.fromCharCodes(
    b.sublist(0, b.length.clamp(0, 100)),
  ).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();
  final bool hintSvg = _isSvgUrl(url);
  Widget inner = FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: hintSvg),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return placeholder ?? SizedBox(width: width, height: height);
      }
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            colorFilter: colorFilter,
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return errorWidget ??
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: (width ?? height ?? 24).toDouble(),
          );
    },
  );
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Preload helpers
// ══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where(
        (u) =>
            u.isNotEmpty &&
            (u.startsWith('http://') || u.startsWith('https://')),
      )
      .toSet();
  await Future.wait(
    valid.map(
      (url) =>
          _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

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
  void register(_RevealState item) {
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) item.onScroll();
      });
    });
  }

  void unregister(_RevealState item) => _items.remove(item);
  void notifyScroll() {
    for (final item in List.of(_items)) item.onScroll();
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
  final Widget child;
  final Duration delay, duration;
  final _SlideDirection direction;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
      Future.delayed(
        widget.delay + const Duration(milliseconds: 120),
        () => _checkAndTrigger(),
      );
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
    final pos = box.localToGlobal(Offset.zero);
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

// ══════════════════════════════════════════════════════════════════════════════
// SVG Pulse Loader
// ══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});
  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null)
      setState(() => _resolvedUrl = widget.logoUrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null)
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: _netImg(
            url: _resolvedUrl!,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AboutCubit()..load()),
        BlocProvider(create: (_) => TermsCubit()..load()),
        BlocProvider(create: (_) => StrategyCubit()..load()),
      ],
      child: const _AboutPageView(),
    );
  }
}

class _AboutPageView extends StatefulWidget {
  const _AboutPageView();
  @override
  State<_AboutPageView> createState() => _AboutPageViewState();
}

class _AboutPageViewState extends State<_AboutPageView> {
  bool _showLoader = true, _preloadStarted = false;
  int? _initialTopTab, _initialSubTab;
  bool _tabParamApplied = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
      _readTabParam();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readTabParam();
  }

  void _readTabParam() {
    if (!mounted) return;
    try {
      final uri = GoRouterState.of(context).uri;
      final tabParam = uri.queryParameters['tab'];
      if (tabParam != null && tabParam.isNotEmpty) {
        final resolved = _resolveTabParam(tabParam);
        if (_initialTopTab != resolved.topTab ||
            _initialSubTab != resolved.subTab) {
          setState(() {
            _initialTopTab = resolved.topTab;
            _initialSubTab = resolved.subTab;
            _tabParamApplied = false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required AboutPageModel model,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;
    final urls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (model.vision.iconUrl.isNotEmpty) model.vision.iconUrl,
      if (model.vision.svgUrl.isNotEmpty) model.vision.svgUrl,
      if (model.mission.iconUrl.isNotEmpty) model.mission.iconUrl,
      if (model.mission.svgUrl.isNotEmpty) model.mission.svgUrl,
      for (final v in model.values)
        if (v.iconUrl.isNotEmpty) v.iconUrl,
    ];
    await _preloadImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data) => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };
        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultGreen,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultGreen,
          ),
          _ => _kDefaultGreen,
        };
        final Color secondaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.secondaryColor,
            fallback: _kGreenLight,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.secondaryColor,
            fallback: _kGreenLight,
          ),
          _ => _kGreenLight,
        };
        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          _ => AppColors.background,
        };
        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            final AboutPageModel? model = switch (state) {
              AboutLoaded() => state.data,
              AboutSaved() => state.data,
              _ => null,
            };
            final bool aboutReady = model != null,
                isError = state is AboutError,
                allReady = homeReady && aboutReady;
            if (allReady && !_preloadStarted)
              _preloadAndReveal(logoUrl: logoUrl, model: model!);
            if (isError && !aboutReady)
              return Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Failed to load: ${(state as AboutError).message}',
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            final Color loaderBg = switch (homeState) {
              HomeCmsLoaded(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              HomeCmsSaved(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              _ => _kLoaderNeutral,
            };
            if (_showLoader || !allReady)
              return _SvgPulseLoader(
                logoUrl: logoUrl.isEmpty ? null : logoUrl,
                backgroundColor: loaderBg,
              );

            return BlocBuilder<TermsCubit, TermsState>(
              builder: (context, termsState) {
                final TermsOfServiceModel termsModel = switch (termsState) {
                  TermsLoaded(:final data) => data,
                  TermsSaved(:final data) => data,
                  _ => TermsOfServiceModel.empty(),
                };
                return BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    final bool isRtl = langState.isArabic;
                    final double w = MediaQuery.of(context).size.width,
                        screenH = MediaQuery.of(context).size.height;
                    return Directionality(
                      textDirection: isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Scaffold(
                        backgroundColor: backgroundColor,
                        body: Stack(
                          children: [
                            _RevealCoordinatorWidget(
                              child: SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: screenH,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 80.h),
                                        _Reveal(
                                          delay: const Duration(
                                            milliseconds: 80,
                                          ),
                                          direction: _SlideDirection.fromLeft,
                                          duration: const Duration(
                                            milliseconds: 650,
                                          ),
                                          child: w < _BP.mobile
                                              ? _AboutHeaderMobile(
                                                  model: model!,
                                                  isRtl: isRtl,
                                                  primaryColor: primaryColor,
                                                )
                                              : _AboutHeaderDesktop(
                                                  model: model!,
                                                  isRtl: isRtl,
                                                  primaryColor: primaryColor,
                                                ),
                                        ),
                                        w < _BP.mobile
                                            ? _AboutBodyMobile(
                                                model: model!,
                                                isRtl: isRtl,
                                                primaryColor: primaryColor,
                                                secondaryColor: secondaryColor,
                                                initialTopTab: _tabParamApplied
                                                    ? null
                                                    : _initialTopTab,
                                                initialSubTab: _tabParamApplied
                                                    ? null
                                                    : _initialSubTab,
                                                onTabApplied: () =>
                                                    _tabParamApplied = true,
                                              )
                                            : w < _BP.tablet
                                            ? _AboutBodyTablet(
                                                model: model!,
                                                isRtl: isRtl,
                                                primaryColor: primaryColor,
                                                secondaryColor: secondaryColor,
                                                initialSubTab: _tabParamApplied
                                                    ? null
                                                    : _initialSubTab,
                                                onTabApplied: () =>
                                                    _tabParamApplied = true,
                                              )
                                            : _AboutBodyDesktop(
                                                model: model!,
                                                termsModel: termsModel,
                                                isRtl: isRtl,
                                                primaryColor: primaryColor,
                                                secondaryColor: secondaryColor,
                                                initialTopTab: _tabParamApplied
                                                    ? null
                                                    : _initialTopTab,
                                                initialSubTab: _tabParamApplied
                                                    ? null
                                                    : _initialSubTab,
                                                onTabApplied: () =>
                                                    _tabParamApplied = true,
                                              ),
                                        const Spacer(),
                                        _Reveal(
                                          delay: const Duration(
                                            milliseconds: 100,
                                          ),
                                          direction: _SlideDirection.fromBottom,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          child: const AppFooter(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Material(
                                color: backgroundColor,
                                elevation: 0,
                                child: AppNavbar(currentRoute: '/about'),
                              ),
                            ),
                          ],
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

// ══════════════════════════════════════════════════════════════════════════════
// Headers
// ══════════════════════════════════════════════════════════════════════════════

class _AboutHeaderDesktop extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity);
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36.h),
      child: Text(
        title,
        style: StyleText.fontSize45Weight600.copyWith(
          fontSize: 48.sp,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
    );
  }
}

class _AboutHeaderMobile extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderMobile({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Text(
        title,
        style: StyleText.fontSize45Weight600.copyWith(
          fontSize: 28.sp,
          fontWeight: FontWeight.w900,
          color: primaryColor,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ══════════════════════════════════════════════════════════════════════════════

class _AboutBodyDesktop extends StatefulWidget {
  final AboutPageModel model;
  final TermsOfServiceModel termsModel;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialTopTab, initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyDesktop({
    required this.model,
    required this.termsModel,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialTopTab,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyDesktop> createState() => _AboutBodyDesktopState();
}

class _AboutBodyDesktopState extends State<_AboutBodyDesktop> {
  late int _selectedTab, _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    _selectedTab = widget.initialSubTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onTabApplied?.call(),
    );
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
  };
  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ =>
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
  };

  String _tabDesc(int i) {
    final desc = switch (i) {
      0 => _ab(widget.model.vision.subDescription, widget.isRtl),
      1 => _ab(widget.model.mission.subDescription, widget.isRtl),
      _ =>
        widget.model.values.isNotEmpty
            ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
            : '',
    };
    if (desc.length > 160) return '${desc.substring(0, 157)}…';
    return desc;
  }

  Widget _downloadButton(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvg(
              assetPath: "assets/download.svg",
              width: 12.h,
              height: 16.h,
              fit: BoxFit.scaleDown,
              color: widget.primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPanel({
    required String description,
    required String svgUrl,
    required String attachEnUrl,
    required String attachArUrl,
    required String labelEn,
    required String labelAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 13.sp,
                    height: 1.75,
                  ),
                ),
              ),
              if (svgUrl.isNotEmpty) ...[
                SizedBox(width: 16.w),
                _netImg(
                  url: svgUrl,
                  width: 180.w,
                  height: 180.h,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _downloadButton(labelEn, attachEnUrl),
            _downloadButton(labelAr, attachArUrl),
          ],
        ),
      ],
    );
  }

  final List<BiText> _topTabs = [
    BiText(ar: 'من نحن', en: 'About Us'),
    BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity),
        gap = 16.w,
        leftW = 280.w;
    final TermsSection terms = widget.termsModel.termsAndConditions,
        privacy = widget.termsModel.privacyPolicy;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Tab Bar ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_topTabs.length, (i) {
                final bool sel = i == _selectedTopTab;
                final bool isRtl = context.read<LanguageCubit>().state.isArabic;
                final String label = isRtl
                    ? (_topTabs[i].ar.isNotEmpty
                          ? _topTabs[i].ar
                          : _topTabs[i].en)
                    : _topTabs[i].en;
                final String svgAsset = switch (i) {
                  0 => 'assets/images/about_us/about_us.svg',
                  1 => 'assets/images/about_us/Our Strategy.svg',
                  2 => 'assets/images/about_us/Terms and Conditions.svg',
                  _ => 'assets/images/about_us/Privacy Policy.svg',
                };
                return GestureDetector(
                  onTap: () => setState(() => _selectedTopTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: sel ? widget.primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: sel
                                ? widget.primaryColor
                                : widget.secondaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              svgAsset,
                              width: 24.sp,
                              height: 24.sp,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                sel ? Colors.white : widget.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel
                                ? widget.primaryColor
                                : AppColors.secondaryBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab 0: About Us ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: leftW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (i) {
                          final bool isLast = i == 2;
                          return _Reveal(
                            key: ValueKey('top_0_tab_$i'),
                            delay: Duration(milliseconds: 120 + i * 80),
                            direction: _SlideDirection.fromLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 0 : 8.h,
                              ),
                              child: _DesktopTabItem(
                                label: _tabLabel(i),
                                iconUrl: _tabIconUrl(i),
                                selectedDesc: _selectedTab == i
                                    ? _tabDesc(i)
                                    : '',
                                isSelected: _selectedTab == i,
                                primaryColor: widget.primaryColor,
                                secondaryColor: widget.secondaryColor,
                                onTap: () => setState(() => _selectedTab = i),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _Reveal(
                        key: const ValueKey('top_0_right'),
                        delay: const Duration(milliseconds: 180),
                        direction: _SlideDirection.fromRight,
                        child: _DesktopRightPanel(
                          model: widget.model,
                          tabIndex: _selectedTab,
                          isRtl: widget.isRtl,
                          primaryColor: widget.primaryColor,
                          secondaryColor: widget.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Tab 1: Our Strategy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: BlocBuilder<StrategyCubit, StrategyState>(
                builder: (context, strategyState) {
                  final String svgUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.vision.svgUrl,
                    StrategySaved(:final data) => data.vision.svgUrl,
                    _ => '',
                  };
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: svgUrl.isNotEmpty
                          ? _netImg(
                              url: svgUrl,
                              width: 300.w,
                              height: 300.h,
                              fit: BoxFit.contain,
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),

          // ── Tab 2: Terms ──
          if (_selectedTopTab == 2)
            _Reveal(
              key: const ValueKey('top_2'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                labelEn: 'Download PDF of Terms and Conditions (ENG)',
                labelAr: 'Download PDF of Terms and Conditions (ARB)',
              ),
            ),

          // ── Tab 3: Privacy ──
          if (_selectedTopTab == 3)
            _Reveal(
              key: const ValueKey('top_3'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                labelEn: 'Download PDF of Privacy Policy (ENG)',
                labelAr: 'Download PDF of Privacy Policy (ARB)',
              ),
            ),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Tab Item
// ══════════════════════════════════════════════════════════════════════════════

class _DesktopTabItem extends StatefulWidget {
  final String label, iconUrl, selectedDesc;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _DesktopTabItem({
    required this.label,
    required this.iconUrl,
    required this.selectedDesc,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_DesktopTabItem> createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends State<_DesktopTabItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isSelected
        ? Colors.white
        : widget.primaryColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.primaryColor
                          : widget.secondaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: widget.iconUrl.isNotEmpty
                          ? _netImg(
                              url: widget.iconUrl,
                              width: 20.sp,
                              height: 20.sp,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 20.sp,
                              color: iconColor,
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  widget.selectedDesc,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 11.sp,
                    height: 1.65,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Right Panel
// ══════════════════════════════════════════════════════════════════════════════

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _DesktopRightPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      // ── CHANGED: skip first value (Main Icon) — it's in the left tab ──
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridDesktop(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }
    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13.sp,
                height: 1.75,
              ),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _netImg(
              url: section.svgUrl,
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ══════════════════════════════════════════════════════════════════════════════

class _ValueDetailPanel extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValueDetailPanel({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _ab(value.title, isRtl),
        shortDesc = _ab(value.shortDescription, isRtl),
        fullDesc = _ab(value.description, isRtl);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
                  ? _netImg(
                      url: value.iconUrl,
                      width: 30.r,
                      height: 30.r,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(Icons.star_outline, size: 20.sp, color: primaryColor),
            ),
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (shortDesc.isNotEmpty) ...[
            Text(
              shortDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryBlack,
                height: 1.6,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (fullDesc.isNotEmpty)
            Text(
              fullDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryBlack,
                height: 1.65,
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — DESKTOP
// ══════════════════════════════════════════════════════════════════════════════

class _ValuesGridDesktop extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridDesktop({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    this.isRtl = false,
  });
  @override
  State<_ValuesGridDesktop> createState() => _ValuesGridDesktopState();
}

class _ValuesGridDesktopState extends State<_ValuesGridDesktop> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.primaryColor.withOpacity(.06),
            widget.primaryColor.withOpacity(.25),
            widget.primaryColor.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: List.generate(widget.values.length, (i) {
              final v = widget.values[i];
              final sel = i == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100.w,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: sel ? widget.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: widget.primaryColor.withOpacity(0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (v.iconUrl.isNotEmpty)
                          _netImg(
                            url: v.iconUrl,
                            width: 22.sp,
                            height: 22.sp,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              sel ? Colors.white : widget.primaryColor,
                              BlendMode.srcIn,
                            ),
                          )
                        else
                          Icon(
                            Icons.star_outline,
                            size: 22.sp,
                            color: sel ? Colors.white : widget.primaryColor,
                          ),
                        SizedBox(height: 6.h),
                        Text(
                          _ab(v.title, widget.isRtl),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TABLET BODY
// ══════════════════════════════════════════════════════════════════════════════

class _AboutBodyTablet extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyTablet({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyTablet> createState() => _AboutBodyTabletState();
}

class _AboutBodyTabletState extends State<_AboutBodyTablet> {
  late int _selectedTab;
  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialSubTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onTabApplied?.call(),
    );
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
  };
  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ =>
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Reveal(
            delay: const Duration(milliseconds: 100),
            direction: _SlideDirection.fromBottom,
            child: Row(
              children: List.generate(3, (i) {
                final bool isLast = i == 2;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: isLast ? 0 : 10.w),
                    child: _TabletTabItem(
                      label: _tabLabel(i),
                      iconUrl: _tabIconUrl(i),
                      isSelected: _selectedTab == i,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      onTap: () => setState(() => _selectedTab = i),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 14.h),
          _Reveal(
            delay: const Duration(milliseconds: 180),
            direction: _SlideDirection.fromBottom,
            child: _TabletContentPanel(
              model: widget.model,
              tabIndex: _selectedTab,
              isRtl: widget.isRtl,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

class _TabletTabItem extends StatelessWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _TabletTabItem({
    required this.label,
    required this.iconUrl,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : _kSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isSelected ? primaryColor : _kDivider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl.isNotEmpty)
              _netImg(
                url: iconUrl,
                width: 16.sp,
                height: 16.sp,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : primaryColor,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                Icons.image_outlined,
                size: 16.sp,
                color: isSelected ? Colors.white : primaryColor,
              ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletContentPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _TabletContentPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      // ── CHANGED: skip first value (Main Icon) ──
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridTablet(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }
    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.svgUrl.isNotEmpty) ...[
            Center(
              child: _netImg(
                url: section.svgUrl,
                width: 160.w,
                height: 160.h,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(
            _ab(section.description, isRtl),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 11.sp,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — TABLET
// ══════════════════════════════════════════════════════════════════════════════

class _ValuesGridTablet extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridTablet({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_ValuesGridTablet> createState() => _ValuesGridTabletState();
}

class _ValuesGridTabletState extends State<_ValuesGridTablet> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: widget.secondaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(widget.values.length, (i) {
                final v = widget.values[i];
                final sel = i == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 88.w,
                    padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                      color: sel ? widget.primaryColor : _kSurface,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                        color: sel ? widget.primaryColor : _kDivider,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: widget.primaryColor.withOpacity(0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (v.iconUrl.isNotEmpty)
                          _netImg(
                            url: v.iconUrl,
                            width: 18.sp,
                            height: 18.sp,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              sel ? Colors.white : widget.primaryColor,
                              BlendMode.srcIn,
                            ),
                          )
                        else
                          Icon(
                            Icons.star_outline,
                            size: 18.sp,
                            color: sel ? Colors.white : widget.primaryColor,
                          ),
                        SizedBox(height: 5.h),
                        Text(
                          _ab(v.title, widget.isRtl),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ══════════════════════════════════════════════════════════════════════════════

class _AboutBodyMobile extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialTopTab, initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyMobile({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialTopTab,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyMobile> createState() => _AboutBodyMobileState();
}

class _AboutBodyMobileState extends State<_AboutBodyMobile> {
  late int _selectedTopTab;
  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onTabApplied?.call(),
    );
  }

  final List<BiText> _topTabs = [
    BiText(ar: 'من نحن', en: 'About Us'),
    BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];
  final List<String> _svgAssets = [
    'assets/images/about_us/about_us.svg',
    'assets/images/about_us/Our Strategy.svg',
    'assets/images/about_us/Terms and Conditions.svg',
    'assets/images/about_us/Privacy Policy.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final TermsOfServiceModel termsModel =
        context.read<TermsCubit>().state is TermsLoaded
        ? (context.read<TermsCubit>().state as TermsLoaded).data
        : context.read<TermsCubit>().state is TermsSaved
        ? (context.read<TermsCubit>().state as TermsSaved).data
        : TermsOfServiceModel.empty();
    final TermsSection terms = termsModel.termsAndConditions,
        privacy = termsModel.privacyPolicy;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_topTabs.length, (i) {
                final sel = i == _selectedTopTab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTopTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: sel ? widget.primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48.sp,
                          height: 48.sp,
                          decoration: BoxDecoration(
                            color: sel
                                ? widget.primaryColor
                                : widget.secondaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              _svgAssets[i],
                              width: 26.sp,
                              height: 26.sp,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                sel ? Colors.white : widget.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          widget.isRtl
                              ? (_topTabs[i].ar.isNotEmpty
                                    ? _topTabs[i].ar
                                    : _topTabs[i].en)
                              : _topTabs[i].en,
                          style: StyleText.fontSize20Weight600.copyWith(
                            color: sel
                                ? widget.primaryColor
                                : AppColors.secondaryBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('mob_top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileAboutUsContent(
                model: widget.model,
                isRtl: widget.isRtl,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
                initialExpanded: widget.initialSubTab,
              ),
            ),
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('mob_top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: BlocBuilder<StrategyCubit, StrategyState>(
                builder: (context, strategyState) {
                  final String svgUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.vision.svgUrl,
                    StrategySaved(:final data) => data.vision.svgUrl,
                    _ => '',
                  };
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: svgUrl.isNotEmpty
                        ? _netImg(
                            url: svgUrl,
                            width: double.infinity,
                            height: 220.h,
                            fit: BoxFit.contain,
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ),
          if (_selectedTopTab == 2)
            _Reveal(
              key: const ValueKey('mob_top_2'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                labelEn: 'Download PDF of Terms and Conditions (ENG)',
                labelAr: 'Download PDF of Terms and Conditions (ARB)',
                primaryColor: widget.primaryColor,
              ),
            ),
          if (_selectedTopTab == 3)
            _Reveal(
              key: const ValueKey('mob_top_3'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                labelEn: 'Download PDF of Privacy Policy (ENG)',
                labelAr: 'Download PDF of Privacy Policy (ARB)',
                primaryColor: widget.primaryColor,
              ),
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ── Mobile About Us Content ──

class _MobileAboutUsContent extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialExpanded;
  const _MobileAboutUsContent({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialExpanded,
  });
  @override
  State<_MobileAboutUsContent> createState() => _MobileAboutUsContentState();
}

class _MobileAboutUsContentState extends State<_MobileAboutUsContent> {
  late int _expanded;
  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded ?? 0;
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
  };
  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ =>
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
  };

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _MobileTabData(
        label: _tabLabel(0),
        iconUrl: _tabIconUrl(0),
        svgUrl: widget.model.vision.svgUrl,
        fullText: _ab(widget.model.vision.description, widget.isRtl),
        tabIndex: 0,
      ),
      _MobileTabData(
        label: _tabLabel(1),
        iconUrl: _tabIconUrl(1),
        svgUrl: widget.model.mission.svgUrl,
        fullText: _ab(widget.model.mission.description, widget.isRtl),
        tabIndex: 1,
      ),
      _MobileTabData(
        label: _tabLabel(2),
        iconUrl: _tabIconUrl(2),
        svgUrl: '',
        fullText: '',
        tabIndex: 2,
      ),
    ];
    return Column(
      children: tabs.map((tab) {
        final bool isOpen = _expanded == tab.tabIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _MobileAccordionItem(
            tab: tab,
            values: widget.model.values,
            isExpanded: isOpen,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            onTap: () => setState(() => _expanded = isOpen ? -1 : tab.tabIndex),
          ),
        );
      }).toList(),
    );
  }
}

// ── Mobile Doc Panel ──

class _MobileDocPanel extends StatelessWidget {
  final String description, svgUrl, attachEnUrl, attachArUrl, labelEn, labelAr;
  final Color primaryColor;
  const _MobileDocPanel({
    required this.description,
    required this.svgUrl,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.labelEn,
    required this.labelAr,
    required this.primaryColor,
  });

  Widget _downloadBtn(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSvg(
                assetPath: "assets/download.svg",
                width: 18.w,
                height: 18.h,
                fit: BoxFit.scaleDown,
                color: primaryColor,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (svgUrl.isNotEmpty) ...[
              Center(
                child: _netImg(
                  url: svgUrl,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 14.h),
            ],
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryBlack,
                  height: 1.75,
                ),
              ),
            ),
            _downloadBtn(labelEn, attachEnUrl),
            _downloadBtn(labelAr, attachArUrl),
          ],
        ),
      ),
    );
  }
}

class _MobileTabData {
  final String label, iconUrl, svgUrl, fullText;
  final int tabIndex;
  const _MobileTabData({
    required this.label,
    required this.iconUrl,
    required this.svgUrl,
    required this.fullText,
    required this.tabIndex,
  });
}

// ── Mobile Accordion Item ──

class _MobileAccordionItem extends StatelessWidget {
  final _MobileTabData tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _MobileAccordionItem({
    required this.tab,
    required this.values,
    required this.isExpanded,
    required this.onTap,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // ── CHANGED: For Values tab, skip first value (Main Icon) ──
    final List<AboutValueItem> gridValues =
        (tab.tabIndex == 2 && values.length > 1)
        ? values.sublist(1)
        : (tab.tabIndex == 2 ? <AboutValueItem>[] : values);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: isExpanded ? primaryColor : secondaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: tab.iconUrl.isNotEmpty
                          ? _netImg(
                              url: tab.iconUrl,
                              width: 18.sp,
                              height: 18.sp,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                isExpanded ? Colors.white : primaryColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 16.sp,
                              color: isExpanded
                                  ? Colors.white
                                  : AppColors.textButton,
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      tab.label,
                      style: StyleText.fontSize16Weight600.copyWith(
                        fontSize: 12.sp,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tab.tabIndex != 2 && tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url: tab.svgUrl,
                        width:
                            MediaQuery.of(context).size.width -
                            16.w * 2 -
                            12.w * 2,
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  if (tab.tabIndex != 2)
                    Text(
                      tab.fullText,
                      style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: 10.sp,
                        height: 1.7,
                      ),
                    ),
                  if (tab.tabIndex == 2)
                    _ValuesGridMobile(
                      values: gridValues,
                      isRtl: isRtl,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — MOBILE
// ══════════════════════════════════════════════════════════════════════════════

class _ValuesGridMobile extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridMobile({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_ValuesGridMobile> createState() => _ValuesGridMobileState();
}

class _ValuesGridMobileState extends State<_ValuesGridMobile> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    final double innerW =
            MediaQuery.of(context).size.width - 16.w * 2 - 12.w * 2,
        gap = 7.w,
        cardW = (innerW - gap) / 2;
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(widget.values.length, (i) {
            final v = widget.values[i];
            final sel = i == idx;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: cardW,
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : _kSurface,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (v.iconUrl.isNotEmpty)
                      _netImg(
                        url: v.iconUrl,
                        width: 16.sp,
                        height: 16.sp,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          sel ? Colors.white : widget.primaryColor,
                          BlendMode.srcIn,
                        ),
                      )
                    else
                      Icon(
                        Icons.star_outline,
                        size: 16.sp,
                        color: sel ? Colors.white : widget.primaryColor,
                      ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        _ab(v.title, widget.isRtl),
                        style: StyleText.fontSize22Weight700.copyWith(
                          fontSize: 10.sp,
                          color: sel ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 10.h),
        _ValueDetailPanel(
          value: selected,
          isRtl: widget.isRtl,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ],
    );
  }
}
