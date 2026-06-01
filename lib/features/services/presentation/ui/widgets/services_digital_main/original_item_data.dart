part of '../../pages/digital_services/services_digital_main.dart';

class _OriginalItemData {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final String iconUrl;

  _OriginalItemData({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.iconUrl,
  });
}

// ── Ordinal helper ─────────────────────────────────────────────────────────
String _ordinal(int n) {
  if (n == 1) return '1st';
  if (n == 2) return '2nd';
  if (n == 3) return '3rd';
  return '${n}th';
}
