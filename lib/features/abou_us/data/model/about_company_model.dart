// ═══════════════════════════════════════════════════════════════════
// FILE 1: about_company_model.dart
// ═══════════════════════════════════════════════════════════════════

class AboutCompanyModel {
  final String id;
  final String aboutEn;
  final String aboutAr;
  final DateTime? lastUpdated;

  const AboutCompanyModel({
    this.id = 'about_company',
    this.aboutEn = '',
    this.aboutAr = '',
    this.lastUpdated,
  });

  factory AboutCompanyModel.empty() => AboutCompanyModel(
    id: 'about_company',
    lastUpdated: DateTime.now(),
  );

  factory AboutCompanyModel.fromMap(String id, Map<String, dynamic> map) {
    return AboutCompanyModel(
      id: id,
      aboutEn: map['aboutEn'] as String? ?? '',
      aboutAr: map['aboutAr'] as String? ?? '',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'aboutEn': aboutEn,
    'aboutAr': aboutAr,
    'lastUpdated': DateTime.now().toIso8601String(),
  };

  AboutCompanyModel copyWith({
    String? id,
    String? aboutEn,
    String? aboutAr,
    DateTime? lastUpdated,
  }) =>
      AboutCompanyModel(
        id: id ?? this.id,
        aboutEn: aboutEn ?? this.aboutEn,
        aboutAr: aboutAr ?? this.aboutAr,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}