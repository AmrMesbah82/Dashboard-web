// ******************* FILE INFO *******************
// File Name: home_page_model.dart
// Description: Pure data model for the Home CMS.
//              No packages — only dart:core types.
// Created by: Amr Mesbah
// FIXED: NavButtonModel now has status field to control navbar visibility
// FIXED: SocialLinkModel now has visibility field to control footer display

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
// Nav Button — WITH STATUS FIELD
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

class SectionCardModel {
  final String imageUrl;
  final String iconUrl;
  final String textBoxColor;
  final BiText description;

  const SectionCardModel({
    this.imageUrl     = '',
    this.iconUrl      = '',
    this.textBoxColor = '#008037',
    this.description  = const BiText(),
  });

  SectionCardModel copyWith({
    String? imageUrl,
    String? iconUrl,
    String? textBoxColor,
    BiText? description,
  }) =>
      SectionCardModel(
        imageUrl:     imageUrl     ?? this.imageUrl,
        iconUrl:      iconUrl      ?? this.iconUrl,
        textBoxColor: textBoxColor ?? this.textBoxColor,
        description:  description  ?? this.description,
      );

  Map<String, dynamic> toMap() => {
    'imageUrl':     imageUrl,
    'iconUrl':      iconUrl,
    'textBoxColor': textBoxColor,
    'description':  description.toMap(),
  };

  factory SectionCardModel.fromMap(Map<String, dynamic> map) => SectionCardModel(
    imageUrl:     map['imageUrl']     ?? '',
    iconUrl:      map['iconUrl']      ?? '',
    textBoxColor: map['textBoxColor'] ?? '#008037',
    description:  BiText.fromMap(map['description'] ?? {}),
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
// Social Link — WITH VISIBILITY FIELD ✅
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
  final String englishFont;
  final String arabicFont;

  const BrandingModel({
    this.logoUrl           = '',
    this.primaryColor      = '#008037',
    this.secondaryColor    = '#D9D9D9',
    this.backgroundColor   = '#D9D9D9',
    this.headerFooterColor = '#D9D9D9',
    this.englishFont       = 'Cairo',
    this.arabicFont        = 'Cairo',
  });

  BrandingModel copyWith({
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    String? headerFooterColor,
    String? englishFont,
    String? arabicFont,
  }) =>
      BrandingModel(
        logoUrl:           logoUrl           ?? this.logoUrl,
        primaryColor:      primaryColor      ?? this.primaryColor,
        secondaryColor:    secondaryColor    ?? this.secondaryColor,
        backgroundColor:   backgroundColor   ?? this.backgroundColor,
        headerFooterColor: headerFooterColor ?? this.headerFooterColor,
        englishFont:       englishFont       ?? this.englishFont,
        arabicFont:        arabicFont        ?? this.arabicFont,
      );

  Map<String, dynamic> toMap() => {
    'logoUrl':           logoUrl,
    'primaryColor':      primaryColor,
    'secondaryColor':    secondaryColor,
    'backgroundColor':   backgroundColor,
    'headerFooterColor': headerFooterColor,
    'englishFont':       englishFont,
    'arabicFont':        arabicFont,
  };

  factory BrandingModel.fromMap(Map<String, dynamic> map) => BrandingModel(
    logoUrl:           map['logoUrl']           ?? '',
    primaryColor:      map['primaryColor']      ?? '#008037',
    secondaryColor:    map['secondaryColor']    ?? '#D9D9D9',
    backgroundColor:   map['backgroundColor']   ?? '#D9D9D9',
    headerFooterColor: map['headerFooterColor'] ?? '#D9D9D9',
    englishFont:       map['englishFont']       ?? 'Cairo',
    arabicFont:        map['arabicFont']        ?? 'Cairo',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT — HomePageModel
// ─────────────────────────────────────────────────────────────────────────────

class HomePageModel {
  final BiText                  title;
  final BiText                  shortDescription;
  final List<NavButtonModel>    navButtons;
  final List<SectionCardModel>  sections;
  final List<HeaderItemModel>   headerItems;
  final List<FooterColumnModel> footerColumns;
  final List<SocialLinkModel>   socialLinks;
  final BrandingModel           branding;
  final String                  publishStatus;
  final DateTime?               lastUpdatedAt;

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
  }) =>
      HomePageModel(
        title:            title            ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        navButtons:       navButtons       ?? this.navButtons,
        sections:         sections         ?? this.sections,
        headerItems:      headerItems      ?? this.headerItems,
        footerColumns:    footerColumns    ?? this.footerColumns,
        socialLinks:      socialLinks      ?? this.socialLinks,
        branding:         branding         ?? this.branding,
        publishStatus:    publishStatus    ?? this.publishStatus,
        lastUpdatedAt:    lastUpdatedAt    ?? this.lastUpdatedAt,
      );

  Map<String, dynamic> toMap() => {
    'title':            title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'navButtons':       navButtons.map((e) => e.toMap()).toList(),
    'sections':         sections.map((e) => e.toMap()).toList(),
    'headerItems':      headerItems.map((e) => e.toMap()).toList(),
    'footerColumns':    footerColumns.map((e) => e.toMap()).toList(),
    'socialLinks':      socialLinks.map((e) => e.toMap()).toList(),
    'branding':         branding.toMap(),
    'publishStatus':    publishStatus,
    'lastUpdatedAt':    lastUpdatedAt?.toIso8601String(),
  };

  factory HomePageModel.fromMap(Map<String, dynamic> map) => HomePageModel(
    title:            BiText.fromMap(map['title'] ?? {}),
    shortDescription: BiText.fromMap(map['shortDescription'] ?? {}),
    navButtons: (map['navButtons'] as List<dynamic>? ?? [])
        .map((e) => NavButtonModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    sections: (map['sections'] as List<dynamic>? ?? [])
        .map((e) => SectionCardModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    headerItems: (map['headerItems'] as List<dynamic>? ?? [])
        .map((e) => HeaderItemModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    footerColumns: (map['footerColumns'] as List<dynamic>? ?? [])
        .map((e) => FooterColumnModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    socialLinks: (map['socialLinks'] as List<dynamic>? ?? [])
        .map((e) => SocialLinkModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    branding:      BrandingModel.fromMap(map['branding'] ?? {}),
    publishStatus: map['publishStatus'] ?? 'draft',
    lastUpdatedAt: _parseDateTime(map['lastUpdatedAt']),
  );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value.runtimeType.toString().contains('Timestamp')) {
      try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    }
    if (value is String) return DateTime.tryParse(value);
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
    branding:      const BrandingModel(),
    publishStatus: 'draft',
    lastUpdatedAt: null,
  );
}