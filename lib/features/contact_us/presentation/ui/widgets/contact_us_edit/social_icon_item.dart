part of '../../pages/contact_us_edit.dart';

class _SocialIconItem {
  final String id;
  final int    counter;

  /// Index into footerLinks list — used as the unique dropdown value
  int?       selectedIndex;
  Uint8List? iconBytes;
  String     iconUrl = '';

  _SocialIconItem({required this.id, required this.counter});
}
