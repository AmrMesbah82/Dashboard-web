/// ******************* FILE INFO *******************
/// File Name: service_page_editor.dart
/// Created by: Amr Mesbah
/// UPDATED: Image picker restricted to SVG format only.
///          FIX: Firebase/network SVG URLs now use SvgPicture.network instead
///               of CustomSvg (which prepends assets/). Camera icon uses
///               Icon widget as fallback to avoid missing-asset crash.

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

// ── Local palette ─────────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
}

// ── Picked-image helper ────────────────────────────────────────────────────────
class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);

  /// True when the URL is a remote http/https address (not a local asset path)
  bool get isNetworkUrl =>
      url != null &&
          (url!.startsWith('http://') || url!.startsWith('https://'));
}

// ── One "Digital Journey" item ────────────────────────────────────────────────
class _JourneyItem {
  final String id;
  final TextEditingController subTitleEn;
  final TextEditingController subTitleAr;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage icon;

  _JourneyItem({required this.id})
      : subTitleEn = TextEditingController(),
        subTitleAr = TextEditingController(),
        titleEn    = TextEditingController(),
        titleAr    = TextEditingController(),
        descEn     = TextEditingController(),
        descAr     = TextEditingController(),
        icon       = const _PickedImage();

  void dispose() {
    subTitleEn.dispose(); subTitleAr.dispose();
    titleEn.dispose();    titleAr.dispose();
    descEn.dispose();     descAr.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ServicePageEditor extends StatefulWidget {
  const ServicePageEditor({super.key});

  @override
  State<ServicePageEditor> createState() => _ServicePageEditorState();
}

class _ServicePageEditorState extends State<ServicePageEditor> {

  bool _submitted = false;
  bool _isSaving  = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Digital Journey items (dynamic) ──────────────────────────────────────
  late List<_JourneyItem> _journeyItems;

  // ── Accordion collapse state ──────────────────────────────────────────────
  final Map<String, bool> _open = {'headings': true};

  // ── Tab selection ─────────────────────────────────────────────────────────
  int _selectedTab = 0;

  // ── Seed tracking ─────────────────────────────────────────────────────────
  int? _seededModelHash;

  // ── Counter for unique IDs ────────────────────────────────────────────────
  int _idCounter = 0;

  String _newId() => 'ji_${_idCounter++}';

  @override
  void initState() {
    super.initState();
    _journeyItems = [_JourneyItem(id: _newId())];
    _open[_journeyItems.first.id] = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCmsCubit>().load();
    });
  }

  // ── SVG-only image picking ────────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()..accept = 'image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      final file = files.first;

