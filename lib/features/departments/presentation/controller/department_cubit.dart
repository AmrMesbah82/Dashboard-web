// ═══════════════════════════════════════════════════════════════════
// FILE 5: department_cubit.dart
// Path: lib/controller/department/department_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';


import '../../data/models/department_model.dart';
import '../../domain/base_repository/department_repo.dart';
import 'department_state.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  final DepartmentRepo _repo;

  DepartmentCubit({required DepartmentRepo repo})
      : _repo = repo,
        super(DepartmentInitial());

  List<DepartmentModel> _allDepartments = [];

  List<DepartmentModel> get allDepartments => _allDepartments;

  List<Map<String, String>> get dropdownItems => _allDepartments
      .map((d) => {'key': d.nameEn, 'value': d.nameEn})
      .toList();

  Future<void> loadDepartments() async {
    try {
      emit(DepartmentLoading());
      _allDepartments = await _repo.fetchAllDepartments();
      emit(DepartmentLoaded(_allDepartments));
    } catch (e) {
      emit(DepartmentError('Failed to load: $e', lastDepartments: _allDepartments));
    }
  }

  Future<void> createDepartment({
    required String nameEn,
    required String nameAr,
    String iconUrl = '',
  }) async {
    try {

      final dept = DepartmentModel(
        id:        '',
        nameEn:    nameEn,
        nameAr:    nameAr,
        iconUrl:   iconUrl,
        createdAt: DateTime.now(),
      );

      final created = await _repo.createDepartment(dept);
      _allDepartments = [created, ..._allDepartments];

      emit(DepartmentCreated(created));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(DepartmentLoaded(_allDepartments));
      });
    } catch (e) {
      emit(DepartmentError('Failed to create: $e', lastDepartments: _allDepartments));
    }
  }

  Future<void> updateDepartment({
    required String id,
    required String nameEn,
    required String nameAr,
    String iconUrl = '',
  }) async {
    try {

      final updated = DepartmentModel(
        id:        id,
        nameEn:    nameEn,
        nameAr:    nameAr,
        iconUrl:   iconUrl,
        createdAt: _allDepartments
            .firstWhere((d) => d.id == id,
            orElse: () => DepartmentModel(
                id: id, nameEn: nameEn, nameAr: nameAr, iconUrl: iconUrl))
            .createdAt,
      );

      final saved = await _repo.updateDepartment(updated);

      _allDepartments = _allDepartments
          .map((d) => d.id == id ? saved : d)
          .toList();

      emit(DepartmentUpdated(saved));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(DepartmentLoaded(_allDepartments));
      });
    } catch (e) {
      emit(DepartmentError('Failed to update: $e', lastDepartments: _allDepartments));
    }
  }

  Future<void> deleteDepartment({required String id}) async {
    try {

      await _repo.deleteDepartment(id);

      _allDepartments = _allDepartments
          .where((d) => d.id != id)
          .toList();

      emit(DepartmentDeleted(id));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(DepartmentLoaded(_allDepartments));
      });
    } catch (e) {
      emit(DepartmentError('Failed to delete: $e', lastDepartments: _allDepartments));
    }
  }
}