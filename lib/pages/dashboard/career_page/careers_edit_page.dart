// ******************* FILE INFO *******************
// File Name: careers_edit_page.dart
// Created by: Amr Mesbah
// Screen: 1.2 — Edit form for Careers Overview + Career Statistics

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color labelText = Color(0xFF333333);
  static const Color red       = Color(0xFFD32F2F);
  static const Color back = Color(0xFFF1F2ED);
}

class CareersEditPage extends StatefulWidget {
  const CareersEditPage({super.key});
  @override
  State<CareersEditPage> createState() => _CareersEditPageState();
}

class _CareersEditPageState extends State<CareersEditPage> {
  late CareersCmsModel _draft;

  late TextEditingController _overviewDescEnCtrl;
  late TextEditingController _overviewDescArCtrl;
  late TextEditingController _overviewBtnEnCtrl;
  late TextEditingController _overviewBtnArCtrl;

  final Map<String, Map<String, TextEditingController>> _statCtrls = {};
  final Map<String, bool> _open = {'overview': true, 'statistics': true};
  bool _saving  = false;
  bool _ready   = false; // true once controllers are wired to real data

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final s = context.read<CareersCmsCubit>().state;
    if (s is CareersCmsLoaded || s is CareersCmsSaved) {
      // Data already in cubit — init immediately
      _initFromModel(context.read<CareersCmsCubit>().current);
      _ready = true;
    } else {
      // Data not loaded yet — fetch first, then init
      context.read<CareersCmsCubit>().load().then((_) {
        if (mounted) {
          setState(() {
            _initFromModel(context.read<CareersCmsCubit>().current);
            _ready = true;
          });
        }
      });
    }
  }

  void _initFromModel(CareersCmsModel model) {
    _draft              = model;
    _overviewDescEnCtrl = TextEditingController(text: model.overview.description.en);
    _overviewDescArCtrl = TextEditingController(text: model.overview.description.ar);
    _overviewBtnEnCtrl  = TextEditingController(text: model.overview.actionButtonLabel.en);
    _overviewBtnArCtrl  = TextEditingController(text: model.overview.actionButtonLabel.ar);
    for (final s in model.statistics) _initStatCtrl(s);
  }

  void _initStatCtrl(CareerStatItem s) {
    _statCtrls[s.id] = {
      'titleEn':     TextEditingController(text: s.title.en),
      'titleAr':     TextEditingController(text: s.title.ar),
      'shortDescEn': TextEditingController(text: s.shortDescription.en),
      'shortDescAr': TextEditingController(text: s.shortDescription.ar),
    };
  }

  @override
  void dispose() {
    if (_ready) {
      _overviewDescEnCtrl.dispose();
      _overviewDescArCtrl.dispose();
      _overviewBtnEnCtrl.dispose();
      _overviewBtnArCtrl.dispose();
      for (final m in _statCtrls.values) {
        for (final c in m.values) c.dispose();
      }
    }
    super.dispose();
  }

  // ── Build draft from controllers ───────────────────────────────────────────

  CareersCmsModel _buildDraft() {
    final draft = _draft.copyWith(
      overview: CareersOverview(
        description: BilingualText(
            en: _overviewDescEnCtrl.text.trim(),
            ar: _overviewDescArCtrl.text.trim()),
        actionButtonLabel: BilingualText(
            en: _overviewBtnEnCtrl.text.trim(),
            ar: _overviewBtnArCtrl.text.trim()),
      ),
      statistics: _draft.statistics.map((s) {
        final m = _statCtrls[s.id];
        if (m == null) return s;
        return s.copyWith(
          title: BilingualText(
              en: m['titleEn']!.text.trim(),
              ar: m['titleAr']!.text.trim()),
          shortDescription: BilingualText(
              en: m['shortDescEn']!.text.trim(),
              ar: m['shortDescAr']!.text.trim()),
        );
      }).toList(),
    );

    // Debug — remove after confirming save works
    debugPrint('🔵 _buildDraft overview.desc.en="${draft.overview.description.en}"');
    debugPrint('🔵 _buildDraft overview.desc.ar="${draft.overview.description.ar}"');
    debugPrint('🔵 _buildDraft stats count=${draft.statistics.length}');

    return draft;
  }

  // ── Add / remove stat ──────────────────────────────────────────────────────

  void _addStat() {
    final newStat = CareerStatItem.empty();
    setState(() {
      _draft = _draft.copyWith(statistics: [..._draft.statistics, newStat]);
      _initStatCtrl(newStat);
    });
  }

  void _removeStat(String id) {
    setState(() {
      _draft = _draft.copyWith(
          statistics: _draft.statistics.where((s) => s.id != id).toList());
      final m = _statCtrls.remove(id);
      if (m != null) for (final c in m.values) c.dispose();
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<CareersCmsCubit>().save(_buildDraft());
    if (mounted) {
      setState(() => _saving = false);
      context.pop();
    }
  }

  Future<void> _preview() async {
    await context.read<CareersCmsCubit>().save(_buildDraft());
    if (mounted) context.pushNamed('careers-cms-preview');
  }

  void _discard() => context.pop();

  // ── Field helpers ──────────────────────────────────────────────────────────

  Widget _arField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height = 36,
    int maxLines  = 1,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label:         label,
        hint:          hint,
        controller:    ctrl,
        height:        height,
        maxLines:      maxLines,
        textDirection: TextDirection.rtl,
        textAlign:     TextAlign.right,
        primaryColor:  _C.primary,
      ),
    );
  }

  Widget _enField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height = 36,
    int maxLines  = 1,
  }) {
    return CustomValidatedTextFieldMaster(
      label:         label,
      hint:          hint,
      controller:    ctrl,
      height:        height,
      maxLines:      maxLines,
      textDirection: TextDirection.ltr,
      primaryColor:  _C.primary,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Show loading spinner until controllers are ready
    if (!_ready) {
      return Scaffold(
        backgroundColor: _C.back,
        body: const Center(
          child: CircularProgressIndicator(color: _C.primary),
        ),
      );
    }

    return BlocListener<CareersCmsCubit, CareersCmsState>(
      listener: (context, state) {
        if (state is CareersCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: _C.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _C.back,
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                AdminSubNavBar(activeIndex: 5),
                SizedBox(height: 20.h),
                Container(
                  width: 1000.w,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editing Main Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                            color: _C.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 20.h),

                      // ── Careers Overview accordion ─────────────────────────
                      _accordion(
                        key: 'overview',
                        title: 'Careers Overview',
                        children: [
                          SizedBox(height: 15.h),
                          _enField(
                            label:    'Description',
                            hint:     'Text Here',
                            ctrl:     _overviewDescEnCtrl,
                            height:   80,
                            maxLines: 4,
                          ),
                          SizedBox(height: 10.h),
                          _arField(
                            label:    'الوصف',
                            hint:     'أكتب هنا',
                            ctrl:     _overviewDescArCtrl,
                            height:   80,
                            maxLines: 4,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _enField(
                                  label: 'Action Button',
                                  hint:  'Text Here',
                                  ctrl:  _overviewBtnEnCtrl,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _arField(
                                  label: 'زر الإجراء',
                                  hint:  'أدخل النص',
                                  ctrl:  _overviewBtnArCtrl,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // ── Career Statistics accordion ────────────────────────
                      _accordion(
                        key: 'statistics',
                        title: 'Career Statistics',
                        children: [
                          SizedBox(height: 15.h),

                          ..._draft.statistics.asMap().entries.map((e) {
                            final i    = e.key;
                            final stat = e.value;
                            final m    = _statCtrls[stat.id]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (i > 0) ...[
                                  const Divider(
                                      color: Color(0xFFE8E8E8), height: 1),
                                  SizedBox(height: 12.h),
                                ],
                                // Stat header
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_ord(i + 1)} Statistics',
                                      style: StyleText.fontSize13Weight600
                                          .copyWith(color: _C.labelText),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeStat(stat.id),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: _C.red,
                                          borderRadius:
                                          BorderRadius.circular(4.r),
                                        ),
                                        child: Text('Remove',
                                            style: StyleText.fontSize12Weight500
                                                .copyWith(
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                // Title EN + AR
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _enField(
                                        label: 'Title',
                                        hint:  'Text Here',
                                        ctrl:  m['titleEn']!,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: _arField(
                                        label: 'العنوان',
                                        hint:  'أدخل النص',
                                        ctrl:  m['titleAr']!,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                // Short Description EN
                                _enField(
                                  label:    'Short Description',
                                  hint:     'Text Here',
                                  ctrl:     m['shortDescEn']!,
                                  height:   60,
                                  maxLines: 3,
                                ),
                                SizedBox(height: 8.h),

                                // Short Description AR
                                _arField(
                                  label:    'وصف مختصر',
                                  hint:     'أكتب هنا',
                                  ctrl:     m['shortDescAr']!,
                                  height:   60,
                                  maxLines: 3,
                                ),
                                SizedBox(height: 12.h),
                              ],
                            );
                          }),

                          // + Statistics button
                          GestureDetector(
                            onTap: _addStat,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 7.h),
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add,
                                        size: 14.sp, color: _C.primary),
                                    SizedBox(width: 4.w),
                                    Text('+ Statistics',
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(color: _C.primary)),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // ── Preview + Save ─────────────────────────────────────
                      Row(children: [
                        SizedBox(height: 15.h),

                        Expanded(
                            child: _btn(
                                label:  'Preview',
                                color:  Colors.grey.shade500,
                                onTap:  _preview)),
                        SizedBox(width: 16.w),
                        Expanded(
                            child: _btn(
                                label:   'Save',
                                color:   _C.primary,
                                onTap:   _saving ? null : _save,
                                loading: _saving)),
                      ]),
                      SizedBox(height: 10.h),
                      _btn(
                          label:  'Discard',
                          color:  Colors.grey.shade400,
                          onTap:  _discard),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────

  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width:   double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size:  20.sp,
              ),
            ]),
          ),
        ),
        if (isOpen)
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:           children),
      ]),
    );
  }

  // ── Button ─────────────────────────────────────────────────────────────────

  Widget _btn({
    required String   label,
    required Color    color,
    VoidCallback?     onTap,
    bool              loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color:        onTap == null ? color.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
            width:  20,
            height: 20,
            child:  CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : Text(label,
            style: StyleText.fontSize14Weight600
                .copyWith(color: Colors.white)),
      ),
    );
  }

  String _ord(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}