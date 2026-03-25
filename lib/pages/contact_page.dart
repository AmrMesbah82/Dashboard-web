// ******************* FILE INFO *******************
// File Name: contact_page.dart  (public-facing website page)
// Created by: Amr Mesbah
// UPDATED: backgroundColor now dynamic from CMS branding.backgroundColor ✅
// Updated: All sizes normalized to match main.dart ScreenUtil design sizes:
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812
//          Full AR / EN bilingual support.
//          PRIMARY COLOR: Fully dynamic from HomeCmsCubit branding.
//          NEW: Twilio OTP verification before form submission.
//          NEW: Office cards open mapLink in Google Maps on tap ✅
//          NEW: Form fields updated — firstName/lastName split, preferredLanguage
//               radio, location country picker, entityName, entityType, entitySize
//          NEW: SendGrid sends 2 emails (client thank-you + sales notification)
// FIX: _SvgPulseLoader backgroundColor now uses branding.backgroundColor from
//      Firebase. Shows neutral background before Firebase responds, then
//      switches to real backgroundColor once HomeCmsLoaded fires.
// FIX: Desktop layout now fully responsive — no overflow when window resized.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/circle_progress.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/navigator.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/constant.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/pages/contatc_us/contacu_us_location_edit.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/app_footer.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import 'package:web_app_admin/controller/contact_us/contact_otp_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contact_otp_state.dart';

// Fallback colors
const Color _kDefaultGreen  = Color(0xFF2D8C4E);
const Color _kGreenLight    = Color(0xFFE8F5EE);
const Color _kDivider       = Color(0xFFDDE8DD);
// Neutral loader background shown before Firebase responds
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAP LINK LAUNCHER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _launchMapLink(String mapLink) async {
  if (mapLink.isEmpty) return;
  String raw = mapLink.trim();
  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    raw = 'https://$raw';
  }
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasAuthority) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

String _t(BuildContext context, {required String en, required String ar}) {
  final isAr = context.read<LanguageCubit>().state.isArabic;
  return (isAr && ar.isNotEmpty) ? ar : en;
}

String _bi(BuildContext context, ContactBilingualText text) =>
    _t(context, en: text.en, ar: text.ar);

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20',  'value': '🇪🇬 +20'},
  {'key': '+234', 'value': '🇳🇬 +234'},
  {'key': '+212', 'value': '🇲🇦 +212'},
  {'key': '+213', 'value': '🇩🇿 +213'},
  {'key': '+216', 'value': '🇹🇳 +216'},
  {'key': '+249', 'value': '🇸🇩 +249'},
  {'key': '+251', 'value': '🇪🇹 +251'},
  {'key': '+254', 'value': '🇰🇪 +254'},
  {'key': '+27',  'value': '🇿🇦 +27'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+968', 'value': '🇴🇲 +968'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+963', 'value': '🇸🇾 +963'},
  {'key': '+964', 'value': '🇮🇶 +964'},
  {'key': '+967', 'value': '🇾🇪 +967'},
  {'key': '+970', 'value': '🇵🇸 +970'},
  {'key': '+90',  'value': '🇹🇷 +90'},
  {'key': '+98',  'value': '🇮🇷 +98'},
  {'key': '+44',  'value': '🇬🇧 +44'},
  {'key': '+33',  'value': '🇫🇷 +33'},
  {'key': '+49',  'value': '🇩🇪 +49'},
  {'key': '+1',   'value': '🇺🇸 +1'},
  {'key': '+91',  'value': '🇮🇳 +91'},
  {'key': '+86',  'value': '🇨🇳 +86'},
  {'key': '+81',  'value': '🇯🇵 +81'},
  {'key': '+61',  'value': '🇦🇺 +61'},
  {'key': '+64',  'value': '🇳🇿 +64'},
];

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
// PAGE ENTRY
// ═══════════════════════════════════════════════════════════════════════════════

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ContactCubit()),
        BlocProvider(create: (_) => ContactUsCmsCubit()..load()),
        BlocProvider(create: (_) => ContactOtpCubit()),
      ],
      child: const _ContactPageView(),
    );
  }
}

class _ContactPageView extends StatefulWidget {
  const _ContactPageView();
  @override
  State<_ContactPageView> createState() => _ContactPageViewState();
}

class _ContactPageViewState extends State<_ContactPageView> {
  // ── NEW: Split name controllers ──
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _entityNameCtrl = TextEditingController();
  final _subjectCtrl    = TextEditingController();
  final _messageCtrl    = TextEditingController();

  String _phoneCode          = '+20';
  String _preferredLanguage  = 'ar';     // Default: Arabic (matches Figma)
  String? _selectedLocation;              // Country name
  String? _selectedEntityType;
  String? _selectedEntitySize;

