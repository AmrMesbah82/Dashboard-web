/// ******************* FILE INFO *******************
/// File Name: home_edit.dart
/// Page 2 — "Editing Main Details"
///
/// ✅ FIXES APPLIED:
///   1. SVG ByteBuffer fix — readAsArrayBuffer returns ByteBuffer, not List<int>
///   2. Validation gate — Publish blocked until ALL required fields are valid
///   3. Only showPublishConfirmDialog used — no success/error snackbars or dialogs
///   4. Navigation via BlocConsumer listener → HomeMainPage (pushAndRemoveUntil)
///   5. _submitted flag reveals inline field errors on first publish attempt

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/circle_progress.dart';
import '../../../../../core/widget/custom_dropdwon.dart';
import '../../../../../core/widget/navigator.dart';
import '../../../../../core/widget/textfield.dart';
import '../../../../careers/presentation/ui/pages/careers_main.dart';
import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../job/presentation/ui/pages/job_listing_main.dart';
import 'main_main.dart';
import 'main_preview.dart'; // adjust import path as needed

part '../widget/main_edit/picked_image.dart';
part '../widget/main_edit/link_item.dart';
part '../widget/main_edit/color_picker_field.dart';
part '../widget/main_edit/color_wheel_overlay.dart';
part '../widget/main_edit/edit_save.dart';
part '../widget/main_edit/edit_sections1.dart';
part '../widget/main_edit/edit_sections2.dart';
part '../widget/main_edit/edit_helpers.dart';

// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color sectionBg = Color(0xFFF5F5F5);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color border    = Color(0xFFE0E0E0);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
//   static const Color divider   = Color(0xFFE8E8E8);
//   static const Color remove    = Color(0xFFE53935);
//   static const Color back      = Color(0xFFF1F2ED);
//   static const Color error     = Color(0xFFE53935);
// }

// ── Route dropdown used only for nav-section route picker ──────────────────
const List<Map<String, String>> _kRoutes = [
  {'key': '',          'value': 'None'},
  {'key': '/',         'value': 'Home (/)'},
  {'key': '/services', 'value': 'Services (/services)'},
  {'key': '/about',    'value': 'About Us (/about)'},
  {'key': '/contact',  'value': 'Contact Us (/contact)'},
  {'key': '/careers',  'value': 'Careers (/careers)'},
  {'key': '/jobs',     'value': 'Jobs (/jobs)'},
];

// ── Fixed label-destination list ─────────────────────────────────────────────
const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  {'key': '/careers?tab=why-join-our-team',      'value': 'Why Join Our Team'},
  {'key': '/careers?tab=interns',                'value': 'Our Interns'},
  {'key': '/careers?tab=our-team',               'value': 'Our Team'},
  {'key': '/contact',                            'value': 'Contact Form'},
];

const List<Map<String, String>> _kFonts = [
  {'key': 'Cairo',     'value': 'Cairo'},
  {'key': 'Roboto',    'value': 'Roboto'},
  {'key': 'Poppins',   'value': 'Poppins'},
  {'key': 'Tajawal',   'value': 'Tajawal'},
  {'key': 'Almarai',   'value': 'Almarai'},
  {'key': 'Noto Sans', 'value': 'Noto Sans'},
];

