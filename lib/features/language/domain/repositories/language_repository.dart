import 'package:hena_masr/features/language/domain/models/language_item.dart';

/// Abstract contract for language operations and queries.
abstract class LanguageRepository {
  /// Returns the immutable list of supported languages.
  List<LanguageItem> getSupportedLanguages();

  /// Gets the item corresponding to an ISO language code.
  LanguageItem getLanguageByCode(String code);

  /// Saves the user's chosen language code to local persistent storage.
  Future<void> saveLanguagePreference(String languageCode);

  /// Retrieves the saved language code or defaults to 'en'.
  Future<String> getLanguagePreference();
}

