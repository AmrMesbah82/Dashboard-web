// ******************* FILE INFO *******************
// File Name: intern_repo.dart
// Firestore collection: careers_interns

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/intern_model.dart';

class InternRepository {
  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;
  static const String     _col     = 'careers_interns';

  // ── Fetch all interns ordered by joinedDate desc ─────────────────────────
  Future<List<InternModel>> fetchAll() async {
    final snap = await _db
        .collection(_col)
        .orderBy('joinedDate', descending: true)
        .get();
    return snap.docs
        .map((d) => InternModel.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<InternModel> create(InternModel intern, {Uint8List? photoBytes}) async {
    final id  = const Uuid().v4();
    String photoUrl = intern.photoUrl;

    if (photoBytes != null) {
      photoUrl = await _uploadPhoto(id, photoBytes);
    }

    final model = intern.copyWith(id: id, photoUrl: photoUrl);
    await _db.collection(_col).doc(id).set(model.toMap());
    return model;
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<InternModel> update(InternModel intern, {Uint8List? photoBytes}) async {
    String photoUrl = intern.photoUrl;

    if (photoBytes != null) {
      photoUrl = await _uploadPhoto(intern.id, photoBytes);
    }

    final model = intern.copyWith(photoUrl: photoUrl);
    await _db.collection(_col).doc(intern.id).update(model.toMap());
    return model;
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _db.collection(_col).doc(id).delete();
    try {
      await _storage.ref('interns/$id/photo').delete();
    } catch (_) {}
  }

  // ── Upload photo ──────────────────────────────────────────────────────────
  Future<String> _uploadPhoto(String id, Uint8List bytes) async {
    final ref = _storage.ref('interns/$id/photo');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }
}