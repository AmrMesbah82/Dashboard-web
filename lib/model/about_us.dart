// ******************* FILE INFO *******************
// File Name: about_us.dart  (model)
// Created by: Amr Mesbah
// Updated: added OurStrategyModel + TermsOfServiceModel + strategicHouse ENG/ARB image fields
// FIXED: added lastUpdatedAt to AboutPageModel (mirrors ServicePageModel pattern)

import 'dart:typed_data';

class AboutBilingualText {
  final String en;
  final String ar;

  const AboutBilingualText({this.en = '', this.ar = ''});

  factory AboutBilingualText.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutBilingualText();
    return AboutBilingualText(
      en: (map['en'] as String?) ?? '',
      ar: (map['ar'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  AboutBilingualText copyWith({String? en, String? ar}) =>
      AboutBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Navigation Label ──────────────────────────────────────────────────────────

class AboutNavigationLabel {
  final String iconUrl;
  final AboutBilingualText title;

  const AboutNavigationLabel({
    this.iconUrl = '',
    this.title = const AboutBilingualText(),
  });

  factory AboutNavigationLabel.empty() => const AboutNavigationLabel();

  factory AboutNavigationLabel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutNavigationLabel();
    return AboutNavigationLabel(
      iconUrl: (map['iconUrl'] as String?) ?? '',
      title: AboutBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'iconUrl': iconUrl,
    'title': title.toMap(),
  };

  AboutNavigationLabel copyWith({
    String? iconUrl,
    AboutBilingualText? title,
  }) =>
      AboutNavigationLabel(
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
      );
}

// ── Values item ───────────────────────────────────────────────────────────────

class AboutValueItem {
  final String id;
  final String iconUrl;
  final AboutBilingualText title;
  final AboutBilingualText shortDescription;
  final AboutBilingualText description;

  const AboutValueItem({
    required this.id,
    this.iconUrl = '',
    this.title = const AboutBilingualText(),
    this.shortDescription = const AboutBilingualText(),
    this.description = const AboutBilingualText(),
  });

  factory AboutValueItem.empty(String id) => AboutValueItem(id: id);

  factory AboutValueItem.fromMap(Map<String, dynamic> map) => AboutValueItem(
    id: (map['id'] as String?) ?? '',
    iconUrl: (map['iconUrl'] as String?) ?? '',
    title:
    AboutBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
    shortDescription: AboutBilingualText.fromMap(
        map['shortDescription'] as Map<String, dynamic>?),
    description: AboutBilingualText.fromMap(
        map['description'] as Map<String, dynamic>?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'iconUrl': iconUrl,
    'title': title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'description': description.toMap(),
  };

  AboutValueItem copyWith({
    String? id,
    String? iconUrl,
    AboutBilingualText? title,
    AboutBilingualText? shortDescription,
    AboutBilingualText? description,
  }) =>
      AboutValueItem(
        id: id ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        description: description ?? this.description,
      );
}

// ── Section (Vision / Mission) ────────────────────────────────────────────────

class AboutSection {
  final String iconUrl;
  final String svgUrl;
  final AboutBilingualText subDescription;
  final AboutBilingualText description;

  const AboutSection({
    this.iconUrl = '',
    this.svgUrl = '',
    this.subDescription = const AboutBilingualText(),
    this.description = const AboutBilingualText(),
  });

  factory AboutSection.empty() => const AboutSection();

  factory AboutSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutSection();
    return AboutSection(
      iconUrl: (map['iconUrl'] as String?) ?? '',
      svgUrl: (map['svgUrl'] as String?) ?? '',
      subDescription: AboutBilingualText.fromMap(
          map['subDescription'] as Map<String, dynamic>?),
      description: AboutBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'iconUrl': iconUrl,
    'svgUrl': svgUrl,
    'subDescription': subDescription.toMap(),
    'description': description.toMap(),
  };

  AboutSection copyWith({
    String? iconUrl,
    String? svgUrl,
    AboutBilingualText? subDescription,
    AboutBilingualText? description,
  }) =>
      AboutSection(
        iconUrl: iconUrl ?? this.iconUrl,
        svgUrl: svgUrl ?? this.svgUrl,
        subDescription: subDescription ?? this.subDescription,
        description: description ?? this.description,
      );
}

// ── About Us Main model ───────────────────────────────────────────────────────

class AboutPageModel {
  final String publishStatus;
  final AboutBilingualText title;
  final AboutNavigationLabel navigationLabel;
  final AboutSection vision;
  final AboutSection mission;
  final List<AboutValueItem> values;

  /// ADDED: tracks the last time this document was saved to Firestore.
  /// Stored as ISO-8601 string in the DB; parsed on load.
  final DateTime? lastUpdatedAt;

  const AboutPageModel({
    this.publishStatus = 'draft',
    this.title = const AboutBilingualText(),
    this.navigationLabel = const AboutNavigationLabel(),
    this.vision = const AboutSection(),
    this.mission = const AboutSection(),
    this.values = const [],
    this.lastUpdatedAt,                          // ← NEW
  });

  factory AboutPageModel.empty() => const AboutPageModel();

  factory AboutPageModel.fromMap(Map<String, dynamic> map) {
    final rawValues = map['values'] as List<dynamic>? ?? [];
    return AboutPageModel(
      publishStatus: (map['publishStatus'] as String?) ?? 'draft',
      title: AboutBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
      navigationLabel: AboutNavigationLabel.fromMap(
          map['navigationLabel'] as Map<String, dynamic>?),
      vision: AboutSection.fromMap(map['vision'] as Map<String, dynamic>?),
      mission: AboutSection.fromMap(map['mission'] as Map<String, dynamic>?),
      values: rawValues
          .map((e) => AboutValueItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      // ← NEW: parse from stored ISO-8601 string, null-safe
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.tryParse(map['lastUpdatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'title': title.toMap(),
    'navigationLabel': navigationLabel.toMap(),
    'vision': vision.toMap(),
    'mission': mission.toMap(),
    'values': values.map((v) => v.toMap()).toList(),
    // ← NEW: always write current timestamp on every save
    'lastUpdatedAt': DateTime.now().toIso8601String(),
  };

  AboutPageModel copyWith({
    String? publishStatus,
    AboutBilingualText? title,
    AboutNavigationLabel? navigationLabel,
    AboutSection? vision,
    AboutSection? mission,
    List<AboutValueItem>? values,
    DateTime? lastUpdatedAt,                     // ← NEW
  }) =>
      AboutPageModel(
        publishStatus: publishStatus ?? this.publishStatus,
        title: title ?? this.title,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        vision: vision ?? this.vision,
        mission: mission ?? this.mission,
        values: values ?? this.values,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,  // ← NEW
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY MODEL
// ═══════════════════════════════════════════════════════════════════════════════

/// A single section inside Our Strategy (e.g. "Vision" accordion item)
class StrategySection {
  final String svgUrl;
  final AboutBilingualText description;

  const StrategySection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
  });

  factory StrategySection.empty() => const StrategySection();

  factory StrategySection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StrategySection();
    return StrategySection(
      svgUrl: (map['svgUrl'] as String?) ?? '',
      description: AboutBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'description': description.toMap(),
  };

  StrategySection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
  }) =>
      StrategySection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
      );
}

class OurStrategyModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final StrategySection vision;
  final String strategicHouseEnUrl;
  final String strategicHouseArUrl;
  final DateTime? lastUpdatedAt;          // ← ADD

  const OurStrategyModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.vision = const StrategySection(),
    this.strategicHouseEnUrl = '',
    this.strategicHouseArUrl = '',
    this.lastUpdatedAt,                   // ← ADD
  });

  factory OurStrategyModel.empty() => const OurStrategyModel();

  factory OurStrategyModel.fromMap(Map<String, dynamic> map) => OurStrategyModel(
    publishStatus: (map['publishStatus'] as String?) ?? 'draft',
    navigationLabel: AboutNavigationLabel.fromMap(
        map['navigationLabel'] as Map<String, dynamic>?),
    vision: StrategySection.fromMap(map['vision'] as Map<String, dynamic>?),
    strategicHouseEnUrl: (map['strategicHouseEnUrl'] as String?) ?? '',
    strategicHouseArUrl: (map['strategicHouseArUrl'] as String?) ?? '',
    // lastUpdatedAt intentionally omitted — injected by repo after Timestamp extraction
  );

  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'navigationLabel': navigationLabel.toMap(),
    'vision': vision.toMap(),
    'strategicHouseEnUrl': strategicHouseEnUrl,
    'strategicHouseArUrl': strategicHouseArUrl,
  };

  OurStrategyModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    StrategySection? vision,
    String? strategicHouseEnUrl,
    String? strategicHouseArUrl,
    DateTime? lastUpdatedAt,              // ← ADD
  }) =>
      OurStrategyModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        vision: vision ?? this.vision,
        strategicHouseEnUrl: strategicHouseEnUrl ?? this.strategicHouseEnUrl,
        strategicHouseArUrl: strategicHouseArUrl ?? this.strategicHouseArUrl,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,   // ← ADD
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE MODEL
// ═══════════════════════════════════════════════════════════════════════════════

/// Holds an SVG, bilingual description, and two optional document URLs
class TermsSection {
  final String svgUrl;
  final AboutBilingualText description;
  final String attachEnUrl;
  final String attachArUrl;

