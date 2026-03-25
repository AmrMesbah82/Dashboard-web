// ******************* FILE INFO *******************
// File Name: job_listing_cubit.dart
// Created by: Amr Mesbah
// Purpose: Cubit for Job Listing — Firebase Firestore via repository pattern
// FIXED: saveJob() no longer forces JobStatus.active on every publish —
//        it now respects the status passed in the model (active OR inactive)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/job_list/job_listing_state.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/repo/job_list/job_listing_repo.dart';

class JobListingCubit extends Cubit<JobListingState> {
  final JobListingRepo _repo;

  JobListingCubit({required JobListingRepo repo})
      : _repo = repo,
        super(JobListingInitial());

  List<JobPostModel> _allJobs = [];
  String _activeFilter = 'All';
  String _searchQuery = '';
  StreamSubscription? _streamSub;

  List<JobPostModel> get allJobs => _allJobs;

  // ══════════════════════════════════════════════════════════════════════════
  //  LOAD ALL JOBS (one-time fetch)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadJobs() async {
    try {
      print('🟡 [JobListingCubit] loadJobs()');
      emit(JobListingLoading());
      _allJobs = await _repo.fetchAllJobs();
      print('🟢 [JobListingCubit] loadJobs() — loaded ${_allJobs.length} jobs');
      _emitLoaded();
    } catch (e) {
      print('🔴 [JobListingCubit] loadJobs() ERROR: $e');
      emit(JobListingError('Failed to load jobs: $e', lastJobs: _allJobs));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STREAM ALL JOBS (real-time)
  // ══════════════════════════════════════════════════════════════════════════

  void streamJobs() {
    print('🟡 [JobListingCubit] streamJobs()');
    emit(JobListingLoading());
    _streamSub?.cancel();
    _streamSub = _repo.streamAllJobs().listen(
          (jobs) {
        print('🟢 [JobListingCubit] streamJobs() — received ${jobs.length} jobs');
        _allJobs = jobs;
        _emitLoaded();
      },
      onError: (e) {
        print('🔴 [JobListingCubit] streamJobs() ERROR: $e');
        emit(JobListingError('Stream error: $e', lastJobs: _allJobs));
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FILTER & SEARCH
  // ══════════════════════════════════════════════════════════════════════════

  void setFilter(String filter) {
    _activeFilter = filter;
    _emitLoaded();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _emitLoaded();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> addJob(JobPostModel job) async {
    try {
      print('🟡 [JobListingCubit] addJob() — title: ${job.title.en}');
      final created = await _repo.createJob(job);
      _allJobs = [created, ..._allJobs];
      _emitLoaded();
      print('🟢 [JobListingCubit] addJob() — done');
    } catch (e) {
      print('🔴 [JobListingCubit] addJob() ERROR: $e');
      emit(JobListingError('Failed to add job: $e', lastJobs: _allJobs));
    }
  }

  Future<void> updateJob(JobPostModel updated) async {
    try {
      print('🟡 [JobListingCubit] updateJob(${updated.id})');
      await _repo.updateJob(updated);
      _allJobs = _allJobs.map((j) => j.id == updated.id ? updated : j).toList();
      _emitLoaded();
      print('🟢 [JobListingCubit] updateJob(${updated.id}) — done');
    } catch (e) {
      print('🔴 [JobListingCubit] updateJob(${updated.id}) ERROR: $e');
      emit(JobListingError('Failed to update job: $e', lastJobs: _allJobs));
    }
  }

  Future<void> removeJob(String id) async {
    try {
      print('🟡 [JobListingCubit] removeJob($id)');
      await _repo.removeJob(id);
      _allJobs = _allJobs.map((j) {
        if (j.id == id) {
          return j.copyWith(status: JobStatus.removed, endedDate: DateTime.now());
        }
        return j;
      }).toList();
      _emitLoaded();
      print('🟢 [JobListingCubit] removeJob($id) — done');
    } catch (e) {
      print('🔴 [JobListingCubit] removeJob($id) ERROR: $e');
      emit(JobListingError('Failed to remove job: $e', lastJobs: _allJobs));
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      print('🟡 [JobListingCubit] deleteJob($id)');
      await _repo.deleteJob(id);
      _allJobs = _allJobs.where((j) => j.id != id).toList();
      _emitLoaded();
      print('🟢 [JobListingCubit] deleteJob($id) — done');
    } catch (e) {
      print('🔴 [JobListingCubit] deleteJob($id) ERROR: $e');
      emit(JobListingError('Failed to delete job: $e', lastJobs: _allJobs));
    }
  }

  Future<void> updateJobStatus(String id, JobStatus status) async {
    try {
      print('🟡 [JobListingCubit] updateJobStatus($id, ${status.label})');
      await _repo.updateJobStatus(id, status);
      _allJobs = _allJobs.map((j) {
        if (j.id == id) {
          return j.copyWith(
            status: status,
            endedDate: (status == JobStatus.ended ||
                status == JobStatus.removed ||
                status == JobStatus.inactive)
                ? DateTime.now()
                : j.endedDate,
            postedDate: status == JobStatus.active ? DateTime.now() : j.postedDate,
          );
        }
        return j;
      }).toList();
      _emitLoaded();
      print('🟢 [JobListingCubit] updateJobStatus($id) — done');
    } catch (e) {
      print('🔴 [JobListingCubit] updateJobStatus($id) ERROR: $e');
      emit(JobListingError('Failed to update status: $e', lastJobs: _allJobs));
    }
  }

  /// Load a single job for editing/preview
  Future<void> loadJobDetail(String id) async {
    try {
      print('🟡 [JobListingCubit] loadJobDetail($id)');
      final local = _allJobs.where((j) => j.id == id).toList();
      if (local.isNotEmpty) {
        emit(JobListingDetailLoaded(local.first));
        return;
      }
      final job = await _repo.fetchJobById(id);
      if (job != null) {
        emit(JobListingDetailLoaded(job));
      } else {
        emit(JobListingError('Job not found', lastJobs: _allJobs));
      }
    } catch (e) {
      print('🔴 [JobListingCubit] loadJobDetail($id) ERROR: $e');
      emit(JobListingError('Failed to load job: $e', lastJobs: _allJobs));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE JOB (create or update)
  //
  //  KEY FIX: We no longer force status = JobStatus.active on publish.
  //  The edit page sets status via the toggle BEFORE calling saveJob(),
  //  so we respect whatever status is already on the model.
  //
  //  Rules:
  //    publishStatus == 'draft'     → status always = drafted
  //    publishStatus == 'published' → use job.status as-is (active OR inactive)
  //
  //  This means:
  //    toggle ON  + Publish → saves as Active
  //    toggle OFF + Publish → saves as Inactive
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveJob(JobPostModel job, {String? publishStatus}) async {
    try {
      final ps = publishStatus ?? job.publishStatus;

      // Draft always forces drafted status.
      // Published keeps the status that was set by the toggle in the edit page.
      final resolvedStatus = ps == 'draft' ? JobStatus.drafted : job.status;

      final updated = job.copyWith(
        publishStatus: ps,
        status: resolvedStatus,
        // Only stamp a new postedDate when first publishing as active
        postedDate: (ps == 'published' && resolvedStatus == JobStatus.active)
            ? DateTime.now()
            : job.postedDate,
      );

      print('🟡 [JobListingCubit] saveJob(${updated.id}) — publishStatus: $ps | status: ${updated.status.label}');

      final existIndex = _allJobs.indexWhere((j) => j.id == updated.id);
      if (existIndex >= 0) {
        await _repo.updateJob(updated);
        _allJobs[existIndex] = updated;
        print('🟢 [JobListingCubit] saveJob() — updated existing');
      } else {
        final created = await _repo.createJob(updated);
        _allJobs = [created, ..._allJobs];
        print('🟢 [JobListingCubit] saveJob() — created new with ID: ${created.id}');
      }

      emit(JobListingSaved(updated));

      // Re-emit loaded state after brief delay so UI can react
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) _emitLoaded();
      });
    } catch (e) {
      print('🔴 [JobListingCubit] saveJob() ERROR: $e');
      emit(JobListingError('Failed to save job: $e', lastJobs: _allJobs));
    }
  }

  /// Back to list from detail
  void backToList() {
    _emitLoaded();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPER
  // ══════════════════════════════════════════════════════════════════════════

  void _emitLoaded() {
    emit(JobListingLoaded(
      jobs: _allJobs,
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
    ));
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}