  bool   _submitted      = false;
  bool   _showLoader     = true;
  bool   _preloadStarted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _entityNameCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required ContactUsCmsModel? cmsData,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    final List<String> allUrls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (cmsData != null)
        for (final icon in cmsData.socialIcons)
          if (icon.iconUrl.isNotEmpty) icon.iconUrl,
      if (cmsData != null)
        for (final office in cmsData.officeLocations)
          if (office.iconUrl.isNotEmpty) office.iconUrl,
      if (cmsData != null && cmsData.confirmMessage.svgUrl.isNotEmpty)
        cmsData.confirmMessage.svgUrl,
    ];

    await _preloadSvgImages(allUrls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  void _onSend() {
    setState(() => _submitted = true);

    // ── Validate required fields ──
    final requiredTextFilled = [
      _firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl,
      _subjectCtrl, _messageCtrl,
    ].every((c) => c.text.trim().isNotEmpty);

    final dropdownsFilled = _selectedLocation != null &&
        _selectedEntityType != null &&
        _selectedEntitySize != null;

    if (!requiredTextFilled || !dropdownsFilled) return;

    String phoneNumber = _phoneCtrl.text.trim();
    if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);

    final fullPhone = '$_phoneCode$phoneNumber';
    final locale    = _preferredLanguage == 'ar' ? 'ar' : 'en';

    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: fullPhone,
      locale:      locale,
    );
  }

  void _submitContactForm() async {
    final submission = ContactSubmission(
      id:                '',
      firstName:         _firstNameCtrl.text.trim(),
      lastName:          _lastNameCtrl.text.trim(),
      email:             _emailCtrl.text.trim(),
      countryCode:       _phoneCode,
      phoneNumber:       _phoneCtrl.text.trim(),
      preferredLanguage: _preferredLanguage,
      location:          _selectedLocation ?? '',
      entityName:        _entityNameCtrl.text.trim(),
      entityType:        _selectedEntityType ?? '',
      entitySize:        _selectedEntitySize ?? '',
      subject:           _subjectCtrl.text.trim(),
      message:           _messageCtrl.text.trim(),
      submissionDate:    DateTime.now(),
    );

    // ContactCubit now handles both Firestore save + email sending
    context.read<ContactCubit>().submitContact(submission);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
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

        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => AppColors.background,
        };

        final Color loaderBg = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => _kLoaderNeutral,
        };

        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader &&
            !_preloadStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final isRtl = langState.isArabic;

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ContactOtpCubit, ContactOtpState>(
                    listener: (context, otpState) {
                      if (otpState is OtpSent) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ContactOtpCubit>(),
                            child: _OtpDialog(
                              phoneNumber:  otpState.phoneNumber,
                              isRtl:        isRtl,
                              primaryColor: primaryColor,
                              onVerified: () {
                                Navigator.of(context).pop();
                                _submitContactForm();
                              },
                            ),
                          ),
                        );
                      }
                      if (otpState is OtpError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:         Text('OTP Error: ${otpState.message}'),
                            backgroundColor: Colors.red,
                            duration:        const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                  BlocListener<ContactCubit, ContactState>(
                    listener: (context, state) {
                      if (state is ContactSubmitted) {
                        _firstNameCtrl.clear();
                        _lastNameCtrl.clear();
                        _emailCtrl.clear();
                        _phoneCtrl.clear();
                        _entityNameCtrl.clear();
                        _subjectCtrl.clear();
                        _messageCtrl.clear();
                        setState(() {
                          _submitted          = false;
                          _preferredLanguage   = 'ar';
                          _selectedLocation    = null;
                          _selectedEntityType  = null;
                          _selectedEntitySize  = null;
                        });

                        final cmsState =
                            context.read<ContactUsCmsCubit>().state;
                        ContactUsCmsModel? cmsData;
                        if (cmsState is ContactUsCmsLoaded) {
                          cmsData = cmsState.data;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => _SuccessDialog(
                            cmsData:      cmsData,
                            isRtl:        isRtl,
                            primaryColor: primaryColor,
                          ),
                        );
                      }
                      if (state is ContactError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:         Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                            duration:        const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
                  builder: (context, cmsState) {
                    final bool cmsReady = cmsState is ContactUsCmsLoaded ||
                        cmsState is ContactUsCmsError;

                    ContactUsCmsModel? cmsData;
                    if (cmsState is ContactUsCmsLoaded) {
                      cmsData = cmsState.data;
                    }

                    if (homeReady && cmsReady && !_preloadStarted) {
                      _preloadAndReveal(
                          logoUrl: logoUrl, cmsData: cmsData);
                    }

                    if (_showLoader || !cmsReady || !homeReady) {
                      return _SvgPulseLoader(
                        logoUrl:         logoUrl.isEmpty ? null : logoUrl,
                        backgroundColor: loaderBg,
                      );
                    }

                    return BlocBuilder<ContactCubit, ContactState>(
                      builder: (context, contactState) {
                        final isSending =
                        contactState is ContactSubmitting;
                        final isMobile = MediaQuery.of(context).size.width <
                            _BP.mobile;

                        return Scaffold(
                          backgroundColor: backgroundColor,
                          body: Stack(children: [
                            _RevealCoordinatorWidget(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 80.h),
                                    _Reveal(
                                      delay: const Duration(
                                          milliseconds: 80),
                                      direction:
                                      _SlideDirection.fromLeft,
                                      duration: const Duration(
                                          milliseconds: 650),
                                      child: isMobile
                                          ? _MobileBody(
                                        firstNameCtrl:       _firstNameCtrl,
                                        lastNameCtrl:        _lastNameCtrl,
                                        emailCtrl:           _emailCtrl,
                                        phoneCtrl:           _phoneCtrl,
                                        entityNameCtrl:      _entityNameCtrl,
                                        subjectCtrl:         _subjectCtrl,
                                        messageCtrl:         _messageCtrl,
                                        submitted:           _submitted,
                                        phoneCode:           _phoneCode,
                                        preferredLanguage:   _preferredLanguage,
                                        selectedLocation:    _selectedLocation,
                                        selectedEntityType:  _selectedEntityType,
                                        selectedEntitySize:  _selectedEntitySize,
                                        isRtl:               isRtl,
                                        primaryColor:        primaryColor,
                                        onCodeChanged:       (v) =>
                                            setState(() =>
                                            _phoneCode = v ?? _phoneCode),
                                        onLanguageChanged:   (v) =>
                                            setState(() =>
                                            _preferredLanguage = v),
                                        onLocationChanged:   (v) =>
                                            setState(() =>
                                            _selectedLocation = v),
                                        onEntityTypeChanged: (v) =>
                                            setState(() =>
                                            _selectedEntityType = v),
                                        onEntitySizeChanged: (v) =>
                                            setState(() =>
                                            _selectedEntitySize = v),
                                        onSend:  _onSend,
                                        cmsData: cmsData,
                                      )
                                          : _DesktopBody(
                                        firstNameCtrl:       _firstNameCtrl,
                                        lastNameCtrl:        _lastNameCtrl,
                                        emailCtrl:           _emailCtrl,
                                        phoneCtrl:           _phoneCtrl,
                                        entityNameCtrl:      _entityNameCtrl,
                                        subjectCtrl:         _subjectCtrl,
                                        messageCtrl:         _messageCtrl,
                                        submitted:           _submitted,
                                        phoneCode:           _phoneCode,
                                        preferredLanguage:   _preferredLanguage,
                                        selectedLocation:    _selectedLocation,
                                        selectedEntityType:  _selectedEntityType,
                                        selectedEntitySize:  _selectedEntitySize,
                                        isRtl:               isRtl,
                                        primaryColor:        primaryColor,
                                        onCodeChanged:       (v) =>
                                            setState(() =>
                                            _phoneCode = v ?? _phoneCode),
                                        onLanguageChanged:   (v) =>
                                            setState(() =>
                                            _preferredLanguage = v),
                                        onLocationChanged:   (v) =>
                                            setState(() =>
                                            _selectedLocation = v),
                                        onEntityTypeChanged: (v) =>
                                            setState(() =>
                                            _selectedEntityType = v),
                                        onEntitySizeChanged: (v) =>
                                            setState(() =>
                                            _selectedEntitySize = v),
                                        onSend:  _onSend,
                                        cmsData: cmsData,
                                      ),
                                    ),
                                    _Reveal(
                                      delay: const Duration(
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
                            ),

                            Positioned(
                              top: 0, left: 0, right: 0,
                              child: Material(
                                color:     backgroundColor,
                                elevation: 0,
                                child: AppNavbar(
                                    currentRoute: '/contact'),
                              ),
                            ),

                            if (isSending)
                              Container(
                                color: Colors.black45,
                                child: Center(
                                  child: Container(
                                    width: isMobile
                                        ? double.infinity
                                        : 600.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(
                                            10.r)),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        CircleProgressMaster(),
                                        SizedBox(height: 8.h),
                                        Text(
                                          isRtl
                                              ? 'جاري ارسال البيانات التي قد ملتها وسيتم الرد عليك بعد اتمما العملية...'
                                              : 'The information you have filled out is being sent, and you will be answered after you complete the process…',
                                          style: StyleText
                                              .fontSize13Weight400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OTP VERIFICATION DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// OTP VERIFICATION DIALOG — Figma-accurate design
// ═══════════════════════════════════════════════════════════════════════════════

class _OtpDialog extends StatefulWidget {
  final String       phoneNumber;
  final bool         isRtl;
  final Color        primaryColor;
  final VoidCallback onVerified;

  const _OtpDialog({
    required this.phoneNumber,
    required this.isRtl,
    required this.primaryColor,
    required this.onVerified,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _digitCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool   _submitted   = false;
  bool   _hasError     = false;
  int    _countdown    = 30;
  bool   _canResend    = false;
  StreamSubscription? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .take(30)
        .listen((_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _digitCtrls.map((c) => c.text).join();

  bool get _isOtpEmpty =>
      _digitCtrls.every((c) => c.text.trim().isEmpty);

  void _verifyOtp() {
    setState(() {
      _submitted = true;
      _hasError  = false;
    });
    final code = _otpCode.trim();
    if (code.length < 6) return;
    context.read<ContactOtpCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      code:        code,
    );
  }

  void _resendOtp() {
    // Clear digits
    for (final c in _digitCtrls) c.clear();
    setState(() {
      _submitted = false;
      _hasError  = false;
    });
    _timer?.cancel();
    _startTimer();

    final locale = widget.isRtl ? 'ar' : 'en';
    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: widget.phoneNumber,
      locale:      locale,
    );
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _hasError = false);

    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-verify when all 6 digits entered
    if (value.length == 1 && index == 5 && _otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _onDigitKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s Sec';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;

    final String title = widget.isRtl
        ? 'رمز التحقق'
        : 'VERIFICATION CODE';
    final String desc = widget.isRtl
        ? 'لقد أرسلنا رمز التحقق إلى هاتفك لإتمام عملية التحقق'
        : 'We have sent the OTP code to your Phone For the verification process';
    final String verifyBtn = widget.isRtl ? 'تحقق الآن'        : 'Verify Now';
    final String resendBtn = widget.isRtl ? 'إعادة إرسال الرمز' : 'Resend Code';
    final String errorMsg  = widget.isRtl
        ? 'رمز غير صحيح، يرجى التحقق والمحاولة مرة أخرى'
        : 'Incorrect code, please check and try again';

    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<ContactOtpCubit, ContactOtpState>(
        listener: (context, state) {
          if (state is OtpVerified) widget.onVerified();
          if (state is OtpError) {
            setState(() => _hasError = true);
          }
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 16.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36.w,
            vertical:   isMobile ? 40 : 36.h,
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 480.w,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32.w,
                vertical:   isMobile ? 28 : 32.h,
              ),
              child: BlocBuilder<ContactOtpCubit, ContactOtpState>(
                builder: (context, state) {
                  final isVerifying = state is OtpVerifying;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // ── SVG Illustration ──
                    SvgPicture.asset(
                    'assets/images/mobile_code_dialog.svg',
                    width:  isMobile ? 120 : 140.w,
                    height: isMobile ? 100 : 120.h,
                    fit:    BoxFit.contain,
                  ),
                  SizedBox(height: isMobile ? 20 : 24.h),

                  // ── Title ──
                  Text(
                  title,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize22Weight700.copyWith(
                  fontSize:      isMobile ? 18.0 : 20.sp,
                  color:         Colors.black,
                  letterSpacing: 1.0,
                  ),
                  ),
                  SizedBox(height: isMobile ? 8 : 10.h),

                  // ── Description ──
                  Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                  fontSize: isMobile ? 12.0 : 13.sp,
                  color:    Colors.grey.shade600,
                  height:   1.5,
                  ),
                  ),
                  SizedBox(height: isMobile ? 24 : 28.h),

                  // ── 6-Digit OTP Boxes ──
                  Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                  final bool filled =
                  _digitCtrls[i].text.isNotEmpty;
                  return Container(
                    width:  isMobile ? 44 : 48.w,
                    height: isMobile ? 50 : 54.h,
                    margin: EdgeInsets.symmetric(
                        horizontal: isMobile ? 3 : 4.w),
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (e) => _onDigitKey(i, e),
                      child: TextField(
                        controller:   _digitCtrls[i],
                        focusNode:    _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign:    TextAlign.center,
                        maxLength:    1,
                        style: StyleText.fontSize22Weight700
                            .copyWith(
                          fontSize: isMobile ? 18.0 : 20.sp,
                          color:    _hasError
                              ? Colors.red
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled:      true,
                          fillColor: _hasError
                              ? Colors.red.withOpacity(0.05)
                              : filled
                              ? widget.primaryColor
                              .withOpacity(0.05)
                              : Colors.grey.shade50,
                          contentPadding:
                          EdgeInsets.symmetric(
                              vertical: isMobile ? 12 : 14.h),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _hasError
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _hasError
                                  ? Colors.red
                                  : filled
                                  ? widget.primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _hasError
                                  ? Colors.red
                                  : widget.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) =>
                            _onDigitChanged(v, i),
                      ),
                    ),
                  );
                  }),
                  ),
                  ),
                  SizedBox(height: isMobile ? 14 : 16.h),

                  // ── Error Message ──
                  if (_hasError)
                  Padding(
                  padding: EdgeInsets.only(
                  bottom: isMobile ? 8 : 10.h),
                  child: Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight400.copyWith(
                  color:    Colors.red,
                  fontSize: isMobile ? 11.0 : 12.sp,
                  ),
                  ),
                  ),

                  // ── Timer ──
                  if (!_canResend)
                  Text(
                  _formatTime(_countdown),
                  style: StyleText.fontSize13Weight400.copyWith(
                  color:    widget.primaryColor,
                  fontSize: isMobile ? 13.0 : 14.sp,
                  fontWeight: FontWeight.w600,
                  ),
                  ),
                  SizedBox(height: isMobile ? 18 : 20.h),

                  // ── Action Button ──
                  SizedBox(
                  width:  double.infinity,
                  height: isMobile ? 46 : 44.h,
                  child: _canResend
                  ? ElevatedButton(
                  onPressed: _resendOtp,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                  ),
                  child: Text(
                  resendBtn,
                  style: StyleText.fontSize16Weight600
                      .copyWith(
                  color:    Colors.white,
                  fontSize: isMobile ? 14.0 : 15.sp,
                  ),
                  ),
                  )
                      : ElevatedButton(
                  onPressed:
                  isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  disabledBackgroundColor:
                  widget.primaryColor
                      .withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                  ),
                  child: isVerifying
                  ? const SizedBox(
                  height: 18,
                  width:  18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  )
                      : Text(
                  verifyBtn,
                  style: StyleText
                      .fontSize16Weight600
                      .copyWith(
                  color: Colors.white,
                  fontSize:
                  isMobile ? 14.0 : 15.sp,
                  ),
                  ),
                  ),
                  ),
                  ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopBody extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, entityNameCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isRtl;
  final String phoneCode, preferredLanguage;
  final String? selectedLocation, selectedEntityType, selectedEntitySize;
  final Color  primaryColor;
  final ValueChanged<String?>  onCodeChanged;
  final ValueChanged<String>   onLanguageChanged;
  final ValueChanged<String?>  onLocationChanged;
  final ValueChanged<String?>  onEntityTypeChanged;
  final ValueChanged<String?>  onEntitySizeChanged;
  final VoidCallback           onSend;
  final ContactUsCmsModel?     cmsData;

  const _DesktopBody({
    required this.firstNameCtrl,    required this.lastNameCtrl,
    required this.emailCtrl,        required this.phoneCtrl,
    required this.entityNameCtrl,   required this.subjectCtrl,
    required this.messageCtrl,      required this.submitted,
    required this.phoneCode,        required this.preferredLanguage,
    required this.selectedLocation, required this.selectedEntityType,
    required this.selectedEntitySize,
    required this.onCodeChanged,    required this.onLanguageChanged,
    required this.onLocationChanged, required this.onEntityTypeChanged,
    required this.onEntitySizeChanged,
    required this.onSend,           required this.isRtl,
    required this.primaryColor,     this.cmsData,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = (248.w * 4) + (8.w * 3);
    final double hPad     = ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    final String pageTitle   = _t(context, en: 'Contact Us',       ar: 'تواصل معنا');
    final String officeTitle = _t(context, en: 'Office Locations', ar: 'مواقع المكاتب');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Text(pageTitle,
                style: StyleText.fontSize45Weight600.copyWith(
                    fontSize:   36.sp,
                    color:      primaryColor,
                    fontWeight: FontWeight.w900)),
          ),
          SizedBox(height: 24.h),
          _Reveal(
            delay:     const Duration(milliseconds: 130),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 2,
                      child: _LeftInfoCard(
                          cmsData:      cmsData,
                          isRtl:        isRtl,
                          primaryColor: primaryColor)),
                  SizedBox(width: 20.w),
                  Expanded(
                      flex: 3,
                      child: _FormCard(
                        firstNameCtrl:       firstNameCtrl,
                        lastNameCtrl:        lastNameCtrl,
                        emailCtrl:           emailCtrl,
                        phoneCtrl:           phoneCtrl,
                        entityNameCtrl:      entityNameCtrl,
                        subjectCtrl:         subjectCtrl,
                        messageCtrl:         messageCtrl,
                        submitted:           submitted,
                        phoneCode:           phoneCode,
                        preferredLanguage:   preferredLanguage,
                        selectedLocation:    selectedLocation,
                        selectedEntityType:  selectedEntityType,
                        selectedEntitySize:  selectedEntitySize,
                        onCodeChanged:       onCodeChanged,
                        onLanguageChanged:   onLanguageChanged,
                        onLocationChanged:   onLocationChanged,
                        onEntityTypeChanged: onEntityTypeChanged,
                        onEntitySizeChanged: onEntitySizeChanged,
                        onSend:              onSend,
                        isRtl:               isRtl,
                        primaryColor:        primaryColor,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _Reveal(
            delay:     const Duration(milliseconds: 180),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(officeTitle,
                    style: StyleText.fontSize45Weight600.copyWith(
                        fontSize:   24.sp,
                        color:      primaryColor,
                        fontWeight: FontWeight.w900)),
                if (cmsData != null &&
                    cmsData!.officeLocations.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: AppColors.card),
                    child: Row(
                      children: cmsData!.officeLocations
                          .map((o) => Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius:
                              BorderRadius.circular(16.r)),
                          padding: EdgeInsets.all(18.sp),
                          child: _OfficeCard(
                              office:       o,
                              isRtl:        isRtl,
                              primaryColor: primaryColor),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileBody extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, entityNameCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isRtl;
  final String phoneCode, preferredLanguage;
  final String? selectedLocation, selectedEntityType, selectedEntitySize;
  final Color  primaryColor;
  final ValueChanged<String?>  onCodeChanged;
  final ValueChanged<String>   onLanguageChanged;
  final ValueChanged<String?>  onLocationChanged;
  final ValueChanged<String?>  onEntityTypeChanged;
  final ValueChanged<String?>  onEntitySizeChanged;
  final VoidCallback           onSend;
  final ContactUsCmsModel?     cmsData;

  const _MobileBody({
    required this.firstNameCtrl,    required this.lastNameCtrl,
    required this.emailCtrl,        required this.phoneCtrl,
    required this.entityNameCtrl,   required this.subjectCtrl,
    required this.messageCtrl,      required this.submitted,
    required this.phoneCode,        required this.preferredLanguage,
    required this.selectedLocation, required this.selectedEntityType,
    required this.selectedEntitySize,
    required this.onCodeChanged,    required this.onLanguageChanged,
    required this.onLocationChanged, required this.onEntityTypeChanged,
    required this.onEntitySizeChanged,
    required this.onSend,           required this.isRtl,
    required this.primaryColor,     this.cmsData,
  });

  @override
  Widget build(BuildContext context) {
    final String pageTitle   = _t(context, en: 'Contact Us',       ar: 'تواصل معنا');
    final String officeTitle = _t(context, en: 'Office Locations', ar: 'مواقع المكاتب');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(pageTitle,
              style: StyleText.fontSize45Weight600.copyWith(
                  fontSize:   26.sp,
                  color:      primaryColor,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 16.h),
          _Reveal(
            delay:     const Duration(milliseconds: 100),
            direction: _SlideDirection.fromLeft,
            child: _MobileInfoCard(
                cmsData:      cmsData,
                isRtl:        isRtl,
                primaryColor: primaryColor),
          ),
          SizedBox(height: 16.h),
          _Reveal(
            delay:     const Duration(milliseconds: 150),
            direction: _SlideDirection.fromBottom,
            child: _FormCard(
              firstNameCtrl:       firstNameCtrl,
              lastNameCtrl:        lastNameCtrl,
              emailCtrl:           emailCtrl,
              phoneCtrl:           phoneCtrl,
              entityNameCtrl:      entityNameCtrl,
              subjectCtrl:         subjectCtrl,
              messageCtrl:         messageCtrl,
              submitted:           submitted,
              phoneCode:           phoneCode,
              preferredLanguage:   preferredLanguage,
              selectedLocation:    selectedLocation,
              selectedEntityType:  selectedEntityType,
              selectedEntitySize:  selectedEntitySize,
              onCodeChanged:       onCodeChanged,
              onLanguageChanged:   onLanguageChanged,
              onLocationChanged:   onLocationChanged,
              onEntityTypeChanged: onEntityTypeChanged,
              onEntitySizeChanged: onEntitySizeChanged,
              onSend:              onSend,
              isMobile:            true,
              isRtl:               isRtl,
              primaryColor:        primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            child: Text(officeTitle,
                style: StyleText.fontSize22Weight700
                    .copyWith(color: primaryColor, fontSize: 18.sp)),
          ),
          SizedBox(height: 12.h),
          if (cmsData != null && cmsData!.officeLocations.isNotEmpty)
            ...cmsData!.officeLocations.asMap().entries.map((e) =>
                _Reveal(
                  delay:     Duration(milliseconds: 100 + e.key * 80),
                  direction: _SlideDirection.fromBottom,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _OfficeCardMobile(
                        office:       e.value,
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
// INFO CARDS
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileInfoCard extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  isRtl;
  final Color primaryColor;
  const _MobileInfoCard(
      {this.cmsData, required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String emailLabel  = _t(context, en: 'Email',     ar: 'البريد الإلكتروني');
    final String followLabel = _t(context, en: 'Follow Us', ar: 'تابعنا');
    final String desc = cmsData != null
        ? _bi(context, cmsData!.subDescription)
        : _t(context,
        en: 'Achieve Your Goals Efficiently And Without Disruption',
        ar: 'حقق أهدافك بكفاءة ودون انقطاع من خلال سير عمل سلس ومتواصل');

    return Container(
      width:   double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc,
              style: StyleText.fontSize12Weight600.copyWith(
                  height: 1.6, color: Colors.black87, fontSize: 12.sp)),
          SizedBox(height: 18.h),
          Text(emailLabel,
              style: StyleText.fontSize15Weight600.copyWith(
                  color: primaryColor, fontSize: 13.sp)),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () async {
              final email = cmsData?.email ?? 'info@bayanatz.com';
              final uri   = Uri(scheme: 'mailto', path: email);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                cmsData?.email ?? 'info@bayanatz.com',
                style: StyleText.fontSize13Weight400.copyWith(
                  color:           primaryColor,
                  fontSize:        12.sp,
                  decoration:      TextDecoration.underline,
                  decorationColor: primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(followLabel,
              style: StyleText.fontSize15Weight600.copyWith(
                  color: primaryColor, fontSize: 13.sp)),
          SizedBox(height: 8.h),
          _SocialRow(
              cmsData: cmsData, scaled: false, primaryColor: primaryColor),
        ],
      ),
    );
  }
}

class _LeftInfoCard extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  isRtl;
  final Color primaryColor;
  const _LeftInfoCard(
      {this.cmsData, required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String emailLabel  = _t(context, en: 'Email',     ar: 'البريد الإلكتروني');
    final String followLabel = _t(context, en: 'Follow Us', ar: 'تابعنا');
    final String desc = cmsData != null
        ? _bi(context, cmsData!.subDescription)
        : _t(context,
        en: 'Achieve Your Goals Efficiently And Without Disruption Through Seamless, Uninterrupted Workflows',
        ar: 'حقق أهدافك بكفاءة ودون انقطاع من خلال سير عمل سلس ومتواصل');

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(desc,
              style: StyleText.fontSize18Weight500.copyWith(
                  height: 1.6, color: Colors.black87, fontSize: 14.sp)),
          SizedBox(height: 24.h),
          Text(emailLabel,
              style: StyleText.fontSize16Weight600.copyWith(
                  color: primaryColor, fontSize: 13.sp)),
          SizedBox(height: 5.h),
          GestureDetector(
            onTap: () async {
              final email = cmsData?.email ?? 'info@bayanatz.com';
              final uri   = Uri(scheme: 'mailto', path: email);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                cmsData?.email ?? 'info@bayanatz.com',
                style: StyleText.fontSize13Weight400.copyWith(
                  color:           primaryColor,
                  fontSize:        12.sp,
                  decoration:      TextDecoration.underline,
                  decorationColor: primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(followLabel,
              style: StyleText.fontSize16Weight600.copyWith(
                  color: primaryColor, fontSize: 13.sp)),
          SizedBox(height: 10.h),
          _SocialRow(
              cmsData: cmsData, scaled: true, primaryColor: primaryColor),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD — UPDATED WITH ALL NEW FIELDS
// ═══════════════════════════════════════════════════════════════════════════════

class _FormCard extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, entityNameCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isMobile, isRtl;
  final String phoneCode, preferredLanguage;
  final String? selectedLocation, selectedEntityType, selectedEntitySize;
  final Color  primaryColor;
  final ValueChanged<String?>  onCodeChanged;
  final ValueChanged<String>   onLanguageChanged;
  final ValueChanged<String?>  onLocationChanged;
  final ValueChanged<String?>  onEntityTypeChanged;
  final ValueChanged<String?>  onEntitySizeChanged;
  final VoidCallback           onSend;

  const _FormCard({
    required this.firstNameCtrl,    required this.lastNameCtrl,
    required this.emailCtrl,        required this.phoneCtrl,
    required this.entityNameCtrl,   required this.subjectCtrl,
    required this.messageCtrl,      required this.submitted,
    required this.phoneCode,        required this.preferredLanguage,
    required this.selectedLocation, required this.selectedEntityType,
    required this.selectedEntitySize,
    required this.onCodeChanged,    required this.onLanguageChanged,
    required this.onLocationChanged, required this.onEntityTypeChanged,
    required this.onEntitySizeChanged,
    required this.onSend,           required this.isRtl,
    required this.primaryColor,     this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final double rad = isMobile ? 12 : 12.r;

    final String title             = _t(context, en: 'GET IN TOUCH',       ar: 'تواصل معنا');
    final String prefLangLabel     = _t(context, en: 'Preferred Language', ar: 'اللغة المفضلة');
    final String firstNameLabel    = _t(context, en: 'First Name',         ar: 'الاسم الأول');
    final String lastNameLabel     = _t(context, en: 'Last Name',          ar: 'اسم العائلة');
    final String emailLabel        = _t(context, en: 'Email',              ar: 'البريد الإلكتروني');
    final String phoneLabel        = _t(context, en: 'Phone Number',       ar: 'رقم الهاتف');
    final String locationLabel     = _t(context, en: 'Location',           ar: 'الموقع');
    final String entityNameLabel   = _t(context, en: "Entity's Name",      ar: 'اسم الجهة');
    final String entityTypeLabel   = _t(context, en: "Entity's Type",      ar: 'نوع الجهة');
    final String entitySizeLabel   = _t(context, en: "Entity's Size",      ar: 'حجم الجهة');
    final String subjectLabel      = _t(context, en: 'Subject',            ar: 'الموضوع');
    final String msgLabel          = _t(context, en: 'Message',            ar: 'الرسالة');
    final String hint              = _t(context, en: 'Text Here',          ar: 'اكتب هنا');
    final String sendLabel         = _t(context, en: 'Send',               ar: 'إرسال');
    final String selectLocation    = _t(context, en: 'Select Location',    ar: 'اختر الموقع');
    final String selectType        = _t(context, en: 'Select Type',        ar: 'اختر النوع');
    final String selectSize        = _t(context, en: 'Select Size',        ar: 'اختر الحجم');

    final TextDirection dir   = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign     align = isRtl ? TextAlign.right   : TextAlign.left;

    // ── Build dropdown items for entity type ──
    final entityTypes = isRtl
        ? ContactFormConstants.entityTypesAr
        : ContactFormConstants.entityTypesEn;
    final entityTypeItems = entityTypes
        .map((t) => {'key': t, 'value': t})
        .toList();

    // ── Build dropdown items for entity size ──
    final entitySizes = isRtl
        ? ContactFormConstants.entitySizesAr
        : ContactFormConstants.entitySizes;
    final entitySizeItems = entitySizes
        .map((s) => {'key': s, 'value': s})
        .toList();

    // ── Build dropdown items for location (countries) ──
    final countries = isRtl
        ? ContactFormConstants.countriesAr
        : ContactFormConstants.countriesEn;
    final countryItems = countries
        .map((c) => {'key': c, 'value': c})
        .toList();

    // ── Language radio labels ──
    final langLabels = isRtl
        ? ContactFormConstants.preferredLanguageLabelsAr
        : ContactFormConstants.preferredLanguageLabelsEn;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14.w : 20.w,
          vertical:   isMobile ? 12.h : 12.h),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(rad)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ──
          Text(title,
              style: StyleText.fontSize22Weight700.copyWith(
                  fontSize:      isMobile ? 16.sp : 16.sp,
                  color:         Colors.black,
                  letterSpacing: 1.2)),
          SizedBox(height: isMobile ? 8.h : 8.h),

          // ── Preferred Language (Radio) ──
          _FormLabel(label: prefLangLabel),
          SizedBox(height: 10.h),
          Row(
            children: ContactFormConstants.preferredLanguages.map((lang) {
              final bool selected = preferredLanguage == lang;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: isMobile ? 16.w : 20.w),
                child: GestureDetector(
                  onTap: () => onLanguageChanged(lang),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isMobile ? 18 : 18.w,
                          height: isMobile ? 18 : 18.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? primaryColor : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                            child: Container(
                              width:  isMobile ? 10 : 10.w,
                              height: isMobile ? 10 : 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            ),
                          )
                              : null,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          langLabels[lang] ?? lang,
                          style: StyleText.fontSize13Weight400.copyWith(
                            color:    selected ? Colors.black87 : Colors.black54,
                            fontSize: isMobile ? 12.sp : 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: isMobile ? 8.h : 10.h),

          // ── First Name / Last Name (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label:         firstNameLabel,
                  hint:          hint,
                  controller:    firstNameCtrl,
                  submitted:     submitted,
                  height:        32,
                  primaryColor:  primaryColor,
                  textDirection: dir,
                  textAlign:     align,
                ),
              ),
              SizedBox(width: isMobile ? 8.w : 12.w),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label:         lastNameLabel,
                  hint:          hint,
                  controller:    lastNameCtrl,
                  submitted:     submitted,
                  height:        32,
                  primaryColor:  primaryColor,
                  textDirection: dir,
                  textAlign:     align,
                ),
              ),
            ],
          ),

          // ── Email / Phone (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label:        emailLabel,
                  primaryColor: primaryColor,
                  hint: _t(context,
                      en: 'Enter your email',
                      ar: 'أدخل بريدك الإلكتروني'),
                  controller:    emailCtrl,
                  submitted:     submitted,
                  height:        32,
                  textDirection: dir,
                  textAlign:     align,
                ),
              ),
              SizedBox(width: isMobile ? 8.w : 12.w),
              Expanded(
                child: _PhoneField(
                  label:         phoneLabel,
                  controller:    phoneCtrl,
                  submitted:     submitted,
                  isMobile:      isMobile,
                  selectedCode:  phoneCode,
                  onCodeChanged: onCodeChanged,
                  isRtl:         isRtl,
                  primaryColor:  primaryColor,
                ),
              ),
            ],
          ),

          // ── Location / Entity Name (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DropdownField(
                  label:        locationLabel,
                  hint:         selectLocation,
                  value:        selectedLocation,
                  items:        countryItems,
                  onChanged:    onLocationChanged,
                  submitted:    submitted,
                  isRtl:        isRtl,
                  isMobile:     isMobile,
                  primaryColor: primaryColor,
                  isSearchable: true,
                ),
              ),
              SizedBox(width: isMobile ? 8.w : 12.w),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label:         entityNameLabel,
                  hint:          hint,
                  controller:    entityNameCtrl,
                  submitted:     false, // Entity name is optional
                  height:        32,
                  primaryColor:  primaryColor,
                  textDirection: dir,
                  textAlign:     align,
                ),
              ),
            ],
          ),

          // ── Entity Type / Entity Size (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DropdownField(
                  label:        entityTypeLabel,
                  hint:         selectType,
                  value:        selectedEntityType,
                  items:        entityTypeItems,
                  onChanged:    onEntityTypeChanged,
                  submitted:    submitted,
                  isRtl:        isRtl,
                  isMobile:     isMobile,
                  primaryColor: primaryColor,
                ),
              ),
              SizedBox(width: isMobile ? 8.w : 12.w),
              Expanded(
                child: _DropdownField(
                  label:        entitySizeLabel,
                  hint:         selectSize,
                  value:        selectedEntitySize,
                  items:        entitySizeItems,
                  onChanged:    onEntitySizeChanged,
                  submitted:    submitted,
                  isRtl:        isRtl,
                  isMobile:     isMobile,
                  primaryColor: primaryColor,
                ),
              ),
            ],
          ),

          // ── Subject (full width) ──
          CustomValidatedTextFieldMaster(
              primaryColor:  primaryColor,
              label:         subjectLabel,
              hint:          hint,
              controller:    subjectCtrl,
              submitted:     submitted,
              height:        32,
              minLength:     10,
              textDirection: dir,
              textAlign:     align),

          // ── Message (full width) ──
          CustomValidatedTextFieldMaster(
              primaryColor:  primaryColor,
              label:         msgLabel,
              hint:          hint,
              controller:    messageCtrl,
              submitted:     submitted,
              height:        72,
              maxLines:      3,
              minLength:     30,
              textDirection: dir,
              textAlign:     align),

          SizedBox(height: 4.h),

          // ── Send Button ──
          SizedBox(
            width:  double.infinity,
            height: isMobile ? 40.h : 36.h,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0),
              child: Text(sendLabel,
                  style: StyleText.fontSize16Weight600
                      .copyWith(color: Colors.white, fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Simple label widget for form fields
class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: StyleText.fontSize14Weight400
        .copyWith(color: AppColors.text, fontSize: 14.sp),
  );
}

class _DropdownField extends StatelessWidget {
  final String  label, hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl, isMobile;
  final Color primaryColor;
  final bool isSearchable;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.submitted,
    required this.isRtl,
    required this.isMobile,
    required this.primaryColor,
    this.isSearchable = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String requiredMsg = _t(context,
        en: 'This field is required',
        ar: 'هذا الحقل مطلوب');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label: label),
        SizedBox(height: 3.h),
        if (isSearchable)
          _SearchableDropdown(
            hint:         hint,
            value:        value,
            items:        items,
            onChanged:    onChanged,
            isRtl:        isRtl,
            isMobile:     isMobile,
            primaryColor: primaryColor,
            hasError:     showError,
          )
        else
          CustomDropdownFormFieldInvMaster(
            selectedValue: value,
            items:         items,
            onChanged:     onChanged,
            width:         double.infinity,
            height:        32,
            borderRadius:  4,
            widthIcon:     16,
            heightIcon:    16,
            hint: Text(hint,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryBlack)),
          ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Text(requiredMsg,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: Colors.red, fontSize: 11.sp)),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }
}

/// Searchable dropdown for country selection (long list)
/// Styled to match [CustomDropdownFormFieldInvMaster]
class _SearchableDropdown extends StatefulWidget {
  final String  hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool  isRtl, isMobile, hasError;
  final Color primaryColor;

  const _SearchableDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isRtl,
    required this.isMobile,
    required this.primaryColor,
    this.hasError = false,
  });

  @override
  State<_SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<_SearchableDropdown> {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();
  OverlayEntry? _overlayEntry;
  final _layerLink = LayerLink();
  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Resolve the display label from key → value
  String _resolveDisplayLabel() {
    final key = widget.value ?? '';
    if (key.isEmpty) return '';
    final match = widget.items.firstWhere(
          (e) => e['key'] == key,
      orElse: () => {'value': key},
    );
    return match['value'] ?? key;
  }

  void _showOverlay() {
    _removeOverlay();
    _filteredItems = widget.items;
    _searchCtrl.clear();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          // Dropdown content
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height),
              showWhenUnlinked: false,
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.background,
                child: StatefulBuilder(
                  builder: (context, setInnerState) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: widget.isMobile ? 220 : 225.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Search input ───────────────────────────────
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode:  _focusNode,
                              autofocus:  true,
                              style: StyleText.fontSize12Weight400
                                  .copyWith(color: AppColors.text),
                              decoration: InputDecoration(
                                hintText:
                                widget.isRtl ? 'بحث...' : 'Search...',
                                hintStyle: StyleText.fontSize12Weight400
                                    .copyWith(color: Colors.grey),
                                prefixIcon:
                                const Icon(Icons.search, size: 18),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(4.r),
                                  borderSide: BorderSide(
                                      color:
                                      Colors.grey.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(4.r),
                                  borderSide: BorderSide(
                                      color:
                                      Colors.grey.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(4.r),
                                  borderSide: BorderSide(
                                      color: widget.primaryColor),
                                ),
                              ),
                              onChanged: (query) {
                                setInnerState(() {
                                  if (query.isEmpty) {
                                    _filteredItems = widget.items;
                                  } else {
                                    final q = query.toLowerCase();
                                    _filteredItems = widget.items
                                        .where((item) =>
                                        (item['value'] ?? '')
                                            .toLowerCase()
                                            .contains(q))
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                          // ── Items list ─────────────────────────────────
                          Flexible(
                            child: ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbVisibility:
                                WidgetStateProperty.all(false),
                                trackVisibility:
                                WidgetStateProperty.all(false),
                                thickness:
                                WidgetStateProperty.all(0),
                                radius: Radius.zero,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _filteredItems.length,
                                itemBuilder: (_, i) {
                                  final item = _filteredItems[i];
                                  final selected =
                                      item['key'] == widget.value;
                                  return InkWell(
                                    onTap: () {
                                      widget.onChanged(item['key']);
                                      _removeOverlay();
                                    },
                                    hoverColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Container(
                                      height: 32.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w),
                                      alignment: AlignmentDirectional
                                          .centerStart,
                                      color: selected
                                          ? widget.primaryColor
                                          .withOpacity(0.08)
                                          : null,
                                      child: Text(
                                        item['value'] ?? '',
                                        style: StyleText
                                            .fontSize12Weight400
                                            .copyWith(
                                          color: selected
                                              ? widget.primaryColor
                                              : AppColors.text,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = _resolveDisplayLabel();

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _showOverlay,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            height: 32.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: widget.hasError
                  ? Colors.white
                  : const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: widget.hasError
                    ? Colors.red
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel.isEmpty ? widget.hint : displayLabel,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: displayLabel.isEmpty
                          ? AppColors.secondaryBlack
                          : AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: AppColors.secondaryBlack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Phone Field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool   submitted, isMobile, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color  primaryColor;

  const _PhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.label,
    required this.primaryColor,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget dropdown = CustomDropdownFormFieldInvMaster(
      selectedValue: selectedCode,
      items:         _phoneCodes,
      onChanged:     onCodeChanged,
      widthIcon:  16,
      heightIcon: 16,
      width:  isMobile ? 100.w : 110.w,
      height: 32,
      borderRadius: 4,
      hint: Text(
          isRtl ? 'أدخل رقم هاتفك' : 'Enter your number',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack)),
    );

    final Widget input = Expanded(
      child: CustomValidatedTextFieldMaster(
        hint:          isRtl ? 'أدخل رقم هاتفك' : 'Enter your number',
        controller:    controller,
        submitted:     submitted,
        primaryColor:  primaryColor,
        height:        32,
        onlyDigits:    true,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign:     isRtl ? TextAlign.right   : TextAlign.left,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.text, fontSize: 14.sp)),
        SizedBox(height: 3.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [dropdown, SizedBox(width: 6.w), input],
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OFFICE CARDS
// ═══════════════════════════════════════════════════════════════════════════════

class _OfficeCard extends StatelessWidget {
  final ContactOfficeLocation office;
  final bool  isRtl;
  final Color primaryColor;
  const _OfficeCard(
      {required this.office,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String name = isRtl && office.locationName.ar.isNotEmpty
        ? office.locationName.ar
        : office.locationName.en;
    final String text = isRtl && office.text1.ar.isNotEmpty
        ? office.text1.ar
        : office.text1.en;

    final bool hasLink = office.mapLink.isNotEmpty;

    return GestureDetector(
      onTap: hasLink ? () => _launchMapLink(office.mapLink) : null,
      child: MouseRegion(
        cursor:
        hasLink ? SystemMouseCursors.click : MouseCursor.defer,
        child: Container(
          width:  double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
              color:        const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(14.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (office.iconUrl.isNotEmpty)
                _officeIcon(
                    office.iconUrl, 80.w, 80.h, primaryColor)
              else
                Icon(Icons.location_on,
                    size: 80.w, color: primaryColor),
              SizedBox(height: 12.h),
              Text(name,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight700.copyWith(
                      color: primaryColor, fontSize: 13.sp)),
              SizedBox(height: 4.h),
              Text(text,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black45, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficeCardMobile extends StatelessWidget {
  final ContactOfficeLocation office;
  final bool  isRtl;
  final Color primaryColor;
  const _OfficeCardMobile(
      {required this.office,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String name = isRtl && office.locationName.ar.isNotEmpty
        ? office.locationName.ar
        : office.locationName.en;
    final String text = isRtl && office.text1.ar.isNotEmpty
        ? office.text1.ar
        : office.text1.en;

    final bool hasLink = office.mapLink.isNotEmpty;

    return GestureDetector(
      onTap: hasLink ? () => _launchMapLink(office.mapLink) : null,
      child: MouseRegion(
        cursor:
        hasLink ? SystemMouseCursors.click : MouseCursor.defer,
        child: Container(
          width:   double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: 22.h, horizontal: 16.w),
          decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (office.iconUrl.isNotEmpty)
                _officeIcon(
                    office.iconUrl, 90.w, 90.h, primaryColor)
              else
                Icon(Icons.location_on,
                    size: 90.w, color: primaryColor),
              SizedBox(height: 12.h),
              Text(name,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight700.copyWith(
                      color: primaryColor, fontSize: 14.sp)),
              SizedBox(height: 4.h),
              Text(text,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black45, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _officeIcon(
    String url, double w, double h, Color primaryColor) =>
    Image.network(
      url,
      width: w, height: h, fit: BoxFit.contain,
      loadingBuilder: (_, child, p) =>
      p == null ? child : SizedBox(width: w, height: h),
      errorBuilder: (_, __, ___) => SvgPicture.network(
        url,
        width: w, height: h, fit: BoxFit.contain,
      ),
    );

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL ICONS
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialRow extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  scaled;
  final Color primaryColor;
  const _SocialRow(
      {this.cmsData,
        required this.scaled,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final rawIcons = (cmsData?.socialIcons ?? [])
        .where((i) => i.iconUrl.isNotEmpty || i.link.isNotEmpty)
        .toList();

    final icons = rawIcons.length >= 3
        ? [rawIcons[1], rawIcons[2], rawIcons[0], ...rawIcons.sublist(3)]
        : rawIcons;

    if (icons.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: icons
            .map((i) => Padding(
          padding: EdgeInsetsDirectional.only(end: 8.w),
          child: scaled
              ? _SocialIconScaled(
              iconUrl:      i.iconUrl,
              link:         i.link,
              primaryColor: primaryColor)
              : _SocialIconRaw(
              iconUrl:      i.iconUrl,
              link:         i.link,
              primaryColor: primaryColor),
        ))
            .toList(),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SocialIconRaw(
            svgPath: 'assets/images/instegrm.svg',
            primaryColor: primaryColor),
        SizedBox(width: 8.w),
        _SocialIconRaw(
            svgPath: 'assets/images/twitter.svg',
            primaryColor: primaryColor),
        SizedBox(width: 8.w),
        _SocialIconRaw(
            svgPath: 'assets/images/linkedin.svg',
            primaryColor: primaryColor),
      ],
    );
  }
}

class _SocialIconScaled extends StatelessWidget {
  final String? svgPath, iconUrl, link;
  final Color   primaryColor;
  const _SocialIconScaled(
      {this.svgPath,
        this.iconUrl,
        this.link,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: (link?.isNotEmpty ?? false)
        ? () async {
      String raw = link!.trim();
      if (!raw.startsWith('http://') &&
          !raw.startsWith('https://')) {
        raw = 'https://$raw';
      }
      final uri = Uri.tryParse(raw);
      if (uri == null || !uri.hasAuthority) return;
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank');
      }
    }
        : null,
    child: MouseRegion(
      cursor: (link?.isNotEmpty ?? false)
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: Container(
        width: 40.w, height: 40.w,
        decoration: BoxDecoration(
            border:       Border.all(color: primaryColor),
            borderRadius: BorderRadius.circular(7.r)),
        child: Center(
          child: iconUrl != null && iconUrl!.isNotEmpty
              ? SvgPicture.network(iconUrl!,
              width:  20.w,
              height: 20.w,
              fit:    BoxFit.contain,
              colorFilter: ColorFilter.mode(
                  primaryColor, BlendMode.srcIn))
              : SvgPicture.asset(
              svgPath ?? 'assets/images/instegrm.svg',
              width:  20.w,
              height: 20.w,
              fit:    BoxFit.contain,
              colorFilter: ColorFilter.mode(
                  primaryColor, BlendMode.srcIn)),
        ),
      ),
    ),
  );
}

class _SocialIconRaw extends StatelessWidget {
  final String? svgPath, iconUrl, link;
  final Color   primaryColor;
  const _SocialIconRaw(
      {this.svgPath,
        this.iconUrl,
        this.link,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: (link?.isNotEmpty ?? false)
        ? () async {
      String raw = link!.trim();
      if (!raw.startsWith('http://') &&
          !raw.startsWith('https://')) {
        raw = 'https://$raw';
      }
      final uri = Uri.tryParse(raw);
      if (uri == null || !uri.hasAuthority) return;
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank');
      }
    }
        : null,
    child: MouseRegion(
      cursor: (link?.isNotEmpty ?? false)
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: Container(
        width: 40.w, height: 40.w,
        decoration: BoxDecoration(
            border:       Border.all(color: primaryColor),
            borderRadius: BorderRadius.circular(7.r)),
        child: Center(
          child: iconUrl != null && iconUrl!.isNotEmpty
              ? SvgPicture.network(iconUrl!,
              width:  20.w,
              height: 20.w,
              fit:    BoxFit.contain,
              colorFilter: ColorFilter.mode(
                  primaryColor, BlendMode.srcIn))
              : SvgPicture.asset(
              svgPath ?? 'assets/images/instegrm.svg',
              width:  20.w,
              height: 20.w,
              fit:    BoxFit.contain,
              colorFilter: ColorFilter.mode(
                  primaryColor, BlendMode.srcIn)),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUCCESS DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _SuccessDialog extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  isRtl;
  final Color primaryColor;
  const _SuccessDialog(
      {this.cmsData,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bool   isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    final String title    = cmsData != null
        ? _bi(context, cmsData!.confirmMessage.title)
        : _t(context,
        en: "WE'VE RECEIVED YOUR MESSAGE — AND WE'RE ON IT!",
        ar: 'لقد استلمنا رسالتك وسنرد عليك في أقرب وقت!');
    final String desc = cmsData != null
        ? _bi(context, cmsData!.confirmMessage.description)
        : _t(context,
        en: "Thanks For Getting In Touch. We're Already Reviewing Your Message And Will Connect With You Soon.",
        ar: 'شكرًا للتواصل معنا — رسالتك في طريقها إلى فريقنا. سنتواصل معك قريبًا.');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(isMobile ? 14 : 16.r)),
        insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 36.w,
            vertical:   isMobile ? 56 : 36.h),
        child: SizedBox(
          width: isMobile ? double.infinity : 640.w,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 32.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cmsData?.confirmMessage.svgUrl.isNotEmpty ?? false)
                  SvgPicture.network(
                    cmsData!.confirmMessage.svgUrl,
                    width:  isMobile ? double.infinity : 260.w,
                    height: isMobile ? 140 : 160.h,
                    fit:    BoxFit.contain,
                  )
                else
                  SvgPicture.asset(
                    'assets/images/contact_us/contact_send.svg',
                    width:  isMobile ? 120 : 140.w,
                    height: isMobile ? 100 : 120.h,
                    fit:    BoxFit.contain,
                  ),
                SizedBox(height: isMobile ? 16.0 : 22.h),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize22Weight700.copyWith(
                      fontSize: isMobile ? 14.0 : 20.sp,
                      color:    Colors.black),
                ),
                SizedBox(height: isMobile ? 10.0 : 14.h),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                      fontSize: isMobile ? 12.0 : 14.sp,
                      height:   1.7,
                      color:    Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}