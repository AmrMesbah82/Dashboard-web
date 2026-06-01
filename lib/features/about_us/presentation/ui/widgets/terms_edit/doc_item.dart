part of '../../pages/terms_page/terms_edit.dart';

class _DocItem {
  Uint8List? bytes;
  String fileName;
  String existingUrl;

  _DocItem({this.bytes, this.fileName = '', this.existingUrl = ''});

  bool get hasFile => bytes != null || existingUrl.isNotEmpty;
  String get displayName =>
      bytes != null ? fileName : existingUrl.split('/').last.split('?').first;
}

// ═══════════════════════════════════════════════════════════════════════════════
