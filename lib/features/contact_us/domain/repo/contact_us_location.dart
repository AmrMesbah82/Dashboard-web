// ******************* FILE INFO *******************
// File Name: contact_us_cms_repo.dart
// Created by: Claude Assistant

import 'dart:typed_data';


import '../../data/model/contact_us_model_location.dart';

abstract class ContactUsCmsRepo {
  /// Load the current Contact Us CMS data
  Future<ContactUsCmsModel> load();

  /// Save Contact Us CMS data with optional image uploads
  ///
  /// [model] - The contact us data model
  /// [imageUploads] - Map of path keys to image bytes for upload
  ///   Example keys:
  ///   - 'contact_cms/social_icons/{id}/icon'
  ///   - 'contact_cms/office_locations/{id}/icon'
  ///   - 'contact_cms/confirm_message/svg'
  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  });
}