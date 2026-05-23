part of '../../pages/why_join_edit.dart';

class _ItemEdit {
  String id;
  _PickedImage icon;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  _PickedImage svg;
  final TextEditingController descEn;
  final TextEditingController descAr;

  _ItemEdit({
    required this.id,
    _PickedImage? icon,
    String titleEn = '',
    String titleAr = '',
    _PickedImage? svg,
    String descEn = '',
    String descAr = '',
  })  : icon = icon ?? const _PickedImage(),
        titleEn = TextEditingController(text: titleEn),
        titleAr = TextEditingController(text: titleAr),
        svg = svg ?? const _PickedImage(),
        descEn = TextEditingController(text: descEn),
        descAr = TextEditingController(text: descAr);

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
