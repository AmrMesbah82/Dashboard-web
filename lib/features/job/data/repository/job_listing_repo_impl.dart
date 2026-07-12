// ******************* FILE INFO *******************
// File Name: job_listing_repo_impl.dart
// Created by: Amr Mesbah
// Purpose: Firebase Firestore implementation of JobListingRepo

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../core/utils/flat_codec.dart';
import '../../domain/base_repository/job_listing_repo.dart';
import '../models/job_listing_model.dart';

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
      final snapshot = await _collection
          .orderBy('Last_Updated_At', descending: true)
          .get(const GetOptions(source: Source.server));

      final jobs = snapshot.docs.map((doc) {
        return JobPostModel.fromMap(
          doc.id,
          FlatCodec.decode(doc.data(), JobPostModel.flatTemplate),
        );
      }).toList();

      return jobs;
    } catch (e) {
      // Fallback to cache if server fails
      try {
        final snapshot = await _collection
            .orderBy('Last_Updated_At', descending: true)
            .get(const GetOptions(source: Source.cache));
        final jobs = snapshot.docs.map((doc) {
          return JobPostModel.fromMap(
          doc.id,
          FlatCodec.decode(doc.data(), JobPostModel.flatTemplate),
        );
        }).toList();
        return jobs;
      } catch (cacheError) {
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
      final doc = await _collection.doc(id).get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final job = JobPostModel.fromMap(
        doc.id,
        FlatCodec.decode(doc.data()!, JobPostModel.flatTemplate),
      );
      return job;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CREATE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<JobPostModel> createJob(JobPostModel job) async {
    try {
      final docRef = await _collection.add(FlatCodec.encodeNew(job.toMap()));
      final created = job.copyWith(id: docRef.id);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> updateJob(JobPostModel job) async {
    try {
      await FlatCodec.writeVersioned(_collection.doc(job.id), job.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE (hard)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> deleteJob(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  REMOVE (soft — sets status to Removed)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> removeJob(String id) async {
    try {
      // Partial update — writeVersioned appends only these changed fields.
      await FlatCodec.writeVersioned(_collection.doc(id), {
        'status': JobStatus.removed.label,
        'endedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE STATUS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> updateJobStatus(String id, JobStatus status) async {
    try {
      final Map<String, dynamic> data = {'status': status.label};
      if (status == JobStatus.ended || status == JobStatus.removed || status == JobStatus.inactive) {
        data['endedDate'] = DateTime.now().toIso8601String();
      }
      if (status == JobStatus.active) {
        data['postedDate'] = DateTime.now().toIso8601String();
      }
      // Partial update — writeVersioned appends only these changed fields.
      await FlatCodec.writeVersioned(_collection.doc(id), data);
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STREAM ALL (real-time)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Stream<List<JobPostModel>> streamAllJobs() {
    return _collection
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        return JobPostModel.fromMap(
          doc.id,
          FlatCodec.decode(doc.data(), JobPostModel.flatTemplate),
        );
      }).toList();
      return jobs;
    });
  }
}