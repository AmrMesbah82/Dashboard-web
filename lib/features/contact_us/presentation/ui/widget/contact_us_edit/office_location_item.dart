part of '../../pages/contact_us_edit.dart';

class _OfficeLocationItem {
  final String id;
  final int    counter;
  final locationNameEnCtrl = TextEditingController();
  final locationNameArCtrl = TextEditingController();
  final text1EnCtrl        = TextEditingController();
  final text1ArCtrl        = TextEditingController();
  final text2EnCtrl        = TextEditingController();
  final text2ArCtrl        = TextEditingController();
  final mapLinkCtrl        = TextEditingController();
  Uint8List? iconBytes;
  String     iconUrl = '';

  _OfficeLocationItem({required this.id, required this.counter});
}
