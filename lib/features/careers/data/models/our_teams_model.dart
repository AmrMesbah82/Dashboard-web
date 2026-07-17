// ******************* FILE INFO *******************
// File Name: our_teams_model.dart
// Model for Our Teams section

class BilingualText {
  final String en;
  final String ar;

  const BilingualText({this.en = '', this.ar = ''});

  factory BilingualText.fromMap(Map<String, dynamic> map) => BilingualText(
    en: map['en'] ?? '',
    ar: map['ar'] ?? '',
  );

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  BilingualText copyWith({String? en, String? ar}) =>
      BilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

class OurTeamsDeliverable {
  final String id;
  final BilingualText label;

  const OurTeamsDeliverable({
    required this.id,
    this.label = const BilingualText(),
  });

  factory OurTeamsDeliverable.fromMap(Map<String, dynamic> map) =>
      OurTeamsDeliverable(
        id: map['id'] ?? '',
        label: BilingualText.fromMap(
            Map<String, dynamic>.from(map['label'] ?? {})),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label.toMap(),
  };

  OurTeamsDeliverable copyWith({String? id, BilingualText? label}) =>
      OurTeamsDeliverable(
        id: id ?? this.id,
        label: label ?? this.label,
      );
}

class OurTeamItem {
  final String id;
  final String iconUrl;
  final BilingualText heading;
  final BilingualText title;
  final BilingualText description;
  final BilingualText deliverables;
  final List<OurTeamsDeliverable> deliverableItems;

  const OurTeamItem({
    required this.id,
    this.iconUrl = '',
    this.heading = const BilingualText(),
    this.title = const BilingualText(),
    this.description = const BilingualText(),
    this.deliverables = const BilingualText(),
    this.deliverableItems = const [],
  });

  factory OurTeamItem.fromMap(Map<String, dynamic> map) => OurTeamItem(
    id: map['id'] ?? '',
    iconUrl: map['iconUrl'] ?? '',
    heading: BilingualText.fromMap(
        Map<String, dynamic>.from(map['heading'] ?? {})),
    title: BilingualText.fromMap(
        Map<String, dynamic>.from(map['title'] ?? {})),
    description: BilingualText.fromMap(
        Map<String, dynamic>.from(map['description'] ?? {})),
    deliverables: BilingualText.fromMap(
        Map<String, dynamic>.from(map['deliverables'] ?? {})),
    deliverableItems: (map['deliverableItems'] as List<dynamic>? ?? [])
        .map((e) =>
        OurTeamsDeliverable.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'iconUrl': iconUrl,
    'heading': heading.toMap(),
    'title': title.toMap(),
    'description': description.toMap(),
    'deliverables': deliverables.toMap(),
    'deliverableItems': deliverableItems.map((d) => d.toMap()).toList(),
  };

  OurTeamItem copyWith({
    String? id,
    String? iconUrl,
    BilingualText? heading,
    BilingualText? title,
    BilingualText? description,
    BilingualText? deliverables,
    List<OurTeamsDeliverable>? deliverableItems,
  }) =>
      OurTeamItem(
        id: id ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        heading: heading ?? this.heading,
        title: title ?? this.title,
        description: description ?? this.description,
        deliverables: deliverables ?? this.deliverables,
        deliverableItems: deliverableItems ?? this.deliverableItems,
      );
}

class OurTeamsModel {
  final String headerIconUrl;
  final BilingualText headerTitle;
  final List<OurTeamItem> items;
  final DateTime? lastUpdated;

  const OurTeamsModel({
    this.headerIconUrl = '',
    this.headerTitle = const BilingualText(),
    this.items = const [],
    this.lastUpdated,
  });

  factory OurTeamsModel.fromMap(Map<String, dynamic> map) => OurTeamsModel(
    headerIconUrl: map['headerIconUrl'] ?? '',
    headerTitle: BilingualText.fromMap(
        Map<String, dynamic>.from(map['headerTitle'] ?? {})),
    items: (map['items'] as List<dynamic>? ?? [])
        .map((e) => OurTeamItem.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    lastUpdated: map['lastUpdated'] != null
        ? DateTime.tryParse(map['lastUpdated'].toString())
        : null,
  );

  Map<String, dynamic> toMap() => {
    'headerIconUrl': headerIconUrl,
    'headerTitle': headerTitle.toMap(),
    'items': items.map((i) => i.toMap()).toList(),
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  /// Nested template for [FlatCodec.decode] (one populated sample element per list).
  static Map<String, dynamic> get flatTemplate => {
        'headerIconUrl': '',
        'headerTitle': {'en': '', 'ar': ''},
        'items': [
          {
            'id': '',
            'iconUrl': '',
            'heading': {'en': '', 'ar': ''},
            'title': {'en': '', 'ar': ''},
            'description': {'en': '', 'ar': ''},
            'deliverables': {
              'id': '',
              'label': {'en': '', 'ar': ''}
            },
            'deliverableItems': [
              {
                'id': '',
                'label': {'en': '', 'ar': ''}
              }
            ],
          }
        ],
        'lastUpdated': '',
      };

  OurTeamsModel copyWith({
    String? headerIconUrl,
    BilingualText? headerTitle,
    List<OurTeamItem>? items,
    DateTime? lastUpdated,
  }) =>
      OurTeamsModel(
        headerIconUrl: headerIconUrl ?? this.headerIconUrl,
        headerTitle: headerTitle ?? this.headerTitle,
        items: items ?? this.items,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}