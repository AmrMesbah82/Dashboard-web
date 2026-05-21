// ******************* FILE INFO *******************
// File Name: home_repository_impl.dart
// Description: Firebase implementation of HomeRepository.
//              Dual-document architecture:
//              - Published → `cms/home_page`
//              - Draft     → `cms/home_page_draft`
//
//              "Save For Later" writes to the _draft doc only.
//              "Publish" writes to the published doc and deletes the draft.
//              "Schedule" writes to the _draft doc with publishStatus = 'scheduled'.
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Dual-document draft system ✅

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../domain/repo/home_repo.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _collection    = 'cms';
  static const String _publishedDoc  = 'home_page';
  static const String _draftDoc      = 'home_page_draft';

  DocumentReference<Map<String, dynamic>> get _publishedRef =>
      _firestore.collection(_collection).doc(_publishedDoc);

  DocumentReference<Map<String, dynamic>> get _draftRef =>
      _firestore.collection(_collection).doc(_draftDoc);

  // ═════════════════════════════════════════════════════════════════════════
  //  PUBLISHED DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<HomePageModel> fetchHomePage() async {
    try {
      final snapshot = await _publishedRef.get();
      if (!snapshot.exists || snapshot.data() == null) {
        return HomePageModel.defaultModel;
      }
      final data = _sanitize(snapshot.data()!);
      final model = HomePageModel.fromMap(data);
      return model;
    } catch (e, st) {
      return HomePageModel.defaultModel;
    }
  }

  @override
  Future<HomePageModel> fetchHomePageFresh() async {
    try {
      final snapshot = await _publishedRef.get(const GetOptions(source: Source.server));
      if (!snapshot.exists || snapshot.data() == null) {
        return HomePageModel.defaultModel;
      }
      final data = _sanitize(snapshot.data()!);
      final model = HomePageModel.fromMap(data);
      return model;
    } catch (e, st) {
      return HomePageModel.defaultModel;
    }
  }

  @override
  Future<void> saveHomePage(HomePageModel model) async {
    try {
      final map = {
        ...model.toMap(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      await _publishedRef.set(map);
    } catch (e, st) {
      rethrow;
    }
  }

  @override
  Stream<HomePageModel> watchHomePage() {
    return _publishedRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return HomePageModel.defaultModel;
      try {
        return HomePageModel.fromMap(snap.data()!);
      } catch (e) {
        return HomePageModel.defaultModel;
      }
    });
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  DRAFT DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<HomePageModel?> fetchDraft() async {
    try {
      final snapshot = await _draftRef.get(const GetOptions(source: Source.server));
      if (snapshot.exists && snapshot.data() != null) {
        final data = _sanitize(snapshot.data()!);
        return HomePageModel.fromMap(data);
      }
      return null;
    } catch (e, st) {
      rethrow;
    }
  }

  @override
  Future<void> saveDraft(HomePageModel model) async {
    try {
      final map = {
        ...model.toMap(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      await _draftRef.set(map);
    } catch (e, st) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDraft() async {
    try {
      final snap = await _draftRef.get();
      if (snap.exists) {
        await _draftRef.delete();
      } else {
      }
    } catch (e, st) {
      rethrow;
    }
  }

  @override
  Future<void> promoteDraft() async {
    try {
      final draft = await fetchDraft();
      if (draft == null) {
        return;
      }
      final publishedModel = draft.copyWith(
        publishStatus: 'published',
        clearScheduledPublishDate: true,
      );
      await saveHomePage(publishedModel);
      await deleteDraft();
    } catch (e, st) {
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ASSETS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  }) async {
    try {
      final ref  = _storage.ref().child(storagePath);
      final mime = _detectMime(bytes);
      final task = await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url  = await task.ref.getDownloadURL();
      return url;
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _sanitize(Map<String, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }

  String _detectMime(Uint8List b) {
    if (b.length < 4) return 'application/octet-stream';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b[0] == 0xFF && b[1] == 0xD8)                                   return 'image/jpeg';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'image/gif';
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b.length >= 12 && b[8] == 0x57 && b[9] == 0x45 &&
        b[10] == 0x42 && b[11] == 0x50)                                  return 'image/webp';
    if (b[0] == 0x3C)                                                    return 'image/svg+xml';
    return 'image/jpeg';
  }
}