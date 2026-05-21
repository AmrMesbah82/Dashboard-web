// ******************* FILE INFO *******************
// File Name: service_cubit.dart
// Created by: Amr Mesbah

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/features/services/presentation/controller/services_state.dart';

import '../../data/models/services_model.dart';
import '../../data/repo_imp/services_repo_imp.dart';
import '../../domain/repo/services_repo.dart';



class ServiceCmsCubit extends Cubit<ServiceCmsState> {
  ServiceCmsCubit({ServiceRepository? repo})
      : _repo = repo ?? ServiceRepositoryImpl(),
        super(ServiceCmsInitial());

  final ServiceRepository _repo;

  ServicePageModel _model = ServicePageModel.empty();
  ServicePageModel get current => _model;

  // ── Unique ID generator ───────────────────────────────────────────────────
  String _generateId() => 'ji_${DateTime.now().microsecondsSinceEpoch}';

  // ── Load (cache-first) ────────────────────────────────────────────────────
  Future<void> load() async {
    emit(ServiceCmsLoading());
    try {
      _model = await _repo.fetchServicePage();
      emit(ServiceCmsLoaded(_model));
    } catch (e) {
      emit(ServiceCmsError(e.toString()));
    }
  }

  // ── Load FRESH (server only) ──────────────────────────────────────────────
  Future<void> loadFresh() async {
    emit(ServiceCmsLoading());
    try {
      _model = await _repo.fetchServicePageFresh();
      emit(ServiceCmsLoaded(_model));
    } catch (e) {
      emit(ServiceCmsError(e.toString()));
    }
  }

  // ── Replace entire model (used by edit pages before save) ─────────────────
  void replaceModel(ServicePageModel model) {
    _model = model;
  }

  // ── Title / Short Description ─────────────────────────────────────────────
  void updateTitle({required String en, required String ar}) {
    _model = _model.copyWith(title: BilingualText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    _model = _model.copyWith(shortDescription: BilingualText(en: en, ar: ar));
  }

  // ── Journey item mutations ────────────────────────────────────────────────
  void updateJourneySubTitle(String id, {required String en, required String ar}) {
    _model = _model.copyWith(
      journeyItems: _model.journeyItems
          .map((j) => j.id == id ? j.copyWith(subTitle: BilingualText(en: en, ar: ar)) : j)
          .toList(),
    );
  }

  void updateJourneyTitle(String id, {required String en, required String ar}) {
    _model = _model.copyWith(
      journeyItems: _model.journeyItems
          .map((j) => j.id == id ? j.copyWith(title: BilingualText(en: en, ar: ar)) : j)
          .toList(),
    );
  }

  void updateJourneyDescription(String id, {required String en, required String ar}) {
    _model = _model.copyWith(
      journeyItems: _model.journeyItems
          .map((j) => j.id == id ? j.copyWith(description: BilingualText(en: en, ar: ar)) : j)
          .toList(),
    );
  }

  // ── Add new journey item (in-memory; persisted on save) ───────────────────
  String addJourneyItem() {
    final newId   = _generateId();
    final newItem = JourneyItemModel(id: newId);
    _model = _model.copyWith(journeyItems: [..._model.journeyItems, newItem]);
    return newId;
  }

  // ── Remove journey item (in-memory; persisted on save) ────────────────────
  void removeJourneyItem(String id) {
    _model = _model.copyWith(
      journeyItems: _model.journeyItems.where((j) => j.id != id).toList(),
    );
  }

  // ── Preserve existing icon URL (no re-upload needed) ────────────────────
  void preserveJourneyIconUrl(String id, String url) {
    _model = _model.copyWith(
      journeyItems: _model.journeyItems
          .map((j) => j.id == id ? j.copyWith(iconUrl: url) : j)
          .toList(),
    );
  }

  // ── Upload journey icon to Firebase Storage ───────────────────────────────
  Future<void> uploadJourneyIcon(String id, Uint8List bytes) async {
    try {
      final url = await _repo.uploadImage(
        bytes:       bytes,
        storagePath: 'service_cms/journey/$id/icon',
      );
      _model = _model.copyWith(
        journeyItems: _model.journeyItems
            .map((j) => j.id == id ? j.copyWith(iconUrl: url) : j)
            .toList(),
      );
    } catch (e) {
      emit(ServiceCmsError('Icon upload failed: $e'));
      rethrow;
    }
  }

  // ── Save all to Firestore ─────────────────────────────────────────────────
  Future<void> save({required String publishStatus}) async {
    try {
      await _repo.saveServicePage(_model);
      // Fetch fresh from server so image URLs are confirmed
      _model = await _repo.fetchServicePageFresh();
      emit(ServiceCmsSaved(_model));
    } catch (e) {
      emit(ServiceCmsError(e.toString()));
    }
  }
}