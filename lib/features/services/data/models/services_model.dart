// ******************* FILE INFO *******************
// File Name: services_model.dart
// Created by: Amr Mesbah
// UPDATED: Added journeyTitle BilingualText field to ServicePageModel
//          to separate "Reasons to Choose..." section title from
//          shortDescription (which belongs to the header only).
// UPDATED: Added lastUpdatedAt DateTime? field to ServicePageModel

class BilingualText {
  final String en;
  final String ar;
  const BilingualText({this.en = '', this.ar = ''});

  BilingualText copyWith({String? en, String? ar}) =>
      BilingualText(en: en ?? this.en, ar: ar ?? this.ar);

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  factory BilingualText.fromMap(dynamic raw) {
    if (raw == null) return const BilingualText();
    final map = Map<String, dynamic>.from(raw as Map);
    return BilingualText(
      en: map['en'] as String? ?? '',
      ar: map['ar'] as String? ?? '',
    );
  }
}

// ── Journey Item ──────────────────────────────────────────────────────────────

class JourneyItemModel {
  final String        id;
  final BilingualText subTitle;
  final BilingualText title;
  final BilingualText description;
  final String        iconUrl;

  const JourneyItemModel({
    required this.id,
    this.subTitle    = const BilingualText(),
    this.title       = const BilingualText(),
    this.description = const BilingualText(),
    this.iconUrl     = '',
  });

  JourneyItemModel copyWith({
    String?        id,
    BilingualText? subTitle,
    BilingualText? title,
    BilingualText? description,
    String?        iconUrl,
  }) => JourneyItemModel(
    id:          id          ?? this.id,
    subTitle:    subTitle    ?? this.subTitle,
    title:       title       ?? this.title,
    description: description ?? this.description,
    iconUrl:     iconUrl     ?? this.iconUrl,
  );

  Map<String, dynamic> toMap() => {
    'id':          id,
    'subTitle':    subTitle.toMap(),
    'title':       title.toMap(),
    'description': description.toMap(),
    'iconUrl':     iconUrl,
  };

  factory JourneyItemModel.fromMap(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return JourneyItemModel(
      id:          map['id']          as String? ?? '',
      subTitle:    BilingualText.fromMap(map['subTitle']),
      title:       BilingualText.fromMap(map['title']),
      description: BilingualText.fromMap(map['description']),
      iconUrl:     map['iconUrl']     as String? ?? '',
    );
  }
}

// ── Page Model ────────────────────────────────────────────────────────────────

class ServicePageModel {
  // ── Firestore field keys ──────────────────────────────────────────────────
  static const String AR = 'ar';
  static const String DESCRIPTION = 'description';
  static const String EN = 'en';
  static const String ICON_URL = 'iconUrl';
  static const String ID = 'id';
  static const String JOURNEY_ITEMS = 'journeyItems';
  static const String JOURNEY_TITLE = 'journeyTitle';
  static const String LAST_UPDATED_AT = 'lastUpdatedAt';
  static const String SHORT_DESCRIPTION = 'shortDescription';
  static const String SUB_TITLE = 'subTitle';
  static const String TITLE = 'title';

  final BilingualText          title;
  final BilingualText          shortDescription;
  // ✅ Separate field for the "Reasons to Choose..." section heading
  final BilingualText          journeyTitle;
  final List<JourneyItemModel> journeyItems;
  // ✅ NEW: tracks when the services page was last updated
  final DateTime?              lastUpdatedAt;

  const ServicePageModel({
    this.title            = const BilingualText(),
    this.shortDescription = const BilingualText(),
    this.journeyTitle     = const BilingualText(
      en: 'Reasons to Choose Bayanatz for Your Digital Journey',
      ar: 'أسباب اختيار بيانتز لرحلتك الرقمية',
    ),
    this.journeyItems     = const [],
    this.lastUpdatedAt,
  });

  ServicePageModel copyWith({
    BilingualText?          title,
    BilingualText?          shortDescription,
    BilingualText?          journeyTitle,
    List<JourneyItemModel>? journeyItems,
    DateTime?               lastUpdatedAt,
  }) => ServicePageModel(
    title:            title            ?? this.title,
    shortDescription: shortDescription ?? this.shortDescription,
    journeyTitle:     journeyTitle     ?? this.journeyTitle,
    journeyItems:     journeyItems     ?? this.journeyItems,
    lastUpdatedAt:    lastUpdatedAt    ?? this.lastUpdatedAt,
  );

  Map<String, dynamic> toMap() => {
    TITLE:            title.toMap(),
    SHORT_DESCRIPTION: shortDescription.toMap(),
    JOURNEY_TITLE:     journeyTitle.toMap(),
    JOURNEY_ITEMS:     journeyItems.map((j) => j.toMap()).toList(),
    // ✅ lastUpdatedAt is handled by FieldValue.serverTimestamp() in the repo
    //    so we only serialize it for reading, not writing
    if (lastUpdatedAt != null)
      LAST_UPDATED_AT: lastUpdatedAt!.toIso8601String(),
  };

  factory ServicePageModel.fromMap(Map<String, dynamic> map) => ServicePageModel(
    title:            BilingualText.fromMap(map[TITLE]),
    shortDescription: BilingualText.fromMap(map[SHORT_DESCRIPTION]),
    journeyTitle:     BilingualText.fromMap(map[JOURNEY_TITLE]),
    journeyItems:     (map[JOURNEY_ITEMS] as List? ?? [])
        .map((j) => JourneyItemModel.fromMap(j))
        .toList(),
    lastUpdatedAt:    _parseDateTime(map[LAST_UPDATED_AT]),
  );

  static ServicePageModel empty() => const ServicePageModel();

  /// ✅ Handles Firestore Timestamp, ISO string, or null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value.runtimeType.toString().contains('Timestamp')) {
      try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}