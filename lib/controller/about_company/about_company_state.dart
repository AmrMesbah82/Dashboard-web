// ═══════════════════════════════════════════════════════════════════
// FILE 4: about_company_state.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:web_app_admin/model/about_company_model.dart';

abstract class AboutCompanyState {}

class AboutCompanyInitial extends AboutCompanyState {}

class AboutCompanyLoading extends AboutCompanyState {}

class AboutCompanyLoaded extends AboutCompanyState {
  final AboutCompanyModel data;
  AboutCompanyLoaded(this.data);
}

class AboutCompanySaved extends AboutCompanyState {
  final AboutCompanyModel data;
  AboutCompanySaved(this.data);
}

class AboutCompanyError extends AboutCompanyState {
  final String message;
  final AboutCompanyModel? lastData;
  AboutCompanyError(this.message, {this.lastData});
}