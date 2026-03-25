// ******************* FILE INFO *******************
// File Name: careers_cms_repo_impl.dart
// Created by: Amr Mesbah

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/repo/career/careers_cms_repo.dart';

class CareersCmsRepoImpl implements CareersCmsRepo {
  static const String _collection = 'cms';
  static const String _docId      = 'careers';

  final FirebaseFirestore _db;

  CareersCmsRepoImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection(_collection).doc(_docId);

  // ── fetch ──────────────────────────────────────────────────────────────────

  @override
  Future<CareersCmsModel> fetch() async {
    print('🟡 [CareersCmsRepo] fetch()');
    final snap = await _ref.get();
    if (!snap.exists || snap.data() == null) {
      print('🟠 [CareersCmsRepo] fetch() → document missing, returning empty');
      return CareersCmsModel.empty();
    }
    final model = CareersCmsModel.fromMap(snap.data()!);
    print(
        '🟢 [CareersCmsRepo] fetch() → OK  stats: ${model.statistics.length}');
    return model;
  }

  // ── save ───────────────────────────────────────────────────────────────────

  @override
  Future<void> save(CareersCmsModel model) async {
    print('🟡 [CareersCmsRepo] save()');
    await _ref.set(model.toMap(), SetOptions(merge: true));
    print('🟢 [CareersCmsRepo] save() → OK');
  }
}