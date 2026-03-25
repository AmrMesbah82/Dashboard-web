// ═══════════════════════════════════════════════════════════════════
// FILE 2: inquiry_repo.dart
// Path: lib/repo/inquiry/inquiry_repo.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/inquiry_model.dart';

abstract class InquiryRepo {
  Future<List<InquiryModel>> fetchAllInquiries();
  Future<InquiryModel?> fetchInquiryById(String id);
  Future<void> updateInquiry(InquiryModel inquiry);
  Future<void> updateStatus(String id, InquiryStatus status);
}