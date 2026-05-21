// ******************* FILE INFO *******************
// File Name: our_teams_repo.dart

import 'dart:typed_data';

import '../../data/models/our_teams_model.dart';

abstract class OurTeamsRepo {
  /// Load the Our Teams section from Firestore.
  Future<OurTeamsModel> load();

  /// Save the Our Teams section to Firestore.
  Future<void> save(OurTeamsModel model);

  /// Upload an icon SVG for a specific team item.
  /// Returns the public download URL.
  Future<String> uploadIcon(String itemId, Uint8List bytes);
}