import 'package:shared_preferences/shared_preferences.dart';

import 'package:hena_masr/features/language/domain/models/language_item.dart';

class LanguageLocalDataSource {
  static const String _kSelectedLanguageKey = 'selected_language_code';

  List<LanguageItem> getSupportedLanguages() => kSupportedLanguages;

  LanguageItem getLanguageByCode(String code) {
    return kSupportedLanguages.firstWhere(
      (e) => e.code == code,
      orElse: () => kSupportedLanguages.first,
    );
  }

  Future<void> persistLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedLanguageKey, code);
  }

  Future<String> fetchSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSelectedLanguageKey) ?? 'en';
  }
}

