import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String _languageKey = 'selected_language';

  LocaleCubit() : super(const LocaleState(Locale('ar')));

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    
    if (savedLang != null) {
      emit(LocaleState(Locale(savedLang)));
    } else {
      // Default to Arabic
      emit(const LocaleState(Locale('ar')));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    emit(LocaleState(Locale(languageCode)));
  }
}
