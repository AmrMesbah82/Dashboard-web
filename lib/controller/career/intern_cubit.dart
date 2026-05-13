// ******************* FILE INFO *******************
// File Name: intern_cubit.dart

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/career/intern_state.dart';
import 'package:web_app_admin/model/intern_model.dart';
import 'package:web_app_admin/repo/career/intern_repository.dart';

class InternCubit extends Cubit<InternState> {
  final InternRepository _repo;
  List<InternModel> _interns = [];

  InternCubit({InternRepository? repo})
      : _repo = repo ?? InternRepository(),
        super(InternInitial());

  List<InternModel> get interns => List.unmodifiable(_interns);

  // ── Load all ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    emit(InternLoading());
    try {
      _interns = await _repo.fetchAll();
      emit(InternLoaded(List.from(_interns)));
    } catch (e) {
      emit(InternError(e.toString()));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> create(InternModel intern, {Uint8List? photoBytes}) async {
    emit(InternSaving());
    try {
      final created = await _repo.create(intern, photoBytes: photoBytes);
      _interns.insert(0, created);
      emit(InternCreated(List.from(_interns), created));
    } catch (e) {
      emit(InternError(e.toString()));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> update(InternModel intern, {Uint8List? photoBytes}) async {
    emit(InternSaving());
    try {
      final updated = await _repo.update(intern, photoBytes: photoBytes);
      final idx = _interns.indexWhere((i) => i.id == intern.id);
      if (idx != -1) _interns[idx] = updated;
      emit(InternUpdated(List.from(_interns)));
    } catch (e) {
      emit(InternError(e.toString()));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      _interns.removeWhere((i) => i.id == id);
      emit(InternDeleted(List.from(_interns)));
    } catch (e) {
      emit(InternError(e.toString()));
    }
  }
}