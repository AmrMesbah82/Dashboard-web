// ******************* FILE INFO *******************
// File Name: service_repository_impl.dart
// Description: Firebase implementation of ServiceRepository.
//   • Firestore  → document: cms/service_page
//   • Storage    → bucket path: service_cms/...
// Created by: Amr Mesbah
// FIXED: _sanitize() now converts lastUpdatedAt Timestamp → ISO string
//        instead of removing it, so ServicePageModel.fromMap() can parse it

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/repo/Services/repo.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage?   storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage   = storage   ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage   _storage;

  static const String _collection = 'cms';
  static const String _document   = 'service_page';

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collection).doc(_document);

  // ── Fetch (cache-first) ───────────────────────────────────────────────────

  @override
  Future<ServicePageModel> fetchServicePage() async {
    print('🔵 [ServiceRepo] fetchServicePage() called (cache-first)');
    try {
      final snapshot = await _docRef.get();
      print('   snapshot.exists            = ${snapshot.exists}');
      print('   snapshot.metadata.isFromCache = ${snapshot.metadata.isFromCache}');
      if (!snapshot.exists || snapshot.data() == null) {
        print('⚠️  [ServiceRepo] fetchServicePage() → no document, returning empty');
        return ServicePageModel.empty();
      }
      final data  = _sanitize(snapshot.data()!);
      final model = ServicePageModel.fromMap(data);
      print('🟢 [ServiceRepo] fetchServicePage() → parsed OK');
      print('   model.title.en            = ${model.title.en}');
      print('   model.journeyItems.length = ${model.journeyItems.length}');
      print('   model.lastUpdatedAt       = ${model.lastUpdatedAt}');
      return model;
    } catch (e, st) {
      print('🔴 [ServiceRepo] fetchServicePage() ERROR: $e');
      print('   StackTrace: $st');
      return ServicePageModel.empty();
    }
  }

  // ── Fetch FRESH (server only, bypasses cache) ─────────────────────────────

  @override
  Future<ServicePageModel> fetchServicePageFresh() async {
    print('🔵 [ServiceRepo] fetchServicePageFresh() called (Source.server)');
    try {
      final snapshot = await _docRef.get(const GetOptions(source: Source.server));
      print('   snapshot.exists               = ${snapshot.exists}');
      print('   snapshot.metadata.isFromCache = ${snapshot.metadata.isFromCache}');
      if (!snapshot.exists || snapshot.data() == null) {
        print('⚠️  [ServiceRepo] fetchServicePageFresh() → no document, returning empty');
        return ServicePageModel.empty();
      }
      final data  = _sanitize(snapshot.data()!);
      final model = ServicePageModel.fromMap(data);
      print('🟢 [ServiceRepo] fetchServicePageFresh() → parsed OK');
      print('   model.title.en            = ${model.title.en}');
      print('   model.journeyItems.length = ${model.journeyItems.length}');
      print('   model.lastUpdatedAt       = ${model.lastUpdatedAt}');
      if (model.journeyItems.isNotEmpty) {
        print('   journeyItems[0].iconUrl  = ${model.journeyItems[0].iconUrl}');
        print('   journeyItems[0].title.en = ${model.journeyItems[0].title.en}');
      }
      return model;
    } catch (e, st) {
      print('🔴 [ServiceRepo] fetchServicePageFresh() ERROR: $e');
      print('   StackTrace: $st');
      return ServicePageModel.empty();
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  @override
  Future<void> saveServicePage(ServicePageModel model) async {
    print('🔵 [ServiceRepo] saveServicePage() called');
    print('   model.title.en            = ${model.title.en}');
    print('   model.journeyItems.length = ${model.journeyItems.length}');
    try {
      final map = {
        ...model.toMap(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      // ✅ Remove the model's own lastUpdatedAt ISO string if present,
      //    since we're replacing it with FieldValue.serverTimestamp()
      // (toMap() may include it as an ISO string — serverTimestamp wins)
      await _docRef.set(map);
      print('🟢 [ServiceRepo] saveServicePage() → Firestore .set() completed');
    } catch (e, st) {
      print('🔴 [ServiceRepo] saveServicePage() ERROR: $e');
      print('   StackTrace: $st');
      rethrow;
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String    storagePath,
  }) async {
    print('🔵 [ServiceRepo] uploadImage() storagePath=$storagePath bytes=${bytes.length}');
    try {
      final ref  = _storage.ref().child(storagePath);
      final mime = _detectMime(bytes);
      print('   detected MIME = $mime');
      final task = await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url  = await task.ref.getDownloadURL();
      print('🟢 [ServiceRepo] uploadImage() → url=$url');
      return url;
    } catch (e, st) {
      print('🔴 [ServiceRepo] uploadImage() ERROR: $e');
      print('   StackTrace: $st');
      rethrow;
    }
  }

  // ── Watch (realtime stream) ───────────────────────────────────────────────

  @override
  Stream<ServicePageModel> watchServicePage() {
    print('🔵 [ServiceRepo] watchServicePage() stream created');
    return _docRef.snapshots().map((snap) {
      print('📡 [ServiceRepo] watchServicePage() snapshot received');
      print('   snap.exists               = ${snap.exists}');
      print('   snap.metadata.isFromCache = ${snap.metadata.isFromCache}');
      if (!snap.exists || snap.data() == null) return ServicePageModel.empty();
      try {
        final data = _sanitize(snap.data()!);
        return ServicePageModel.fromMap(data);
      } catch (e) {
        print('🔴 [ServiceRepo] watchServicePage() parse ERROR: $e');
        return ServicePageModel.empty();
      }
    });
  }

  // ── ✅ FIXED: Sanitize raw Firestore map ──────────────────────────────────
  // Previously this removed lastUpdatedAt entirely, so the model never got it.
  // Now it converts Firestore Timestamp → ISO string so fromMap() can parse it.

  Map<String, dynamic> _sanitize(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);

    // ✅ Convert Firestore Timestamp to ISO string instead of removing it
    final rawTs = copy['lastUpdatedAt'];
    if (rawTs != null && rawTs.runtimeType.toString().contains('Timestamp')) {
      try {
        final dt = (rawTs as dynamic).toDate() as DateTime;
        copy['lastUpdatedAt'] = dt.toIso8601String();
        print('   [ServiceRepo] _sanitize() → converted lastUpdatedAt Timestamp → ${copy['lastUpdatedAt']}');
      } catch (e) {
        print('   [ServiceRepo] _sanitize() → failed to convert lastUpdatedAt: $e, removing');
        copy.remove('lastUpdatedAt');
      }
    }

    print('   [ServiceRepo] _sanitize() → remaining keys = ${copy.keys.toList()}');
    return copy;
  }

  // ── MIME sniff ────────────────────────────────────────────────────────────

  String _detectMime(Uint8List b) {
    if (b.length < 4) return 'application/octet-stream';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b[0] == 0xFF && b[1] == 0xD8)                                   return 'image/jpeg';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'image/gif';
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b.length >= 12 && b[8] == 0x57 && b[9] == 0x45 &&
        b[10] == 0x42 && b[11] == 0x50)                                 return 'image/webp';
    if (b[0] == 0x3C)                                                   return 'image/svg+xml';
    return 'image/jpeg';
  }
}