// ******************* FILE INFO *******************
// File Name: contact_us_cms_state.dart
// Created by: Claude Assistant



import '../../data/model/contact_us_model_location.dart';

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