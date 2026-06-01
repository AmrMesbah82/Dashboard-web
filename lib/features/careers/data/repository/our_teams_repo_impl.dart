// ******************* FILE INFO *******************
// File Name: our_teams_repo_impl.dart

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../domain/base_repository/our_teams_repo.dart';
import '../models/our_teams_model.dart';

class OurTeamsRepoImpl implements OurTeamsRepo {
  final FirebaseFirestore _db;
  final FirebaseStorage   _storage;

  OurTeamsRepoImpl({
    FirebaseFirestore? db,
    FirebaseStorage?   storage,
  })  : _db      = db      ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ── Firestore document reference ────────────────────────────────────────────
  DocumentReference<Map<String, dynamic>> get _docRef =>
      _db.collection('cms').doc('ourTeams');

  // ── Load ────────────────────────────────────────────────────────────────────
  @override
  Future<OurTeamsModel> load() async {
    try {
      final snap = await _docRef.get();
      if (!snap.exists || snap.data() == null) {
        return const OurTeamsModel();
      }
      return OurTeamsModel.fromMap(snap.data()!);
    } catch (e) {
      throw Exception('OurTeamsRepo.load failed: $e');
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  @override
  Future<void> save(OurTeamsModel model) async {
    try {
      final data = model.toMap();
      data['lastUpdated'] = FieldValue.serverTimestamp();
      await _docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('OurTeamsRepo.save failed: $e');
    }
  }

  // ── Upload icon ──────────────────────────────────────────────────────────────
  @override
  Future<String> uploadIcon(String itemId, Uint8List bytes) async {
    try {
      final ref = _storage
          .ref()
          .child('cms/ourTeams/icons/$itemId.svg');
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/svg+xml'),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw Exception('OurTeamsRepo.uploadIcon failed: $e');
    }
  }
}