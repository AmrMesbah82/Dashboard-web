// ═══════════════════════════════════════════════════════════════════
// FILE 5: inquiry_cubit.dart
// Path: lib/controller/inquiry/inquiry_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/inquire/inquiry_state.dart';
import 'package:web_app_admin/model/inquiry_model.dart';
import 'package:web_app_admin/repo/inquire/inquiry_repo.dart';

class InquiryCubit extends Cubit<InquiryState> {
  final InquiryRepo _repo;

  InquiryCubit({required InquiryRepo repo})
      : _repo = repo,
        super(InquiryInitial());

  List<InquiryModel> _allInquiries = [];
  String _searchQuery = '';

  List<InquiryModel> get allInquiries => _allInquiries;

  Future<void> loadInquiries() async {
    try {
      print('🟡 [InquiryCubit] loadInquiries()');
      emit(InquiryLoading());
      _allInquiries = await _repo.fetchAllInquiries();
      print('🟢 [InquiryCubit] loadInquiries() — ${_allInquiries.length}');
      _emitLoaded();
    } catch (e) {
      print('🔴 [InquiryCubit] loadInquiries() ERROR: $e');
      emit(InquiryError('Failed to load: $e', lastInquiries: _allInquiries));
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    _emitLoaded();
  }

  Future<void> loadDetail(String id) async {
    try {
      print('🟡 [InquiryCubit] loadDetail($id)');
      final local = _allInquiries.where((i) => i.id == id).toList();
      if (local.isNotEmpty) {
        emit(InquiryDetailLoaded(local.first));
        return;
      }
      final inquiry = await _repo.fetchInquiryById(id);
      if (inquiry != null) {
        emit(InquiryDetailLoaded(inquiry));
      } else {
        emit(InquiryError('Inquiry not found', lastInquiries: _allInquiries));
      }
    } catch (e) {
      print('🔴 [InquiryCubit] loadDetail() ERROR: $e');
      emit(InquiryError('Failed to load: $e', lastInquiries: _allInquiries));
    }
  }

  Future<void> updateStatus(String id, InquiryStatus newStatus) async {
    try {
      print('🟡 [InquiryCubit] updateStatus($id → ${newStatus.label})');
      await _repo.updateStatus(id, newStatus);
      _allInquiries = _allInquiries.map((i) {
        if (i.id == id) return i.copyWith(status: newStatus);
        return i;
      }).toList();
      final updated = _allInquiries.firstWhere((i) => i.id == id);
      emit(InquiryUpdated(updated));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) _emitLoaded();
      });
      print('🟢 [InquiryCubit] updateStatus() — done');
    } catch (e) {
      print('🔴 [InquiryCubit] updateStatus() ERROR: $e');
      emit(InquiryError('Failed to update: $e', lastInquiries: _allInquiries));
    }
  }

  Future<void> updateNote(String id, String note) async {
    try {
      print('🟡 [InquiryCubit] updateNote($id)');
      final inquiry = _allInquiries.firstWhere((i) => i.id == id);
      final updated = inquiry.copyWith(note: note);
      await _repo.updateInquiry(updated);
      _allInquiries = _allInquiries.map((i) => i.id == id ? updated : i).toList();
      emit(InquiryUpdated(updated));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) _emitLoaded();
      });
      print('🟢 [InquiryCubit] updateNote() — done');
    } catch (e) {
      print('🔴 [InquiryCubit] updateNote() ERROR: $e');
      emit(InquiryError('Failed to save: $e', lastInquiries: _allInquiries));
    }
  }

  void backToList() => _emitLoaded();

  void _emitLoaded() {
    emit(InquiryLoaded(inquiries: _allInquiries, searchQuery: _searchQuery));
  }
}