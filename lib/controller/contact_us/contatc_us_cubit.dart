// ******************* FILE INFO *******************
// File Name: contact_cubit.dart
// Created by: Amr Mesbah

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_state.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/repo/contact_us/contact_us_repo.dart';
import 'package:web_app_admin/repo/contact_us/contact_us_repo_imp.dart';


class ContactCubit extends Cubit<ContactState> {
  final ContactRepo _repo;

  ContactCubit({ContactRepo? repo})
      : _repo = repo ?? ContactRepoImpl(),
        super(ContactInitial());

  // ── Submit (public Contact page) ───────────────────────────────────────────

  Future<void> submitContact(ContactSubmission submission) async {
    print('🟡 [ContactCubit] submitContact()');
    emit(ContactSubmitting());
    try {
      await _repo.submitContact(submission);
      print('🟢 [ContactCubit] submitContact() → OK');
      emit(ContactSubmitted());
    } catch (e) {
      print('🔴 [ContactCubit] submitContact() ERROR: $e');
      emit(ContactError(e.toString()));
    }
  }

  // ── Load all submissions (admin list page) ─────────────────────────────────

  Future<void> loadAll() async {
    print('🟡 [ContactCubit] loadAll()');
    emit(ContactLoading());
    try {
      final list = await _repo.fetchAll();
      print('🟢 [ContactCubit] loadAll() → ${list.length} items');
      emit(ContactLoaded(all: list, filtered: list));
    } catch (e) {
      print('🔴 [ContactCubit] loadAll() ERROR: $e');
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
    print('🟡 [ContactCubit] updateSubmission(${submission.id})');
    emit(ContactLoading());
    try {
      await _repo.updateSubmission(submission);
      print('🟢 [ContactCubit] updateSubmission() → OK');
      emit(ContactUpdated(submission));
    } catch (e) {
      print('🔴 [ContactCubit] updateSubmission() ERROR: $e');
      emit(ContactError(e.toString()));
    }
  }
}