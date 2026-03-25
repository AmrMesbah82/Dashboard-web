// ═══════════════════════════════════════════════════════════════════
// FILE 3: inquiry_repo_imp.dart (UPDATED)
// Path: lib/repo/inquiry/inquiry_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_app_admin/model/inquiry_model.dart';
import 'package:web_app_admin/repo/inquire/inquiry_repo.dart';

class InquiryRepoImp implements InquiryRepo {
  final FirebaseFirestore _firestore;

  InquiryRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ✅ Changed from 'inquiries' to 'contact_submissions'
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contact_submissions');

  @override
  Future<List<InquiryModel>> fetchAllInquiries() async {
    try {
      print('🟡 [InquiryRepoImp] fetchAllInquiries() from contact_submissions');
      final snapshot = await _collection
          .orderBy('submissionDate', descending: true)
          .get(const GetOptions(source: Source.server));

      final list = snapshot.docs
          .map((doc) => InquiryModel.fromMap(doc.id, doc.data()))
          .toList();

      print('🟢 [InquiryRepoImp] fetchAllInquiries() — got ${list.length}');
      return list;
    } catch (e) {
      print('🔴 [InquiryRepoImp] fetchAllInquiries() ERROR: $e');
      try {
        final snapshot = await _collection
            .orderBy('submissionDate', descending: true)
            .get(const GetOptions(source: Source.cache));
        return snapshot.docs
            .map((doc) => InquiryModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<InquiryModel?> fetchInquiryById(String id) async {
    try {
      print('🟡 [InquiryRepoImp] fetchInquiryById($id) from contact_submissions');
      final doc = await _collection.doc(id).get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      return InquiryModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      print('🔴 [InquiryRepoImp] fetchInquiryById() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateInquiry(InquiryModel inquiry) async {
    try {
      print('🟡 [InquiryRepoImp] updateInquiry(${inquiry.id}) in contact_submissions');
      await _collection.doc(inquiry.id).update(inquiry.toMap());
      print('🟢 [InquiryRepoImp] updateInquiry() — done');
    } catch (e) {
      print('🔴 [InquiryRepoImp] updateInquiry() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String id, InquiryStatus status) async {
    try {
      print('🟡 [InquiryRepoImp] updateStatus($id → ${status.label}) in contact_submissions');
      await _collection.doc(id).update({'status': status.label});
      print('🟢 [InquiryRepoImp] updateStatus() — done');
    } catch (e) {
      print('🔴 [InquiryRepoImp] updateStatus() ERROR: $e');
      rethrow;
    }
  }
}