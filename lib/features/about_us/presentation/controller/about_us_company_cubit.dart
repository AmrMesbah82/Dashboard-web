// ═══════════════════════════════════════════════════════════════════
// FILE 5: about_company_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/base_repository/about_company_repo.dart';
import '../../data/models/about_us_company_model.dart';
import 'about_us_company_state.dart';

class AboutCompanyCubit extends Cubit<AboutCompanyState> {
  final AboutCompanyRepo _repo;

  AboutCompanyCubit({required AboutCompanyRepo repo})
    : _repo = repo,
      super(AboutCompanyInitial());

  AboutCompanyModel? _cachedData;

  AboutCompanyModel? get cachedData => _cachedData;

  // ══════════════════════════════════════════════════════════════════════════
  //  LOAD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadAboutCompany() async {
    try {
      emit(AboutCompanyLoading());

      final data = await _repo.fetchAboutCompany();
      _cachedData = data ?? AboutCompanyModel.empty();

      emit(AboutCompanyLoaded(_cachedData!));
    } catch (e) {
      emit(AboutCompanyError('Failed to load: $e', lastData: _cachedData));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveAboutCompany({
    required String aboutEn,
    required String aboutAr,
  }) async {
    try {

      final updated = (_cachedData ?? AboutCompanyModel.empty()).copyWith(
        aboutEn: aboutEn,
        aboutAr: aboutAr,
        lastUpdated: DateTime.now(),
      );

      await _repo.saveAboutCompany(updated);
      _cachedData = updated;

      emit(AboutCompanySaved(updated));

      // Re-emit loaded so UI refreshes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(AboutCompanyLoaded(updated));
      });
    } catch (e) {
      emit(AboutCompanyError('Failed to save: $e', lastData: _cachedData));
    }
  }
}
