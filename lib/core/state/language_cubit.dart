import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/quran/services/preferences_service.dart';

class LanguageCubit extends Cubit<String> {
  static const String _prefKey = 'app_language_code';
  
  // Default is 'en' for English. Other possibilities: 'ur', 'fr', 'es', etc.
  LanguageCubit() : super('en') {
    _loadLanguage();
  }

  void _loadLanguage() {
    final prefs = PreferencesService().prefs;
    if (prefs != null) {
      final savedLang = prefs.getString(_prefKey);
      if (savedLang != null) {
        emit(savedLang);
      }
    }
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = PreferencesService().prefs;
    if (prefs != null) {
      await prefs.setString(_prefKey, langCode);
    }
    emit(langCode);
  }
}
