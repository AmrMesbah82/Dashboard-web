// ******************* FILE INFO *******************
// File Name: service_repo.dart
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:web_app_admin/model/services_model.dart';

abstract class ServiceRepository {
  Future<ServicePageModel> fetchServicePage();
  Future<ServicePageModel> fetchServicePageFresh();
  Future<void> saveServicePage(ServicePageModel model);
  Future<String> uploadImage({required Uint8List bytes, required String storagePath});
  Stream<ServicePageModel> watchServicePage();
}