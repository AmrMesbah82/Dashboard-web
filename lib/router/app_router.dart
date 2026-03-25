import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/pages/about_us_control/about_us_edit.dart';
import 'package:web_app_admin/pages/about_us_control/about_us_preview.dart';
import 'package:web_app_admin/pages/blog_control/blog_edit_page.dart';
import 'package:web_app_admin/pages/blog_control/blog_list_page.dart';
import 'package:web_app_admin/pages/blog_detail_page.dart';
import 'package:web_app_admin/pages/contatc_us/contact_us_list.dart';
import 'package:web_app_admin/pages/contatc_us/contact_us_preview_page.dart';
import 'package:web_app_admin/pages/contatc_us/contatc_us_details.dart';
import 'package:web_app_admin/pages/contatc_us/contacu_us_location_edit.dart';
import 'package:web_app_admin/pages/dashboard/about_page/about_main_page_master.dart';
import 'package:web_app_admin/pages/dashboard/career_page/careers_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/career_page/careers_main_page.dart';
import 'package:web_app_admin/pages/dashboard/career_page/careers_preview_page.dart';
import 'package:web_app_admin/pages/dashboard/contact_page/contact_us_main_page.dart';
import 'package:web_app_admin/pages/dashboard/home_page/home_main_page.dart';


import 'package:web_app_admin/pages/dashboard/main_page/home_edit_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_main_page.dart';
import 'package:web_app_admin/pages/dashboard/main_page/home_preview_page.dart';
import 'package:web_app_admin/pages/home_control/home_control_edit.dart';
import 'package:web_app_admin/pages/home_control/home_control_preview.dart';
import 'package:web_app_admin/pages/services_control/edit_page_servcies.dart';
import 'package:web_app_admin/pages/services_control/preview_services.dart';
import 'package:web_app_admin/pages/job_page.dart';
import 'package:web_app_admin/pages/services_page.dart';
import 'package:web_app_admin/pages/contact_page.dart';
import 'package:web_app_admin/pages/careers_page.dart';
import 'package:web_app_admin/repo/repo.dart';

import '../pages/about_page.dart';
import '../pages/careers_main_dashboard.dart';
import '../pages/home_page.dart';
import '../repo/application/application_repo_imp.dart';
import '../repo/job_list/job_listing_repo_imp.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE + ANGLE + FADE PAGE TRANSITION
// ═══════════════════════════════════════════════════════════════════════════════

enum SlideDirection { fromRight, fromLeft, fromBottom }

