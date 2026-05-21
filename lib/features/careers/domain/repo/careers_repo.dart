// ******************* FILE INFO *******************
// File Name: careers_repo.dart
// Created by: Amr Mesbah


import '../../data/models/careers_model.dart';

abstract class CareersCmsRepo {
  /// Fetch the careers CMS document from Firestore.
  Future<CareersCmsModel> fetch();

  /// Persist the careers CMS document to Firestore.
  Future<void> save(CareersCmsModel model);
}