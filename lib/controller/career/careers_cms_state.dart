// ******************* FILE INFO *******************
// File Name: careers_cms_state.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/careers_cms_model.dart';

abstract class CareersCmsState {}

/// Before any load has been attempted.
class CareersCmsInitial extends CareersCmsState {}

/// Network / Firestore operation in progress.
class CareersCmsLoading extends CareersCmsState {}

/// Data fetched successfully — read-only views use this.
class CareersCmsLoaded extends CareersCmsState {
  final CareersCmsModel data;
  CareersCmsLoaded(this.data);
}

/// Save completed — carry the freshly-saved model so the UI can refresh.
class CareersCmsSaved extends CareersCmsState {
  final CareersCmsModel data;
  CareersCmsSaved(this.data);
}

/// Any error (fetch or save).
class CareersCmsError extends CareersCmsState {
  final String message;
  final CareersCmsModel? lastData;
  CareersCmsError(this.message, {this.lastData});
}