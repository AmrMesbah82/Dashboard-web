// ******************* FILE INFO *******************
// File Name: repo.dart
// Description: Abstract repository for Home CMS.
//              Supports dual-document architecture:
//              - Published doc  → `cms/home_page`
//              - Draft doc      → `cms/home_page_draft`
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Added draft lifecycle methods (fetch, save, delete, promote) ✅

import 'dart:typed_data';
import 'package:web_app_admin/model/home_model.dart';

abstract class HomeRepository {
  // ── Published document ───────────────────────────────────────────────────
  Future<HomePageModel> fetchHomePage();
  Future<HomePageModel> fetchHomePageFresh();
  Future<void> saveHomePage(HomePageModel model);
  Stream<HomePageModel> watchHomePage();

  // ── Draft document ───────────────────────────────────────────────────────
  /// Fetch the draft version. Returns null if no draft exists.
  Future<HomePageModel?> fetchDraft();

  /// Save form edits as a draft (does NOT touch the published doc).
  Future<void> saveDraft(HomePageModel model);

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