part of '../../pages/home_edit.dart';

class _SectionItem {
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage image;
  _PickedImage icon;
  bool visibility;

  _SectionItem()
    : descEn = TextEditingController(),
      descAr = TextEditingController(),
      image = const _PickedImage(),
      icon = const _PickedImage(),
      visibility = true;

  void dispose() {
    descEn.dispose();
    descAr.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color Picker (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
