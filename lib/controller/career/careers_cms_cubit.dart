// ******************* FILE INFO *******************
// File Name: careers_cms_cubit.dart
// Created by: Amr Mesbah
// FIXED: loadRealData() now fetches live jobs + applications from Firestore
//        and builds the dashboard via CareersDashboardData.fromRealData()

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/model/application_model.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/model/job_listing_model.dart';
import 'package:web_app_admin/repo/application/application_repo.dart';
import 'package:web_app_admin/repo/career/careers_cms_repo.dart';
import 'package:web_app_admin/repo/career/careers_cms_repo_impl.dart';
import 'package:web_app_admin/repo/job_list/job_listing_repo.dart';

class CareersCmsCubit extends Cubit<CareersCmsState> {
  final CareersCmsRepo _repo;
  final JobListingRepo _jobRepo;
  final ApplicationRepo _appRepo;

  CareersCmsCubit({
    CareersCmsRepo? repo,
    required JobListingRepo jobRepo,
    required ApplicationRepo appRepo,
  })  : _repo = repo ?? CareersCmsRepoImpl(),
        _jobRepo = jobRepo,
        _appRepo = appRepo,
        super(CareersCmsInitial());

  // ── Convenience getter for the current model (never null) ──────────────────

  CareersCmsModel get current {
    final s = state;
    if (s is CareersCmsLoaded) return s.data;
    if (s is CareersCmsSaved) return s.data;
    if (s is CareersCmsError && s.lastData != null) return s.lastData!;
    return CareersCmsModel.empty();
  }

  // ── Load CMS content from Firestore ───────────────────────────────────────

  Future<void> load() async {
    print('🟡 [CareersCmsCubit] load()');
    emit(CareersCmsLoading());
    try {
      final model = await _repo.fetch();
      emit(CareersCmsLoaded(model));
    } catch (e) {
      print('🔴 [CareersCmsCubit] load() ERROR: $e');
      emit(CareersCmsError(e.toString()));
    }
  }

  // ── Load REAL dashboard data from Firestore jobs + applications ────────────

  Future<void> loadRealData() async {
    print('🟡 [CareersCmsCubit] loadRealData()');
    emit(CareersCmsLoading());
    try {
      // Fetch CMS content (overview, statistics) + real-time data in parallel
      final results = await Future.wait([
        _repo.fetch(),
        _jobRepo.fetchAllJobs(),
        _appRepo.fetchAllApplications(),
      ]);

      final cmsModel        = results[0] as CareersCmsModel;
      final jobs            = results[1] as List<JobPostModel>;
      final apps            = results[2] as List<ApplicationModel>;

      print('🟢 [CareersCmsCubit] loadRealData() — jobs: ${jobs.length}, apps: ${apps.length}');

      // Build dashboard from real Firebase data
      final dashboard = CareersDashboardData.fromRealData(
        jobs: jobs,
        apps: apps,
      );

      // Merge: keep CMS overview/statistics, replace dashboard with live data
      final merged = cmsModel.copyWith(dashboard: dashboard);

      emit(CareersCmsLoaded(merged));
    } catch (e) {
      print('🔴 [CareersCmsCubit] loadRealData() ERROR: $e');
      // Fallback to demo so the page still shows something
      emit(CareersCmsLoaded(CareersCmsModel.empty()));
    }
  }

  /// Fallback demo (no Firestore needed) — keep for offline testing
  void loadDemo() {
    print('🟡 [CareersCmsCubit] loadDemo()');
    emit(CareersCmsLoaded(CareersCmsModel.empty()));
  }

  // ── Save to Firestore ──────────────────────────────────────────────────────

  Future<void> save(CareersCmsModel model) async {
    print('🟡 [CareersCmsCubit] save()');
    final previous = current;
    emit(CareersCmsLoading());
    try {
      await _repo.save(model);
      print('🟢 [CareersCmsCubit] save() → OK');
      emit(CareersCmsSaved(model));
    } catch (e) {
      print('🔴 [CareersCmsCubit] save() ERROR: $e');
      emit(CareersCmsError(e.toString(), lastData: previous));
    }
  }

  // ── Local draft mutations (edit page uses these before final save) ─────────

  void updateOverviewDescription(BilingualText value) {
    final updated = current.copyWith(
      overview: current.overview.copyWith(description: value),
    );
    emit(CareersCmsLoaded(updated));
  }

  void updateOverviewActionButton(BilingualText value) {
    final updated = current.copyWith(
      overview: current.overview.copyWith(actionButtonLabel: value),
    );
    emit(CareersCmsLoaded(updated));
  }

  void addStatistic() {
    final stats = List<CareerStatItem>.from(current.statistics)
      ..add(CareerStatItem.empty());
    emit(CareersCmsLoaded(current.copyWith(statistics: stats)));
  }

  void removeStatistic(String id) {
    final stats = current.statistics.where((s) => s.id != id).toList();
    emit(CareersCmsLoaded(current.copyWith(statistics: stats)));
  }

  void updateStatistic(CareerStatItem updated) {
    final stats = current.statistics
        .map((s) => s.id == updated.id ? updated : s)
        .toList();
    emit(CareersCmsLoaded(current.copyWith(statistics: stats)));
  }
}