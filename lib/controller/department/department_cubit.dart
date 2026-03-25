// ═══════════════════════════════════════════════════════════════════
// FILE 5: department_cubit.dart
// Path: lib/controller/department/department_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/department/department_state.dart';
import 'package:web_app_admin/model/department_model.dart';
import 'package:web_app_admin/repo/department/department_repo.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  final DepartmentRepo _repo;

  DepartmentCubit({required DepartmentRepo repo})
      : _repo = repo,
        super(DepartmentInitial());

  List<DepartmentModel> _allDepartments = [];

  List<DepartmentModel> get allDepartments => _allDepartments;

  /// Returns departments as dropdown items for Job Listing edit page
  List<Map<String, String>> get dropdownItems => _allDepartments
      .map((d) => {'key': d.nameEn, 'value': d.nameEn})
      .toList();

  Future<void> loadDepartments() async {
    try {
      print('🟡 [DepartmentCubit] loadDepartments()');
      emit(DepartmentLoading());
      _allDepartments = await _repo.fetchAllDepartments();
      print('🟢 [DepartmentCubit] loadDepartments() — ${_allDepartments.length}');
      emit(DepartmentLoaded(_allDepartments));
    } catch (e) {
      print('🔴 [DepartmentCubit] loadDepartments() ERROR: $e');
      emit(DepartmentError('Failed to load: $e', lastDepartments: _allDepartments));
    }
  }

  Future<void> createDepartment({
    required String nameEn,
    required String nameAr,
    String iconUrl = '',
  }) async {
    try {
      print('🟡 [DepartmentCubit] createDepartment() — $nameEn');

      final dept = DepartmentModel(
        id: '',
        nameEn: nameEn,
        nameAr: nameAr,
        iconUrl: iconUrl,
        createdAt: DateTime.now(),
      );

      final created = await _repo.createDepartment(dept);
      _allDepartments = [created, ..._allDepartments];

      print('🟢 [DepartmentCubit] createDepartment() — done');
      emit(DepartmentCreated(created));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(DepartmentLoaded(_allDepartments));
      });
    } catch (e) {
      print('🔴 [DepartmentCubit] createDepartment() ERROR: $e');
      emit(DepartmentError('Failed to create: $e', lastDepartments: _allDepartments));
    }
  }
}