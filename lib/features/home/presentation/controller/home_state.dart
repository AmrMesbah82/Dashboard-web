// ******************* FILE INFO *******************
// File Name: home_state.dart
// Description: States for HomeCmsCubit.
//              Supports dual-document architecture (published + draft).
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Added isFromDraft flag to HomeCmsLoaded ✅
// UPDATED: Added HomeCmsDraftSaved state ✅
// UPDATED: Added HomeCmsDraftDeleted state ✅


import '../../data/model/home_model.dart';

abstract class HomeCmsState {}

class HomeCmsInitial extends HomeCmsState {}

class HomeCmsLoading extends HomeCmsState {}

/// Loaded state — carries the data being edited AND whether it came from a draft.
class HomeCmsLoaded extends HomeCmsState {
  final HomePageModel data;

  /// true  → the data was loaded from the `_draft` document
  /// false → the data was loaded from the published document
  final bool isFromDraft;

  HomeCmsLoaded(this.data, {this.isFromDraft = false});
}

class HomeCmsSaving extends HomeCmsState {
  final HomePageModel data;
  HomeCmsSaving(this.data);
}

/// Published successfully — draft was saved to the published doc
/// and the draft doc was deleted.
class HomeCmsSaved extends HomeCmsState {
  final HomePageModel data;
  HomeCmsSaved(this.data);
}

/// Draft saved successfully — published doc was NOT touched.
class HomeCmsDraftSaved extends HomeCmsState {
  final HomePageModel data;
  HomeCmsDraftSaved(this.data);
}

/// Draft deleted (e.g. user chose Discard while editing a draft).
class HomeCmsDraftDeleted extends HomeCmsState {}

class HomeCmsError extends HomeCmsState {
  final String message;
  final HomePageModel? lastData;
  HomeCmsError(this.message, [this.lastData]);
}