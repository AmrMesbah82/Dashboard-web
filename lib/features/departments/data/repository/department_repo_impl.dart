// ═══════════════════════════════════════════════════════════════════
// FILE 3: department_repo_impl.dart
// Path: lib/features/departments/data/repository/department_repo_impl.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/flat_codec.dart';
import '../../domain/base_repository/department_repo.dart';
import '../models/department_model.dart';


class DepartmentRepoImp implements DepartmentRepo {
  final FirebaseFirestore _firestore;

  DepartmentRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('departments');

  @override
  Future<List<DepartmentModel>> fetchAllDepartments() async {
    try {
      final snapshot = await _collection
          .orderBy('Last_Updated_At', descending: true)
          .get(const GetOptions(source: Source.server));

      final depts = snapshot.docs
          .map((doc) => DepartmentModel.fromMap(
                doc.id,
                FlatCodec.decode(doc.data(), DepartmentModel.flatTemplate),
              ))
          .toList();

      return depts;
    } catch (e) {
      try {
        final snapshot = await _collection
            .orderBy('Last_Updated_At', descending: true)
            .get(const GetOptions(source: Source.cache));
        return snapshot.docs
            .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (cacheError) {
        rethrow;
      }
    }
  }

  @override
  Future<DepartmentModel> createDepartment(DepartmentModel dept) async {
    try {
      final docRef = await _collection.add(FlatCodec.encodeNew(dept.toMap()));
      final created = dept.copyWith(id: docRef.id);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DepartmentModel> updateDepartment(DepartmentModel dept) async {
    try {
      await FlatCodec.writeVersioned(_collection.doc(dept.id), dept.toMap());
      return dept;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}