  const TermsSection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
    this.attachEnUrl = '',
    this.attachArUrl = '',
  });

  factory TermsSection.empty() => const TermsSection();

  factory TermsSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TermsSection();
    return TermsSection(
      svgUrl: (map['svgUrl'] as String?) ?? '',
      description: AboutBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
      attachEnUrl: (map['attachEnUrl'] as String?) ?? '',
      attachArUrl: (map['attachArUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'description': description.toMap(),
    'attachEnUrl': attachEnUrl,
    'attachArUrl': attachArUrl,
  };

  TermsSection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
    String? attachEnUrl,
    String? attachArUrl,
  }) =>
      TermsSection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
        attachEnUrl: attachEnUrl ?? this.attachEnUrl,
        attachArUrl: attachArUrl ?? this.attachArUrl,
      );
}

class TermsOfServiceModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final TermsSection termsAndConditions;
  final TermsSection privacyPolicy;
  final DateTime? lastUpdatedAt;          // ← ADD

  const TermsOfServiceModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.termsAndConditions = const TermsSection(),
    this.privacyPolicy = const TermsSection(),
    this.lastUpdatedAt,                   // ← ADD
  });

  factory TermsOfServiceModel.empty() => const TermsOfServiceModel();

  factory TermsOfServiceModel.fromMap(Map<String, dynamic> map) =>
      TermsOfServiceModel(
        publishStatus: (map['publishStatus'] as String?) ?? 'draft',
        navigationLabel: AboutNavigationLabel.fromMap(
            map['navigationLabel'] as Map<String, dynamic>?),
        termsAndConditions: TermsSection.fromMap(
            map['termsAndConditions'] as Map<String, dynamic>?),
        privacyPolicy: TermsSection.fromMap(
            map['privacyPolicy'] as Map<String, dynamic>?),
        // lastUpdatedAt intentionally omitted — injected by repo after Timestamp extraction
      );

  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'navigationLabel': navigationLabel.toMap(),
    'termsAndConditions': termsAndConditions.toMap(),
    'privacyPolicy': privacyPolicy.toMap(),
  };

  TermsOfServiceModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    TermsSection? termsAndConditions,
    TermsSection? privacyPolicy,
    DateTime? lastUpdatedAt,              // ← ADD
  }) =>
      TermsOfServiceModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        termsAndConditions: termsAndConditions ?? this.termsAndConditions,
        privacyPolicy: privacyPolicy ?? this.privacyPolicy,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,   // ← ADD
      );
}

class DocUpload {
  final Uint8List bytes;
  final String fileName;
  const DocUpload({required this.bytes, required this.fileName});
}