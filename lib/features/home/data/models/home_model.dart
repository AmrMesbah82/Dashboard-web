// ******************* FILE INFO *******************
// File Name: home_page_model.dart
// Description: Pure data model for the Home CMS.
//              No packages — only dart:core types.
// Created by: Amr Mesbah
// FIXED: NavButtonModel now has status field to control navbar visibility
// FIXED: SocialLinkModel now has visibility field to control footer display
// ADDED: scheduledPublishDate field on HomePageModel for publish scheduling

/// Bilingual text wrapper
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  factory BiText.fromMap(Map<String, dynamic> map) =>
      BiText(en: map['en'] ?? '', ar: map['ar'] ?? '');

  @override
  String toString() => 'BiText(en: $en, ar: $ar)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button — WITH 'status' FIELD
// ─────────────────────────────────────────────────────────────────────────────

class NavButtonModel {
  final String id;
  final BiText name;
  final String route;
  final bool   status; // controls visibility in navbar

  const NavButtonModel({
    required this.id,
    this.name   = const BiText(),
    this.route  = '',
    this.status = true,
  });

  NavButtonModel copyWith({String? id, BiText? name, String? route, bool? status}) =>
      NavButtonModel(
        id:     id     ?? this.id,
        name:   name   ?? this.name,
        route:  route  ?? this.route,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
    'id':     id,
    'name':   name.toMap(),
    'route':  route,
    'status': status,
  };

