// ******************* FILE INFO *******************
// File Name: careers_repo_impl.dart
// Created by: Amr Mesbah

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../domain/base_repository/careers_repo.dart';
import '../models/careers_model.dart';

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
    final snap = await _ref.get();
    if (!snap.exists || snap.data() == null) {
      return CareersCmsModel.empty();
    }
    final model = CareersCmsModel.fromMap(snap.data()!);

    return model;
  }

  // ── save ───────────────────────────────────────────────────────────────────

  @override
  Future<void> save(CareersCmsModel model) async {
    await _ref.set(model.toMap(), SetOptions(merge: true));
  }
}