// ******************* FILE INFO *******************
// File Name: careers_section_state.dart
// States for CareersSectionCubit (Why Join Our Team / Our Interns / Our Teams)

import 'package:web_app_admin/model/careers_section_model.dart';

abstract class CareersSectionState {}

class CareersSectionInitial extends CareersSectionState {}

class CareersSectionLoading extends CareersSectionState {}

class CareersSectionLoaded extends CareersSectionState {
  final CareersSectionModel data;
  CareersSectionLoaded(this.data);
}

class CareersSectionSaved extends CareersSectionState {
  final CareersSectionModel data;
  CareersSectionSaved(this.data);
}

class CareersSectionError extends CareersSectionState {
  final String message;
  CareersSectionError(this.message);
}