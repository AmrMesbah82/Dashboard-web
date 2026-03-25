// ═══════════════════════════════════════════════════════════════════
// FILE 4: application_state.dart
// Path: lib/controller/application/application_state.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/application_model.dart';

abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  final List<ApplicationModel> applications;
  final String activeDeptFilter;
  final String searchQuery;

  ApplicationLoaded({
    required this.applications,
    this.activeDeptFilter = 'All',
    this.searchQuery = '',
  });

  List<ApplicationModel> get filteredApps {
    var result = List<ApplicationModel>.from(applications);

    if (activeDeptFilter != 'All') {
      result = result
          .where((a) => a.department.toLowerCase() == activeDeptFilter.toLowerCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((a) {
        return a.fullName.toLowerCase().contains(q) ||
            a.email.toLowerCase().contains(q) ||
            a.jobTitle.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // ── Summary counts ──
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

  /// Unique departments with counts for filter tabs
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