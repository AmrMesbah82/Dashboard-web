// ******************* FILE INFO *******************
// File Name: contact_state.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/contact_us_model.dart';

abstract class ContactState {}

class ContactInitial  extends ContactState {}
class ContactLoading  extends ContactState {}
class ContactSubmitting extends ContactState {}

/// List page state
class ContactLoaded extends ContactState {
  final List<ContactSubmission> all;
  final List<ContactSubmission> filtered;
  ContactLoaded({required this.all, required this.filtered});
}

/// Single submission loaded (detail page)
class ContactDetailLoaded extends ContactState {
  final ContactSubmission submission;
  ContactDetailLoaded(this.submission);
}

/// After a new contact form submission (public page)
class ContactSubmitted extends ContactState {}

/// After admin saves status / note
class ContactUpdated extends ContactState {
  final ContactSubmission submission;
  ContactUpdated(this.submission);
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
}