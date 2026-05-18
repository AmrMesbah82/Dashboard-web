// ═══════════════════════════════════════════════════════════════════
// FILE 2: about_us_company_repo.dart
// ═══════════════════════════════════════════════════════════════════


import '../../../abou_us/data/model/about_us_company_model.dart';

abstract class AboutCompanyRepo {
  Future<AboutCompanyModel?> fetchAboutCompany();
  Future<void> saveAboutCompany(AboutCompanyModel data);
}