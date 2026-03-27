// ******************* FILE INFO *******************
// File Name: job_listing_state.dart
// Created by: Amr Mesbah
// Purpose: States for Job Listing Cubit — Firebase-backed
// FIXED: JobListingLoaded now supports advancedFilter from dialog
// FIXED: Advanced filter uses actual JobPostModel fields

import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/widgets/job_listing_filter_dialog.dart';

abstract class JobListingState {}

class JobListingInitial extends JobListingState {}

class JobListingLoading extends JobListingState {}

/// List of all jobs loaded
class JobListingLoaded extends JobListingState {
  final List<JobPostModel> jobs;
  final String activeFilter; // 'All', 'Active', 'Inactive', etc.
  final String searchQuery;
  final JobListingFilterData? advancedFilter;

  JobListingLoaded({
    required this.jobs,
    this.activeFilter = 'All',
    this.searchQuery = '',
    this.advancedFilter,
  });

  List<JobPostModel> get filteredJobs {
    var result = List<JobPostModel>.from(jobs);

    // ── Filter by status tab ─────────────────────────────────────────────
    if (activeFilter != 'All') {
      result = result.where((j) {
        return j.status.label.toLowerCase() == activeFilter.toLowerCase();
      }).toList();
    }

    // ── Filter by search query ───────────────────────────────────────────
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((j) {
        return j.title.en.toLowerCase().contains(q) ||
            j.title.ar.contains(q) ||
            j.department.toLowerCase().contains(q);
      }).toList();
    }

    // ── Advanced filter from dialog ──────────────────────────────────────
    if (advancedFilter != null && !advancedFilter!.isEmpty) {
      final af = advancedFilter!;

      // Department — matches job.department string
      if (af.department != null && af.department!.isNotEmpty) {
        result = result.where((j) {
          return j.department.toLowerCase() == af.department!.toLowerCase();
        }).toList();
      }

      // Location — matches job.workType label (On Site / Remotely / Hybrid)
      // Filter dialog location keys: 'cairo', 'alex', 'giza', 'remote'
      // For 'remote' key → match WorkType.remote; others → match onSite/hybrid
      if (af.location != null && af.location!.isNotEmpty) {
        result = result.where((j) {
          if (af.location == 'remote') {
            return j.workType == WorkType.remote;
          }
          // Non-remote locations → show onSite and hybrid jobs
          return j.workType == WorkType.onSite || j.workType == WorkType.hybrid;
        }).toList();
      }

      // Employment Type — matches job.employmentType enum label
      // Filter keys: 'full_time', 'part_time', 'contract', 'internship', 'freelance'
      if (af.employmentType != null && af.employmentType!.isNotEmpty) {
        result = result.where((j) {
          return _matchesEmploymentType(j.employmentType, af.employmentType!);
        }).toList();
      }

      // Years of Experience — matches job.experienceLevel enum
      // Filter keys: '0_1', '1_3', '3_5', '5_10', '10+'
      if (af.yearsOfExperience != null && af.yearsOfExperience!.isNotEmpty) {
        result = result.where((j) {
          return _matchesExperienceLevel(j.experienceLevel, af.yearsOfExperience!);
        }).toList();
      }

      // Date — show jobs posted on or after the selected date
      if (af.date != null) {
        result = result.where((j) {
          if (j.postedDate == null) return false;
          final posted = DateTime(j.postedDate!.year, j.postedDate!.month, j.postedDate!.day);
          final picked = DateTime(af.date!.year, af.date!.month, af.date!.day);
          return posted.isAtSameMomentAs(picked) || posted.isAfter(picked);
        }).toList();
      }
    }

    return result;
  }

  /// Match employment type filter key against the EmploymentType enum
  bool _matchesEmploymentType(EmploymentType type, String filterKey) {
    switch (filterKey) {
      case 'full_time':
        return type == EmploymentType.fullTime;
      case 'part_time':
        return type == EmploymentType.partTime;
    // contract, internship, freelance don't exist in the enum yet —
    // return false so they simply don't match any job
      default:
        return false;
    }
  }

  /// Match experience level filter key against the ExperienceLevel enum
  /// Maps year-range keys to the closest experience level(s)
  bool _matchesExperienceLevel(ExperienceLevel level, String yoeKey) {
    switch (yoeKey) {
      case '0_1':
        return level == ExperienceLevel.intern;
      case '1_3':
        return level == ExperienceLevel.junior;
      case '3_5':
        return level == ExperienceLevel.junior || level == ExperienceLevel.senior;
      case '5_10':
        return level == ExperienceLevel.senior;
      case '10+':
        return level == ExperienceLevel.senior || level == ExperienceLevel.leadership;
      default:
        return true;
    }
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