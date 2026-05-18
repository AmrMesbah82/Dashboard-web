// ******************* FILE INFO *******************
// File Name: contact_us_model.dart
// Created by: Amr Mesbah
// Updated: Added new fields (firstName, lastName, preferredLanguage,
//          location, entityName, entityType, entitySize)

class ContactSubmission {
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
    String firstName = (map['firstName'] as String?) ?? '';
    String lastName  = (map['lastName']  as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map['fullName'] as String?) ?? '';
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
      email:             (map['email']             as String?) ?? '',
      countryCode:       (map['countryCode']       as String?) ?? '',
      phoneNumber:       (map['phoneNumber']       as String?) ?? '',
      preferredLanguage: (map['preferredLanguage'] as String?) ?? 'en',
      location:          (map['location']          as String?) ?? '',
      entityName:        (map['entityName']        as String?) ?? '',
      entityType:        (map['entityType']        as String?) ?? '',
      entitySize:        (map['entitySize']        as String?) ?? '',
      subject:           (map['subject']           as String?) ?? '',
      message:           (map['message']           as String?) ?? '',
      note:              (map['note']              as String?) ?? '',
      status:            (map['status']            as String?) ?? 'New',
      submissionDate:    map['submissionDate'] != null
          ? DateTime.parse(map['submissionDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName':         firstName,
    'lastName':          lastName,
    'fullName':          fullName, // ← keep for backward compat / easy queries
    'email':             email,
    'countryCode':       countryCode,
    'phoneNumber':       phoneNumber,
    'preferredLanguage': preferredLanguage,
    'location':          location,
    'entityName':        entityName,
    'entityType':        entityType,
    'entitySize':        entitySize,
    'subject':           subject,
    'message':           message,
    'note':              note,
    'status':            status,
    'submissionDate':    submissionDate.toIso8601String(),
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