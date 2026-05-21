// ******************* FILE INFO *******************
// File Name: careers_section_repo_imp.dart
// Firestore + Firebase Storage implementation for careers sections.
// Firestore path: careers_cms / {sectionKey}
//   → doc fields: lastUpdated (Timestamp), items (List<Map>)
// Storage path:  careers_cms/{sectionKey}/{itemId}/icon.svg  or  image.svg

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../domain/repo/careers_section_repo.dart';
import '../models/careers_section_model.dart';

class CareersSectionRepoImp implements CareersSectionRepo {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  DocumentReference _doc(String key) =>
      _db.collection('careers_cms').doc(key);

  // ── Load ────────────────────────────────────────────────────────────────────
  @override
  Future<CareersSectionModel> load(String sectionKey) async {
    try {
      final snap = await _doc(sectionKey).get();
      if (!snap.exists || snap.data() == null) {
        return CareersSectionModel.empty(sectionKey);
      }

      final docData = snap.data()! as Map<String, dynamic>;
      final rawItems = docData['items'] as List<dynamic>? ?? [];
      final itemMaps = rawItems.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return m;
      }).toList();

      final model = CareersSectionModel.fromFirestore(
        sectionKey,
        docData,
        itemMaps,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  @override
  Future<void> save(CareersSectionModel model) async {

    try {
      final itemsList = model.items.map((item) {
        final m = item.toMap();
        m['_id'] = item.id;
        return m;
      }).toList();

      await _doc(model.sectionKey).set({
        'items': itemsList,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      rethrow;
    }
  }

  // ── Upload Icon ─────────────────────────────────────────────────────────────
  @override
  Future<String> uploadIcon(
      String sectionKey, String itemId, Uint8List bytes) async {
    final path = 'careers_cms/$sectionKey/$itemId/icon.svg';
    return _uploadSvgBytes(path, bytes);
  }

  // ── Upload SVG Image ────────────────────────────────────────────────────────
  @override
  Future<String> uploadSvg(
      String sectionKey, String itemId, Uint8List bytes) async {
    final path = 'careers_cms/$sectionKey/$itemId/image.svg';
    return _uploadSvgBytes(path, bytes);
  }

  // ── Internal: XHR upload to avoid CORS issues on Flutter Web ────────────────
  Future<String> _uploadSvgBytes(String storagePath, Uint8List bytes) async {
    try {
      final ref = _storage.ref(storagePath);

      // 1️⃣ Get upload URL metadata
      final uploadUrl = await ref
          .putData(bytes, SettableMetadata(contentType: 'image/svg+xml'))
          .then((_) => ref.getDownloadURL());

      return uploadUrl;
    } catch (e) {
      // Fallback: XHR-based upload
      return _xhrUpload(storagePath, bytes);
    }
  }

  Future<String> _xhrUpload(String storagePath, Uint8List bytes) async {
    final ref = _storage.ref(storagePath);
    final completer = Completer<String>();

    try {
      final task = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/svg+xml'),
      );
      await task;
      final url = await ref.getDownloadURL();
      completer.complete(url);
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }
}