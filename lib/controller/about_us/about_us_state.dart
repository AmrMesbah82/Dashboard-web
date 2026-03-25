// ******************* FILE INFO *******************
// File Name: about_us_state.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/about_us.dart';

// ── About Us states ───────────────────────────────────────────────────────────
abstract class AboutState {}

class AboutInitial extends AboutState {}
class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  final AboutPageModel data;
  AboutLoaded(this.data);
}

class AboutSaved extends AboutState {
  final AboutPageModel data;
  AboutSaved(this.data);
}

class AboutError extends AboutState {
  final String message;
  AboutError(this.message);
}

// ── Our Strategy states ───────────────────────────────────────────────────────
abstract class StrategyState {}

class StrategyInitial extends StrategyState {}
class StrategyLoading extends StrategyState {}

class StrategyLoaded extends StrategyState {
  final OurStrategyModel data;
  StrategyLoaded(this.data);
}

class StrategySaved extends StrategyState {
  final OurStrategyModel data;
  StrategySaved(this.data);
}

class StrategyError extends StrategyState {
  final String message;
  StrategyError(this.message);
}

// ── Terms of Service states ───────────────────────────────────────────────────
abstract class TermsState {}

class TermsInitial extends TermsState {}
class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final TermsOfServiceModel data;
  TermsLoaded(this.data);
}

class TermsSaved extends TermsState {
  final TermsOfServiceModel data;
  TermsSaved(this.data);
}

class TermsError extends TermsState {
  final String message;
  TermsError(this.message);
}