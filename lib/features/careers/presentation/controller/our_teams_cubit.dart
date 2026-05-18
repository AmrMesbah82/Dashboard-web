// ******************* FILE INFO *******************
// File Name: our_teams_cubit.dart

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/our_teams_model.dart';
import '../../data/repo_imp/our_teams_repo_impl.dart';
import '../../domain/repo/our_teams_repo.dart';
import 'our_teams_state.dart';



class OurTeamsCubit extends Cubit<OurTeamsState> {
  final OurTeamsRepo _repo;
  OurTeamsModel _current = const OurTeamsModel();

  OurTeamsCubit({OurTeamsRepo? repo})
      : _repo = repo ?? OurTeamsRepoImpl(),
        super(OurTeamsInitial());

  OurTeamsModel get current => _current;

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> load() async {
    emit(OurTeamsLoading());
    try {
      _current = await _repo.load();
      emit(OurTeamsLoaded(_current));
    } catch (e) {
      emit(OurTeamsError(e.toString()));
    }
  }

  // ── Add team item ────────────────────────────────────────────────────────────
  void addItem() {
    final newItem = OurTeamItem(
      id: const Uuid().v4(),
      deliverableItems: [],
    );
    _current = _current.copyWith(
      items: [..._current.items, newItem],
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Remove team item ─────────────────────────────────────────────────────────
  void removeItem(String itemId) {
    _current = _current.copyWith(
      items: _current.items.where((i) => i.id != itemId).toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Update heading ───────────────────────────────────────────────────────────
  void updateHeading(String itemId, {required String en, required String ar}) {
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(heading: BilingualText(en: en, ar: ar))
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Update title ─────────────────────────────────────────────────────────────
  void updateTitle(String itemId, {required String en, required String ar}) {
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(title: BilingualText(en: en, ar: ar))
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Update description ───────────────────────────────────────────────────────
  void updateDescription(String itemId,
      {required String en, required String ar}) {
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(description: BilingualText(en: en, ar: ar))
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Add deliverable ──────────────────────────────────────────────────────────
  void addDeliverable(String itemId) {
    final newD = OurTeamsDeliverable(id: const Uuid().v4());
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(
          deliverableItems: [...i.deliverableItems, newD])
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Remove deliverable ───────────────────────────────────────────────────────
  void removeDeliverable(String itemId, String deliverableId) {
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(
          deliverableItems: i.deliverableItems
              .where((d) => d.id != deliverableId)
              .toList())
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Update deliverable label ─────────────────────────────────────────────────
  void updateDeliverable(
      String itemId, String deliverableId, BilingualText label) {
    _current = _current.copyWith(
      items: _current.items
          .map((i) => i.id == itemId
          ? i.copyWith(
          deliverableItems: i.deliverableItems
              .map((d) =>
          d.id == deliverableId ? d.copyWith(label: label) : d)
              .toList())
          : i)
          .toList(),
    );
    emit(OurTeamsLoaded(_current));
  }

  // ── Upload icon ──────────────────────────────────────────────────────────────
  Future<void> uploadIcon(String itemId, Uint8List bytes) async {
    try {
      final url = await _repo.uploadIcon(itemId, bytes);
      _current = _current.copyWith(
        items: _current.items
            .map((i) => i.id == itemId ? i.copyWith(iconUrl: url) : i)
            .toList(),
      );
      emit(OurTeamsLoaded(_current));
    } catch (e) {
      emit(OurTeamsError(e.toString()));
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> save() async {
    try {
      final toSave = _current.copyWith(lastUpdated: DateTime.now());
      await _repo.save(toSave);
      _current = toSave;
      emit(OurTeamsSaved(_current));
    } catch (e) {
      emit(OurTeamsError(e.toString()));
    }
  }
}