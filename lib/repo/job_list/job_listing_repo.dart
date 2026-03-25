// ******************* FILE INFO *******************
// File Name: job_listing_repo.dart
// Created by: Amr Mesbah
// Purpose: Abstract repository for Job Listing CRUD — Firebase Firestore

import 'package:web_app_admin/model/job_listing_model.dart';

abstract class JobListingRepo {
  /// Fetch all job posts from Firestore
  Future<List<JobPostModel>> fetchAllJobs();

  /// Fetch a single job post by ID
  Future<JobPostModel?> fetchJobById(String id);

  /// Create a new job post — returns the created model with Firestore doc ID
  Future<JobPostModel> createJob(JobPostModel job);

  /// Update an existing job post
  Future<void> updateJob(JobPostModel job);

  /// Delete a job post by ID (hard delete)
  Future<void> deleteJob(String id);

  /// Soft-remove: sets status to 'Removed'
  Future<void> removeJob(String id);

  /// Update only the status field
  Future<void> updateJobStatus(String id, JobStatus status);

  /// Stream all jobs (real-time listener)
  Stream<List<JobPostModel>> streamAllJobs();
}