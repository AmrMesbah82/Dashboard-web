// ═══════════════════════════════════════════════════════════════════
// FILE 1: inquiry_model.dart (UPDATED)
// Path: lib/model/inquiry_model.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:web_app_admin/model/contact_us_model.dart';

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

  Color get color {
    switch (this) {
      case InquiryStatus.newInquiry:
        return const Color(0xFF008037);
      case InquiryStatus.replied:
        return const Color(0xFFFF9800);
      case InquiryStatus.closed:
        return const Color(0xFFE53935);
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
    String firstName = (map['firstName'] as String?) ?? '';
    String lastName = (map['lastName'] as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map['fullName'] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    return InquiryModel(
      id: id,
      preferredLanguage: (map['preferredLanguage'] as String?) ?? 'en',
      firstName: firstName,
      lastName: lastName,
      email: (map['email'] as String?) ?? '',
      countryCode: (map['countryCode'] as String?) ?? '',
      phone: (map['phoneNumber'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      entityName: (map['entityName'] as String?) ?? '',
      entityType: (map['entityType'] as String?) ?? '',
      entitySize: (map['entitySize'] as String?) ?? '',
      subject: (map['subject'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      note: (map['note'] as String?) ?? '',
      status: InquiryStatus.fromString((map['status'] as String?) ?? 'New'),
      submissionDate: map['submissionDate'] != null
          ? DateTime.parse(map['submissionDate'] as String)
          : null,
    );
  }

  // ── To Firestore Map ────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'email': email,
    'countryCode': countryCode,
    'phoneNumber': phone,
    'preferredLanguage': preferredLanguage,
    'location': location,
    'entityName': entityName,
    'entityType': entityType,
    'entitySize': entitySize,
    'subject': subject,
    'message': message,
    'note': note,
    'status': status.label,
    'submissionDate': submissionDate?.toIso8601String(),
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