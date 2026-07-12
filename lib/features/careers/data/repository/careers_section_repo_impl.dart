// ******************* FILE INFO *******************
// File Name: careers_section_repo_impl.dart
// Firestore + Firebase Storage implementation for careers sections.
// Firestore path: careers_cms / {sectionKey}
//   → doc fields: lastUpdated (Timestamp), items (List<Map>)
// Storage path:  careers_cms/{sectionKey}/{itemId}/icon.svg  or  image.svg

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../../../core/utils/flat_codec.dart';
import '../../domain/base_repository/careers_section_repo.dart';
import '../models/careers_section_model.dart';

class CareersSectionRepoImp implements CareersSectionRepo {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _doc(String key) =>
      _db.collection('whyJoinOurTeam').doc(key);

  // ── Load ────────────────────────────────────────────────────────────────────
  @override
  Future<CareersSectionModel> load(String sectionKey) async {
    try {
      final snap = await _doc(sectionKey).get();
      if (!snap.exists || snap.data() == null) {
        return CareersSectionModel.empty(sectionKey);
      }

      final raw = snap.data()! as Map<String, dynamic>;
      // Decode the flat versioned document back into nested { items: [...] }.
      final nested = FlatCodec.decode(raw, CareersSectionModel.flatTemplate);
      final itemMaps = (nested['items'] as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        m['_id'] = m['id'] ?? ''; // fromFirestore reads the id from '_id'
        return m;
      }).toList();

      final model = CareersSectionModel.fromFirestore(
        sectionKey,
        {'lastUpdated': raw['Last_Updated_At']}, // scalar timestamp
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
      // Versioned append write; scalar Last_Updated_At added by the codec.
      final nested = {
        'items': model.items.map((item) => {'id': item.id, ...item.toMap()}).toList(),
      };
      await FlatCodec.writeVersioned(_doc(model.sectionKey), nested);

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