      final mime = file.type;
      if (mime != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Only SVG files are allowed. Selected file type: $mime',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
              ),
              backgroundColor: _C.remove,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ));
          }
        });
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is List<int>) {
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
      if (!completed) { completed = true; completer.complete(null); }
    });

    return completer.future;
  }

  // ── Seed from model ────────────────────────────────────────────────────────
  void _seedFromModel(ServicePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en, d.title.ar,
      d.shortDescription.en, d.shortDescription.ar,
      ...d.journeyItems.map((j) => j.iconUrl + j.title.en),
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    for (final item in _journeyItems) item.dispose();
    _journeyItems = [];
    _open.removeWhere((k, _) => k.startsWith('ji_'));

    for (final j in d.journeyItems) {
      final item = _JourneyItem(id: j.id.isEmpty ? _newId() : j.id);
      // item.subTitleEn.text = j.subTitle.en;
      // item.subTitleAr.text = j.subTitle.ar;
      item.titleEn.text    = j.title.en;
      item.titleAr.text    = j.title.ar;
      item.descEn.text     = j.description.en;
      item.descAr.text     = j.description.ar;
      // Store the Firebase URL as-is — _PickedImage.isNetworkUrl will be true
      item.icon = j.iconUrl.isNotEmpty
          ? _PickedImage(url: j.iconUrl)
          : const _PickedImage();
      _journeyItems.add(item);
      _open[item.id] = true;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save(ServiceCmsCubit cubit) async {
    setState(() { _submitted = true; _isSaving = true; });

    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(
          en: _shortDescEn.text, ar: _shortDescAr.text);

      for (final j in cubit.current.journeyItems.toList()) {
        cubit.removeJourneyItem(j.id);
      }

      for (final item in _journeyItems) {
        final String modelId = cubit.addJourneyItem();
        // cubit.updateJourneySubTitle(modelId,
        //     en: item.subTitleEn.text, ar: item.subTitleAr.text);
        cubit.updateJourneyTitle(modelId,
            en: item.titleEn.text, ar: item.titleAr.text);
        cubit.updateJourneyDescription(modelId,
            en: item.descEn.text, ar: item.descAr.text);

        if (item.icon.bytes != null) {
          await cubit.uploadJourneyIcon(modelId, item.icon.bytes!);
        } else if (!item.icon.isEmpty) {
          cubit.preserveJourneyIconUrl(modelId, item.icon.url!);
        }
      }

      final status = _selectedTab == 0
          ? 'published'
          : _selectedTab == 1
          ? 'scheduled'
          : 'draft';
      await cubit.save(publishStatus: status);

    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleEn.dispose(); _titleAr.dispose();
    _shortDescEn.dispose(); _shortDescAr.dispose();
    for (final item in _journeyItems) item.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceCmsCubit, ServiceCmsState>(
      listener: (context, state) {
        if (state is ServiceCmsSaved) {
          _seededModelHash = null;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Service page saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is ServiceCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is ServiceCmsLoaded) _seedFromModel(state.data);
        if (state is ServiceCmsSaved)  _seedFromModel(state.data);

        final cubit = context.read<ServiceCmsCubit>();

        if (state is ServiceCmsInitial || state is ServiceCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.sectionBg,
              body: Column(
                children: [
                  AppNavbar(currentRoute: '/services'),
                  _topBar(cubit),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Service Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _headingsSection(),
                          SizedBox(height: 10.h),
                          ..._buildJourneySections(cubit),
                          SizedBox(height: 10.h),
                          _addSectionButton(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Saving overlay ──
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 24)
                      ],
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: _C.primary),
                          SizedBox(height: 20.h),
                          Text('Saving...',
                              style: StyleText.fontSize14Weight600
                                  .copyWith(color: _C.primary)),
                          SizedBox(height: 6.h),
                          Text('Uploading images & saving data',
                              style: StyleText.fontSize12Weight400
                                  .copyWith(color: _C.hintText)),
                        ]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _topBar(ServiceCmsCubit cubit) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 14.h, right: 24.w),
          child: Row(children: [
            const Spacer(),
            GestureDetector(
              onTap: _isSaving ? null : () => _save(cubit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _isSaving
                      ? _C.primary.withOpacity(0.5)
                      : _C.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: _isSaving
                    ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text('Save',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ]),
        ),
        Row(children: [
          _tabBtn('Published', 0),
          _tabBtn('Schedule',  1),
          _tabBtn('Draft',     2),
        ]),
      ],
    ),
  );

  Widget _tabBtn(String label, int index) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.only(right: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
                child: Text(label,
                    style: active
                        ? StyleText.fontSize16Weight600
                        .copyWith(color: _C.primary)
                        : StyleText.fontSize16Weight600
                        .copyWith(color: _C.hintText)),
              ),
              Container(
                height: 3.sp,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: active ? _C.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Headings section ───────────────────────────────────────────────────────
  Widget _headingsSection() => _accordion(
    key: 'headings',
    title: 'Headings',
    children: [
      _biRow('Title', 'العنوان', _titleEn, _titleAr, useRow: true),
      SizedBox(height: 14.h),
      CustomValidatedTextFieldMaster(
        label: 'Short Description',
        hint: 'Text Here',
        controller: _shortDescEn,
        maxLines: 3,
        height: 80,
        showCharCount: false,
        submitted: _submitted,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 10.h),
      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'وصف مختصر',
          hint: 'أدخل النص هنا',
          controller: _shortDescAr,
          maxLines: 3,
          height: 80,
          showCharCount: false,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );

  // ── Journey sections ───────────────────────────────────────────────────────
  List<Widget> _buildJourneySections(ServiceCmsCubit cubit) {
    final List<Widget> widgets = [];
    for (var i = 0; i < _journeyItems.length; i++) {
      final item  = _journeyItems[i];
      final label = i == 0
          ? 'Digital Journey'
          : '${_ordinalFull(i + 1)} Digital Journey';
      widgets.add(
          _journeyAccordion(index: i, item: item, title: label));
      if (i < _journeyItems.length - 1) widgets.add(SizedBox(height: 10.h));
    }
    return widgets;
  }

  Widget _journeyAccordion({
    required int index,
    required _JourneyItem item,
    required String title,
  }) {
    final isOpen = _open[item.id] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _open[item.id] = !isOpen),
            child: Container(
              width: double.infinity,
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
                            .copyWith(color: Colors.white))),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ]),
            ),
          ),

          // Body
          if (isOpen)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _biRow('SubTitle', 'العنوان', item.subTitleEn,
                  //     item.subTitleAr,
                  //     useRow: true),
                  // SizedBox(height: 14.h),

                  // Icon row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Icon (SVG only)',
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: _C.labelText)),
                          SizedBox(height: 6.h),
                          _imgBox(
                            picked: item.icon,
                            onPick: () async {
                              final p = await _pickImage();
                              if (p != null) setState(() => item.icon = p);
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_journeyItems.length > 1)
                        GestureDetector(
                          onTap: () => setState(() {
                            final removed = _journeyItems.removeAt(index);
                            _open.remove(removed.id);
                            WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => removed.dispose());
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: _C.remove,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text('Remove',
                                style: StyleText.fontSize12Weight500
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  _biRow('Title', 'العنوان', item.titleEn, item.titleAr,
                      useRow: true),
                  SizedBox(height: 14.h),

                  CustomValidatedTextFieldMaster(
                    label: 'Description',
                    hint: 'Text Here',
                    controller: item.descEn,
                    maxLines: 5,
                    height: 100,
                    showCharCount: true,
                    maxLength: 500,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.h),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomValidatedTextFieldMaster(
                      label: 'الوصف',
                      hint: 'أدخل النص هنا',
                      controller: item.descAr,
                      maxLines: 5,
                      height: 100,
                      showCharCount: true,
                      maxLength: 500,
                      submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Add section button ─────────────────────────────────────────────────────
  Widget _addSectionButton() => GestureDetector(
    onTap: () {
      final newItem = _JourneyItem(id: _newId());
      setState(() {
        _journeyItems.add(newItem);
        _open[newItem.id] = true;
      });
    },
    child: Container(
      padding:
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: const BoxDecoration(
                color: _C.primary, shape: BoxShape.circle),
            child: Icon(Icons.add, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Text(
            'Add Digital Journey Section',
            style: StyleText.fontSize13Weight600
                .copyWith(color: _C.primary),
          ),
        ],
      ),
    ),
  );

  // ── Accordion wrapper ──────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                            .copyWith(color: Colors.white))),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  // ── Bilingual row helper ───────────────────────────────────────────────────
  Widget _biRow(
      String enLabel,
      String arLabel,
      TextEditingController enCtrl,
      TextEditingController arCtrl, {
        int  maxLines      = 1,
        bool showCharCount = false,
        bool useRow        = false,
      }) {
    final double fieldH = maxLines > 1 ? 80 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel,
      hint: 'Text Here',
      controller: enCtrl,
      maxLines: maxLines,
      height: fieldH,
      showCharCount: showCharCount,
      submitted: _submitted,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    final arField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel,
        hint: 'أدخل النص هنا',
        controller: arCtrl,
        maxLines: maxLines,
        height: fieldH,
        showCharCount: showCharCount,
        submitted: _submitted,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
    );
    if (useRow) {
      return Row(children: [
        Expanded(child: enField),
        SizedBox(width: 16.w),
        Expanded(child: arField),
      ]);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [enField, SizedBox(height: 10.h), arField]);
  }

  // ── Image box ──────────────────────────────────────────────────────────────
  // FIX: Network URLs (Firebase Storage) → SvgPicture.network
  //      Local asset bytes  → SvgPicture.memory
  //      Empty              → grey circle placeholder (no asset file needed)
  //      Camera badge       → Icon widget (no missing-asset crash)
  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      // Newly picked SVG bytes
      content = ClipOval(
        child: SvgPicture.memory(
          picked.bytes!,
          width: 70.w,
          height: 70.h,
          fit: BoxFit.cover,
        ),
      );
    } else if (picked.isNetworkUrl) {
      // Existing Firebase / remote SVG URL — must use .network, never .asset
      content = ClipOval(
        child: SvgPicture.network(
          picked.url!,
          width: 70.w,
          height: 70.h,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _greyCircle(70),
        ),
      );
    } else {
      // No image yet
      content = _greyCircle(70);
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 26.w,
            height: 26.h,
            decoration: BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            // Use an Icon widget — avoids "assets/home_control/camera.svg" 404
            child: Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 13.sp),
          ),
        ),
      ),
    ]);
  }

  Widget _greyCircle(double size) => Container(
    width: size.w,
    height: size.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Icon(Icons.image_outlined,
        color: Colors.white70, size: (size * 0.4).sp),
  );

  // ── Ordinal helpers ────────────────────────────────────────────────────────
  String _ordinalFull(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}