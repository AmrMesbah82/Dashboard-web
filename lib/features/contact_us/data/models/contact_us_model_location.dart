class ContactUsCmsModel {
  final String publishStatus;
  final ContactBilingualText subDescription;
  final String email;
  final ContactBilingualText followUsTitle;
  final List<ContactSocialIcon> socialIcons;
  final List<ContactOfficeLocation> officeLocations;
  final ContactConfirmMessage confirmMessage;
  final DateTime? lastUpdatedAt;

  ContactUsCmsModel({
    required this.publishStatus,
    required this.subDescription,
    required this.email,
    required this.followUsTitle,
    required this.socialIcons,
    required this.officeLocations,
    required this.confirmMessage,
    this.lastUpdatedAt,
  });

  factory ContactUsCmsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsCmsModel(
      publishStatus: json['publishStatus'] ?? 'draft',
      subDescription: ContactBilingualText.fromJson(json['subDescription'] ?? {'en': '', 'ar': ''}),
      email: json['email'] ?? '',
      followUsTitle: ContactBilingualText.fromJson(json['followUsTitle'] ?? {'en': '', 'ar': ''}),
      socialIcons: (json['socialIcons'] as List<dynamic>?)?.map((e) => ContactSocialIcon.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      officeLocations: (json['officeLocations'] as List<dynamic>?)?.map((e) => ContactOfficeLocation.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      confirmMessage: ContactConfirmMessage.fromJson(json['confirmMessage'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publishStatus': publishStatus,
      'subDescription': subDescription.toJson(),
      'email': email,
      'followUsTitle': followUsTitle.toJson(),
      'socialIcons': socialIcons.map((e) => e.toJson()).toList(),
      'officeLocations': officeLocations.map((e) => e.toJson()).toList(),
      'confirmMessage': confirmMessage.toJson(),
    };
  }

  /// Nested template for [FlatCodec.decode] (one populated sample per list).
  static Map<String, dynamic> get flatTemplate => {
        'publishStatus': '',
        'subDescription': {'en': '', 'ar': ''},
        'email': '',
        'followUsTitle': {'en': '', 'ar': ''},
        'socialIcons': [
          {'id': '', 'iconUrl': '', 'link': ''}
        ],
        'officeLocations': [
          {
            'id': '',
            'iconUrl': '',
            'locationName': {'en': '', 'ar': ''},
            'text1': {'en': '', 'ar': ''},
            'text2': {'en': '', 'ar': ''},
            'mapLink': '',
          }
        ],
        'confirmMessage': {
          'svgUrl': '',
          'title': {'en': '', 'ar': ''},
          'description': {'en': '', 'ar': ''},
        },
      };

  ContactUsCmsModel copyWith({
    String? publishStatus,
    ContactBilingualText? subDescription,
    String? email,
    ContactBilingualText? followUsTitle,
    List<ContactSocialIcon>? socialIcons,
    List<ContactOfficeLocation>? officeLocations,
    ContactConfirmMessage? confirmMessage,
    DateTime? lastUpdatedAt,
  }) {
    return ContactUsCmsModel(
      publishStatus: publishStatus ?? this.publishStatus,
      subDescription: subDescription ?? this.subDescription,
      email: email ?? this.email,
      followUsTitle: followUsTitle ?? this.followUsTitle,
      socialIcons: socialIcons ?? this.socialIcons,
      officeLocations: officeLocations ?? this.officeLocations,
      confirmMessage: confirmMessage ?? this.confirmMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

class ContactBilingualText {
  final String en;
  final String ar;
  ContactBilingualText({required this.en, required this.ar});
  factory ContactBilingualText.fromJson(Map<String, dynamic> json) => ContactBilingualText(en: json['en'] ?? '', ar: json['ar'] ?? '');
  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};
  ContactBilingualText copyWith({String? en, String? ar}) => ContactBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

class ContactSocialIcon {
  final String id;
  final String iconUrl;
  final String link;
  ContactSocialIcon({required this.id, required this.iconUrl, required this.link});
  factory ContactSocialIcon.fromJson(Map<String, dynamic> json) => ContactSocialIcon(id: json['id'] ?? '', iconUrl: json['iconUrl'] ?? '', link: json['link'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'iconUrl': iconUrl, 'link': link};
  ContactSocialIcon copyWith({String? id, String? iconUrl, String? link}) => ContactSocialIcon(id: id ?? this.id, iconUrl: iconUrl ?? this.iconUrl, link: link ?? this.link);
}

class ContactOfficeLocation {
  final String id;
  final String iconUrl;
  final ContactBilingualText locationName;
  final ContactBilingualText text1;
  final ContactBilingualText text2;
  final String mapLink;
  ContactOfficeLocation({required this.id, required this.iconUrl, required this.locationName, required this.text1, required this.text2, this.mapLink = ''});
  factory ContactOfficeLocation.fromJson(Map<String, dynamic> json) => ContactOfficeLocation(id: json['id'] ?? '', iconUrl: json['iconUrl'] ?? '', locationName: ContactBilingualText.fromJson(json['locationName'] ?? {'en': '', 'ar': ''}), text1: ContactBilingualText.fromJson(json['text1'] ?? {'en': '', 'ar': ''}), text2: ContactBilingualText.fromJson(json['text2'] ?? {'en': '', 'ar': ''}), mapLink: json['mapLink'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'iconUrl': iconUrl, 'locationName': locationName.toJson(), 'text1': text1.toJson(), 'text2': text2.toJson(), 'mapLink': mapLink};
  ContactOfficeLocation copyWith({String? id, String? iconUrl, ContactBilingualText? locationName, ContactBilingualText? text1, ContactBilingualText? text2, String? mapLink}) => ContactOfficeLocation(id: id ?? this.id, iconUrl: iconUrl ?? this.iconUrl, locationName: locationName ?? this.locationName, text1: text1 ?? this.text1, text2: text2 ?? this.text2, mapLink: mapLink ?? this.mapLink);
}

class ContactConfirmMessage {
  final String svgUrl;
  final ContactBilingualText title;
  final ContactBilingualText description;
  ContactConfirmMessage({required this.svgUrl, required this.title, required this.description});
  factory ContactConfirmMessage.fromJson(Map<String, dynamic> json) => ContactConfirmMessage(svgUrl: json['svgUrl'] ?? '', title: ContactBilingualText.fromJson(json['title'] ?? {'en': '', 'ar': ''}), description: ContactBilingualText.fromJson(json['description'] ?? {'en': '', 'ar': ''}));
  Map<String, dynamic> toJson() => {'svgUrl': svgUrl, 'title': title.toJson(), 'description': description.toJson()};
  ContactConfirmMessage copyWith({String? svgUrl, ContactBilingualText? title, ContactBilingualText? description}) => ContactConfirmMessage(svgUrl: svgUrl ?? this.svgUrl, title: title ?? this.title, description: description ?? this.description);
}