// ******************* FILE INFO *******************
// File Name: home_state.dart
// Description: States for HomeCmsCubit.
// Created by: Amr Mesbah

import 'package:web_app_admin/model/home_model.dart';

abstract class HomeCmsState {}

class HomeCmsInitial extends HomeCmsState {}

class HomeCmsLoading extends HomeCmsState {}

class HomeCmsLoaded extends HomeCmsState {
  final HomePageModel data;
  HomeCmsLoaded(this.data);
}

class HomeCmsSaving extends HomeCmsState {
  final HomePageModel data;
  HomeCmsSaving(this.data);
}

class HomeCmsSaved extends HomeCmsState {
  final HomePageModel data;
  HomeCmsSaved(this.data);
}

class HomeCmsError extends HomeCmsState {
  final String message;
  final HomePageModel? lastData; // keep last known data so UI doesn't go blank
  HomeCmsError(this.message, [this.lastData]);
}