CustomTransitionPage<T> animatedPage<T>({
  required LocalKey key,
  required Widget child,
  SlideDirection slideDirection = SlideDirection.fromRight,
  Duration duration = const Duration(milliseconds: 650),
  Curve curve = Curves.easeOutCubic,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final Offset beginOffset = switch (slideDirection) {
        SlideDirection.fromRight  => const Offset(0.12, 0.0),
        SlideDirection.fromLeft   => const Offset(-0.12, 0.0),
        SlideDirection.fromBottom => const Offset(0.0, 0.08),
      };

      final slideAnim = Tween<Offset>(begin: beginOffset, end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
        ),
      );

      final skewSign = slideDirection == SlideDirection.fromLeft ? 1.0 : -1.0;
      final skewAnim = Tween<double>(begin: skewSign * 0.05, end: 0.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final scaleAnim = Tween<double>(begin: 0.97, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final exitFade = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: exitFade,
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateY(skewAnim.value)
                  ..scale(scaleAnim.value),
                alignment: Alignment.center,
                child: child,
              ),
              child: pageChild,
            ),
          ),
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROUTER
// ═══════════════════════════════════════════════════════════════════════════════

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [

      // ── Public pages ───────────────────────────────────────────────────────

      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const CareersMainPageDashboard(),
      ),

      GoRoute(
        path: '/services',
        name: 'services',
        pageBuilder: (context, state) {
          final String? section = state.uri.queryParameters['section'];
          return animatedPage(
            key:   state.pageKey,
            child: ServicesPage(scrollTo: section),
          );
        },
      ),

      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: const AboutPage(),
        ),
      ),

      GoRoute(
        path: '/contact',
        name: 'contact',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: const ContactPage(),
        ),
      ),

      GoRoute(
        path: '/careers',
        name: 'careers',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: const CareersPage(),
        ),
      ),

      GoRoute(
        path: '/jobs',
        name: 'jobs',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: const JobListingsPage(),
        ),
      ),

      GoRoute(
        path: '/blog/:index',
        name: 'blog',
        pageBuilder: (context, state) {
          final index =
              int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
          return animatedPage(
            key:   state.pageKey,
            child: BlogDetailPage(),
          );
        },
      ),

      // ── Admin CMS pages ────────────────────────────────────────────────────

      GoRoute(
        path: '/admin/home-editor',
        name: 'home-editor',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const HomePageEditor(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/home-preview',
        name: 'home-control-preview',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const HomePagePreview(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/service-editor',
        name: 'service-editor',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ServicePageEditor(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/service-preview',
        name: 'service-preview',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ServicePreviewPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/blog-list',
        name: 'blog-list',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const BlogEditPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      // ── About Us CMS ───────────────────────────────────────────────────────

      GoRoute(
        path: '/admin/about-edit',
        name: 'about-edit',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const AboutEditPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      // ── Home CMS (HomeMainPageMaster) ──────────────────────────────────────────
      GoRoute(
        path: '/admin/home-page',
        name: 'home-page',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child: BlocProvider.value(
            value: context.read<HomeCmsCubit>(), // ✅ reuse global cubit from main.dart
            child: const HomeMainPageMaster(),
          ),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/about-cms',
        name: 'about-cms',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child: BlocProvider(
            create: (_) => AboutCubit()..load(),
            child: const AboutMainPageMasterDashboard(),
          ),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/about-preview',
        name: 'about-preview',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const AboutPreviewPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      // ── Dashboard (Main / Edit / Preview) ─────────────────────────────────

      GoRoute(
        path: '/admin/dashboard',
        name: 'home_main',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const HomeMainPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/dashboard/edit',
        name: 'home_edit',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const HomeEditPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/dashboard/preview',
        name: 'home_preview',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const HomePreviewPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      // ── Contact Submissions ────────────────────────────────────────────────

      GoRoute(
        path: '/admin/contacts',
        name: 'contacts',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ContactsListPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/contacts/detail',
        name: 'contact-detail',
        pageBuilder: (context, state) {
          final submission = state.extra;
          if (submission == null || submission is! ContactSubmission) {
            return animatedPage(
              key:            state.pageKey,
              child:          const ContactsListPage(),
              slideDirection: SlideDirection.fromBottom,
            );
          }
          return animatedPage(
            key:            state.pageKey,
            child:          ContactDetailPage(submission: submission),
            slideDirection: SlideDirection.fromBottom,
          );
        },
      ),

      // ── Contact Us CMS ─────────────────────────────────────────────────────

      GoRoute(
        path: '/admin/contact-cms',
        name: 'contact-cms',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ContactUsMainPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/contact-cms/edit',
        name: 'contact-cms-edit',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ContactUsCmsEditPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/contact-cms/preview',
        name: 'contact-cms-preview',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child:          const ContactUsCmsPreviewPage(),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      // ── Careers CMS ────────────────────────────────────────────────────────

      // ✅ AFTER
      GoRoute(
        path: '/admin/careers-cms',
        name: 'careers-cms',
        pageBuilder: (context, state) => animatedPage(
          key:            state.pageKey,
          child: BlocProvider(
            create: (_) => CareersCmsCubit(
              jobRepo: JobListingRepoImp(),
              appRepo: ApplicationRepoImp(), // your application repo implementation
            )..load(),
            child: const CareersMainPageMaster(),
          ),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/careers-cms/edit',
        name: 'careers-cms-edit',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: BlocProvider(
            create: (_) => CareersCmsCubit(
              jobRepo: JobListingRepoImp(),
              appRepo: ApplicationRepoImp(), // your application repo implementation
            )..load(),
            child: const CareersEditPage(),
          ),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),

      GoRoute(
        path: '/admin/careers-cms/preview',
        name: 'careers-cms-preview',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: BlocProvider(
            create: (_) => CareersCmsCubit(
              jobRepo: JobListingRepoImp(),
              appRepo: ApplicationRepoImp(), // your application repo implementation
            )..load(),
            child: const CareersPreviewPage(),
          ),
          slideDirection: SlideDirection.fromBottom,
        ),
      ),
    ],
  );
}