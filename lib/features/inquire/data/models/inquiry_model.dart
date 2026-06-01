// ═══════════════════════════════════════════════════════════════════
// FILE 1: inquiry_model.dart (UPDATED)
// Path: lib/features/inquire/data/models/inquiry_model.dart
// ═══════════════════════════════════════════════════════════════════

import '../../../contact_us/data/models/contact_us_model.dart';

enum InquiryStatus {
  newInquiry,
  replied,
  closed;

  String get label {
    switch (this) {
      case InquiryStatus.newInquiry:
        return 'New';
      case InquiryStatus.replied:
        return 'Replied';
      case InquiryStatus.closed:
        return 'Closed';
    }
  }

  static InquiryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return InquiryStatus.newInquiry;
      case 'replied':
        return InquiryStatus.replied;
      case 'closed':
        return InquiryStatus.closed;
      default:
        return InquiryStatus.newInquiry;
    }
  }
}

class InquiryModel {
  // ── Firestore field keys ──────────────────────────────────────────────────
  static const String CLOSED = 'closed';
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
  static const String NEW = 'new';
  static const String NOTE = 'note';
  static const String PHONE_NUMBER = 'phoneNumber';
  static const String PREFERRED_LANGUAGE = 'preferredLanguage';
  static const String REPLIED = 'replied';
  static const String STATUS = 'status';
  static const String SUBJECT = 'subject';
  static const String SUBMISSION_DATE = 'submissionDate';

  final String id;
  final String preferredLanguage;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phone;
  final String location;
  final String entityName;
  final String entityType;
  final String entitySize;
  final String subject;
  final String message;
  final String note;
  final InquiryStatus status;
  final DateTime? submissionDate;

  const InquiryModel({
    required this.id,
    required this.preferredLanguage,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.location,
    required this.entityName,
    required this.entityType,
    required this.entitySize,
    required this.subject,
    required this.message,
    required this.note,
    required this.status,
    this.submissionDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  // ── Factory: Create from ContactSubmission ──────────────────────────────
  factory InquiryModel.fromContactSubmission(ContactSubmission contact) {
    return InquiryModel(
      id: contact.id,
      preferredLanguage: contact.preferredLanguage,
      firstName: contact.firstName,
      lastName: contact.lastName,
      email: contact.email,
      countryCode: contact.countryCode,
      phone: contact.phoneNumber,
      location: contact.location,
      entityName: contact.entityName,
      entityType: contact.entityType,
      entitySize: contact.entitySize,
      subject: contact.subject,
      message: contact.message,
      note: contact.note,
      status: InquiryStatus.fromString(contact.status),
      submissionDate: contact.submissionDate,
    );
  }

  // ── Factory: From Firestore Map ─────────────────────────────────────────
  factory InquiryModel.fromMap(String id, Map<String, dynamic> map) {
    // Handle backward compatibility with old 'fullName' field
    String firstName = (map[FIRST_NAME] as String?) ?? '';
    String lastName = (map[LAST_NAME] as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map[FULL_NAME] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    return InquiryModel(
      id: id,
      preferredLanguage: (map[PREFERRED_LANGUAGE] as String?) ?? 'en',
      firstName: firstName,
      lastName: lastName,
      email: (map[EMAIL] as String?) ?? '',
      countryCode: (map[COUNTRY_CODE] as String?) ?? '',
      phone: (map[PHONE_NUMBER] as String?) ?? '',
      location: (map[LOCATION] as String?) ?? '',
      entityName: (map[ENTITY_NAME] as String?) ?? '',
      entityType: (map[ENTITY_TYPE] as String?) ?? '',
      entitySize: (map[ENTITY_SIZE] as String?) ?? '',
      subject: (map[SUBJECT] as String?) ?? '',
      message: (map[MESSAGE] as String?) ?? '',
      note: (map[NOTE] as String?) ?? '',
      status: InquiryStatus.fromString((map[STATUS] as String?) ?? 'New'),
      submissionDate: map[SUBMISSION_DATE] != null
          ? DateTime.parse(map[SUBMISSION_DATE] as String)
          : null,
    );
  }

  // ── To Firestore Map ────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    FIRST_NAME: firstName,
    LAST_NAME: lastName,
    FULL_NAME: fullName,
    EMAIL: email,
    COUNTRY_CODE: countryCode,
    PHONE_NUMBER: phone,
    PREFERRED_LANGUAGE: preferredLanguage,
    LOCATION: location,
    ENTITY_NAME: entityName,
    ENTITY_TYPE: entityType,
    ENTITY_SIZE: entitySize,
    SUBJECT: subject,
    MESSAGE: message,
    NOTE: note,
    STATUS: status.label,
    SUBMISSION_DATE: submissionDate?.toIso8601String(),
  };

  InquiryModel copyWith({
    String? id,
    String? preferredLanguage,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? phone,
    String? location,
    String? entityName,
    String? entityType,
    String? entitySize,
    String? subject,
    String? message,
    String? note,
    InquiryStatus? status,
    DateTime? submissionDate,
  }) =>
      InquiryModel(
        id: id ?? this.id,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        countryCode: countryCode ?? this.countryCode,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        entityName: entityName ?? this.entityName,
        entityType: entityType ?? this.entityType,
        entitySize: entitySize ?? this.entitySize,
        subject: subject ?? this.subject,
        message: message ?? this.message,
        note: note ?? this.note,
        status: status ?? this.status,
        submissionDate: submissionDate ?? this.submissionDate,
      );
}