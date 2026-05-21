// ═══════════════════════════════════════════════════════════════════
// FILE 3: application_repo_imp.dart
// Path: lib/repo/application/application_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../domain/repo/application_repo.dart';
import '../models/application_model.dart';

class ApplicationRepoImp implements ApplicationRepo {
  final FirebaseFirestore _firestore;

  ApplicationRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _appCollection(String jobId) =>
      _firestore.collection('jobListings').doc(jobId).collection('applications');

  @override
  Future<List<ApplicationModel>> fetchAllApplications() async {
    try {

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

      return allApps;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApplicationModel?> fetchApplicationById(String jobId, String appId) async {
    try {
      final doc = await _appCollection(jobId).doc(appId).get(
          const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) return null;

      return ApplicationModel.fromMap(doc.id, {
        ...doc.data()!,
        'jobId': jobId,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateApplication(ApplicationModel app) async {
    try {
      await _appCollection(app.jobId).doc(app.id).update(app.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String jobId, String appId, ApplicationStatus status) async {
    try {
      await _appCollection(jobId).doc(appId).update({'status': status.label});
    } catch (e) {
      rethrow;
    }
  }
}