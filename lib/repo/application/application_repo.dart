// ═══════════════════════════════════════════════════════════════════
// FILE 2: application_repo.dart
// Path: lib/repo/application/application_repo.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/application_model.dart';

abstract class ApplicationRepo {
  Future<List<ApplicationModel>> fetchAllApplications();
  Future<ApplicationModel?> fetchApplicationById(String jobId, String appId);
  Future<void> updateApplication(ApplicationModel app);
  Future<void> updateStatus(String jobId, String appId, ApplicationStatus status);
}