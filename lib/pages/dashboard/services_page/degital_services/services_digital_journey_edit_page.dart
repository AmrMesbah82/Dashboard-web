// ******************* FILE INFO *******************
// File Name: services_digital_journey_edit_page.dart
// UPDATED: Subtitle accordion now edits model.journeyTitle (the
//          "Reasons to Choose..." section heading) instead of
//          model.shortDescription (which belongs to the header only).

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/core/widget/button.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/theme/app_wight.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';
import 'services_digital_journey_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFF008037);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFDDE8DD);
  static const Color labelText = Color(0xFF1A1A1A);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color back = Color(0xFFF1F2ED);
}

class ServicesDigitalJourneyEditPage extends StatefulWidget {
  final ServicePageModel model;
  const ServicesDigitalJourneyEditPage({super.key, required this.model});

  @override
  State<ServicesDigitalJourneyEditPage> createState() =>
      _ServicesDigitalJourneyEditPageState();
}

class _ServicesDigitalJourneyEditPageState
    extends State<ServicesDigitalJourneyEditPage> {
  // ── journeyTitle controllers (the "Reasons to Choose..." heading) ──────────
  // ✅ FIXED: was editing shortDescription — now correctly edits journeyTitle
  late final TextEditingController _journeyTitleEnCtrl;
  late final TextEditingController _journeyTitleArCtrl;

  // ── Per-item controllers ───────────────────────────────────────────────────
  late List<_ItemControllers> _itemCtrls;

  // ── Accordion open states ──────────────────────────────────────────────────
  bool        _headerOpen = true;
  late List<bool> _itemOpen;

  // ── Submitted flag for validation ─────────────────────────────────────────
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    // ✅ FIXED: pre-populate from journeyTitle, not shortDescription
    _journeyTitleEnCtrl = TextEditingController(text: widget.model.journeyTitle.en);
    _journeyTitleArCtrl = TextEditingController(text: widget.model.journeyTitle.ar);

    _itemCtrls = widget.model.journeyItems
        .map((item) => _ItemControllers.fromModel(item))
        .toList();
    if (_itemCtrls.isEmpty) _itemCtrls.add(_ItemControllers.empty());
    _itemOpen = List.generate(_itemCtrls.length, (_) => true);
  }

  @override
  void dispose() {
    _journeyTitleEnCtrl.dispose();
    _journeyTitleArCtrl.dispose();
    for (final c in _itemCtrls) c.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _itemCtrls.add(_ItemControllers.empty());
      _itemOpen.add(true);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemCtrls[index].dispose();
      _itemCtrls.removeAt(index);
      _itemOpen.removeAt(index);
    });
  }

  // ✅ FIXED: _edited now writes into journeyTitle (not shortDescription),
  //           preserving shortDescription exactly as it came in from the model.
  ServicePageModel get _edited {
    final items = _itemCtrls.map((c) => JourneyItemModel(
      id:          c.itemId,
      iconUrl:     c.iconUrl,
      title:       BilingualText(en: c.titleEnCtrl.text, ar: c.titleArCtrl.text),
      description: BilingualText(en: c.descEnCtrl.text,  ar: c.descArCtrl.text),
    )).toList();
    return widget.model.copyWith(
      // ✅ Only update journeyTitle — shortDescription is untouched
      journeyTitle: BilingualText(
        en: _journeyTitleEnCtrl.text,
        ar: _journeyTitleArCtrl.text,
      ),
      journeyItems: items,
    );
  }

  void _onPreview() {
    setState(() => _submitted = true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceCmsCubit>(),
          child: ServicesDigitalJourneyPreviewPage(model: _edited),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _submitted = true);
    context.read<ServiceCmsCubit>().replaceModel(_edited);
    await context.read<ServiceCmsCubit>().save(publishStatus: 'published');
    if (mounted) Navigator.pop(context);
  }

  void _onDiscard() => Navigator.pop(context);

  Future<void> _pickIcon(int index) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;

      setState(() => _itemCtrls[index].iconUrl = 'loading');

      final bytes    = await file.readAsBytes();
      final fileName = 'journey_icon_${DateTime.now().microsecondsSinceEpoch}.svg';

      final ref = FirebaseStorage.instance
          .ref()
          .child('services/journey_icons/$fileName');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/svg+xml'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      setState(() => _itemCtrls[index].iconUrl = downloadUrl);
    } catch (e) {
      setState(() => _itemCtrls[index].iconUrl = '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<ServiceCmsCubit, ServiceCmsState>(
        listener: (context, state) {
          if (state is ServiceCmsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved successfully')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 2),
                      SizedBox(height: 20.h),

                      Text(
                        'Editing Digital Journey Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),


                      SizedBox(height: 20.h),

                      // ── Journey section title accordion ───────────────────
                      // ✅ Label updated: "Section Title" instead of "SubTitle"
                      //    to make clear this controls the "Reasons to Choose..."
                      //    heading on the public page, not the header description.
                      _buildAccordion(
                        title:    'Digital Journey Section Title',
                        isOpen:   _headerOpen,
                        onToggle: () =>
                            setState(() => _headerOpen = !_headerOpen),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Section Title', style: _labelStyle()),
                                Text('عنوان القسم',   style: _labelStyle()),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(children: [
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  controller:    _journeyTitleEnCtrl,
                                  hint:          'Text Here',
                                  submitted:     _submitted,
                                  primaryColor:  _C.primary,

                                  textDirection: TextDirection.ltr,
                                  height:        36,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  controller:    _journeyTitleArCtrl,
                                  hint:          'أدخل النص هنا',
                                  submitted:     _submitted,
                                  primaryColor:  _C.primary,

                                  textDirection: TextDirection.rtl,
                                  textAlign:     TextAlign.right,
                                  height:        36,
                                ),
                              ),
                            ]

                            ),
                          ],
                        ),
                      ),


                      // ── Per-item accordions ───────────────────────────────
                      ...List.generate(_itemCtrls.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildItemAccordion(i),
                        );
                      }),

                      // ── + Digital Journey button ──────────────────────────
                      GestureDetector(
                        onTap: _addItem,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _C.primary,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('Digital Journey',
                                  style: StyleText.fontSize12Weight600
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _actionButtons(),
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

  // ── Per-item accordion ──────────────────────────────────────────────────────
  Widget _buildItemAccordion(int i) {
    final c      = _itemCtrls[i];
    final isOpen = _itemOpen[i];

    return _buildAccordion(
      title:    '${_ordinal(i + 1)} Digital Journey',
      isOpen:   isOpen,
      onToggle: () => setState(() => _itemOpen[i] = !isOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [



              Text('Icon', style: _labelStyle()),
              GestureDetector(
                onTap: () => _removeItem(i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text('Remove',
                      style: StyleText.fontSize12Weight600
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          GestureDetector(
            onTap: () => _pickIcon(i),
            child: Container(
              width: 56.w, height: 56.w,
              decoration: BoxDecoration(
                color:  _C.sectionBg,
                shape:  BoxShape.circle,

              ),
              child: _iconPreview(c.iconUrl),
            ),
          ),
          SizedBox(height: 14.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Title',   style: _labelStyle()),
              Text('العنوان', style: _labelStyle()),
            ],
          ),
          SizedBox(height: 6.h),
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                controller:    c.titleEnCtrl,
                hint:          'Text Here',
                submitted:     _submitted,
                primaryColor:  _C.primary,

                textDirection: TextDirection.ltr,
                height:        36,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                controller:    c.titleArCtrl,
                hint:          'أدخل النص هنا',
                submitted:     _submitted,
                primaryColor:  _C.primary,

                textDirection: TextDirection.rtl,
                textAlign:     TextAlign.right,
                height:        36,
              ),
            ),
          ]),
          SizedBox(height: 14.h),

          Text('Description', style: _labelStyle()),
          SizedBox(height: 6.h),
          CustomValidatedTextFieldMaster(
            controller:    c.descEnCtrl,
            hint:          'Text Here',
            submitted:     false,
            primaryColor:  _C.primary,
            textDirection: TextDirection.ltr,
            maxLines:      4,
            height:        100,
            showCharCount: true,
            maxLength:     900,
          ),
          SizedBox(height: 14.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text('الوصف', style: _labelStyle()),
          ),
          SizedBox(height: 6.h),
          CustomValidatedTextFieldMaster(
            controller:    c.descArCtrl,
            hint:          'أدخل النص هنا',
            submitted:     false,
            primaryColor:  _C.primary,
            textDirection: TextDirection.rtl,
            textAlign:     TextAlign.right,
            maxLines:      4,
            height:        100,
            showCharCount: true,
            maxLength:     900,
          ),
        ],
      ),
    );
  }

  // ── Reusable accordion ──────────────────────────────────────────────────────
  Widget _buildAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            child,
        ],
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _onPreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          Expanded(child: const SizedBox()),
        ]),
        SizedBox(height: 10.h),

        Row(children: [
          Expanded(
            child: customButton(
              title: 'Discard',
              function: _onDiscard,
              height: 44.h,
              color: _C.grey,
              radius: 8.r,
              textColor: Colors.white,
              textStyle: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Save',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  // ── Icon preview ────────────────────────────────────────────────────────────
  Widget _iconPreview(String url) {
    if (url.isEmpty) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 28.sp, color: _C.primary),
          Positioned(
            right: 6.w, bottom: 6.w,
            child: Container(
              width: 14.w, height: 14.w,
              decoration: const BoxDecoration(
                  color: _C.primary, shape: BoxShape.circle),
              child: Icon(Icons.edit, size: 8.sp, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (url == 'loading') {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 1.5, color: _C.primary),
      );
    }

    if (url.startsWith('http')) {
      return ClipOval(
        child: Center(
          child: SvgPicture.network(
            url,
            fit: BoxFit.scaleDown,
            width: 56.w,
            height: 56.w,
            placeholderBuilder: (_) => Center(
              child: CircularProgressIndicator(strokeWidth: 1.5, color: _C.primary),
            ),
          ),
        ),
      );
    }

    return ClipOval(
      child: Icon(Icons.image, size: 28.sp, color: _C.grey),
    );
  }

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: _C.labelText);
}

// ── Per-item controller holder ──────────────────────────────────────────────
class _ItemControllers {
  final String                itemId;
  final TextEditingController titleEnCtrl;
  final TextEditingController titleArCtrl;
  final TextEditingController descEnCtrl;
  final TextEditingController descArCtrl;
  String iconUrl;

  _ItemControllers({
    required this.itemId,
    required this.titleEnCtrl,
    required this.titleArCtrl,
    required this.descEnCtrl,
    required this.descArCtrl,
    required this.iconUrl,
  });

  factory _ItemControllers.fromModel(JourneyItemModel m) => _ItemControllers(
    itemId:      m.id,
    titleEnCtrl: TextEditingController(text: m.title.en),
    titleArCtrl: TextEditingController(text: m.title.ar),
    descEnCtrl:  TextEditingController(text: m.description.en),
    descArCtrl:  TextEditingController(text: m.description.ar),
    iconUrl:     m.iconUrl,
  );

  factory _ItemControllers.empty() => _ItemControllers(
    itemId:      'ji_${DateTime.now().microsecondsSinceEpoch}',
    titleEnCtrl: TextEditingController(),
    titleArCtrl: TextEditingController(),
    descEnCtrl:  TextEditingController(),
    descArCtrl:  TextEditingController(),
    iconUrl:     '',
  );

  void dispose() {
    titleEnCtrl.dispose();
    titleArCtrl.dispose();
    descEnCtrl.dispose();
    descArCtrl.dispose();
  }
}

// ── Ordinal helper ──────────────────────────────────────────────────────────
String _ordinal(int n) {
  if (n == 1) return '1st';
  if (n == 2) return '2nd';
  if (n == 3) return '3rd';
  return '${n}th';
}