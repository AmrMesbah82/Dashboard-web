// ******************* FILE INFO *******************
// File Name: contact_us_model.dart
// Created by: Claude Assistant
// UPDATED: ContactOfficeLocation now has mapLink field for Google Maps

class ContactUsCmsModel {
  final String publishStatus;
  final ContactBilingualText subDescription;
  final String email;
  final List<ContactSocialIcon> socialIcons;
  final List<ContactOfficeLocation> officeLocations;
  final ContactConfirmMessage confirmMessage;

  ContactUsCmsModel({
    required this.publishStatus,
    required this.subDescription,
    required this.email,
    required this.socialIcons,
    required this.officeLocations,
    required this.confirmMessage,
  });

  factory ContactUsCmsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsCmsModel(
      publishStatus: json['publishStatus'] ?? 'draft',
      subDescription: ContactBilingualText.fromJson(
        json['subDescription'] ?? {'en': '', 'ar': ''},
      ),
      email: json['email'] ?? '',
      socialIcons: (json['socialIcons'] as List<dynamic>?)
          ?.map((e) => ContactSocialIcon.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      officeLocations: (json['officeLocations'] as List<dynamic>?)
          ?.map((e) => ContactOfficeLocation.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      confirmMessage: ContactConfirmMessage.fromJson(
        json['confirmMessage'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publishStatus': publishStatus,
      'subDescription': subDescription.toJson(),
      'email': email,
      'socialIcons': socialIcons.map((e) => e.toJson()).toList(),
      'officeLocations': officeLocations.map((e) => e.toJson()).toList(),
      'confirmMessage': confirmMessage.toJson(),
    };
  }

  ContactUsCmsModel copyWith({
    String? publishStatus,
    ContactBilingualText? subDescription,
    String? email,
    List<ContactSocialIcon>? socialIcons,
    List<ContactOfficeLocation>? officeLocations,
    ContactConfirmMessage? confirmMessage,
  }) {
    return ContactUsCmsModel(
      publishStatus: publishStatus ?? this.publishStatus,
      subDescription: subDescription ?? this.subDescription,
      email: email ?? this.email,
      socialIcons: socialIcons ?? this.socialIcons,
      officeLocations: officeLocations ?? this.officeLocations,
      confirmMessage: confirmMessage ?? this.confirmMessage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Bilingual Text
// ═══════════════════════════════════════════════════════════════════════════

class ContactBilingualText {
  final String en;
  final String ar;

  ContactBilingualText({required this.en, required this.ar});

  factory ContactBilingualText.fromJson(Map<String, dynamic> json) {
    return ContactBilingualText(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};

  ContactBilingualText copyWith({String? en, String? ar}) {
    return ContactBilingualText(
      en: en ?? this.en,
      ar: ar ?? this.ar,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Social Icon
// ═══════════════════════════════════════════════════════════════════════════

class ContactSocialIcon {
  final String id;
  final String iconUrl;
  final String link;

  ContactSocialIcon({
    required this.id,
    required this.iconUrl,
    required this.link,
  });

  factory ContactSocialIcon.fromJson(Map<String, dynamic> json) {
    return ContactSocialIcon(
      id:      json['id']      ?? '',
      iconUrl: json['iconUrl'] ?? '',
      link:    json['link']    ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':      id,
    'iconUrl': iconUrl,
    'link':    link,
  };

  ContactSocialIcon copyWith({String? id, String? iconUrl, String? link}) {
    return ContactSocialIcon(
      id:      id      ?? this.id,
      iconUrl: iconUrl ?? this.iconUrl,
      link:    link    ?? this.link,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Office Location  ── NEW: mapLink field
// ═══════════════════════════════════════════════════════════════════════════

class ContactOfficeLocation {
  final String id;
  final String iconUrl;
  final ContactBilingualText locationName;
  final ContactBilingualText text1;
  final ContactBilingualText text2;

  /// Google Maps URL or any link opened when the card is tapped.
  /// e.g. "https://maps.google.com/?q=30.0444,31.2357"
  final String mapLink;

  ContactOfficeLocation({
    required this.id,
    required this.iconUrl,
    required this.locationName,
    required this.text1,
    required this.text2,
    this.mapLink = '',
  });

  factory ContactOfficeLocation.fromJson(Map<String, dynamic> json) {
    return ContactOfficeLocation(
      id:           json['id']      ?? '',
      iconUrl:      json['iconUrl'] ?? '',
      locationName: ContactBilingualText.fromJson(
          json['locationName'] ?? {'en': '', 'ar': ''}),
      text1: ContactBilingualText.fromJson(
          json['text1'] ?? {'en': '', 'ar': ''}),
      text2: ContactBilingualText.fromJson(
          json['text2'] ?? {'en': '', 'ar': ''}),
      mapLink: json['mapLink'] ?? '', // ✅ new — old docs default to ''
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'iconUrl':      iconUrl,
    'locationName': locationName.toJson(),
    'text1':        text1.toJson(),
    'text2':        text2.toJson(),
    'mapLink':      mapLink,           // ✅ persisted
  };

  ContactOfficeLocation copyWith({
    String? id,
    String? iconUrl,
    ContactBilingualText? locationName,
    ContactBilingualText? text1,
    ContactBilingualText? text2,
    String? mapLink,
  }) {
    return ContactOfficeLocation(
      id:           id           ?? this.id,
      iconUrl:      iconUrl      ?? this.iconUrl,
      locationName: locationName ?? this.locationName,
      text1:        text1        ?? this.text1,
      text2:        text2        ?? this.text2,
      mapLink:      mapLink      ?? this.mapLink,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confirm Message
// ═══════════════════════════════════════════════════════════════════════════

class ContactConfirmMessage {
  final String svgUrl;
  final ContactBilingualText title;
  final ContactBilingualText description;

  ContactConfirmMessage({
    required this.svgUrl,
    required this.title,
    required this.description,
  });

  factory ContactConfirmMessage.fromJson(Map<String, dynamic> json) {
    return ContactConfirmMessage(
      svgUrl: json['svgUrl'] ?? '',
      title: ContactBilingualText.fromJson(
          json['title'] ?? {'en': '', 'ar': ''}),
      description: ContactBilingualText.fromJson(
          json['description'] ?? {'en': '', 'ar': ''}),
    );
  }

  Map<String, dynamic> toJson() => {
    'svgUrl':      svgUrl,
    'title':       title.toJson(),
    'description': description.toJson(),
  };

  ContactConfirmMessage copyWith({
    String? svgUrl,
    ContactBilingualText? title,
    ContactBilingualText? description,
  }) {
    return ContactConfirmMessage(
      svgUrl:      svgUrl      ?? this.svgUrl,
      title:       title       ?? this.title,
      description: description ?? this.description,
    );
  }
}