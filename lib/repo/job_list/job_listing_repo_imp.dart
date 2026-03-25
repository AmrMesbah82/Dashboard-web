// ******************* FILE INFO *******************
// File Name: job_listing_repo_imp.dart
// Created by: Amr Mesbah
// Purpose: Firebase Firestore implementation of JobListingRepo

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/repo/job_list/job_listing_repo.dart';

class JobListingRepoImp implements JobListingRepo {
  final FirebaseFirestore _firestore;

  JobListingRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ── Collection reference ──────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('jobListings');

  // ══════════════════════════════════════════════════════════════════════════
  //  FETCH ALL
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<JobPostModel>> fetchAllJobs() async {
    try {
      print('🟡 [JobListingRepoImp] fetchAllJobs() — fetching from Firestore...');
      final snapshot = await _collection
          .orderBy('postedDate', descending: true)
          .get(const GetOptions(source: Source.server));

      final jobs = snapshot.docs.map((doc) {
        return JobPostModel.fromMap(doc.id, doc.data());
      }).toList();

      print('🟢 [JobListingRepoImp] fetchAllJobs() — got ${jobs.length} jobs');
      return jobs;
    } catch (e) {
      print('🔴 [JobListingRepoImp] fetchAllJobs() ERROR: $e');
      // Fallback to cache if server fails
      try {
        final snapshot = await _collection
            .orderBy('postedDate', descending: true)
            .get(const GetOptions(source: Source.cache));
        final jobs = snapshot.docs.map((doc) {
          return JobPostModel.fromMap(doc.id, doc.data());
        }).toList();
        print('🟡 [JobListingRepoImp] fetchAllJobs() — got ${jobs.length} jobs from CACHE');
        return jobs;
      } catch (cacheError) {
        print('🔴 [JobListingRepoImp] fetchAllJobs() CACHE ERROR: $cacheError');
        rethrow;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FETCH BY ID
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<JobPostModel?> fetchJobById(String id) async {
    try {
      print('🟡 [JobListingRepoImp] fetchJobById($id)');
      final doc = await _collection.doc(id).get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) {
        print('🟡 [JobListingRepoImp] fetchJobById($id) — not found');
        return null;
      }
      final job = JobPostModel.fromMap(doc.id, doc.data()!);
      print('🟢 [JobListingRepoImp] fetchJobById($id) — found: ${job.title.en}');
      return job;
    } catch (e) {
      print('🔴 [JobListingRepoImp] fetchJobById($id) ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CREATE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<JobPostModel> createJob(JobPostModel job) async {
    try {
      print('🟡 [JobListingRepoImp] createJob() — title: ${job.title.en}');
      final docRef = await _collection.add(job.toMap());
      final created = job.copyWith(id: docRef.id);
      print('🟢 [JobListingRepoImp] createJob() — created with ID: ${docRef.id}');
      return created;
    } catch (e) {
      print('🔴 [JobListingRepoImp] createJob() ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> updateJob(JobPostModel job) async {
    try {
      print('🟡 [JobListingRepoImp] updateJob(${job.id}) — title: ${job.title.en}');
      await _collection.doc(job.id).update(job.toMap());
      print('🟢 [JobListingRepoImp] updateJob(${job.id}) — done');
    } catch (e) {
      print('🔴 [JobListingRepoImp] updateJob(${job.id}) ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE (hard)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> deleteJob(String id) async {
    try {
      print('🟡 [JobListingRepoImp] deleteJob($id)');
      await _collection.doc(id).delete();
      print('🟢 [JobListingRepoImp] deleteJob($id) — done');
    } catch (e) {
      print('🔴 [JobListingRepoImp] deleteJob($id) ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  REMOVE (soft — sets status to Removed)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> removeJob(String id) async {
    try {
      print('🟡 [JobListingRepoImp] removeJob($id) — soft remove');
      await _collection.doc(id).update({
        'status': JobStatus.removed.label,
        'endedDate': DateTime.now().toIso8601String(),
      });
      print('🟢 [JobListingRepoImp] removeJob($id) — done');
    } catch (e) {
      print('🔴 [JobListingRepoImp] removeJob($id) ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE STATUS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> updateJobStatus(String id, JobStatus status) async {
    try {
      print('🟡 [JobListingRepoImp] updateJobStatus($id, ${status.label})');
      final Map<String, dynamic> data = {'status': status.label};
      if (status == JobStatus.ended || status == JobStatus.removed || status == JobStatus.inactive) {
        data['endedDate'] = DateTime.now().toIso8601String();
      }
      if (status == JobStatus.active) {
        data['postedDate'] = DateTime.now().toIso8601String();
      }
      await _collection.doc(id).update(data);
      print('🟢 [JobListingRepoImp] updateJobStatus($id) — done');
    } catch (e) {
      print('🔴 [JobListingRepoImp] updateJobStatus($id) ERROR: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STREAM ALL (real-time)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Stream<List<JobPostModel>> streamAllJobs() {
    print('🟡 [JobListingRepoImp] streamAllJobs() — opening stream');
    return _collection
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        return JobPostModel.fromMap(doc.id, doc.data());
      }).toList();
      print('🟢 [JobListingRepoImp] streamAllJobs() — streamed ${jobs.length} jobs');
      return jobs;
    });
  }
}