class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});

  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  /// Set to true the first time the user taps Publish, to reveal inline errors.
  bool _submitted = false;

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.of(
    List.generate(3, (_) => {
      'nameEn': TextEditingController(),
      'nameAr': TextEditingController(),
    }),
  );
  final List<String?> _navRoutes = List.of([null, null, null]);
  final List<bool>    _navStatus = List.of([true,  true,  true]);

  // ── Sections 1–4 ──────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections =
  List.generate(4, (_) => {
    'textBox':       TextEditingController(text: '#008037'),
    'description':   TextEditingController(),
    'descriptionAr': TextEditingController(),
  });

  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4,
        (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Footer columns ────────────────────────────────────────────────────────
  late final List<Map<String, dynamic>> _footerColumns;

  // ── Social links ──────────────────────────────────────────────────────────
  late final List<_LinkItem> _links;

  // ── Logo ──────────────────────────────────────────────────────────────────
  _PickedImage _logoPicked = const _PickedImage();

  // ── Branding ──────────────────────────────────────────────────────────────
  final _primaryColor      = TextEditingController(text: '#008037');
  final _secondaryColor    = TextEditingController(text: '#D9D9D9');
  final _bgColor           = TextEditingController(text: '#D9D9D9');
  final _headerFooterColor = TextEditingController(text: '#D9D9D9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';

  // ── Accordion open/close ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'theme': true, 'footer': true, 'links': true,
    'headings': true, 'navBtn': true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  // ── Seed-hash guard ───────────────────────────────────────────────────────
  int? _seededModelHash;

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return ColorPick.primary;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ VALIDATION GATE
  //    Returns true ONLY when ALL required fields are filled and valid.
  //    Publish button is disabled (dimmed + tap-blocked) until this is true.
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isFormValid {
    // ── Helper: has Arabic characters ──────────────────────────────────────
    bool hasArabic(String t) => RegExp(r'[\u0600-\u06FF]').hasMatch(t);
    bool hasEnglish(String t) => RegExp(r'[a-zA-Z]').hasMatch(t);

    // Logo required
    if (_logoPicked.isEmpty) return false;

    // Nav buttons
    for (int i = 0; i < _navBtns.length; i++) {
      final route = _navRoutes[i];
      if (route == null || route.isEmpty) return false;

      final en = _navBtns[i]['nameEn']!.text;
      final ar = _navBtns[i]['nameAr']!.text;
      if (en.trim().isEmpty || hasArabic(en)) return false;
      if (ar.trim().isEmpty || hasEnglish(ar)) return false;
    }

    // Footer columns
    for (final col in _footerColumns) {
      final colRoute = col['route'] as String?;
      if (colRoute == null || colRoute.isEmpty) return false;

      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        final labelRoute = label['route'] as String?;
        if (labelRoute == null || labelRoute.isEmpty) return false;

        final en = (label['en'] as TextEditingController).text;
        final ar = (label['ar'] as TextEditingController).text;
        if (en.trim().isEmpty || hasArabic(en)) return false;
        if (ar.trim().isEmpty || hasEnglish(ar)) return false;
      }
    }

    // Social links
    for (final link in _links) {
      if (link.icon.isEmpty) return false;
      if (link.text.text.trim().isEmpty) return false;
    }

    // Fonts
    if (_engFont == null || _engFont!.isEmpty) return false;
    if (_arFont  == null || _arFont!.isEmpty)  return false;

    return true;
  }

  // Collects the first validation error message to display in the dialog.
  String? _getValidationError() {
    if (_logoPicked.isEmpty) {
      return 'Please upload a logo image (SVG format)';
    }

    for (int i = 0; i < _navBtns.length; i++) {
      final route = _navRoutes[i];
      if (route == null || route.isEmpty) {
        return 'Please select a route for navigation button ${i + 1}';
      }
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) {
        return 'Please enter English title for navigation button ${i + 1}';
      }
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) {
        return 'Please enter Arabic title for navigation button ${i + 1}';
      }
    }

    for (int i = 0; i < _footerColumns.length; i++) {
      final col = _footerColumns[i];
      final colRoute = col['route'] as String?;
      if (colRoute == null || colRoute.isEmpty) {
        return 'Please select a navigation route for Footer Column ${i + 1}';
      }

      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (int j = 0; j < labels.length; j++) {
        final label = labels[j];
        final labelRoute = label['route'] as String?;
        if (labelRoute == null || labelRoute.isEmpty) {
          return 'Please select a destination for Label ${j + 1} in Footer Column ${i + 1}';
        }
        if ((label['en'] as TextEditingController).text.trim().isEmpty) {
          return 'Please enter English text for Label ${j + 1} in Footer Column ${i + 1}';
        }
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) {
          return 'Please enter Arabic text for Label ${j + 1} in Footer Column ${i + 1}';
        }
      }
    }

    for (int i = 0; i < _links.length; i++) {
      if (_links[i].icon.isEmpty) {
        return 'Please upload an icon for Social Link ${i + 1}';
      }
      if (_links[i].text.text.trim().isEmpty) {
        return 'Please enter a URL for Social Link ${i + 1}';
      }
    }

    if (_engFont == null || _engFont!.isEmpty) {
      return 'Please select an English Font';
    }
    if (_arFont == null || _arFont!.isEmpty) {
      return 'Please select an Arabic Font';
    }

    return null;
  }

  // ── Helpers: build a nav-items dropdown list from current local state ──────
  List<Map<String, String>> _buildNavDropdownItems() {
    final items = <Map<String, String>>[
      {'key': '', 'value': 'None'},
    ];
    for (var i = 0; i < _navBtns.length; i++) {
      final en    = _navBtns[i]['nameEn']!.text.trim();
      final route = _navRoutes[i] ?? '';
      if (route.isEmpty) continue;
      items.add({'key': route, 'value': en.isNotEmpty ? en : route});
    }
    return items;
  }

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _seededModelHash = null;
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links         = List.generate(4, (_) => _LinkItem());

    // Listen to all text controllers so _isFormValid re-evaluates on change
    for (final m in _sections) {
      for (final c in m.values) c.addListener(_onFieldChanged);
    }
    _primaryColor.addListener(_onFieldChanged);
    _secondaryColor.addListener(_onFieldChanged);
    _bgColor.addListener(_onFieldChanged);
    _headerFooterColor.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeCmsCubit>().load();
    });
  }

  // ── Image picker (SVG only) ───────────────────────────────────────────────
  // ✅ FIX: readAsArrayBuffer returns ByteBuffer, not List<int>.
  //    We must cast to ByteBuffer and wrap with Uint8List.view().
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;

      // ── SVG-only guard ──────────────────────────────────────────────────
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          // ✅ ByteBuffer fix: readAsArrayBuffer returns a ByteBuffer object,
          //    not List<int>. Use Uint8List.view() to wrap it correctly.
          if (result is ByteBuffer) {

            completer.complete(
                _PickedImage(bytes: Uint8List.view(result)));
          } else if (result is List<int>) {
            // Fallback — should not normally happen with readAsArrayBuffer

            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
          } else {

            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) {
        completed = true;
        completer.complete(null);
      }
    });

    return completer.future;
  }

  // ── Footer/label helpers ──────────────────────────────────────────────────
  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route':   null as String?,
    'labels':  <Map<String, dynamic>>[_newLabelRow()],
  };

  Map<String, dynamic> _newLabelRow() => {
    'en':    TextEditingController(),
    'ar':    TextEditingController(),
    'route': null as String?,
  };

  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, dynamic>>) {
      _disposeLabel(l);
    }
  }

  void _disposeLabel(Map<String, dynamic> label) {
    (label['en'] as TextEditingController).dispose();
    (label['ar'] as TextEditingController).dispose();
  }

  @override
  void dispose() {
    for (final m in _navBtns) {
      for (final c in m.values) {
        c.removeListener(_onFieldChanged);
        c.dispose();
      }
    }
    for (final m in _sections) {
      for (final c in m.values) {
        c.removeListener(_onFieldChanged);
        c.dispose();
      }
    }
    for (final col in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor..removeListener(_onFieldChanged)..dispose();
    _secondaryColor..removeListener(_onFieldChanged)..dispose();
    _bgColor..removeListener(_onFieldChanged)..dispose();
    _headerFooterColor..removeListener(_onFieldChanged)..dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {

        // ── Published / Saved successfully → navigate to HomeMainPage ──────
        // ✅ Uses pushAndRemoveUntil to clear the entire back stack,
        //    exactly like master_edit_page.dart does.
        if (state is HomeCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const HomeMainPage()),
                    (route) => false,
              );
            }
          });
        }

        // ── Error state ───────────────────────────────────────────────────
        if (state is HomeCmsError) {
          // Errors are visible to the user through the cubit state;
          // add a snackbar/dialog here if you want, but no success dialogs.
        }
      },
      builder: (context, state) {

        if (state is HomeCmsLoaded) {
          _seedFromModel(state.data);
        } else if (state is HomeCmsSaved) {
          _seedFromModel(state.data); // HomeCmsSaved must expose .data
        }
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.white,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          AppAdminNavbar(
                            activeLabel:    'Home',
                            homePage:       CareersMainPageDashboard(),
                            webPage:        HomeMainPage(),
                            jobListingPage: JobListingMainPage(),
                          ),

                          SizedBox(width: 20.w),
                          AdminSubNavBar(activeIndex: 0),
                          SizedBox(
                            width: 1050.w,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editing Main Details',
                                    style: StyleText.fontSize45Weight600.copyWith(
                                      color: ColorPick.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),

                                  // ── Theme & Logo ─────────────────────────
                                  _accordion(
                                      key: 'theme',
                                      title: 'Theme and Logo',
                                      children: [_logoAndBrandingSection()]),
                                  _gap(),

                                  // ── Navigation Items ─────────────────────
                                  _navSection(),
                                  _gap(),

                                  // ── Footer ───────────────────────────────
                                  _footerSection(cubit),
                                  _gap(),

                                  // ── Social Links ─────────────────────────
                                  _linksSection(),
                                  _gap(),

                                  // ── Actions ──────────────────────────────
                                  _bottomActions(cubit),
                                  _gap(),

                                  // ── Discard button ────────────────────────
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                  const HomeMainPage(),
                                                ),
                                              );
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration:
                                            const Duration(milliseconds: 200),
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF797979),
                                              borderRadius:
                                              BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text('Discard',
                                                  style: StyleText
                                                      .fontSize14Weight600
                                                      .copyWith(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 300.w),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                        ],
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
  }

}
