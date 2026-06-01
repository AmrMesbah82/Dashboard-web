// ═══════════════════════════════════════════════════════════════════
// FILE 2: application_repo.dart
// Path: lib/features/job/domain/base_repository/application_repo.dart
// ═══════════════════════════════════════════════════════════════════


import '../../data/models/application_model.dart';

abstract class ApplicationRepo {
  Future<List<ApplicationModel>> fetchAllApplications();
  Future<ApplicationModel?> fetchApplicationById(String jobId, String appId);
  Future<void> updateApplication(ApplicationModel app);
  Future<void> updateStatus(String jobId, String appId, ApplicationStatus status);
}