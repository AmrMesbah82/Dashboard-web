import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_app_admin/controller/about_company/AboutCompanyCubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_cubit.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web_app_admin/pages/dashboard/inquire/inquiry_main_page.dart';
import 'package:web_app_admin/repo/Services/repo_imp.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_app_admin/repo/application/application_repo_imp.dart';
import 'package:web_app_admin/repo/department/department_repo_imp.dart';
import 'package:web_app_admin/repo/home_repository_impl.dart';
import 'package:web_app_admin/repo/inquire/inquiry_repo_imp.dart';
import 'package:web_app_admin/repo/job_list/about_company_repo_imp.dart';
import 'package:web_app_admin/repo/job_list/job_listing_repo_imp.dart';
import 'controller/application/application_cubit.dart';
import 'controller/blog/blog_cubit.dart';
import 'controller/department/department_cubit.dart';
import 'controller/inquire/inquiry_cubit.dart';
import 'controller/job_list/job_listing_cubit.dart';
import 'controller/lang_state.dart';
import 'controller/services/services_cubit.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  usePathUrlStrategy(); // ← removes the # from URLs
  AppTheme.setCurrentThemeColors();
  runApp(const BayanatzApp());
}

Size _getDesignSize({
  required double screenWidth,
  required double screenHeight,
}) {
  final isLandscape = screenWidth > screenHeight;

  // ignore: avoid_print
  print('📱 [DESIGN-SIZE] Screen: ${screenWidth}×${screenHeight} (landscape: $isLandscape)');

  // ==================== DESKTOP PLATFORMS ====================
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    // ignore: avoid_print
    print('🖥️ [DESIGN-SIZE] Desktop platform detected');

    if (screenWidth >= 1920) {
      const size = Size(1920, 1080);
      // ignore: avoid_print
      print('🖥️ [DESIGN-SIZE] Large desktop (≥1920): $size');
      return size;
    }
    if (screenWidth >= 1366) {
      const size = Size(1366, 768);
      // ignore: avoid_print
      print('💻 [DESIGN-SIZE] Laptop desktop (1366–1919): $size');
      return size;
    }
    if (screenWidth >= 768) {
      final size = isLandscape ? const Size(1024, 768) : const Size(768, 1024);
      // ignore: avoid_print
      print('📱 [DESIGN-SIZE] Tablet desktop (768–1365): $size');
      return size;
    }
    const size = Size(375, 812);
    // ignore: avoid_print
    print('📱 [DESIGN-SIZE] Small desktop (<768): $size');
    return size;
  }

  // ==================== LARGE DESKTOP / TV (≥ 1920) ====================
  if (screenWidth >= 1920) {
    const size = Size(1920, 1080);
    // ignore: avoid_print
    print('🖥️ [DESIGN-SIZE] Large desktop / TV (≥1920): $size');
    return size;
  }

  // ==================== LAPTOP (1366 – 1919) ====================
  if (screenWidth >= 1366) {
    const size = Size(1366, 768);
    // ignore: avoid_print
    print('💻 [DESIGN-SIZE] Laptop (1366–1919): $size');
    return size;
  }

  // ==================== TABLET (768 – 1365) ====================
  if (screenWidth >= 768) {
    final size = isLandscape ? const Size(1024, 768) : const Size(768, 1024);
    // ignore: avoid_print
    print('📱 [DESIGN-SIZE] Tablet (768–1365): $size');
    return size;
  }

  // ==================== MOBILE (< 768) ====================
  final size = isLandscape ? const Size(812, 375) : const Size(375, 812);
  // ignore: avoid_print
  print('📱 [DESIGN-SIZE] Mobile (<768): $size');
  return size;
}

class BayanatzApp extends StatelessWidget {
  const BayanatzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = View.of(context).physicalSize / View.of(context).devicePixelRatio;
    final designSize = _getDesignSize(
      screenWidth: screen.width,
      screenHeight: screen.height,
    );

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      builder: (ctx, _) {
        return MultiBlocProvider(
          providers: [
            // ← Add LanguageCubit FIRST so it's available to all widgets
            BlocProvider<LanguageCubit>(
              create: (_) => LanguageCubit(),
            ),
            BlocProvider<HomeCmsCubit>(
              create: (_) => HomeCmsCubit(
                repository: HomeRepositoryImpl(),
              )..load(),
            ),
            BlocProvider<ServiceCmsCubit>(
              create: (_) => ServiceCmsCubit(
                repo: ServiceRepositoryImpl(),
              )..load(),
            ),
            BlocProvider<BlogCubit>(
              create: (_) => BlogCubit()..load(),
            ),
            BlocProvider<AboutCubit>(
              create: (_) => AboutCubit()..load(),
            ),
            BlocProvider<ContactCubit>(
              create: (_) => ContactCubit(),
            ),
            BlocProvider<ContactUsCmsCubit>(
              create: (_) => ContactUsCmsCubit()..load(),
            ),
            BlocProvider<CareersCmsCubit>(
              create: (_) => CareersCmsCubit(
                jobRepo: JobListingRepoImp(),
                appRepo: ApplicationRepoImp(), // your application repo implementation
              )..loadRealData(), // ← was ..load()
            ),

            BlocProvider(
              create: (_) => InquiryCubit(repo: InquiryRepoImp()),
              child: InquiryMainPage(),
            ),

            BlocProvider<JobListingCubit>(
              create: (_) => JobListingCubit(repo: JobListingRepoImp())..loadJobs(),
            ),

            BlocProvider<AboutCompanyCubit>(
              create: (_) => AboutCompanyCubit(
                repo: AboutCompanyRepoImp(),
              )..loadAboutCompany(),
            ),

            BlocProvider<DepartmentCubit>(
              create: (_) => DepartmentCubit(
                repo: DepartmentRepoImp(),
              )..loadDepartments(),
            ),
            BlocProvider<ApplicationCubit>(
              create: (_) => ApplicationCubit(
                repo: ApplicationRepoImp(),
              ),
            ),
            BlocProvider<InquiryCubit>(
              create: (_) => InquiryCubit(repo: InquiryRepoImp()),
            ),

          ],
          child: BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return MaterialApp.router(
                title: 'Bayanatz',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: AppTheme.isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
                locale: langState.locale,
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('ar'), // Arabic
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          ),
        );
      },
    );
  }
}