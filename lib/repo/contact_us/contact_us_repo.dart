// ******************* FILE INFO *******************
// File Name: contact_repo.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/contact_us_model.dart';

abstract class ContactRepo {
  /// Submit a new message from the public Contact page
  Future<void> submitContact(ContactSubmission submission);

  /// Fetch all submissions (admin)
  Future<List<ContactSubmission>> fetchAll();

  /// Update status / note on a single submission
  Future<void> updateSubmission(ContactSubmission submission);
}