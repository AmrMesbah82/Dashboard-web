// ******************* FILE INFO *******************
// File Name: careers_section_model.dart
// Shared model for the three Careers sub-tabs:
//   • Why Join Our Team
//   • Our Interns
//   • Our Teams
// Each tab stores a list of CareersSectionItem entries in Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Bilingual text helper ─────────────────────────────────────────────────────
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  factory BiText.fromMap(Map<String, dynamic>? map) => BiText(
    en: map?['en'] as String? ?? '',
    ar: map?['ar'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Single item inside a careers section ──────────────────────────────────────
class CareersSectionItem {
  final String id;
  final String iconUrl;
  final BiText title;
  final String svgUrl;
  final BiText description;

  const CareersSectionItem({
    required this.id,
    this.iconUrl = '',
    this.title = const BiText(),
    this.svgUrl = '',
    this.description = const BiText(),
  });

  factory CareersSectionItem.fromMap(Map<String, dynamic> map, String docId) =>
      CareersSectionItem(
        id: docId,
        iconUrl: map['iconUrl'] as String? ?? '',
        title: BiText.fromMap(map['title'] as Map<String, dynamic>?),
        svgUrl: map['svgUrl'] as String? ?? '',
        description:
        BiText.fromMap(map['description'] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toMap() => {
    'iconUrl': iconUrl,
    'title': title.toMap(),
    'svgUrl': svgUrl,
    'description': description.toMap(),
  };

  CareersSectionItem copyWith({
    String? id,
    String? iconUrl,
    BiText? title,
    String? svgUrl,
    BiText? description,
  }) =>
      CareersSectionItem(
        id: id ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
      );
}

// ── Full section model (one per tab) ──────────────────────────────────────────
class CareersSectionModel {
  final String sectionKey; // 'whyJoinOurTeam' | 'ourInterns' | 'ourTeams'
  final List<CareersSectionItem> items;
  final DateTime? lastUpdated;

  const CareersSectionModel({
    required this.sectionKey,
    this.items = const [],
    this.lastUpdated,
  });

  factory CareersSectionModel.fromFirestore(
      String sectionKey,
      Map<String, dynamic> docData,
      List<Map<String, dynamic>> itemMaps,
      ) {
    final items = <CareersSectionItem>[];
    for (final m in itemMaps) {
      final id = m['_id'] as String? ?? '';
      items.add(CareersSectionItem.fromMap(m, id));
    }

    DateTime? lastUpdated;
    final ts = docData['lastUpdated'];
    if (ts is Timestamp) lastUpdated = ts.toDate();

    return CareersSectionModel(
      sectionKey: sectionKey,
      items: items,
      lastUpdated: lastUpdated,
    );
  }

  factory CareersSectionModel.empty(String sectionKey) => CareersSectionModel(
    sectionKey: sectionKey,
    items: const [],
    lastUpdated: null,
  );

  CareersSectionModel copyWith({
    String? sectionKey,
    List<CareersSectionItem>? items,
    DateTime? lastUpdated,
  }) =>
      CareersSectionModel(
        sectionKey: sectionKey ?? this.sectionKey,
        items: items ?? this.items,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}