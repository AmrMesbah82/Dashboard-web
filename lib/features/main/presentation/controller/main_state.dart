// ******************* FILE INFO *******************
// File Name: main_state.dart
// Description: States for MainCmsCubit (branding/footer/social — MAIN data).
//              Mirrors the Home CMS dual-document states.
// Created by: Amr Mesbah

import '../../data/models/main_model.dart';

abstract class MainCmsState {}

class MainCmsInitial extends MainCmsState {}

class MainCmsLoading extends MainCmsState {}

/// Loaded state — carries the data being edited AND whether it came from a draft.
class MainCmsLoaded extends MainCmsState {
  final MainPageModel data;

  /// true  → the data was loaded from the `_draft` document
  /// false → the data was loaded from the published document
  final bool isFromDraft;

  MainCmsLoaded(this.data, {this.isFromDraft = false});
}

class MainCmsSaving extends MainCmsState {
  final MainPageModel data;
  MainCmsSaving(this.data);
}

/// Published successfully.
class MainCmsSaved extends MainCmsState {
  final MainPageModel data;
  MainCmsSaved(this.data);
}

/// Draft saved successfully — published doc was NOT touched.
class MainCmsDraftSaved extends MainCmsState {
  final MainPageModel data;
  MainCmsDraftSaved(this.data);
}

/// Draft deleted (e.g. user chose Discard while editing a draft).
class MainCmsDraftDeleted extends MainCmsState {}

class MainCmsError extends MainCmsState {
  final String message;
  final MainPageModel? lastData;
  MainCmsError(this.message, [this.lastData]);
}
