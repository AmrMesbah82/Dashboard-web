// ******************* FILE INFO *******************
// File Name: about_repo.dart
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:web_app_admin/model/about_us.dart';

abstract class AboutRepo {
  // About Us
  Future<AboutPageModel> fetchAboutPage();
  Future<void> saveAboutPage(AboutPageModel model);

  // Our Strategy
  Future<OurStrategyModel> fetchStrategy();
  Future<void> saveStrategy(OurStrategyModel model);

  // Terms of Service
  Future<TermsOfServiceModel> fetchTerms();
  Future<void> saveTerms(TermsOfServiceModel model);

  // Shared upload
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  });

  // Upload document (PDF / any file)
  Future<String> uploadDocument({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
  });
}