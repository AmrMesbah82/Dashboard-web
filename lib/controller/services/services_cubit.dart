// ******************* FILE INFO *******************
// File Name: service_cubit.dart
// Created by: Amr Mesbah

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/repo/Services/repo.dart';
import 'package:web_app_admin/repo/Services/repo_imp.dart';


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
    print('🟡 [ServiceCubit] load() called');
    emit(ServiceCmsLoading());
    try {
      _model = await _repo.fetchServicePage();
      print('🟢 [ServiceCubit] load() → emitting ServiceCmsLoaded');
      emit(ServiceCmsLoaded(_model));
    } catch (e) {
      print('🔴 [ServiceCubit] load() ERROR: $e');
      emit(ServiceCmsError(e.toString()));
    }
  }

  // ── Load FRESH (server only) ──────────────────────────────────────────────
  Future<void> loadFresh() async {
    print('🟡 [ServiceCubit] loadFresh() called');
    emit(ServiceCmsLoading());
    try {
      _model = await _repo.fetchServicePageFresh();
      print('🟢 [ServiceCubit] loadFresh() → emitting ServiceCmsLoaded');
      emit(ServiceCmsLoaded(_model));
    } catch (e) {
      print('🔴 [ServiceCubit] loadFresh() ERROR: $e');
      emit(ServiceCmsError(e.toString()));
    }
  }

  // ── Replace entire model (used by edit pages before save) ─────────────────
  void replaceModel(ServicePageModel model) {
    print('🟡 [ServiceCubit] replaceModel() journeyItems=${model.journeyItems.length}');
    _model = model;
  }

  // ── Title / Short Description ─────────────────────────────────────────────
  void updateTitle({required String en, required String ar}) {
    print('🟡 [ServiceCubit] updateTitle() en=$en ar=$ar');
    _model = _model.copyWith(title: BilingualText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    print('🟡 [ServiceCubit] updateShortDescription()');
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
    print('🟡 [ServiceCubit] addJourneyItem() → id=$newId');
    return newId;
  }

  // ── Remove journey item (in-memory; persisted on save) ────────────────────
  void removeJourneyItem(String id) {
    print('🟡 [ServiceCubit] removeJourneyItem() id=$id');
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
    print('🟡 [ServiceCubit] uploadJourneyIcon() id=$id');
    try {
      final url = await _repo.uploadImage(
        bytes:       bytes,
        storagePath: 'service_cms/journey/$id/icon',
      );
      print('🟢 [ServiceCubit] uploadJourneyIcon() → url=$url');
      _model = _model.copyWith(
        journeyItems: _model.journeyItems
            .map((j) => j.id == id ? j.copyWith(iconUrl: url) : j)
            .toList(),
      );
    } catch (e) {
      print('🔴 [ServiceCubit] uploadJourneyIcon() ERROR: $e');
      emit(ServiceCmsError('Icon upload failed: $e'));
      rethrow;
    }
  }

  // ── Save all to Firestore ─────────────────────────────────────────────────
  Future<void> save({required String publishStatus}) async {
    print('🟡 [ServiceCubit] save() publishStatus=$publishStatus');
    print('   model.title.en            = ${_model.title.en}');
    print('   model.journeyItems.length = ${_model.journeyItems.length}');
    try {
      await _repo.saveServicePage(_model);
      // Fetch fresh from server so image URLs are confirmed
      _model = await _repo.fetchServicePageFresh();
      print('🟢 [ServiceCubit] save() → emitting ServiceCmsSaved');
      emit(ServiceCmsSaved(_model));
    } catch (e) {
      print('🔴 [ServiceCubit] save() ERROR: $e');
      emit(ServiceCmsError(e.toString()));
    }
  }
}