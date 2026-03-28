import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const _key = 'app_locale';

  static const supportedLocales = [
    _LangOption('sv', '🇸🇪', 'Svenska'),
    _LangOption('en', '🇬🇧', 'English'),
    _LangOption('tr', '🇹🇷', 'Türkçe'),
    _LangOption('de', '🇩🇪', 'Deutsch'),
    _LangOption('es', '🇪🇸', 'Español'),
    _LangOption('fr', '🇫🇷', 'Français'),
  ];

  // Default: Swedish
  LanguageCubit() : super(const Locale('sv'));

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'sv';
    emit(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    emit(locale);
  }
}

class _LangOption {
  final String code;
  final String flag;
  final String name;
  const _LangOption(this.code, this.flag, this.name);
}
