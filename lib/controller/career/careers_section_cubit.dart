// ******************* FILE INFO *******************
// File Name: careers_section_cubit.dart
// Cubit for Why Join Our Team / Our Interns / Our Teams
// One cubit instance per section tab — pass sectionKey in constructor.

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_app_admin/controller/career/careers_section_state.dart';
import 'package:web_app_admin/model/careers_section_model.dart';
import 'package:web_app_admin/repo/career/careers_section_repo.dart';
import 'package:web_app_admin/repo/career/careers_section_repo_imp.dart';


class CareersSectionCubit extends Cubit<CareersSectionState> {
  final String sectionKey; // 'whyJoinOurTeam' | 'ourInterns' | 'ourTeams'
  final CareersSectionRepo _repo;
  late CareersSectionModel _model;

  CareersSectionCubit({
    required this.sectionKey,
    CareersSectionRepo? repo,
  })  : _repo = repo ?? CareersSectionRepoImp(),
        super(CareersSectionInitial()) {
    _model = CareersSectionModel.empty(sectionKey);
  }

  CareersSectionModel get current => _model;

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> load() async {
    print('🟡 [CareersSectionCubit] load($sectionKey)');
    emit(CareersSectionLoading());
    try {
      _model = await _repo.load(sectionKey);
      emit(CareersSectionLoaded(_model));
      print('🟢 [CareersSectionCubit] loaded ${_model.items.length} items');
    } catch (e) {
      print('🔴 [CareersSectionCubit] load error: $e');
      emit(CareersSectionError(e.toString()));
    }
  }

  // ── Add Item ────────────────────────────────────────────────────────────────
  void addItem() {
    final newId = const Uuid().v4();
    final updated = List<CareersSectionItem>.from(_model.items)
      ..add(CareersSectionItem(id: newId));
    _model = _model.copyWith(items: updated);
    emit(CareersSectionLoaded(_model));
    print('🟢 [CareersSectionCubit] addItem → ${_model.items.length} items');
  }

  // ── Remove Item ─────────────────────────────────────────────────────────────
  void removeItem(String itemId) {
    final updated =
    _model.items.where((item) => item.id != itemId).toList();
    _model = _model.copyWith(items: updated);
    emit(CareersSectionLoaded(_model));
    print('🟢 [CareersSectionCubit] removeItem($itemId) → '
        '${_model.items.length} items');
  }

  // ── Update Title ────────────────────────────────────────────────────────────
  void updateTitle(String itemId, {String? en, String? ar}) {
    final updated = _model.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(
        title: item.title.copyWith(en: en, ar: ar),
      );
    }).toList();
    _model = _model.copyWith(items: updated);
  }

  // ── Update Description ──────────────────────────────────────────────────────
  void updateDescription(String itemId, {String? en, String? ar}) {
    final updated = _model.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(
        description: item.description.copyWith(en: en, ar: ar),
      );
    }).toList();
    _model = _model.copyWith(items: updated);
  }

  // ── Upload Icon ─────────────────────────────────────────────────────────────
  Future<void> uploadIcon(String itemId, Uint8List bytes) async {
    print('🟡 [CareersSectionCubit] uploadIcon($itemId)');
    final url = await _repo.uploadIcon(sectionKey, itemId, bytes);
    final updated = _model.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(iconUrl: url);
    }).toList();
    _model = _model.copyWith(items: updated);
    print('🟢 [CareersSectionCubit] icon uploaded → $url');
  }

  // ── Upload SVG Image ────────────────────────────────────────────────────────
  Future<void> uploadSvg(String itemId, Uint8List bytes) async {
    print('🟡 [CareersSectionCubit] uploadSvg($itemId)');
    final url = await _repo.uploadSvg(sectionKey, itemId, bytes);
    final updated = _model.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(svgUrl: url);
    }).toList();
    _model = _model.copyWith(items: updated);
    print('🟢 [CareersSectionCubit] svg uploaded → $url');
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> save() async {
    print('🟡 [CareersSectionCubit] save($sectionKey)');
    emit(CareersSectionLoading());
    try {
      _model = _model.copyWith(lastUpdated: DateTime.now());
      await _repo.save(_model);
      // Reload to get server timestamp
      _model = await _repo.load(sectionKey);
      emit(CareersSectionSaved(_model));
      print('🟢 [CareersSectionCubit] saved successfully');
    } catch (e) {
      print('🔴 [CareersSectionCubit] save error: $e');
      emit(CareersSectionError(e.toString()));
    }
  }
}