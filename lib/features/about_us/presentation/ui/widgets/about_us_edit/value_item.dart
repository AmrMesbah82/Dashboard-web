part of '../../pages/about_us_edit.dart';

class _ValueItem {
  final String id;
  final int counter;
  final titleEnCtrl = TextEditingController();
  final titleArCtrl = TextEditingController();
  final shortDescEnCtrl = TextEditingController();
  final shortDescArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}
