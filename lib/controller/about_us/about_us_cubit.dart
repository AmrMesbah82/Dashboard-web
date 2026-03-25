// ******************* FILE INFO *******************
// File Name: about_cubit.dart  (3 cubits in one file)
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_app_admin/controller/about_us/about_us_state.dart';
import 'package:web_app_admin/model/about_us.dart'; // DocUpload lives here
import 'package:web_app_admin/repo/about_us/about_repo.dart';
import 'package:web_app_admin/repo/about_us/about_repo_imp.dart';

// ── Safe emit — never throws "Cannot emit after close" ────────────────────────
// This happens when Navigator.popUntil() disposes the page (and its cubit)
// while an async save() is still running in the background.
extension _SafeEmit<S> on Cubit<S> {
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ABOUT US CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class AboutCubit extends Cubit<AboutState> {
  final AboutRepo _repo;

  AboutCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(AboutInitial());

  Future<void> load() async {
    print('🟡 [AboutCubit] load()');
    safeEmit(AboutLoading());
    try {
      safeEmit(AboutLoaded(await _repo.fetchAboutPage()));
    } catch (e) {
      safeEmit(AboutError(e.toString()));
    }
  }

  Future<void> save({
    required AboutPageModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    print('🟡 [AboutCubit] save()');
    try {
      var updated = model;

      if (imageUploads != null && imageUploads.isNotEmpty) {
        for (final entry in imageUploads.entries) {
          final url = await _repo.uploadImage(
              bytes: entry.value, storagePath: entry.key);

          if (entry.key.contains('vision/icon')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(iconUrl: url));
          } else if (entry.key.contains('vision/svg')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(svgUrl: url));
          } else if (entry.key.contains('mission/icon')) {
            updated = updated.copyWith(
                mission: updated.mission.copyWith(iconUrl: url));
          } else if (entry.key.contains('mission/svg')) {
            updated = updated.copyWith(
                mission: updated.mission.copyWith(svgUrl: url));
          } else if (entry.key.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          } else if (entry.key.contains('values/')) {
            final parts  = entry.key.split('/');
            final itemId = parts.length >= 3 ? parts[2] : null;
            if (itemId != null) {
              final newValues = updated.values.map((v) {
                if (v.id == itemId) return v.copyWith(iconUrl: url);
                return v;
              }).toList();
              updated = updated.copyWith(values: newValues);
            }
          }
        }
      }

      await _repo.saveAboutPage(updated);
      print('🟢 [AboutCubit] save OK');
      safeEmit(AboutSaved(updated));
    } catch (e) {
      print('🔴 [AboutCubit] save ERROR: $e');
      safeEmit(AboutError(e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class StrategyCubit extends Cubit<StrategyState> {
  final AboutRepo _repo;

  StrategyCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(StrategyInitial());

  Future<void> load() async {
    print('🟡 [StrategyCubit] load()');
    safeEmit(StrategyLoading());
    try {
      safeEmit(StrategyLoaded(await _repo.fetchStrategy()));
    } catch (e) {
      safeEmit(StrategyError(e.toString()));
    }
  }

  Future<void> save({
    required OurStrategyModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    print('🟡 [StrategyCubit] save()');
    try {
      var updated = model;

      if (imageUploads != null && imageUploads.isNotEmpty) {
        for (final entry in imageUploads.entries) {
          final url = await _repo.uploadImage(
              bytes: entry.value, storagePath: entry.key);

          if (entry.key.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          } else if (entry.key.contains('vision/svg')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(svgUrl: url));
          }
        }
      }

      await _repo.saveStrategy(updated);
      print('🟢 [StrategyCubit] save OK');
      safeEmit(StrategySaved(updated));
    } catch (e) {
      print('🔴 [StrategyCubit] save ERROR: $e');
      safeEmit(StrategyError(e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class TermsCubit extends Cubit<TermsState> {
  final AboutRepo _repo;

  TermsCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(TermsInitial());

  Future<void> load() async {
    print('🟡 [TermsCubit] load()');
    safeEmit(TermsLoading());
    try {
      safeEmit(TermsLoaded(await _repo.fetchTerms()));
    } catch (e) {
      safeEmit(TermsError(e.toString()));
    }
  }

  Future<void> save({
    required TermsOfServiceModel model,
    Map<String, Uint8List>?      imageUploads,
    Map<String, DocUpload>?      docUploads,  // PUBLIC type from about_us.dart
  }) async {
    print('🟡 [TermsCubit] save()');
    try {
      var updated = model;

      // ── image / svg uploads ───────────────────────────────────────────────
      if (imageUploads != null && imageUploads.isNotEmpty) {
        for (final entry in imageUploads.entries) {
          final url = await _repo.uploadImage(
              bytes: entry.value, storagePath: entry.key);

          if (entry.key.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          } else if (entry.key.contains('terms/svg')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(svgUrl: url));
          } else if (entry.key.contains('privacy/svg')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(svgUrl: url));
          }
        }
      }

      // ── document uploads ──────────────────────────────────────────────────
      if (docUploads != null && docUploads.isNotEmpty) {
        for (final entry in docUploads.entries) {
          final url = await _repo.uploadDocument(
            bytes:       entry.value.bytes,
            storagePath: entry.key,
            fileName:    entry.value.fileName,
          );
          if (entry.key.contains('terms/en')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(attachEnUrl: url));
          } else if (entry.key.contains('terms/ar')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(attachArUrl: url));
          } else if (entry.key.contains('privacy/en')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(attachEnUrl: url));
          } else if (entry.key.contains('privacy/ar')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(attachArUrl: url));
          }
        }
      }

      await _repo.saveTerms(updated);
      print('🟢 [TermsCubit] save OK');
      safeEmit(TermsSaved(updated));
    } catch (e) {
      print('🔴 [TermsCubit] save ERROR: $e');
      safeEmit(TermsError(e.toString()));
    }
  }
}

// NOTE: DocUpload class lives in model/about_us.dart — do NOT redeclare it here.