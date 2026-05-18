// ******************* FILE INFO *******************
// File Name: careers_section_repo.dart
// Abstract repository for Why Join Our Team / Our Interns / Our Teams

import 'dart:typed_data';

import '../../data/model/careers_section_model.dart';

abstract class CareersSectionRepo {
  /// Load all items for a given section key
  Future<CareersSectionModel> load(String sectionKey);

  /// Save the full section (items list + lastUpdated)
  Future<void> save(CareersSectionModel model);

  /// Upload an SVG icon and return the download URL
  Future<String> uploadIcon(String sectionKey, String itemId, Uint8List bytes);

  /// Upload an SVG image and return the download URL
  Future<String> uploadSvg(String sectionKey, String itemId, Uint8List bytes);
}