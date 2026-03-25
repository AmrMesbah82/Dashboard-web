// ******************* FILE INFO *******************
// File Name: about_repo_impl.dart
// Created by: Amr Mesbah
// UPDATED: Source.server in all fetch methods for fresh Firestore data

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web_app_admin/model/about_us.dart';
import 'package:web_app_admin/repo/about_us/about_repo.dart';

class AboutRepoImpl implements AboutRepo {
  static const String _collection = 'cms';
  static const String _aboutDoc    = 'about_page';
  static const String _strategyDoc = 'our_strategy';
  static const String _termsDoc    = 'terms_of_service';

  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _ref(String doc) =>
      _db.collection(_collection).doc(doc);

  @override
  Future<AboutPageModel> fetchAboutPage() async {
    try {
      final snap = await _ref(_aboutDoc)
          .get(const GetOptions(source: Source.server)); // ← FIXED
      if (!snap.exists || snap.data() == null) {
        _log('   [AboutRepo] about_page doc missing → empty');
        return AboutPageModel.empty();
      }
      return AboutPageModel.fromMap(_sanitize(snap.data()!));
    } catch (e) {
      _log('🔴 [AboutRepo] fetchAboutPage ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAboutPage(AboutPageModel model) async {
    try {
      final data = model.toMap()
        ..['lastUpdatedAt'] = FieldValue.serverTimestamp();
      await _ref(_aboutDoc).set(data);
      _log('🟢 [AboutRepo] saveAboutPage OK');
    } catch (e) {
      _log('🔴 [AboutRepo] saveAboutPage ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<OurStrategyModel> fetchStrategy() async {
    try {
      final snap = await _ref(_strategyDoc)
          .get(const GetOptions(source: Source.server)); // ← FIXED
      if (!snap.exists || snap.data() == null) {
        _log('   [AboutRepo] our_strategy doc missing → empty');
        return OurStrategyModel.empty();
      }
      return OurStrategyModel.fromMap(_sanitize(snap.data()!));
    } catch (e) {
      _log('🔴 [AboutRepo] fetchStrategy ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveStrategy(OurStrategyModel model) async {
    try {
      final data = model.toMap()
        ..['lastUpdatedAt'] = FieldValue.serverTimestamp();
      await _ref(_strategyDoc).set(data);
      _log('🟢 [AboutRepo] saveStrategy OK');
    } catch (e) {
      _log('🔴 [AboutRepo] saveStrategy ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<TermsOfServiceModel> fetchTerms() async {
    try {
      final snap = await _ref(_termsDoc)
          .get(const GetOptions(source: Source.server)); // ← FIXED
      if (!snap.exists || snap.data() == null) {
        _log('   [AboutRepo] terms_of_service doc missing → empty');
        return TermsOfServiceModel.empty();
      }
      return TermsOfServiceModel.fromMap(_sanitize(snap.data()!));
    } catch (e) {
      _log('🔴 [AboutRepo] fetchTerms ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveTerms(TermsOfServiceModel model) async {
    try {
      final data = model.toMap()
        ..['lastUpdatedAt'] = FieldValue.serverTimestamp();
      await _ref(_termsDoc).set(data);
      _log('🟢 [AboutRepo] saveTerms OK');
    } catch (e) {
      _log('🔴 [AboutRepo] saveTerms ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  }) async {
    try {
      _log('🔵 [AboutRepo] uploadImage → $storagePath');
      final mime = _detectMime(bytes);
      final ref  = _storage.ref(storagePath);
      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _log('🟢 [AboutRepo] uploadImage → $url');
      return url;
    } catch (e) {
      _log('🔴 [AboutRepo] uploadImage ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadDocument({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
  }) async {
    try {
      _log('🔵 [AboutRepo] uploadDocument → $storagePath/$fileName');
      final mime = fileName.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'application/octet-stream';
      final ref  = _storage.ref('$storagePath/$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _log('🟢 [AboutRepo] uploadDocument → $url');
      return url;
    } catch (e) {
      _log('🔴 [AboutRepo] uploadDocument ERROR: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _sanitize(Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    copy.remove('lastUpdatedAt');
    return copy;
  }

  String _detectMime(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
      if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'image/webp';
    }
    if (bytes.length > 4) {
      final header = String.fromCharCodes(bytes.take(5));
      if (header.contains('<svg') || header.contains('<?xml'))
        return 'image/svg+xml';
    }
    return 'image/png';
  }

  void _log(String msg) => print(msg);
}