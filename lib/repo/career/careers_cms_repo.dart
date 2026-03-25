// ******************* FILE INFO *******************
// File Name: careers_cms_repo.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/careers_cms_model.dart';

abstract class CareersCmsRepo {
  /// Fetch the careers CMS document from Firestore.
  Future<CareersCmsModel> fetch();

  /// Persist the careers CMS document to Firestore.
  Future<void> save(CareersCmsModel model);
}