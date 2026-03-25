// ******************* FILE INFO *******************
// File Name: contact_us_cms_state.dart
// Created by: Claude Assistant

import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';

abstract class ContactUsCmsState {}

// ── Initial state ─────────────────────────────────────────────────────────

class ContactUsCmsInitial extends ContactUsCmsState {}

// ── Loading state ─────────────────────────────────────────────────────────

class ContactUsCmsLoading extends ContactUsCmsState {}

// ── Loaded state ──────────────────────────────────────────────────────────

class ContactUsCmsLoaded extends ContactUsCmsState {
  final ContactUsCmsModel data;

  ContactUsCmsLoaded(this.data);
}

// ── Saved state ───────────────────────────────────────────────────────────

class ContactUsCmsSaved extends ContactUsCmsState {
  final ContactUsCmsModel data;  // ✅ Added data field

  ContactUsCmsSaved(this.data);
}

// ── Error state ───────────────────────────────────────────────────────────

class ContactUsCmsError extends ContactUsCmsState {
  final String message;

  ContactUsCmsError(this.message);
}