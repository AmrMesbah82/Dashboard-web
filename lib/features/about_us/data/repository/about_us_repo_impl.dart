// ******************* FILE INFO *******************
// File Name: about_us_repo_impl.dart
// Created by: Amr Mesbah
// UPDATED: Fixed storage paths for strategy images

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../domain/base_repository/about_us_repo.dart';
import '../models/about_us_model.dart';

class AboutRepoImpl implements AboutRepo {
  static const String _aboutCollection    = 'aboutPage';
  static const String _strategyCollection = 'ourStrategy';
  static const String _termsCollection    = 'termsOfService';
  static const String _aboutDoc    = 'about_page';
  static const String _strategyDoc = 'our_strategy';
  static const String _termsDoc    = 'terms_of_service';

  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _ref(String doc) {
    final collection = doc == _strategyDoc
        ? _strategyCollection
        : doc == _termsDoc
            ? _termsCollection
            : _aboutCollection;
    return _db.collection(collection).doc(doc);
  }

  @override
  Future<AboutPageModel> fetchAboutPage() async {
    try {
      final snap = await _ref(_aboutDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return AboutPageModel.empty();
      }

      final raw = snap.data()!;

      // ── Extract lastUpdatedAt BEFORE sanitize() removes it ──
      DateTime? lastUpdatedAt;
      final ts = raw['lastUpdatedAt'];
      if (ts is Timestamp) {
        lastUpdatedAt = ts.toDate();
      } else if (ts is String) {
        lastUpdatedAt = DateTime.tryParse(ts);
      }

      final model = AboutPageModel.fromMap(_sanitize(raw));
      return model.copyWith(lastUpdatedAt: lastUpdatedAt); // ← inject it back

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveAboutPage(AboutPageModel model) async {
    try {
      final data = model.toMap();
      // Overwrite the ISO string from toMap() with the accurate server timestamp
      data['lastUpdatedAt'] = FieldValue.serverTimestamp();
      await _ref(_aboutDoc).set(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OurStrategyModel> fetchStrategy() async {
    try {
      final snap = await _ref(_strategyDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return OurStrategyModel.empty();
      }

      final raw = snap.data()!;

      // ── Extract lastUpdatedAt BEFORE _sanitize() removes it ──
      DateTime? lastUpdatedAt;
      final ts = raw['lastUpdatedAt'];
      if (ts is Timestamp) {
        lastUpdatedAt = ts.toDate();
      } else if (ts is String) {
        lastUpdatedAt = DateTime.tryParse(ts);
      }

      final model = OurStrategyModel.fromMap(_sanitize(raw));
      return model.copyWith(lastUpdatedAt: lastUpdatedAt);  // ← inject back

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveStrategy(OurStrategyModel model) async {
    try {
      final data = model.toMap()
        ..['lastUpdatedAt'] = FieldValue.serverTimestamp();


      await _ref(_strategyDoc).set(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TermsOfServiceModel> fetchTerms() async {
    try {
      final snap = await _ref(_termsDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return TermsOfServiceModel.empty();
      }

      final raw = snap.data()!;

      // ── Debug: print what lastUpdatedAt looks like in Firestore ──

      DateTime? lastUpdatedAt;
      final ts = raw['lastUpdatedAt'];
      if (ts is Timestamp) {
        lastUpdatedAt = ts.toDate();
      } else if (ts is String) {
        lastUpdatedAt = DateTime.tryParse(ts);
      } else {
      }

      final model = TermsOfServiceModel.fromMap(_sanitize(raw));
      return model.copyWith(lastUpdatedAt: lastUpdatedAt);

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveTerms(TermsOfServiceModel model) async {
    try {
      final data = model.toMap()
        ..['lastUpdatedAt'] = FieldValue.serverTimestamp();
      await _ref(_termsDoc).set(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  }) async {
    try {

      // Generate a unique filename to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _detectExtension(bytes);
      final uniquePath = storagePath.contains('.')
          ? storagePath.replaceFirst('.', '_$timestamp.')
          : '$storagePath$timestamp.$extension';

      final mime = _detectMime(bytes);
      final ref = _storage.ref(uniquePath);

      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
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
      final mime = fileName.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'application/octet-stream';
      final ref = _storage.ref('$storagePath/$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
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

  String _detectExtension(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'png';
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'jpg';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'gif';
      if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'webp';
    }
    if (bytes.length > 4) {
      final header = String.fromCharCodes(bytes.take(5));
      if (header.contains('<svg') || header.contains('<?xml'))
        return 'svg';
    }
    return 'png';
  }

}