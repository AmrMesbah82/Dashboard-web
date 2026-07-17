// ******************* FILE INFO *******************
// File Name: main_repo.dart
// Description: Abstract repository for the MAIN page CMS (branding/theme,
//              logo, footer columns, social links).
//              Dual-document architecture:
//              - Published doc → `mainPage/main`
//              - Draft doc     → `mainPage/main_draft`
// Created by: Amr Mesbah

import 'dart:typed_data';

import '../../data/models/main_model.dart';

abstract class MainRepository {
  // ── Published document ───────────────────────────────────────────────────
  Future<MainPageModel> fetchMainPage();
  Future<MainPageModel> fetchMainPageFresh();
  Future<void> saveMainPage(MainPageModel model);
  Stream<MainPageModel> watchMainPage();

  // ── Draft document ───────────────────────────────────────────────────────
  /// Fetch the draft version. Returns null if no draft exists.
  Future<MainPageModel?> fetchDraft();

  /// Save form edits as a draft (does NOT touch the published doc).
  Future<void> saveDraft(MainPageModel model);

  /// Delete the draft document (e.g. after publish or discard).
  Future<void> deleteDraft();

  /// Promote draft → published: copies draft into the published doc,
  /// then deletes the draft.
  Future<void> promoteDraft();

  // ── Assets ───────────────────────────────────────────────────────────────
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  });
}
