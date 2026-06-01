part of '../../pages/home_edit.dart';

class _NavBtnItem {
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  String? route;
  bool status;

  _NavBtnItem()
    : nameEn = TextEditingController(),
      nameAr = TextEditingController(),
      status = true;

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}
