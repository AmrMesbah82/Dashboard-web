// ******************* FILE INFO *******************
// File Name: repo.dart
// Description: Abstract repository contract for Home CMS.
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:web_app_admin/model/home_model.dart';

abstract class HomeRepository {
  /// Fetch from Firestore (may use local cache).
  Future<HomePageModel> fetchHomePage();

  /// Fetch directly from Firestore server — bypasses local IndexedDB cache.
  /// Always use this after a save() to guarantee reading the written data.
  Future<HomePageModel> fetchHomePageFresh();

  /// Persist [model] to Firestore.
  Future<void> saveHomePage(HomePageModel model);

  /// Upload raw image [bytes] to Firebase Storage under [storagePath]
  /// and return the public HTTPS download URL.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  });

  /// Real-time stream of updates (used for live preview sync).
  Stream<HomePageModel> watchHomePage();
}