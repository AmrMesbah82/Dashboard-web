part of '../../pages/terms_page/terms_edit.dart';

class _PickedImage {
  Uint8List? bytes;
  String? url;
  String fileName;

  _PickedImage({this.bytes, this.url, this.fileName = ''});

  bool get hasImage => bytes != null || (url != null && url!.isNotEmpty);
  void clear() {
    bytes = null;
    url = null;
    fileName = '';
  }
}

// ── Local UI-only holder for documents ─────────────────────────────────────
