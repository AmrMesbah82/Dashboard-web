// ═══════════════════════════════════════════════════════════════════
// FILE 5: application_cubit.dart
// Path: lib/controller/application/application_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/application/application_state.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/repo/application/application_repo.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepo _repo;

  ApplicationCubit({required ApplicationRepo repo})
      : _repo = repo,
        super(ApplicationInitial());

  List<ApplicationModel> _allApps = [];
  String _activeDeptFilter = 'All';
  String _searchQuery = '';

  List<ApplicationModel> get allApps => _allApps;

  Future<void> loadApplications() async {
    try {
      print('🟡 [ApplicationCubit] loadApplications()');
      emit(ApplicationLoading());
      _allApps = await _repo.fetchAllApplications();
      print('🟢 [ApplicationCubit] loadApplications() — ${_allApps.length}');
      _emitLoaded();
    } catch (e) {
      print('🔴 [ApplicationCubit] loadApplications() ERROR: $e');
      emit(ApplicationError('Failed to load: $e', lastApps: _allApps));
    }
  }

  void setDeptFilter(String dept) {
    _activeDeptFilter = dept;
    _emitLoaded();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _emitLoaded();
  }

  Future<void> loadDetail(String jobId, String appId) async {
    try {
      print('🟡 [ApplicationCubit] loadDetail($jobId/$appId)');
      final local = _allApps.where((a) => a.id == appId && a.jobId == jobId).toList();
      if (local.isNotEmpty) {
        emit(ApplicationDetailLoaded(local.first));
        return;
      }
      final app = await _repo.fetchApplicationById(jobId, appId);
      if (app != null) {
        emit(ApplicationDetailLoaded(app));
      } else {
        emit(ApplicationError('Application not found', lastApps: _allApps));
      }
    } catch (e) {
      print('🔴 [ApplicationCubit] loadDetail() ERROR: $e');
      emit(ApplicationError('Failed to load: $e', lastApps: _allApps));
    }
  }

  Future<void> updateStatus(String jobId, String appId, ApplicationStatus newStatus) async {
    try {
      print('🟡 [ApplicationCubit] updateStatus($appId → ${newStatus.label})');
      await _repo.updateStatus(jobId, appId, newStatus);

      _allApps = _allApps.map((a) {
        if (a.id == appId && a.jobId == jobId) return a.copyWith(status: newStatus);
        return a;
      }).toList();

      final updated = _allApps.firstWhere((a) => a.id == appId && a.jobId == jobId);
      emit(ApplicationUpdated(updated));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) _emitLoaded();
      });

      print('🟢 [ApplicationCubit] updateStatus() — done');
    } catch (e) {
      print('🔴 [ApplicationCubit] updateStatus() ERROR: $e');
      emit(ApplicationError('Failed to update: $e', lastApps: _allApps));
    }
  }

  Future<void> updateScoring(ApplicationModel updated) async {
    try {
      print('🟡 [ApplicationCubit] updateScoring(${updated.id})');
      await _repo.updateApplication(updated);

      _allApps = _allApps.map((a) {
        if (a.id == updated.id && a.jobId == updated.jobId) return updated;
        return a;
      }).toList();

      emit(ApplicationUpdated(updated));

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) _emitLoaded();
      });

      print('🟢 [ApplicationCubit] updateScoring() — done');
    } catch (e) {
      print('🔴 [ApplicationCubit] updateScoring() ERROR: $e');
      emit(ApplicationError('Failed to save: $e', lastApps: _allApps));
    }
  }

  void backToList() => _emitLoaded();

  void _emitLoaded() {
    emit(ApplicationLoaded(
      applications: _allApps,
      activeDeptFilter: _activeDeptFilter,
      searchQuery: _searchQuery,
    ));
  }
}