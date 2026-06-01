// ******************* FILE INFO *******************
// File Name: contact_us_model.dart
// Created by: Amr Mesbah
// Updated: Added new fields (firstName, lastName, preferredLanguage,
//          location, entityName, entityType, entitySize)

class ContactSubmission {
  // ── Firestore field keys ──────────────────────────────────────────────────
  static const String COUNTRY_CODE = 'countryCode';
  static const String EMAIL = 'email';
  static const String ENTITY_NAME = 'entityName';
  static const String ENTITY_SIZE = 'entitySize';
  static const String ENTITY_TYPE = 'entityType';
  static const String FIRST_NAME = 'firstName';
  static const String FULL_NAME = 'fullName';
  static const String LAST_NAME = 'lastName';
  static const String LOCATION = 'location';
  static const String MESSAGE = 'message';
  static const String NOTE = 'note';
  static const String PHONE_NUMBER = 'phoneNumber';
  static const String PREFERRED_LANGUAGE = 'preferredLanguage';
  static const String STATUS = 'status';
  static const String SUBJECT = 'subject';
  static const String SUBMISSION_DATE = 'submissionDate';

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final String preferredLanguage; // 'ar' | 'en' | 'other'
  final String location;          // Country name
  final String entityName;
  final String entityType;        // 'Public Sector' | 'Semi-Government' | etc.
  final String entitySize;        // '1 to 50' | '51 to 150' | etc.
  final String subject;
  final String message;
  final String note;               // admin-editable note
  final String status;             // 'New' | 'Replied' | 'Closed'
  final DateTime submissionDate;

  const ContactSubmission({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
    this.location          = '',
    this.entityName        = '',
    this.entityType        = '',
    this.entitySize        = '',
    required this.subject,
    required this.message,
    this.note              = '',
    this.status            = 'New',
    required this.submissionDate,
  });

  /// Helper to get full name (for display / backward compat)
  String get fullName => '$firstName $lastName'.trim();

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory ContactSubmission.fromMap(String id, Map<String, dynamic> map) {
    // ── Backward compatibility: handle old docs that have 'fullName' ──
    String firstName = (map[FIRST_NAME] as String?) ?? '';
    String lastName  = (map[LAST_NAME]  as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map[FULL_NAME] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    return ContactSubmission(
      id:                id,
      firstName:         firstName,
      lastName:          lastName,
      email:             (map[EMAIL]             as String?) ?? '',
      countryCode:       (map[COUNTRY_CODE]       as String?) ?? '',
      phoneNumber:       (map[PHONE_NUMBER]       as String?) ?? '',
      preferredLanguage: (map[PREFERRED_LANGUAGE] as String?) ?? 'en',
      location:          (map[LOCATION]          as String?) ?? '',
      entityName:        (map[ENTITY_NAME]        as String?) ?? '',
      entityType:        (map[ENTITY_TYPE]        as String?) ?? '',
      entitySize:        (map[ENTITY_SIZE]        as String?) ?? '',
      subject:           (map[SUBJECT]           as String?) ?? '',
      message:           (map[MESSAGE]           as String?) ?? '',
      note:              (map[NOTE]              as String?) ?? '',
      status:            (map[STATUS]            as String?) ?? 'New',
      submissionDate:    map[SUBMISSION_DATE] != null
          ? DateTime.parse(map[SUBMISSION_DATE] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    FIRST_NAME:         firstName,
    LAST_NAME:          lastName,
    FULL_NAME:          fullName, // ← keep for backward compat / easy queries
    EMAIL:             email,
    COUNTRY_CODE:       countryCode,
    PHONE_NUMBER:       phoneNumber,
    PREFERRED_LANGUAGE: preferredLanguage,
    LOCATION:          location,
    ENTITY_NAME:        entityName,
    ENTITY_TYPE:        entityType,
    ENTITY_SIZE:        entitySize,
    SUBJECT:           subject,
    MESSAGE:           message,
    NOTE:              note,
    STATUS:            status,
    SUBMISSION_DATE:    submissionDate.toIso8601String(),
  };

  ContactSubmission copyWith({
    String?   id,
    String?   firstName,
    String?   lastName,
    String?   email,
    String?   countryCode,
    String?   phoneNumber,
    String?   preferredLanguage,
    String?   location,
    String?   entityName,
    String?   entityType,
    String?   entitySize,
    String?   subject,
    String?   message,
    String?   note,
    String?   status,
    DateTime? submissionDate,
  }) =>
      ContactSubmission(
        id:                id                ?? this.id,
        firstName:         firstName         ?? this.firstName,
        lastName:          lastName          ?? this.lastName,
        email:             email             ?? this.email,
        countryCode:       countryCode       ?? this.countryCode,
        phoneNumber:       phoneNumber       ?? this.phoneNumber,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        location:          location          ?? this.location,
        entityName:        entityName        ?? this.entityName,
        entityType:        entityType        ?? this.entityType,
        entitySize:        entitySize        ?? this.entitySize,
        subject:           subject           ?? this.subject,
        message:           message           ?? this.message,
        note:              note              ?? this.note,
        status:            status            ?? this.status,
        submissionDate:    submissionDate    ?? this.submissionDate,
      );
}