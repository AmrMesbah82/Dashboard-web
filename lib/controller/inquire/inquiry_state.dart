// ═══════════════════════════════════════════════════════════════════
// FILE 4: inquiry_state.dart
// Path: lib/controller/inquiry/inquiry_state.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/inquiry_model.dart';

abstract class InquiryState {}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiryLoaded extends InquiryState {
  final List<InquiryModel> inquiries;
  final String searchQuery;

  InquiryLoaded({required this.inquiries, this.searchQuery = ''});

  List<InquiryModel> get filtered {
    if (searchQuery.isEmpty) return inquiries;
    final q = searchQuery.toLowerCase();
    return inquiries.where((i) {
      return i.fullName.toLowerCase().contains(q) ||
          i.email.toLowerCase().contains(q) ||
          i.subject.toLowerCase().contains(q) ||
          i.entityName.toLowerCase().contains(q);
    }).toList();
  }

  int get totalCount    => filtered.length;
  int get newCount      => filtered.where((i) => i.status == InquiryStatus.newInquiry).length;
  int get repliedCount  => filtered.where((i) => i.status == InquiryStatus.replied).length;
  int get closedCount   => filtered.where((i) => i.status == InquiryStatus.closed).length;

  // ── Chart data ──
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