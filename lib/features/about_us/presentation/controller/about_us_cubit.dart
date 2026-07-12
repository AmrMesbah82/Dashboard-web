// ******************* FILE INFO *******************
// File Name: about_cubit.dart  (3 cubits in one file)
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../../data/models/about_us_model.dart';
import '../../data/repository/about_us_repo_impl.dart';
import '../../domain/base_repository/about_us_repo.dart';
import 'about_us_state.dart';

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
      safeEmit(AboutSaved(updated));
    } catch (e) {
      safeEmit(AboutError(e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class StrategyCubit extends Cubit<StrategyState> {
  final AboutRepo _repo;

  StrategyCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(StrategyInitial());

  Future<void> load() async {
    safeEmit(StrategyLoading());
    try {
      final data = await _repo.fetchStrategy();
      safeEmit(StrategyLoaded(data));
    } catch (e) {
      safeEmit(StrategyError(e.toString()));
    }
  }

  Future<void> save({
    required OurStrategyModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {

    try {
      var updated = model;

      if (imageUploads != null && imageUploads.isNotEmpty) {

        for (final entry in imageUploads.entries) {
          final path = entry.key;
          final bytes = entry.value;

          final url = await _repo.uploadImage(
              bytes: bytes, storagePath: path);

          // Update the model with the new URL based on the path
          if (path.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          }
          // Strategic House EN - Desktop
          else if (path.contains('strategicHouse/en/desktop')) {
            updated = updated.copyWith(strategicHouseEnDesktopUrl: url);
          }
          // Strategic House EN - Tablet
          else if (path.contains('strategicHouse/en/tablet')) {
            updated = updated.copyWith(strategicHouseEnTabletUrl: url);
          }
          // Strategic House EN - Mobile
          else if (path.contains('strategicHouse/en/mobile')) {
            updated = updated.copyWith(strategicHouseEnMobileUrl: url);
          }
          // Strategic House AR - Desktop
          else if (path.contains('strategicHouse/ar/desktop')) {
            updated = updated.copyWith(strategicHouseArDesktopUrl: url);
          }
          // Strategic House AR - Tablet
          else if (path.contains('strategicHouse/ar/tablet')) {
            updated = updated.copyWith(strategicHouseArTabletUrl: url);
          }
          // Strategic House AR - Mobile
          else if (path.contains('strategicHouse/ar/mobile')) {
            updated = updated.copyWith(strategicHouseArMobileUrl: url);
          }
          else if (path.contains('vision/svg')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(svgUrl: url));
          }
        }
      }


      await _repo.saveStrategy(updated);
      safeEmit(StrategySaved(updated));
    } catch (e) {
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
    safeEmit(TermsLoading());
    try {
      safeEmit(TermsLoaded(await _repo.fetchTerms()));
    } catch (e) {
      safeEmit(TermsError(e.toString()));
    }
  }

// In about_cubit.dart - TermsCubit save method
  Future<void> save({
    required TermsOfServiceModel model,
    Map<String, Uint8List>?      imageUploads,
    Map<String, DocUpload>?      docUploads,
  }) async {
    safeEmit(TermsSaving());  // ← ADD THIS LINE

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
      safeEmit(TermsSaved(updated));
    } catch (e) {
      safeEmit(TermsError(e.toString()));
    }
  }
}

// NOTE: DocUpload class lives in model/about_us_model.dart — do NOT redeclare it here.