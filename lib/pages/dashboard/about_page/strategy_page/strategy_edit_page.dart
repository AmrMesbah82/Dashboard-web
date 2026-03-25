// ******************* FILE INFO *******************
// File Name: strategy_edit_page.dart
// Screen 2 of 3 — Our Strategy CMS: Edit page

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web_app_admin/controller/about_us/about_us_cubit.dart';
import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

import 'strategy_preview_page.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyEditPage extends StatefulWidget {
  const StrategyEditPage({super.key});

  @override
  State<StrategyEditPage> createState() => _StrategyEditPageState();
}

class _StrategyEditPageState extends State<StrategyEditPage> {
  // ── Navigation Label ──
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // ── Vision ──

  Uint8List? _visionSvgBytes;
  String _visionSvgUrl = '';

  bool _navLabelOpen = true;
  bool _visionOpen   = true;
  bool _submitted    = false;
  bool _seeded       = false;
  bool _isSaving     = false;

  @override
  void initState() {
    super.initState();
    context.read<StrategyCubit>().load();
  }

  @override
  void dispose() {
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
    super.dispose();
  }

  // ── File pickers ──────────────────────────────────────────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(null); return; }
      final reader = html.FileReader()..readAsArrayBuffer(files.first);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer) c.complete(r.asUint8List());
        else if (r is Uint8List) c.complete(r);
        else c.complete(null);
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  Future<Uint8List?> _pickSvg() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) { c.complete(null); return; }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ SVG files only! You selected: ${file.name}'),
          backgroundColor: _kRed,
        ));
        c.complete(null);
        return;
      }
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer) c.complete(r.asUint8List());
        else if (r is Uint8List) c.complete(r);
        else c.complete(null);
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  // ── Seed ─────────────────────────────────────────────────────────────────
  void _seed(OurStrategyModel m) {
    if (_seeded) return;
    _seeded = true;
    _navTitleEnCtrl.text   = m.navigationLabel.title.en;
    _navTitleArCtrl.text   = m.navigationLabel.title.ar;
    _navIconUrl            = m.navigationLabel.iconUrl;
    _visionSvgUrl          = m.vision.svgUrl;
  }

  // ── Build model ───────────────────────────────────────────────────────────
  OurStrategyModel _buildModel(String status) => OurStrategyModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,
      title: AboutBilingualText(
          en: _navTitleEnCtrl.text.trim(),
          ar: _navTitleArCtrl.text.trim()),
    ),
    vision: StrategySection(
      svgUrl: _visionSvgUrl,
      description: const AboutBilingualText(), // ← empty, no fields
    ),
  );

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_navIconBytes  != null) uploads['strategy_cms/navLabel/icon'] = _navIconBytes!;
    if (_visionSvgBytes != null) uploads['strategy_cms/vision/svg']   = _visionSvgBytes!;
    return uploads;
  }

  bool _validate() {
    return [
      _navTitleEnCtrl,
      _navTitleArCtrl,
    ].every((c) => c.text.trim().isNotEmpty);
  }

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validate()) return;
    final cubit   = context.read<StrategyCubit>();
    final model   = _buildModel('draft');
    final uploads = _collectUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StrategyPreviewPage(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validate()) return;
    setState(() => _isSaving = true);
    await context.read<StrategyCubit>().save(
      model: _buildModel(status),
      imageUploads: _collectUploads().isEmpty ? null : _collectUploads(),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyCubit, StrategyState>(
      listener: (context, state) {
        if (state is StrategyLoaded) _seed(state.data);
        if (state is StrategySaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Our Strategy saved!'),
              backgroundColor: _kGreenSolid));
          Navigator.pop(context);
        }
        if (state is StrategyError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed));
        }
      },
      builder: (context, state) {
        final loading =
            state is StrategyLoading || state is StrategyInitial;

        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 1000.w,
                        child: Column(
                          children: [


                            SizedBox(height: 20.h),
                            AdminSubNavBar(activeIndex: 3),
                            SizedBox(height: 20.h),
                            loading
                                ? const Center(
                                child: CircularProgressIndicator(
                                    color: _kGreenSolid))
                                : _buildForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving) _savingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editing Our Strategy',
            style: StyleText.fontSize45Weight600.copyWith(
                color: _kGreen, fontWeight: FontWeight.w700)),
        SizedBox(height: 24.h),

        // Navigation Label
        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () => setState(() => _navLabelOpen = !_navLabelOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: _navIconBytes,
                url: _navIconUrl,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) setState(() => _navIconBytes = b);
                },
              ),
              SizedBox(height: 16.h),
              _fieldLabel('Title'),
              SizedBox(height: 8.h),
              _bilingualRow(
                  enCtrl: _navTitleEnCtrl, arCtrl: _navTitleArCtrl,
                  enHint: 'Text Here', arHint: 'أدخل النص هنا'),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Vision
        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUploadCircle(
                label: 'SVG',
                bytes: _visionSvgBytes,
                url: _visionSvgUrl,
                isSvg: true,
                onTap: () async {
                  final b = await _pickSvg();
                  if (b != null) setState(() => _visionSvgBytes = b);
                },
              ),
              SizedBox(height: 20.h),

            ],
          ),
        ),
        SizedBox(height: 32.h),

        // Action buttons
        Row(children: [
          Expanded(
              child: _btn(
                  label: 'Preveiw',
                  color: const Color(0xFF4CAF50),
                  onTap: _onPreview)),
          SizedBox(width: 16.w),
          Expanded(
              child: _btn(
                  label: 'Publish',
                  color: _kGreenSolid,
                  onTap: () => _save('published'))),
        ]),
        SizedBox(height: 12.h),
        _btn(
            label: 'Discard',
            color: const Color(0xFF9E9E9E),
            onTap: () => Navigator.pop(context)),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _kGreenSolid,
            borderRadius: isOpen
                ? BorderRadius.vertical(top: Radius.circular(12.r))
                : BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp),
            ],
          ),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          padding: EdgeInsets.all(20.w),
          child: child,
        ),
    ]);
  }

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w, height: 64.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEEEEEE),

                ),
                child: hasImage
                    ? ClipOval(child: _buildImgWidget(bytes, url, isSvg))
                    : Icon(
                    isSvg ? Icons.description_outlined : Icons.add,
                    color: Colors.grey[600],
                    size: 28.sp),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  width: 24.w, height: 24.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGreenSolid,

                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 13.sp),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImgWidget(Uint8List? bytes, String url, bool isSvg) {
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final h = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = h.startsWith('<svg') || h.startsWith('<?xml');
    }
    if (isSvg || isSvgData) {
      if (bytes != null) return SvgPicture.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvgBytes(url),
          builder: (_, snap) => snap.hasData
              ? SvgPicture.memory(snap.data!, fit: BoxFit.cover)
              : Icon(Icons.description, color: Colors.grey[400], size: 28.sp),
        );
      }
    } else {
      if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty)
        return Image.network(url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp));
    }
    return Icon(isSvg ? Icons.description : Icons.image,
        color: Colors.grey, size: 28.sp);
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    final res = await html.HttpRequest.request(url,
        method: 'GET', responseType: 'arraybuffer');
    if (res.status != 200) throw Exception('Failed: ${res.status}');
    return (res.response as ByteBuffer).asUint8List();
  }

  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint, controller: enCtrl, height: 42, maxLines: 1,
            maxLength: 200, submitted: _submitted,
            textDirection: TextDirection.ltr, textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint, controller: arCtrl, height: 42, maxLines: 1,
            maxLength: 200, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

  Widget _fieldLabelAr(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(t,
        style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87)),
  );

  Widget _btn(
      {required String label,
        required Color color,
        required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10.r)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w, height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _kGreenSolid),
            SizedBox(height: 12.h),
            Text('Saving...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}