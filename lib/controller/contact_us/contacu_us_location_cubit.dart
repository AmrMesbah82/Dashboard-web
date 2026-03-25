// ******************* FILE INFO *******************
// File Name: contact_us_cms_cubit.dart
// Created by: Claude Assistant

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/repo/contact_us/contact_us_location.dart';
import 'package:web_app_admin/repo/contact_us/contacu_us_repo_im.dart';


class ContactUsCmsCubit extends Cubit<ContactUsCmsState> {
  final ContactUsCmsRepo _repo;

  ContactUsCmsCubit({ContactUsCmsRepo? repo})
      : _repo = repo ?? ContactUsCmsRepoImpl(),
        super(ContactUsCmsInitial());

  // ── Load contact us CMS data ──────────────────────────────────────────────

  Future<void> load() async {
    try {
      emit(ContactUsCmsLoading());
      final data = await _repo.load();
      emit(ContactUsCmsLoaded(data));
    } catch (e) {
      emit(ContactUsCmsError('Failed to load contact us data: ${e.toString()}'));
    }
  }

  // ── Save contact us CMS data ──────────────────────────────────────────────

  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    try {
      await _repo.save(model: model, imageUploads: imageUploads);


      // ✅ Reload to get updated URLs and emit with data
      final updatedData = await _repo.load();
      emit(ContactUsCmsSaved(updatedData));
    } catch (e) {
      emit(ContactUsCmsError('Failed to save contact us data: ${e.toString()}'));
    }
  }
}