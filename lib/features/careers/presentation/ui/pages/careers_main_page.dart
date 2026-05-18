// ******************* FILE INFO *******************
// File Name: careers_main_page.dart
// Updated: Our Teams tab now uses OurTeamsCubit + OurTeamsViewPage
// FIXED: Properly load data in Main tab and handle empty statistics
// ADDED: Character counters (0/500 EN, ٥٠٠/٠ AR) on description fields
// FIXED: Tab bar now always visible when switching between tabs

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/features/careers/presentation/ui/pages/why_join_section_edit_page.dart';
import 'package:web_app_admin/features/careers/presentation/ui/pages/why_join_section_preview_page.dart';

import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/button.dart';
import '../../../../main/presentation/ui/pages/home_main_page.dart';
import '../../../data/model/careers_cms_model.dart';
import '../../../data/model/careers_section_model.dart';
import '../../../data/model/intern_model.dart';
import '../../controller/careers_cms_cubit.dart';
import '../../controller/careers_cms_state.dart';
import '../../controller/careers_section_cubit.dart';
import '../../controller/careers_section_state.dart';
import '../../controller/intern_cubit.dart';
import '../../controller/intern_state.dart';
import '../../controller/our_teams_cubit.dart';
import 'add_intern_page.dart';
import 'our_teams_view_page.dart';




class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color discard   = Color(0xFF797979);
}

// ═══════════════════════════════════════════════════════════════════════════════
class CareersMainPageMaster extends StatefulWidget {
  const CareersMainPageMaster({super.key});

  @override
  State<CareersMainPageMaster> createState() => _CareersMainPageMasterState();
}

class _CareersMainPageMasterState extends State<CareersMainPageMaster> {
  final Map<String, bool> _open = {
    'overview':   true,
    'statistics': true,
  };

