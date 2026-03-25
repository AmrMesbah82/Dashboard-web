// ═══════════════════════════════════════════════════════════════════
// FILE 4: department_state.dart
// Path: lib/controller/department/department_state.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/department_model.dart';

abstract class DepartmentState {}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentLoaded extends DepartmentState {
  final List<DepartmentModel> departments;
  DepartmentLoaded(this.departments);
}

class DepartmentCreated extends DepartmentState {
  final DepartmentModel department;
  DepartmentCreated(this.department);
}

class DepartmentError extends DepartmentState {
  final String message;
  final List<DepartmentModel>? lastDepartments;
  DepartmentError(this.message, {this.lastDepartments});
}