// ═══════════════════════════════════════════════════════════════════
// FILE 3: application_repo_imp.dart
// Path: lib/repo/application/application_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/repo/application/application_repo.dart';

class ApplicationRepoImp implements ApplicationRepo {
  final FirebaseFirestore _firestore;

  ApplicationRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _appCollection(String jobId) =>
      _firestore.collection('jobListings').doc(jobId).collection('applications');

  @override
  Future<List<ApplicationModel>> fetchAllApplications() async {
    try {
      print('🟡 [ApplicationRepoImp] fetchAllApplications()');

      // Get all jobListings first, then their applications subcollections
      final jobsSnapshot = await _firestore
          .collection('jobListings')
          .get(const GetOptions(source: Source.server));

      final List<ApplicationModel> allApps = [];

      for (final jobDoc in jobsSnapshot.docs) {
        final appsSnapshot = await jobDoc.reference
            .collection('applications')
            .orderBy('applicationDate', descending: true)
            .get(const GetOptions(source: Source.server));

        for (final appDoc in appsSnapshot.docs) {
          allApps.add(ApplicationModel.fromMap(appDoc.id, {
            ...appDoc.data(),
            'jobId': jobDoc.id,
          }));
        }
      }

      print('🟢 [ApplicationRepoImp] fetchAllApplications() — got ${allApps.length}');
      return allApps;
    } catch (e) {
      print('🔴 [ApplicationRepoImp] fetchAllApplications() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<ApplicationModel?> fetchApplicationById(String jobId, String appId) async {
    try {
      print('🟡 [ApplicationRepoImp] fetchApplicationById($jobId/$appId)');
      final doc = await _appCollection(jobId).doc(appId).get(
          const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) return null;

      return ApplicationModel.fromMap(doc.id, {
        ...doc.data()!,
        'jobId': jobId,
      });
    } catch (e) {
      print('🔴 [ApplicationRepoImp] fetchApplicationById() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateApplication(ApplicationModel app) async {
    try {
      print('🟡 [ApplicationRepoImp] updateApplication(${app.jobId}/${app.id})');
      await _appCollection(app.jobId).doc(app.id).update(app.toMap());
      print('🟢 [ApplicationRepoImp] updateApplication() — done');
    } catch (e) {
      print('🔴 [ApplicationRepoImp] updateApplication() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String jobId, String appId, ApplicationStatus status) async {
    try {
      print('🟡 [ApplicationRepoImp] updateStatus($jobId/$appId → ${status.label})');
      await _appCollection(jobId).doc(appId).update({'status': status.label});
      print('🟢 [ApplicationRepoImp] updateStatus() — done');
    } catch (e) {
      print('🔴 [ApplicationRepoImp] updateStatus() ERROR: $e');
      rethrow;
    }
  }
}