// ═══════════════════════════════════════════════════════════════════
// FILE 2: department_repo.dart
// Path: lib/repo/department/department_repo.dart
// ═══════════════════════════════════════════════════════════════════


import '../../data/models/department_model.dart';

abstract class DepartmentRepo {
  Future<List<DepartmentModel>> fetchAllDepartments();
  Future<DepartmentModel> createDepartment(DepartmentModel dept);
  Future<DepartmentModel> updateDepartment(DepartmentModel dept);
  Future<void> deleteDepartment(String id);
}