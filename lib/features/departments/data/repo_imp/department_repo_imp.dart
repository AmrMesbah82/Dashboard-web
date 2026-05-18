// ═══════════════════════════════════════════════════════════════════
// FILE 3: department_repo_imp.dart
// Path: lib/repo/department/department_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repo/department_repo.dart';
import '../model/department_model.dart';


class DepartmentRepoImp implements DepartmentRepo {
  final FirebaseFirestore _firestore;

  DepartmentRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('departments');

  @override
  Future<List<DepartmentModel>> fetchAllDepartments() async {
    try {
      print('🟡 [DepartmentRepoImp] fetchAllDepartments()');
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      final depts = snapshot.docs
          .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
          .toList();

      print('🟢 [DepartmentRepoImp] fetchAllDepartments() — got ${depts.length}');
      return depts;
    } catch (e) {
      print('🔴 [DepartmentRepoImp] fetchAllDepartments() ERROR: $e');
      try {
        final snapshot = await _collection
            .orderBy('createdAt', descending: true)
            .get(const GetOptions(source: Source.cache));
        return snapshot.docs
            .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (cacheError) {
        print('🔴 [DepartmentRepoImp] CACHE ERROR: $cacheError');
        rethrow;
      }
    }
  }

  @override
  Future<DepartmentModel> createDepartment(DepartmentModel dept) async {
    try {
      print('🟡 [DepartmentRepoImp] createDepartment() — ${dept.nameEn}');
      final docRef = await _collection.add(dept.toMap());
      final created = dept.copyWith(id: docRef.id);
      print('🟢 [DepartmentRepoImp] createDepartment() — ID: ${docRef.id}');
      return created;
    } catch (e) {
      print('🔴 [DepartmentRepoImp] createDepartment() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<DepartmentModel> updateDepartment(DepartmentModel dept) async {
    try {
      print('🟡 [DepartmentRepoImp] updateDepartment() — ${dept.id}');
      await _collection.doc(dept.id).update(dept.toMap());
      print('🟢 [DepartmentRepoImp] updateDepartment() — done');
      return dept;
    } catch (e) {
      print('🔴 [DepartmentRepoImp] updateDepartment() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      print('🟡 [DepartmentRepoImp] deleteDepartment() — $id');
      await _collection.doc(id).delete();
      print('🟢 [DepartmentRepoImp] deleteDepartment() — done');
    } catch (e) {
      print('🔴 [DepartmentRepoImp] deleteDepartment() ERROR: $e');
      rethrow;
    }
  }
}