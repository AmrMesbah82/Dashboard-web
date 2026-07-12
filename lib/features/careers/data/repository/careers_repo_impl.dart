// ******************* FILE INFO *******************
// File Name: careers_repo_impl.dart
// Created by: Amr Mesbah

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../core/utils/flat_codec.dart';
import '../../domain/base_repository/careers_repo.dart';
import '../models/careers_model.dart';

class CareersCmsRepoImpl implements CareersCmsRepo {
  static const String _collection = 'careersPage';
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
    final raw = snap.data()!;
    final decoded = FlatCodec.decode(raw, CareersCmsModel.flatTemplate);

    // Last_Updated_At is stored as a SCALAR Firestore Timestamp by the codec;
    // surface it to the model under 'lastUpdated'.
    final ts = raw['Last_Updated_At'];
    if (ts is Timestamp) {
      decoded['lastUpdated'] = ts.toDate().toIso8601String();
    }

    return CareersCmsModel.fromMap(decoded);
  }

  // ── save ───────────────────────────────────────────────────────────────────

  @override
  Future<void> save(CareersCmsModel model) async {
    // Versioned append write; scalar Last_Updated_At added by the codec.
    final nested = model.toMap()..remove('lastUpdated');
    await FlatCodec.writeVersioned(_ref, nested);
  }
}