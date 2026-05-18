// ═══════════════════════════════════════════════════════════════════
// FILE 3: about_us_company_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repo/about_company_repo.dart';
import '../model/about_us_company_model.dart';

class AboutCompanyRepoImp implements AboutCompanyRepo {
  final FirebaseFirestore _firestore;

  AboutCompanyRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Single document in 'cmsPages' collection with ID 'about_company'
  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('cmsPages').doc('about_company');

  // ══════════════════════════════════════════════════════════════════════════
  //  FETCH
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<AboutCompanyModel?> fetchAboutCompany() async {
    try {
      print('🟡 [AboutCompanyRepoImp] fetchAboutCompany() — fetching from Firestore...');
      final snapshot = await _doc.get(const GetOptions(source: Source.server));

      if (!snapshot.exists || snapshot.data() == null) {
        print('🟡 [AboutCompanyRepoImp] fetchAboutCompany() — doc not found, returning null');
        return null;
      }

      final model = AboutCompanyModel.fromMap(snapshot.id, snapshot.data()!);
      print('🟢 [AboutCompanyRepoImp] fetchAboutCompany() — loaded successfully');
      return model;
    } catch (e) {
      print('🔴 [AboutCompanyRepoImp] fetchAboutCompany() ERROR: $e');
      // Fallback to cache
      try {
        final snapshot = await _doc.get(const GetOptions(source: Source.cache));
        if (!snapshot.exists || snapshot.data() == null) return null;
        final model = AboutCompanyModel.fromMap(snapshot.id, snapshot.data()!);
        print('🟡 [AboutCompanyRepoImp] fetchAboutCompany() — got from CACHE');
        return model;
      } catch (cacheError) {
        print('🔴 [AboutCompanyRepoImp] fetchAboutCompany() CACHE ERROR: $cacheError');
        rethrow;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> saveAboutCompany(AboutCompanyModel data) async {
    try {
      print('🟡 [AboutCompanyRepoImp] saveAboutCompany()');
      await _doc.set(data.toMap(), SetOptions(merge: true));
      print('🟢 [AboutCompanyRepoImp] saveAboutCompany() — done');
    } catch (e) {
      print('🔴 [AboutCompanyRepoImp] saveAboutCompany() ERROR: $e');
      rethrow;
    }
  }
}