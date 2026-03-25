import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for language management
class LanguageState {
  final Locale locale;

  const LanguageState(this.locale);

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';
}

/// Cubit to manage app language
class LanguageCubit extends Cubit<LanguageState> {
  static const String _kLanguageKey = 'app_language';

  LanguageCubit() : super(const LanguageState(Locale('en'))) {
    _loadSavedLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_kLanguageKey) ?? 'en';
      emit(LanguageState(Locale(savedLang)));
    } catch (e) {
      // If loading fails, keep default English
      emit(const LanguageState(Locale('en')));
    }
  }

  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLocale = state.isEnglish ? const Locale('ar') : const Locale('en');
    await _saveLanguage(newLocale.languageCode);
    emit(LanguageState(newLocale));
  }

  /// Set specific language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;
    await _saveLanguage(languageCode);
    emit(LanguageState(Locale(languageCode)));
  }

  /// Save language preference
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, languageCode);
    } catch (e) {
      // Handle error silently
    }
  }
}