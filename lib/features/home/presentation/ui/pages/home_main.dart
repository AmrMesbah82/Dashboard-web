/// ******************* FILE INFO *******************
/// File Name: home_main_page_master.dart
/// Updated: AppNavbar now receives [onItemTap] so clicking a nav item in the
///          admin shell never routes to the public site.
/// Pages 1–3 — Read-only overview (Figma screens 1, 2, 3)
/// Sub-navbar: Main(active) | Home | Services | About Us | Contact Us | Careers
/// Status tabs: Published | Scheduled | Draft
/// FIXED: Tabs now show real content filtered by publishStatus
/// FIXED: Scheduled tab shows scheduled date info
/// FIXED: Draft tab shows draft content with "last saved" info
/// ADDED: Read-only "Headings" accordion (Title EN/AR + Short Desc EN/AR)
/// ADDED: Read-only "Navigation Button" accordion (button list with name/route/status)
/// FIXED: Handle HomeCmsDraftSaved / HomeCmsDraftDeleted states ✅
/// FIXED: Re-load data on initState to get fresh state after navigation ✅

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/core/widget/navigator.dart';



import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../../services/presentation/ui/pages/services_main/services_main.dart';
import '../../../data/models/home_model.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import 'home_edit.dart';
import 'home_preview.dart';
part '../widget/home_main/home_main_builders.dart';
part '../widget/home_main/home_main_read_only.dart';


// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color border    = Color(0xFFE0E0E0);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color scheduled = Color(0xFFFF8F00);
// }

/// Available route labels for display in the read-only view
const Map<String, String> _kRouteLabelMap = {
  '/':         'Home',
  '/services': 'Services',
  '/about':    'About',
  '/contact':  'Contact Us',
  '/careers':  'Careers',
};

// ─────────────────────────────────────────────────────────────────────────────
class HomeMainPageMaster extends StatefulWidget {
  const HomeMainPageMaster({super.key});
  @override
  State<HomeMainPageMaster> createState() => _HomeMainPageMasterState();
}

class _HomeMainPageMasterState extends State<HomeMainPageMaster>
    with SingleTickerProviderStateMixin {
  int _subNavIndex = 1; // "Home" tab is active
  final List<String> _subNavLabels = [
    'Main', 'Home', 'Services', 'About Us', 'Contact Us', 'Careers'
  ];

  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // rebuild to update tab underline styles
      }
    });

    // ✅ Re-load data when this page is created (e.g. after navigating back
    //    from edit page). This ensures we always show the latest state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, bool> _open = {
    'headings':   true,
    'navButtons': true,
    'navBtn':     true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  Color _hexColor(String hex) {
    try {
      final c = hex.replaceAll('#', '');
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    } catch (_) {}
    return ColorPick.primary;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        // ✅ Extract data from ALL possible data-carrying states
        HomePageModel? data;
        if (state is HomeCmsLoaded)       data = state.data;
        if (state is HomeCmsSaved)        data = state.data;
        if (state is HomeCmsDraftSaved)   data = state.data;
        if (state is HomeCmsSaving)       data = state.data;

        // ✅ For HomeCmsDraftDeleted, re-load to get the published data
        if (state is HomeCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HomeCmsCubit>().load();
          });
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        // ✅ For HomeCmsError, try to use lastData
        if (state is HomeCmsError) {
          data = state.lastData;
        }

        // ✅ Fallback: use cubit's current model
        data ??= context.read<HomeCmsCubit>().current;

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel:    'Web Page',
                    homePage:       CareersMainPageDashboard(),
                    webPage:        HomeMainPage(),
                    jobListingPage: JobListingMainPage(),
                  ),

                  SizedBox(height: 20.h),
                  AdminSubNavBar(
                    activeIndex: 1,
                    homeCubit: context.read<HomeCmsCubit>(),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 1000.w,
                    child: _body(data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
