// ═══════════════════════════════════════════════════════════════════
// FILE 1: department_model.dart
// Path: lib/model/department_model.dart
// ═══════════════════════════════════════════════════════════════════

class DepartmentModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String iconUrl;
  final DateTime? createdAt;

  const DepartmentModel({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
    this.iconUrl = '',
    this.createdAt,
  });

  factory DepartmentModel.empty() => DepartmentModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt: DateTime.now(),
  );

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    return DepartmentModel(
      id: id,
      nameEn: map['nameEn'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'nameEn': nameEn,
    'nameAr': nameAr,
    'iconUrl': iconUrl,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  DepartmentModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? iconUrl,
    DateTime? createdAt,
  }) =>
      DepartmentModel(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        iconUrl: iconUrl ?? this.iconUrl,
        createdAt: createdAt ?? this.createdAt,
      );
}