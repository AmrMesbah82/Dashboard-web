// ═══════════════════════════════════════════════════════════════════
// FILE 4: application_state.dart
// Path: lib/controller/application/application_state.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/widgets/application_filter_dialog.dart';

abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  final List<ApplicationModel> applications;
  final String activeDeptFilter;
  final String searchQuery;
  final ApplicationFilterData? filterData;

  ApplicationLoaded({
    required this.applications,
    this.activeDeptFilter = 'All',
    this.searchQuery = '',
    this.filterData,
  });

  List<ApplicationModel> get filteredApps {
    var result = List<ApplicationModel>.from(applications);

    // ── 1. Department filter ──────────────────────────────────────────────
    if (activeDeptFilter != 'All') {
      result = result
          .where((a) => a.department.toLowerCase() == activeDeptFilter.toLowerCase())
          .toList();
    }

    // ── 2. Search query ───────────────────────────────────────────────────
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((a) {
        return a.fullName.toLowerCase().contains(q) ||
            a.email.toLowerCase().contains(q) ||
            a.jobTitle.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q);
      }).toList();
    }

    // ── 3. Dialog filter ──────────────────────────────────────────────────
    if (filterData != null && !filterData!.isEmpty) {

      // Employment Type
      if (filterData!.employmentType != null) {
        result = result
            .where((a) => a.employmentType.toLowerCase() ==
            filterData!.employmentType!.toLowerCase())
            .toList();
      }

      // Years of Experience
      if (filterData!.yearsOfExperience != null) {
        result = result
            .where((a) => a.experienceLevel.toLowerCase() ==
            filterData!.yearsOfExperience!.toLowerCase())
            .toList();
      }

      // Status (matches enum label e.g. "Offer: Approved")
      if (filterData!.status != null) {
        result = result
            .where((a) => a.status.label == filterData!.status)
            .toList();
      }

      // Stage (matches enum stage e.g. "Interview")
      if (filterData!.stage != null) {
        result = result
            .where((a) => a.status.stage == filterData!.stage)
            .toList();
      }

      // Score / Tag (e.g. "Strong", "Adequate", "Weak")
      if (filterData!.score != null) {
        result = result
            .where((a) =>
        a.tag.toLowerCase() == filterData!.score!.toLowerCase())
            .toList();
      }

      // Sort By
      if (filterData!.sortBy != null) {
        switch (filterData!.sortBy) {
          case 'date_desc':
            result.sort((a, b) =>
                (b.applicationDate ?? DateTime(0))
                    .compareTo(a.applicationDate ?? DateTime(0)));
            break;
          case 'date_asc':
            result.sort((a, b) =>
                (a.applicationDate ?? DateTime(0))
                    .compareTo(b.applicationDate ?? DateTime(0)));
            break;
          case 'name_asc':
            result.sort((a, b) => a.fullName.compareTo(b.fullName));
            break;
          case 'name_desc':
            result.sort((a, b) => b.fullName.compareTo(a.fullName));
            break;
        }
      }
    }

    return result;
  }

  // ── Summary counts ────────────────────────────────────────────────────────
  int get totalCount => filteredApps.length;

  int get appliedQualified =>
      filteredApps.where((a) => a.status == ApplicationStatus.qualified).length;
  int get appliedUnqualified =>
      filteredApps.where((a) => a.status == ApplicationStatus.unqualified).length;

  int get interviewPassed =>
      filteredApps.where((a) => a.status == ApplicationStatus.interviewPassed).length;
  int get interviewWithdrew =>
      filteredApps.where((a) => a.status == ApplicationStatus.interviewWithdrew).length;
  int get interviewFailed =>
      filteredApps.where((a) => a.status == ApplicationStatus.interviewFailed).length;

  int get offerApproved =>
      filteredApps.where((a) => a.status == ApplicationStatus.offerApproved).length;
  int get offerPending =>
      filteredApps.where((a) => a.status == ApplicationStatus.offerPending).length;
  int get offerRejected =>
      filteredApps.where((a) => a.status == ApplicationStatus.offerRejected).length;

  int get hiredCompleted =>
      filteredApps.where((a) => a.status == ApplicationStatus.hired).length;

  // ── Department counts for filter tabs ────────────────────────────────────
  Map<String, int> get departmentCounts {
    final map = <String, int>{};
    for (final a in applications) {
      if (a.department.isNotEmpty) {
        map[a.department] = (map[a.department] ?? 0) + 1;
      }
    }
    return map;
  }
}

class ApplicationDetailLoaded extends ApplicationState {
  final ApplicationModel application;
  ApplicationDetailLoaded(this.application);
}

class ApplicationUpdated extends ApplicationState {
  final ApplicationModel application;
  ApplicationUpdated(this.application);
}

class ApplicationError extends ApplicationState {
  final String message;
  final List<ApplicationModel>? lastApps;
  ApplicationError(this.message, {this.lastApps});
}