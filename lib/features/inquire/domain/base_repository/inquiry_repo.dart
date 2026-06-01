// ═══════════════════════════════════════════════════════════════════
// FILE 2: inquiry_repo.dart
// Path: lib/features/inquire/domain/base_repository/inquiry_repo.dart
// ═══════════════════════════════════════════════════════════════════


import '../../data/models/inquiry_model.dart';

abstract class InquiryRepo {
  Future<List<InquiryModel>> fetchAllInquiries();
  Future<InquiryModel?> fetchInquiryById(String id);
  Future<void> updateInquiry(InquiryModel inquiry);
  Future<void> updateStatus(String id, InquiryStatus status);
}