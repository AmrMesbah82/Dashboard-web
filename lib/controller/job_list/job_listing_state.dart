// ******************* FILE INFO *******************
// File Name: job_listing_state.dart
// Created by: Amr Mesbah
// Purpose: States for Job Listing Cubit — Firebase-backed

import 'package:web_app_admin/model/job_listing_model.dart';

abstract class JobListingState {}

class JobListingInitial extends JobListingState {}

class JobListingLoading extends JobListingState {}

/// List of all jobs loaded
class JobListingLoaded extends JobListingState {
  final List<JobPostModel> jobs;
  final String activeFilter; // 'All', 'Active', 'Inactive', etc.
  final String searchQuery;

  JobListingLoaded({
    required this.jobs,
    this.activeFilter = 'All',
    this.searchQuery = '',
  });

  List<JobPostModel> get filteredJobs {
    var result = List<JobPostModel>.from(jobs);

    // Filter by status
    if (activeFilter != 'All') {
      result = result.where((j) {
        return j.status.label.toLowerCase() == activeFilter.toLowerCase();
      }).toList();
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((j) {
        return j.title.en.toLowerCase().contains(q) ||
            j.title.ar.contains(q) ||
            j.department.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}

/// Single job loaded for edit/preview
class JobListingDetailLoaded extends JobListingState {
  final JobPostModel job;
  JobListingDetailLoaded(this.job);
}

class JobListingSaved extends JobListingState {
  final JobPostModel job;
  JobListingSaved(this.job);
}

class JobListingError extends JobListingState {
  final String message;
  final List<JobPostModel>? lastJobs;
  JobListingError(this.message, {this.lastJobs});
}