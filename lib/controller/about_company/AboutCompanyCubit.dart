// ═══════════════════════════════════════════════════════════════════
// FILE 5: about_company_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/about_company/about_company_state.dart';
import 'package:web_app_admin/model/about_company_model.dart';
import 'package:web_app_admin/repo/job_list/about_company_repo.dart';

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
      print('🟡 [AboutCompanyCubit] loadAboutCompany()');
      emit(AboutCompanyLoading());

      final data = await _repo.fetchAboutCompany();
      _cachedData = data ?? AboutCompanyModel.empty();

      print('🟢 [AboutCompanyCubit] loadAboutCompany() — loaded');
      emit(AboutCompanyLoaded(_cachedData!));
    } catch (e) {
      print('🔴 [AboutCompanyCubit] loadAboutCompany() ERROR: $e');
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
      print('🟡 [AboutCompanyCubit] saveAboutCompany()');

      final updated = (_cachedData ?? AboutCompanyModel.empty()).copyWith(
        aboutEn: aboutEn,
        aboutAr: aboutAr,
        lastUpdated: DateTime.now(),
      );

      await _repo.saveAboutCompany(updated);
      _cachedData = updated;

      print('🟢 [AboutCompanyCubit] saveAboutCompany() — done');
      emit(AboutCompanySaved(updated));

      // Re-emit loaded so UI refreshes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(AboutCompanyLoaded(updated));
      });
    } catch (e) {
      print('🔴 [AboutCompanyCubit] saveAboutCompany() ERROR: $e');
      emit(AboutCompanyError('Failed to save: $e', lastData: _cachedData));
    }
  }
}