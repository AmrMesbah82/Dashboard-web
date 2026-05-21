// ═══════════════════════════════════════════════════════════════════
// FILE 3: inquiry_repo_imp.dart (UPDATED)
// Path: lib/repo/inquiry/inquiry_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repo/inquiry_repo.dart';
import '../models/inquiry_model.dart';

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
      final snapshot = await _collection
          .orderBy('submissionDate', descending: true)
          .get(const GetOptions(source: Source.server));

      final list = snapshot.docs
          .map((doc) => InquiryModel.fromMap(doc.id, doc.data()))
          .toList();

      return list;
    } catch (e) {
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
      final doc = await _collection.doc(id).get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      return InquiryModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateInquiry(InquiryModel inquiry) async {
    try {
      await _collection.doc(inquiry.id).update(inquiry.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String id, InquiryStatus status) async {
    try {
      await _collection.doc(id).update({'status': status.label});
    } catch (e) {
      rethrow;
    }
  }
}