// ******************* FILE INFO *******************
// File Name: contact_cubit.dart
// Created by: Amr Mesbah


import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/contact_us_model.dart';
import '../../data/repo_imp/contact_us_repo_imp.dart';
import '../../domain/repo/contact_us_repo.dart';
import 'contatc_us_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepo _repo;

  ContactCubit({ContactRepo? repo})
      : _repo = repo ?? ContactRepoImpl(),
        super(ContactInitial());

  // ── Submit (public Contact page) ───────────────────────────────────────────

  Future<void> submitContact(ContactSubmission submission) async {
    emit(ContactSubmitting());
    try {
      await _repo.submitContact(submission);
      emit(ContactSubmitted());
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  // ── Load all submissions (admin list page) ─────────────────────────────────

  Future<void> loadAll() async {
    emit(ContactLoading());
    try {
      final list = await _repo.fetchAll();
      emit(ContactLoaded(all: list, filtered: list));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  // ── Filter by status and/or date ──────────────────────────────────────────

  void filter({String? status, DateTime? date}) {
    final current = state;
    if (current is! ContactLoaded) return;

    var result = current.all;

    if (status != null && status.isNotEmpty) {
      result = result.where((s) => s.status == status).toList();
    }
    if (date != null) {
      result = result.where((s) =>
      s.submissionDate.year  == date.year  &&
          s.submissionDate.month == date.month &&
          s.submissionDate.day   == date.day,
      ).toList();
    }

    emit(ContactLoaded(all: current.all, filtered: result));
  }

  // ── Clear filter ───────────────────────────────────────────────────────────

  void clearFilter() {
    final current = state;
    if (current is! ContactLoaded) return;
    emit(ContactLoaded(all: current.all, filtered: current.all));
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void search(String query) {
    final current = state;
    if (current is! ContactLoaded) return;
    if (query.trim().isEmpty) {
      emit(ContactLoaded(all: current.all, filtered: current.all));
      return;
    }
    final q = query.toLowerCase();
    final result = current.all.where((s) =>
    s.fullName.toLowerCase().contains(q)    ||
        s.email.toLowerCase().contains(q)       ||
        s.subject.toLowerCase().contains(q)     ||
        s.phoneNumber.toLowerCase().contains(q),
    ).toList();
    emit(ContactLoaded(all: current.all, filtered: result));
  }

  // ── Load single submission (detail page) ──────────────────────────────────

  void loadDetail(ContactSubmission submission) {
    emit(ContactDetailLoaded(submission));
  }

  // ── Save status / note (admin) ────────────────────────────────────────────

  Future<void> updateSubmission(ContactSubmission submission) async {
    emit(ContactLoading());
    try {
      await _repo.updateSubmission(submission);
      emit(ContactUpdated(submission));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}