  factory NavButtonModel.fromMap(Map<String, dynamic> map) => NavButtonModel(
    id:     map['id']     ?? '',
    name:   BiText.fromMap(map['name'] ?? {}),
    route:  map['route']  ?? '',
    status: map['status'] ?? true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card (1–4)
// ─────────────────────────────────────────────────────────────────────────────

/// Fixed layout position for each of the 4 home Section cards.
/// Index 0 → left, 1 → leftCorner, 2 → right, 3 → rightCorner.
const List<String> kSectionPositions = ['left', 'leftCorner', 'right', 'rightCorner'];

/// Human-readable labels for [kSectionPositions] (same order).
const List<String> kSectionPositionLabels = ['Left', 'Left Corner', 'Right', 'Right Corner'];

class SectionCardModel {
  final String imageUrl;
  final String iconUrl;
  final String position; // ✅ left | leftCorner | right | rightCorner
  final String textBoxColor;
  final BiText description;
  final bool   visibility; // ✅ controls whether section shows on public site

  const SectionCardModel({
    this.imageUrl     = '',
    this.iconUrl      = '',
    this.position     = 'left', // ✅ default to first position
    this.textBoxColor = '#008037',
    this.description  = const BiText(),
    this.visibility   = true, // ✅ default visible
  });

  SectionCardModel copyWith({
    String? imageUrl,
    String? iconUrl,
    String? position, // ✅
    String? textBoxColor,
    BiText? description,
    bool?   visibility, // ✅
  }) =>
      SectionCardModel(
        imageUrl:     imageUrl     ?? this.imageUrl,
        iconUrl:      iconUrl      ?? this.iconUrl,
        position:     position     ?? this.position, // ✅
        textBoxColor: textBoxColor ?? this.textBoxColor,
        description:  description  ?? this.description,
        visibility:   visibility   ?? this.visibility, // ✅
      );

  Map<String, dynamic> toMap() => {
    'imageUrl':     imageUrl,
    'iconUrl':      iconUrl,
    'position':     position, // ✅ persisted to Firestore
    'textBoxColor': textBoxColor,
    'description':  description.toMap(),
    'visibility':   visibility, // ✅ persisted to Firestore
  };

  factory SectionCardModel.fromMap(Map<String, dynamic> map) => SectionCardModel(
    imageUrl:     map['imageUrl']     ?? '',
    iconUrl:      map['iconUrl']      ?? '',
    position:     map['position']     ?? 'left', // ✅ old docs default; see fromMap list for slot-based fallback
    textBoxColor: map['textBoxColor'] ?? '#008037',
    description:  BiText.fromMap(map['description'] ?? {}),
    visibility:   map['visibility']   ?? true, // ✅ old docs default to true
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Item
// ─────────────────────────────────────────────────────────────────────────────

class HeaderItemModel {
  final String id;
  final BiText title;
  final bool   status;

  const HeaderItemModel({
    required this.id,
    this.title  = const BiText(),
    this.status = true,
  });

  HeaderItemModel copyWith({String? id, BiText? title, bool? status}) =>
      HeaderItemModel(
        id:     id     ?? this.id,
        title:  title  ?? this.title,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
    'id':     id,
    'title':  title.toMap(),
    'status': status,
  };

  factory HeaderItemModel.fromMap(Map<String, dynamic> map) => HeaderItemModel(
    id:     map['id']     ?? '',
    title:  BiText.fromMap(map['title'] ?? {}),
    status: map['status'] ?? true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer Label Row
// ─────────────────────────────────────────────────────────────────────────────

class FooterLabelModel {
  final String id;
  final BiText label;
  final String route;

  const FooterLabelModel({
    required this.id,
    this.label = const BiText(),
    this.route = '',
  });

  FooterLabelModel copyWith({String? id, BiText? label, String? route}) =>
      FooterLabelModel(
        id:    id    ?? this.id,
        label: label ?? this.label,
        route: route ?? this.route,
      );

  Map<String, dynamic> toMap() => {
    'id':    id,
    'label': label.toMap(),
    'route': route,
  };

  factory FooterLabelModel.fromMap(Map<String, dynamic> map) => FooterLabelModel(
    id:    map['id']    ?? '',
    label: BiText.fromMap(map['label'] ?? {}),
    route: map['route'] ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer Column
// ─────────────────────────────────────────────────────────────────────────────

class FooterColumnModel {
  final String id;
  final BiText title;
  final String route;
  final List<FooterLabelModel> labels;

  const FooterColumnModel({
    required this.id,
    this.title  = const BiText(),
    this.route  = '',
    this.labels = const [],
  });

  FooterColumnModel copyWith({
    String?                  id,
    BiText?                  title,
    String?                  route,
    List<FooterLabelModel>?  labels,
  }) =>
      FooterColumnModel(
        id:     id     ?? this.id,
        title:  title  ?? this.title,
        route:  route  ?? this.route,
        labels: labels ?? this.labels,
      );

  Map<String, dynamic> toMap() => {
    'id':     id,
    'title':  title.toMap(),
    'route':  route,
    'labels': labels.map((l) => l.toMap()).toList(),
  };

  factory FooterColumnModel.fromMap(Map<String, dynamic> map) => FooterColumnModel(
    id:    map['id']    ?? '',
    title: BiText.fromMap(map['title'] ?? {}),
    route: map['route'] ?? '',
    labels: (map['labels'] as List<dynamic>? ?? [])
        .map((l) => FooterLabelModel.fromMap(l as Map<String, dynamic>))
        .toList(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Link — WITH 'visibility' FIELD ✅
// ─────────────────────────────────────────────────────────────────────────────

class SocialLinkModel {
  final String id;
  final String iconUrl;
  final String url;
  final bool   visibility; // ✅ controls whether icon shows in footer

  const SocialLinkModel({
    required this.id,
    this.iconUrl    = '',
    this.url        = '',
    this.visibility = true, // ✅ default visible
  });

  SocialLinkModel copyWith({
    String? id,
    String? iconUrl,
    String? url,
    bool?   visibility, // ✅
  }) =>
      SocialLinkModel(
        id:         id         ?? this.id,
        iconUrl:    iconUrl    ?? this.iconUrl,
        url:        url        ?? this.url,
        visibility: visibility ?? this.visibility, // ✅
      );

  Map<String, dynamic> toMap() => {
    'id':         id,
    'iconUrl':    iconUrl,
    'url':        url,
    'visibility': visibility, // ✅ persisted to Firestore
  };

  factory SocialLinkModel.fromMap(Map<String, dynamic> map) => SocialLinkModel(
    id:         map['id']         ?? '',
    iconUrl:    map['iconUrl']    ?? '',
    url:        map['url']        ?? '',
    visibility: map['visibility'] ?? true, // ✅ old docs default to true
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Branding
// ─────────────────────────────────────────────────────────────────────────────

class BrandingModel {
  final String logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String headerFooterColor;
  final String mainWidgetColor;    // Main Widget Color   ← NEW
  final String englishFont;
  final String arabicFont;

  const BrandingModel({
    this.logoUrl           = '',
    this.primaryColor      = '#008037',
    this.secondaryColor    = '#D9D9D9',
    this.backgroundColor   = '#D9D9D9',
    this.headerFooterColor = '#D9D9D9',
    this.mainWidgetColor   = '#D9D9D9',   // ← NEW
    this.englishFont       = 'Cairo',
    this.arabicFont        = 'Cairo',
  });

  BrandingModel copyWith({
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    String? headerFooterColor,
    String? mainWidgetColor,      // ← NEW
    String? englishFont,
    String? arabicFont,
  }) =>
      BrandingModel(
        logoUrl:           logoUrl           ?? this.logoUrl,
        primaryColor:      primaryColor      ?? this.primaryColor,
        secondaryColor:    secondaryColor    ?? this.secondaryColor,
        backgroundColor:   backgroundColor   ?? this.backgroundColor,
        headerFooterColor: headerFooterColor ?? this.headerFooterColor,
        mainWidgetColor:   mainWidgetColor   ?? this.mainWidgetColor,    // ← NEW
        englishFont:       englishFont       ?? this.englishFont,
        arabicFont:        arabicFont        ?? this.arabicFont,
      );

  Map<String, dynamic> toMap() => {
    'logoUrl':           logoUrl,
    'primaryColor':      primaryColor,
    'secondaryColor':    secondaryColor,
    'backgroundColor':   backgroundColor,
    'headerFooterColor': headerFooterColor,
    'mainWidgetColor':   mainWidgetColor,    // ← NEW
    'englishFont':       englishFont,
    'arabicFont':        arabicFont,
  };

  factory BrandingModel.fromMap(Map<String, dynamic> map) => BrandingModel(
    logoUrl:           map['logoUrl']           ?? '',
    primaryColor:      map['primaryColor']      ?? '#008037',
    secondaryColor:    map['secondaryColor']    ?? '#D9D9D9',
    backgroundColor:   map['backgroundColor']   ?? '#D9D9D9',
    headerFooterColor: map['headerFooterColor'] ?? '#D9D9D9',
    mainWidgetColor:   map['mainWidgetColor']   ?? '#D9D9D9',    // ← NEW
    englishFont:       map['englishFont']       ?? 'Cairo',
    arabicFont:        map['arabicFont']        ?? 'Cairo',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT — HomePageModel
// ─────────────────────────────────────────────────────────────────────────────

class HomePageModel {
  // ── Firestore field keys ──────────────────────────────────────────────────
  static const String AR = 'ar';
  static const String ARABIC_FONT = 'arabicFont';
  static const String BACKGROUND_COLOR = 'backgroundColor';
  static const String BRANDING = 'branding';
  static const String DESCRIPTION = 'description';
  static const String EN = 'en';
  static const String ENGLISH_FONT = 'englishFont';
  static const String FOOTER_COLUMNS = 'footerColumns';
  static const String HEADER_FOOTER_COLOR = 'headerFooterColor';
  static const String HEADER_ITEMS = 'headerItems';
  static const String ICON_URL = 'iconUrl';
  static const String ID = 'id';
  static const String IMAGE_URL = 'imageUrl';
  static const String LABEL = 'label';
  static const String LABELS = 'labels';
  static const String LOGO_URL = 'logoUrl';
  static const String NAME = 'name';
  static const String NAV_BUTTONS = 'navButtons';
  static const String PRIMARY_COLOR = 'primaryColor';
  static const String PUBLISH_STATUS = 'publishStatus';
  static const String ROUTE = 'route';
  static const String SECONDARY_COLOR = 'secondaryColor';
  static const String SECTIONS = 'sections';
  static const String SHORT_DESCRIPTION = 'shortDescription';
  static const String SOCIAL_LINKS = 'socialLinks';
  static const String STATUS = 'status';
  static const String TEXT_BOX_COLOR = 'textBoxColor';
  static const String TITLE = 'title';
  static const String URL = 'url';
  static const String VISIBILITY = 'visibility';

  final BiText                  title;
  final BiText                  shortDescription;
  final List<NavButtonModel>    navButtons;
  final List<SectionCardModel>  sections;
  final List<HeaderItemModel>   headerItems;
  final List<FooterColumnModel> footerColumns;
  final List<SocialLinkModel>   socialLinks;
  final BrandingModel           branding;
  final String                  publishStatus; // 'published' | 'scheduled' | 'draft'
  final DateTime?               lastUpdatedAt;
  final DateTime?               scheduledPublishDate; // ✅ NEW — when to auto-publish

  const HomePageModel({
    this.title            = const BiText(),
    this.shortDescription = const BiText(),
    this.navButtons       = const [],
    this.sections         = const [],
    this.headerItems      = const [],
    this.footerColumns    = const [],
    this.socialLinks      = const [],
    this.branding         = const BrandingModel(),
    this.publishStatus    = 'draft',
    this.lastUpdatedAt,
    this.scheduledPublishDate, // ✅ NEW
  });

  HomePageModel copyWith({
    BiText?                  title,
    BiText?                  shortDescription,
    List<NavButtonModel>?    navButtons,
    List<SectionCardModel>?  sections,
    List<HeaderItemModel>?   headerItems,
    List<FooterColumnModel>? footerColumns,
    List<SocialLinkModel>?   socialLinks,
    BrandingModel?           branding,
    String?                  publishStatus,
    DateTime?                lastUpdatedAt,
    DateTime?                scheduledPublishDate, // ✅ NEW
    // ✅ use this sentinel to explicitly clear the scheduled date
    bool                     clearScheduledPublishDate = false,
  }) =>
      HomePageModel(
        title:                title                ?? this.title,
        shortDescription:     shortDescription     ?? this.shortDescription,
        navButtons:           navButtons           ?? this.navButtons,
        sections:             sections             ?? this.sections,
        headerItems:          headerItems          ?? this.headerItems,
        footerColumns:        footerColumns        ?? this.footerColumns,
        socialLinks:          socialLinks          ?? this.socialLinks,
        branding:             branding             ?? this.branding,
        publishStatus:        publishStatus        ?? this.publishStatus,
        lastUpdatedAt:        lastUpdatedAt        ?? this.lastUpdatedAt,
        scheduledPublishDate: clearScheduledPublishDate
            ? null
            : (scheduledPublishDate ?? this.scheduledPublishDate),
      );

  Map<String, dynamic> toMap() => {
    TITLE:                title.toMap(),
    SHORT_DESCRIPTION:     shortDescription.toMap(),
    NAV_BUTTONS:           navButtons.map((e) => e.toMap()).toList(),
    SECTIONS:             sections.map((e) => e.toMap()).toList(),
    HEADER_ITEMS:          headerItems.map((e) => e.toMap()).toList(),
    FOOTER_COLUMNS:        footerColumns.map((e) => e.toMap()).toList(),
    SOCIAL_LINKS:          socialLinks.map((e) => e.toMap()).toList(),
    BRANDING:             branding.toMap(),
    PUBLISH_STATUS:        publishStatus,
  };

  factory HomePageModel.fromMap(Map<String, dynamic> map) => HomePageModel(
    title:            BiText.fromMap(map[TITLE] ?? {}),
    shortDescription: BiText.fromMap(map[SHORT_DESCRIPTION] ?? {}),
    navButtons: (map[NAV_BUTTONS] as List<dynamic>? ?? [])
        .map((e) => NavButtonModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    sections: (map[SECTIONS] as List<dynamic>? ?? [])
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final section = SectionCardModel.fromMap(entry.value as Map<String, dynamic>);
          // ✅ Each of the 4 slots has a fixed position; fall back to slot index
          //    for old docs that were saved before the position field existed.
          final slotPosition = entry.key < kSectionPositions.length
              ? kSectionPositions[entry.key]
              : 'left';
          return (entry.value as Map).containsKey('position')
              ? section
              : section.copyWith(position: slotPosition);
        })
        .toList(),
    headerItems: (map[HEADER_ITEMS] as List<dynamic>? ?? [])
        .map((e) => HeaderItemModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    footerColumns: (map[FOOTER_COLUMNS] as List<dynamic>? ?? [])
        .map((e) => FooterColumnModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    socialLinks: (map[SOCIAL_LINKS] as List<dynamic>? ?? [])
        .map((e) => SocialLinkModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    branding:             BrandingModel.fromMap(map[BRANDING] ?? {}),
    publishStatus:        map[PUBLISH_STATUS] ?? 'draft',
    lastUpdatedAt:        _parseDateTime(map['lastUpdatedAt']),
    scheduledPublishDate: _parseDateTime(map['scheduledPublishDate']), // ✅ NEW
  );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    try {
      if (value is DateTime) {
        return value;
      }
      final type = value.runtimeType.toString();
      if (type.contains('Timestamp')) {
        final dt = value.toDate() as DateTime;
        return dt;
      }
      if (value is String && value.isNotEmpty) {
        final dt = DateTime.tryParse(value);
        return dt;
      }
      if (value is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(value);
        return dt;
      }
    } catch (e) {
    }
    return null;
  }

  static HomePageModel get defaultModel => HomePageModel(
    title:            const BiText(en: 'Bayanatz', ar: 'بيانتز'),
    shortDescription: const BiText(
      en: "MENA'S Digital Transformation Pioneers",
      ar: 'رواد التحول الرقمي في منطقة الشرق الأوسط وشمال أفريقيا',
    ),
    navButtons: const [
      NavButtonModel(id: 'nb_1', name: BiText(en: 'Home',       ar: 'الرئيسية'), route: '/',         status: true),
      NavButtonModel(id: 'nb_2', name: BiText(en: 'Services',   ar: 'الخدمات'),  route: '/services', status: true),
      NavButtonModel(id: 'nb_3', name: BiText(en: 'About',      ar: 'من نحن'),   route: '/about',    status: true),
      NavButtonModel(id: 'nb_4', name: BiText(en: 'Contact Us', ar: 'اتصل بنا'), route: '/contact',  status: true),
      NavButtonModel(id: 'nb_5', name: BiText(en: 'Careers',    ar: 'الوظائف'),  route: '/careers',  status: true),
    ],
    sections: List.generate(
      4,
          (i) => SectionCardModel(
        position: kSectionPositions[i], // ✅ left | leftCorner | right | rightCorner
        textBoxColor: '#008037',
        description: BiText(
          en: 'Section ${i + 1} description goes here.',
          ar: 'وصف القسم ${i + 1} يأتي هنا.',
        ),
      ),
    ),
    headerItems: List.generate(
      5,
          (i) => HeaderItemModel(
        id: 'hi_$i',
        title: BiText(en: 'Header Title ${i + 1}', ar: 'عنوان ${i + 1}'),
        status: true,
      ),
    ),
    footerColumns: const [
      FooterColumnModel(
        id: 'fc_1',
        title: BiText(en: 'Services', ar: 'الخدمات'),
        route: '/services',
        labels: [
          FooterLabelModel(id: 'fl_1a', label: BiText(en: 'Digital Strategy', ar: 'الاستراتيجية الرقمية')),
          FooterLabelModel(id: 'fl_1b', label: BiText(en: 'Data Analytics',   ar: 'تحليل البيانات')),
        ],
      ),
      FooterColumnModel(
        id: 'fc_2',
        title: BiText(en: 'About Us', ar: 'من نحن'),
        route: '/about',
        labels: [
          FooterLabelModel(id: 'fl_2a', label: BiText(en: 'Mission', ar: 'الرسالة')),
          FooterLabelModel(id: 'fl_2b', label: BiText(en: 'Vision',  ar: 'الرؤية')),
        ],
      ),
      FooterColumnModel(
        id: 'fc_3',
        title: BiText(en: 'Contact Us', ar: 'اتصل بنا'),
        route: '/contact',
        labels: [
          FooterLabelModel(id: 'fl_3a', label: BiText(en: 'Contact Form', ar: 'نموذج التواصل')),
        ],
      ),
    ],
    socialLinks: [
      SocialLinkModel(id: 'sl_0', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_1', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_2', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_3', iconUrl: '', url: '', visibility: true),
    ],
    branding:             const BrandingModel(),
    publishStatus:        'draft',
    lastUpdatedAt:        null,
    scheduledPublishDate: null, // ✅ NEW
  );
}