  int _careersTab = 0;
  final List<String> _careersTabLabels = [
    'Main', 'Why Join Our Team', 'Our Interns', 'Our Teams',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareersCmsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareersCmsCubit, CareersCmsState>(
      builder: (context, state) {
        if (state is CareersCmsInitial || state is CareersCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        if (state is CareersCmsError) {
          return Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading data: ${state.message}',
                      style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<CareersCmsCubit>().load(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        CareersCmsModel data;
        if (state is CareersCmsLoaded) {
          data = state.data;
        } else if (state is CareersCmsSaved) {
          data = state.data;
        } else {
          data = CareersCmsModel.empty();
        }

        print('🟢 Main page: statistics count = ${data.statistics.length}');

        return Scaffold(
          backgroundColor: Color(0xFFF1F2ED),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 1000.w,
                    child: Column(
                      children: [

                        AppAdminNavbar(
                          activeLabel: 'Web Page',
                          homePage: HomeMainPage(),
                          webPage: HomeMainPage(),
                          jobListingPage: HomeMainPage(),
                        ),
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 20.h),
                        SizedBox(height: 20.h),
                        Container(
                          width: 1000.w,
                          child: _buildFullTabLayout(data),
                        ),
                        SizedBox(height: 40.h),
                      ],
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

  // ════════════════════════════════════════════════════════════════════════════
  // ALWAYS-VISIBLE HEADER: title + preview button + tab bar
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildFullTabLayout(CareersCmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview button (always visible) ──────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('Careers',
              style: StyleText.fontSize45Weight600.copyWith(
                  color: _C.primary, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pushNamed('careers-cms-preview'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                  color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
              child: Text('Preview Screen',
                  style: StyleText.fontSize14Weight500.copyWith(color: Colors.white)),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        // ── Tab bar (always visible) ─────────────────────────────────────────
        Container(
          width: 1000.w,
          child: Row(
            children: List.generate(_careersTabLabels.length, (i) {
              final active = _careersTab == i;
              return GestureDetector(
                onTap: () => setState(() => _careersTab = i),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? _C.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(_careersTabLabels[i],
                      style: StyleText.fontSize15Weight500.copyWith(
                        color: active ? _C.primary : _C.labelText,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      )),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Tab body ─────────────────────────────────────────────────────────
        _buildTabBody(data),
      ],
    );
  }

  Widget _buildTabBody(CareersCmsModel data) {
    switch (_careersTab) {
      case 0:  return _mainBody(data);
      case 1:  return _sectionBody('whyJoinOurTeam', 'Why Join Our Team');
      case 2:  return _internsBody();
      case 3:  return _ourTeamsBody();
      default: return const SizedBox();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  Widget _ourTeamsBody() {
    return BlocProvider(
      create: (_) => OurTeamsCubit()..load(),
      child: const OurTeamsViewPage(),
    );
  }

  Widget _internsBody() {
    return BlocProvider(
      create: (_) => InternCubit()..load(),
      child: _InternsTabBody(),
    );
  }

  Widget _sectionBody(String sectionKey, String sectionTitle) {
    return BlocProvider(
      create: (context) => CareersSectionCubit(sectionKey: sectionKey)..load(),
      child: BlocBuilder<CareersSectionCubit, CareersSectionState>(
        builder: (context, state) {
          if (state is CareersSectionInitial || state is CareersSectionLoading) {
            return const Center(child: CircularProgressIndicator(color: _C.primary));
          }

          CareersSectionModel? data;
          if (state is CareersSectionLoaded) data = state.data;
          if (state is CareersSectionSaved)  data = state.data;

          if (data == null) {
            return const Center(child: CircularProgressIndicator(color: _C.primary));
          }

          final cubit = context.read<CareersSectionCubit>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: CareersSectionPreviewPage(
                          sectionKey: sectionKey, sectionTitle: sectionTitle,
                        ),
                      ),
                    )),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                      child: Text('Preview Screen',
                          style: StyleText.fontSize14Weight500.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
                    child: Text(
                      data.lastUpdated != null
                          ? 'Last Updated On ${_formatDate(data.lastUpdated!)}'
                          : 'Last Updated On —',
                      style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: CareersSectionEditPage(
                          sectionKey: sectionKey, sectionTitle: sectionTitle,
                        ),
                      ),
                    )),
                    child: Container(
                      width: 130.w, height: 36.h,
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
                      child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Edit Details',
                              style: StyleText.fontSize14Weight500.copyWith(color: Colors.black)),
                          SizedBox(width: 6.w),
                          CustomSvg(
                              assetPath: 'assets/control/edit_icon_pick.svg',
                              width: 20.w, height: 20.h,
                              fit: BoxFit.scaleDown, color: _C.primary),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _accordion(
                key: 'section_$sectionKey',
                title: sectionTitle,
                children: [
                  if (data.items.isEmpty)
                    Text('No items added yet.',
                        style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText))
                  else
                    ...data.items.asMap().entries.map((e) => _itemView(e.key, e.value)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _itemView(int index, CareersSectionItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          Divider(color: const Color(0xFFE8E8E8), height: 1),
          SizedBox(height: 12.h),
        ] else
          SizedBox(height: 12.h),
        Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        _imgCircle(item.iconUrl, isAdd: true),
        SizedBox(height: 14.h),
        Row(children: [
          Expanded(child: _readField('Title', item.title.en)),
          SizedBox(width: 16.w),
          Expanded(child: _readFieldRtl('العنوان', item.title.ar)),
        ]),
        SizedBox(height: 14.h),
        Text('SVG', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 6.h),
        _imgCircle(item.svgUrl),
        SizedBox(height: 14.h),
        _readField('Sub description', item.description.en, height: 80),
        SizedBox(height: 8.h),
        _readFieldRtl('الوصف', item.description.ar, height: 80),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _imgCircle(String url, {bool isAdd = false}) {
    return Container(
      width: 60.w, height: 60.h,
      decoration: BoxDecoration(
        color: url.isNotEmpty ? Colors.white : const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: url.isNotEmpty
          ? ClipOval(child: Padding(
          padding: EdgeInsets.all(15.r),
          child: SvgPicture.network(url, fit: BoxFit.contain,
              placeholderBuilder: (_) => const SizedBox())))
          : Center(child: Icon(
          isAdd ? Icons.add : Icons.image_outlined,
          color: Colors.grey, size: 20.sp)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN TAB BODY  (title/preview/tab-bar removed – now in _buildFullTabLayout)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _mainBody(CareersCmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
                color: _C.cardBg, borderRadius: BorderRadius.circular(4.r)),
            child: Text(
              data.lastUpdated != null
                  ? 'Last Updated On ${_formatDate(data.lastUpdated!)}'
                  : 'Last Updated On —',
              style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pushNamed('careers-cms-edit'),
            child: Container(
              width: 130.w, height: 36.h,
              decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(4.r)),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Edit Details',
                      style: StyleText.fontSize14Weight500.copyWith(color: Colors.black)),
                  SizedBox(width: 6.w),
                  CustomSvg(
                      assetPath: 'assets/control/edit_icon_pick.svg',
                      width: 20.w, height: 20.h,
                      fit: BoxFit.scaleDown, color: _C.primary),
                ]),
              ),
            ),
          ),
        ]),

        _accordion(
          key: 'overview',
          title: 'Careers Overview',
          children: [
            _readField(
              'Description',
              data.overview.description.en,
              height: 80,
              maxLength: 500,
            ),
            SizedBox(height: 10.h),
            _readFieldRtl(
              'الوصف',
              data.overview.description.ar,
              height: 80,
              maxLength: 500,
            ),
            SizedBox(height: 16.h),
            Row(children: [
              Expanded(
                child: _readField(
                    'Action Button',
                    data.overview.actionButtonLabel.en.isEmpty
                        ? 'Text Here'
                        : data.overview.actionButtonLabel.en),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _readFieldRtl(
                    'زر الإجراء',
                    data.overview.actionButtonLabel.ar.isEmpty
                        ? 'أدخل النص'
                        : data.overview.actionButtonLabel.ar),
              ),
            ]),
          ],
        ),
        SizedBox(height: 10.h),

        _accordion(
          key: 'statistics',
          title: 'Career Statistics',
          children: [
            if (data.statistics.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                    'No statistics added yet. Click "Edit Details" to add statistics.',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize13Weight400.copyWith(color: _C.hintText)),
              )
            else
              ...data.statistics.asMap().entries.map((e) {
                final i    = e.key;
                final stat = e.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i > 0) ...[
                      SizedBox(height: 12.h),
                    ],
                    Text('${_ordLabel(i + 1)} Statistics',
                        style: StyleText.fontSize16Weight600.copyWith(color: _C.labelText)),
                    SizedBox(height: 8.h),
                    Row(children: [
                      Expanded(child: _readField('Title', stat.title.en)),
                      SizedBox(width: 16.w),
                      Expanded(child: _readFieldRtl('العنوان', stat.title.ar)),
                    ]),
                    SizedBox(height: 8.h),
                    _readField('Short Description', stat.shortDescription.en, height: 60),
                    SizedBox(height: 8.h),
                    _readFieldRtl('وصف مختصر', stat.shortDescription.ar, height: 60),
                    SizedBox(height: 12.h),
                  ],
                );
              }),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Accordion ───────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                  color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 25.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
        ],
      ),
    );
  }

  // ── Read-only fields ─────────────────────────────────────────────────────────

  Widget _readField(String label, String value,
      {double height = 36, int? maxLength}) {
    final current = value.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        height: height.h,
        padding: EdgeInsets.symmetric(
            horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
        alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
        child: Text(
          value.isEmpty ? 'Text Here' : value,
          style: StyleText.fontSize12Weight400
              .copyWith(color: value.isEmpty ? _C.hintText : _C.labelText),
          maxLines: height > 36 ? 5 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (maxLength != null) ...[
        SizedBox(height: 4.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$current/$maxLength',
            style: StyleText.fontSize11Weight400.copyWith(color: _C.hintText),
          ),
        ),
      ],
    ]);
  }

  Widget _readFieldRtl(String label, String value,
      {double height = 36, int? maxLength}) {
    final current = value.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: height.h,
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
          alignment: height > 36 ? Alignment.topRight : Alignment.centerRight,
          child: Text(
            value.isEmpty ? 'أكتب هنا' : value,
            style: StyleText.fontSize12Weight400
                .copyWith(color: value.isEmpty ? _C.hintText : _C.labelText),
            textDirection: TextDirection.rtl,
            maxLines: height > 36 ? 5 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (maxLength != null) ...[
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_toArabicNumerals(maxLength)}/${_toArabicNumerals(current)}',
              textDirection: TextDirection.rtl,
              style: StyleText.fontSize11Weight400.copyWith(color: _C.hintText),
            ),
          ),
        ],
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _toArabicNumerals(int n) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? eastern[d] : c;
    }).join();
  }

  String _ordLabel(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_monthName(dt.month)} ${dt.year}';

  String _monthName(int m) => const [
    '',    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTERNS TAB BODY  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _InternsTabBody extends StatefulWidget {
  @override
  State<_InternsTabBody> createState() => _InternsTabBodyState();
}

class _InternsTabBodyState extends State<_InternsTabBody> {
  bool   _isGrid     = true;
  String _search     = '';
  final  _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<InternModel> _filtered(List<InternModel> all) {
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all
        .where((i) =>
    i.fullName.toLowerCase().contains(q) ||
        i.position.toLowerCase().contains(q) ||
        i.degrees.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternCubit, InternState>(
      listener: (context, state) {
        if (state is InternError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        List<InternModel> interns = [];
        bool loading = false;

        if (state is InternLoading) loading = true;
        if (state is InternLoaded)  interns = state.interns;
        if (state is InternCreated) interns = state.interns;
        if (state is InternUpdated) interns = state.interns;
        if (state is InternDeleted) interns = state.interns;

        final cubit    = context.read<InternCubit>();
        final filtered = _filtered(interns);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Row(children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
                  child: Row(children: [
                    SizedBox(width: 12.w),
                    Icon(Icons.search, color: _C.hintText, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: StyleText.fontSize13Weight400.copyWith(color: _C.hintText),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: StyleText.fontSize13Weight400.copyWith(color: _C.labelText),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                  ]),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                    color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                child: Center(
                  child: Text('Time Frame',
                      style: StyleText.fontSize13Weight500.copyWith(color: Colors.white)),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                      value: cubit, child: const AddInternPage()),
                )),
                child: Container(
                  height: 40.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                      color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(
                    child: Text('Add New Intern',
                        style: StyleText.fontSize13Weight500.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ]),
            SizedBox(height: 14.h),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: _C.cardBg, borderRadius: BorderRadius.circular(6.r)),
                  child: Text(
                    'Total Interns:  ${filtered.length}',
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText),
                  ),
                ),
                const Spacer(),
                customButtonWithImage(
                  title: 'Export',
                  function: () => showDialog(context: context,
                      builder: (_) => _InternExportDialog(interns: filtered)),
                  textStyle: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  height: 32.h, space: 4.w, radius: 6,
                  color: _C.primary, image: 'assets/images/export.svg',
                  widthImage: 14.sp, heightImage: 14.sp,
                  colorBorder: _C.primary, svgColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                ),
                SizedBox(width: 8.w),
                customButtonWithImage(
                  title: '', function: () => setState(() => _isGrid = true),
                  textStyle: const TextStyle(),
                  height: 32.sp, width: 32.sp, space: 0, radius: 6,
                  color: _isGrid ? _C.primary : _C.cardBg,
                  image: 'assets/images/grid.svg',
                  widthImage: 16.sp, heightImage: 16.sp,
                  colorBorder: Colors.transparent,
                  svgColor: _isGrid ? Colors.white : _C.hintText,
                ),
                SizedBox(width: 4.w),
                customButtonWithImage(
                  title: '', function: () => setState(() => _isGrid = false),
                  textStyle: const TextStyle(),
                  height: 32.sp, width: 32.sp, space: 0, radius: 6,
                  color: !_isGrid ? _C.primary : _C.cardBg,
                  image: 'assets/images/table.svg',
                  widthImage: 16.sp, heightImage: 16.sp,
                  colorBorder: Colors.transparent,
                  svgColor: !_isGrid ? Colors.white : _C.hintText,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (loading)
              const Center(child: CircularProgressIndicator(color: _C.primary))
            else if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40.w),
                  child: Text(
                    _search.isEmpty
                        ? 'No interns yet. Tap "Add New Intern" to get started.'
                        : 'No results for "$_search".',
                    style: StyleText.fontSize14Weight400.copyWith(color: _C.hintText),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_isGrid)
                _GridView(interns: filtered, cubit: cubit)
              else
                _InternTableView(interns: filtered, cubit: cubit),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRID VIEW  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _GridView extends StatelessWidget {
  final List<InternModel> interns;
  final InternCubit       cubit;
  const _GridView({required this.interns, required this.cubit});

  @override
  Widget build(BuildContext context) {
    const int cols = 3;
    final rows = <Widget>[];

    for (int i = 0; i < interns.length; i += cols) {
      final rowItems = <Widget>[];
      for (int j = i; j < i + cols; j++) {
        if (j < interns.length) {
          rowItems.add(Expanded(child: _InternCard(intern: interns[j], cubit: cubit)));
        } else {
          rowItems.add(const Expanded(child: SizedBox()));
        }
        if (j < i + cols - 1) rowItems.add(SizedBox(width: 14.w));
      }
      rows.add(IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: rowItems)));
      if (i + cols < interns.length) rows.add(SizedBox(height: 14.h));
    }

    return Column(children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLE VIEW  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _InternTableView extends StatelessWidget {
  final List<InternModel> interns;
  final InternCubit       cubit;
  const _InternTableView({required this.interns, required this.cubit});

  Map<int, TableColumnWidth> get _columnWidths => {
    0: const FlexColumnWidth(1.1),
    1: const FlexColumnWidth(1.4),
    2: const FlexColumnWidth(1.0),
    3: const FlexColumnWidth(1.0),
    4: const FlexColumnWidth(1.1),
    5: const FlexColumnWidth(1.1),
    6: const FlexColumnWidth(2.0),
  };

  static const _headers = [
    'Joined Date', 'Interns Name', 'First Name', 'Last Name',
    'Position', 'Degrees', 'What Have I Learned',
  ];

  TextStyle get _headerStyle => StyleText.fontSize13Weight600.copyWith(
      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.sp);

  TextStyle get _cellStyle => StyleText.fontSize12Weight400.copyWith(
      color: _C.labelText, fontSize: 12.sp, height: 1.4);

  String _firstName(String n) {
    final p = n.trim().split(' ');
    return p.isNotEmpty ? p.first : '-';
  }

  String _lastName(String n) {
    final p = n.trim().split(' ');
    return p.length > 1 ? p.sublist(1).join(' ') : '-';
  }

  Widget _headerCell(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    child: Text(text, style: _headerStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
  );

  Widget _textCell(String text, {int maxLines = 2}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    child: Text(text.isEmpty ? '-' : text,
        maxLines: maxLines, overflow: TextOverflow.ellipsis, style: _cellStyle),
  );

  Widget _nameCell(InternModel intern) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    child: Row(children: [
      Container(
        width: 30.w, height: 30.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _C.primary, width: 1.5),
          color: const Color(0xFFE0E0E0),
          image: intern.photoUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(intern.photoUrl), fit: BoxFit.cover)
              : null,
        ),
        child: intern.photoUrl.isEmpty
            ? Center(child: Icon(Icons.person, color: Colors.grey, size: 15.sp))
            : null,
      ),
      SizedBox(width: 8.w),
      Flexible(
        child: Text(
          intern.fullName.isEmpty ? '-' : intern.fullName,
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: _cellStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ]),
  );

  void _confirmDelete(BuildContext context, InternModel intern) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Delete Intern',
            style: StyleText.fontSize16Weight600.copyWith(color: Colors.black87)),
        content: Text('Are you sure you want to delete ${intern.fullName}?',
            style: StyleText.fontSize14Weight400.copyWith(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: StyleText.fontSize13Weight500.copyWith(color: _C.hintText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.delete(intern.id);
            },
            child: Text('Delete',
                style: StyleText.fontSize13Weight600.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color rowOdd  = Color(0xFFF1F2ED);
    const Color rowEven = Colors.white;
    const Color divider = Color(0xFFE0E0E0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r)),
            ),
            child: Table(
              columnWidths: _columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(children: _headers.map((h) => _headerCell(h)).toList()),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: divider, width: 0.5),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r), bottomRight: Radius.circular(8.r)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r), bottomRight: Radius.circular(8.r)),
              child: Table(
                columnWidths: _columnWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                    horizontalInside: BorderSide(color: divider, width: 0.8)),
                children: List.generate(interns.length, (index) {
                  final intern   = interns[index];
                  final rowColor = index.isOdd ? rowOdd : rowEven;

                  void onRowTap() => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                        value: cubit, child: AddInternPage(existing: intern)),
                  ));

                  Widget tap(Widget child) => InkWell(
                    onTap: onRowTap,
                    hoverColor: _C.primary.withOpacity(0.06),
                    mouseCursor: SystemMouseCursors.click,
                    child: child,
                  );

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      tap(_textCell(intern.joinDateLabel, maxLines: 1)),
                      tap(_nameCell(intern)),
                      tap(_textCell(_firstName(intern.fullName))),
                      tap(_textCell(_lastName(intern.fullName))),
                      tap(_textCell(intern.position)),
                      tap(_textCell(intern.degrees)),
                      tap(_textCell(intern.whatHaveILearned, maxLines: 3)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTERN CARD  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _InternCard extends StatefulWidget {
  final InternModel intern;
  final InternCubit cubit;
  final bool        listMode;
  const _InternCard({
    required this.intern,
    required this.cubit,
    this.listMode = false,
  });

  @override
  State<_InternCard> createState() => _InternCardState();
}

class _InternCardState extends State<_InternCard> {
  bool _hovered = false;

  void _openEditPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => BlocProvider.value(
          value: widget.cubit, child: AddInternPage(existing: widget.intern)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final intern = widget.intern;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _openEditPage(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: _gridLayout(context, intern),
        ),
      ),
    );
  }

  Widget _gridLayout(BuildContext context, InternModel intern) {
    final double avatarSz = 52.w;
    final double leftColW = 110.w;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: leftColW,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(intern, avatarSz),
              SizedBox(height: 8.h),
              Text(intern.fullName,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight600.copyWith(
                      fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
              SizedBox(height: 3.h),
              Text(intern.degrees,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize11Weight400.copyWith(
                      fontSize: 9.sp, color: Colors.black45, height: 1.4)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 4.w, runSpacing: 3.h, alignment: WrapAlignment.center,
                children: intern.tags.map((tag) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                      color: _C.primary, borderRadius: BorderRadius.circular(4.r)),
                  child: Text(tag,
                      style: StyleText.fontSize10Weight700.copyWith(
                          fontSize: 9.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                )).toList(),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(intern.joinDateLabel,
                  style: StyleText.fontSize10Weight400.copyWith(
                      fontSize: 9.sp, color: Colors.black45)),
              SizedBox(height: 12.h),
              Text('What Have I Learned',
                  style: StyleText.fontSize13Weight600.copyWith(
                      fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
              SizedBox(height: 6.h),
              Text(intern.whatHaveILearned,
                  style: StyleText.fontSize12Weight400.copyWith(
                      fontSize: 10.sp, height: 1.5, color: Colors.black54),
                  maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(InternModel intern, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _C.primary, width: 1.5),
        color: const Color(0xFFE0E0E0),
        image: intern.photoUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(intern.photoUrl), fit: BoxFit.cover)
            : null,
      ),
      child: intern.photoUrl.isEmpty
          ? Center(child: Icon(Icons.person, color: Colors.grey, size: size * 0.5))
          : null,
    );
  }

  void _confirmDelete(BuildContext context, InternModel intern) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Delete Intern',
            style: StyleText.fontSize16Weight600.copyWith(color: Colors.black87)),
        content: Text('Are you sure you want to delete ${intern.fullName}?',
            style: StyleText.fontSize14Weight400.copyWith(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: StyleText.fontSize13Weight500.copyWith(color: _C.hintText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.cubit.delete(intern.id);
            },
            child: Text('Delete',
                style: StyleText.fontSize13Weight600.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTERN EXPORT DIALOG  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _InternExportDialog extends StatefulWidget {
  final List<InternModel> interns;
  const _InternExportDialog({required this.interns});

  @override
  State<_InternExportDialog> createState() => _InternExportDialogState();
}

class _InternExportDialogState extends State<_InternExportDialog> {
  final _nameCtrl = TextEditingController();
  bool  _saving   = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _escapeCsv(String v) {
    if (v.isEmpty) return '';
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  Future<void> _export() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a file name.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ));
      return;
    }

    setState(() => _saving = true);

    final buf = StringBuffer();
    buf.writeln('No,Full Name,Position,Degrees,Joined Date,What Have I Learned,Tags');

    for (int i = 0; i < widget.interns.length; i++) {
      final n = widget.interns[i];
      buf.writeln([
        '${i + 1}',
        _escapeCsv(n.fullName),
        _escapeCsv(n.position),
        _escapeCsv(n.degrees),
        _escapeCsv(n.joinDateLabel),
        _escapeCsv(n.whatHaveILearned),
        _escapeCsv(n.tags.join('; ')),
      ].join(','));
    }

    final fileName = name.toLowerCase().endsWith('.csv') ? name : '$name.csv';
    final blob = html.Blob([buf.toString()], 'text/csv');
    final url  = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Exported "$fileName" successfully!',
          style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
      backgroundColor: _C.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 360.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 32.w, height: 32.h,
                decoration: BoxDecoration(color: _C.primary, shape: BoxShape.circle),
                child: Center(
                  child: CustomSvg(
                    assetPath: 'assets/images/export.svg',
                    width: 16.w, height: 16.h,
                    fit: BoxFit.scaleDown, color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text('Export Interns',
                  style: StyleText.fontSize16Weight600.copyWith(color: _C.labelText)),
            ]),
            SizedBox(height: 20.h),
            Text('File Name',
                style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
            SizedBox(height: 6.h),
            Container(
              height: 36.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.r)),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. interns_2025',
                  hintStyle: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  isDense: true,
                ),
                style: StyleText.fontSize12Weight400.copyWith(color: _C.labelText),
              ),
            ),
            SizedBox(height: 24.h),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _saving ? null : () => Navigator.pop(context),
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: _saving ? Colors.grey.shade300 : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text('Discard',
                          style: StyleText.fontSize14Weight600.copyWith(
                              color: _saving ? Colors.grey : _C.discard)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: _saving ? null : _export,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: _saving
                          ? _C.primary.withOpacity(0.5)
                          : _nameCtrl.text.trim().isEmpty
                          ? _C.primary.withOpacity(0.4)
                          : _C.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: _saving
                          ? SizedBox(
                        width: 18.w, height: 18.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : Text('Download',
                          style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}