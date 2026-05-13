// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_state.dart
// Path: lib/controller/inquiry/inquiry_state.dart
// UPDATED: Added filter fields for status, entity type, location, month
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/inquiry_model.dart';

abstract class InquiryState {}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiryLoaded extends InquiryState {
  final List<InquiryModel> inquiries;
  final String searchQuery;
  final String? statusFilter;
  final String? entityTypeFilter;
  final String? locationFilter;
  final int? monthFilter;

  InquiryLoaded({
    required this.inquiries,
    this.searchQuery = '',
    this.statusFilter,
    this.entityTypeFilter,
    this.locationFilter,
    this.monthFilter,
  });

  List<InquiryModel> get filtered {
    var list = inquiries.toList();

    // ── Status filter ──
    if (statusFilter != null && statusFilter!.isNotEmpty) {
      list = list.where((i) => i.status.label == statusFilter).toList();
    }

    // ── Entity type filter ──
    if (entityTypeFilter != null && entityTypeFilter!.isNotEmpty) {
      list = list.where((i) => i.entityType == entityTypeFilter).toList();
    }

    // ── Location filter ──
    if (locationFilter != null && locationFilter!.isNotEmpty) {
      list = list.where((i) => i.location == locationFilter).toList();
    }

    // ── Month filter ──
    if (monthFilter != null) {
      list = list.where((i) =>
      i.submissionDate != null && i.submissionDate!.month == monthFilter,
      ).toList();
    }

    // ── Search filter ──
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((i) {
        return i.fullName.toLowerCase().contains(q) ||
            i.email.toLowerCase().contains(q) ||
            i.subject.toLowerCase().contains(q) ||
            i.entityName.toLowerCase().contains(q) ||
            i.phone.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  int get totalCount   => filtered.length;
  int get newCount     => filtered.where((i) => i.status == InquiryStatus.newInquiry).length;
  int get repliedCount => filtered.where((i) => i.status == InquiryStatus.replied).length;
  int get closedCount  => filtered.where((i) => i.status == InquiryStatus.closed).length;

  // ── Unique values for dropdown items ──
  List<String> get uniqueStatuses =>
      inquiries.map((i) => i.status.label).toSet().toList()..sort();

  List<String> get uniqueEntityTypes =>
      inquiries.map((i) => i.entityType).where((e) => e.isNotEmpty).toSet().toList()..sort();

  List<String> get uniqueLocations =>
      inquiries.map((i) => i.location).where((e) => e.isNotEmpty).toSet().toList()..sort();

  List<int> get uniqueMonths {
    final months = inquiries
        .where((i) => i.submissionDate != null)
        .map((i) => i.submissionDate!.month)
        .toSet()
        .toList()
      ..sort();
    return months;
  }

  // ── Chart data (uses ALL inquiries, not filtered) ──
  Map<String, int> get entityTypeCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.entityType.isNotEmpty) map[i.entityType] = (map[i.entityType] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get entitySizeCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.entitySize.isNotEmpty) map[i.entitySize] = (map[i.entitySize] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get locationCounts {
    final map = <String, int>{};
    for (final i in inquiries) {
      if (i.location.isNotEmpty) map[i.location] = (map[i.location] ?? 0) + 1;
    }
    return map;
  }

  Map<int, int> get monthlySubmissions {
    final map = <int, int>{};
    for (final i in inquiries) {
      if (i.submissionDate != null) {
        map[i.submissionDate!.month] = (map[i.submissionDate!.month] ?? 0) + 1;
      }
    }
    return map;
  }
}

class InquiryDetailLoaded extends InquiryState {
  final InquiryModel inquiry;
  InquiryDetailLoaded(this.inquiry);
}

class InquiryUpdated extends InquiryState {
  final InquiryModel inquiry;
  InquiryUpdated(this.inquiry);
}

class InquiryError extends InquiryState {
  final String message;
  final List<InquiryModel>? lastInquiries;
  InquiryError(this.message, {this.lastInquiries});
}