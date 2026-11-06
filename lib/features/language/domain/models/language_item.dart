import 'package:hena_masr/core/constants/asset_paths.dart';

/// Domain entity representing a supported language option.
class LanguageItem {
  final String code;
  final String nativeName;
  final String englishName;
  final String flagAsset;
  final bool isRtl;

  const LanguageItem({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flagAsset,
    this.isRtl = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageItem &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// The 15 supported languages in business-defined display order:
/// Arabic first in list, English is default selected.
const List<LanguageItem> kSupportedLanguages = [
  LanguageItem(
    code: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    flagAsset: AssetPaths.flagEgypt,
    isRtl: true,
  ),
  LanguageItem(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    flagAsset: AssetPaths.flagBritain,
  ),
  LanguageItem(
    code: 'fr',
    nativeName: 'Français',
    englishName: 'French',
    flagAsset: AssetPaths.flagFrance,
  ),
  LanguageItem(
    code: 'de',
    nativeName: 'Deutsch',
    englishName: 'German',
    flagAsset: AssetPaths.flagGermany,
  ),
  LanguageItem(
    code: 'es',
    nativeName: 'Español',
    englishName: 'Spanish',
    flagAsset: AssetPaths.flagSpain,
  ),
  LanguageItem(
    code: 'it',
    nativeName: 'Italiano',
    englishName: 'Italian',
    flagAsset: AssetPaths.flagItaly,
  ),
  LanguageItem(
    code: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    flagAsset: AssetPaths.flagRussia,
  ),
  LanguageItem(
    code: 'zh',
    nativeName: '中文',
    englishName: 'Chinese',
    flagAsset: AssetPaths.flagChina,
  ),
  LanguageItem(
    code: 'ja',
    nativeName: '日本語',
    englishName: 'Japanese',
    flagAsset: AssetPaths.flagJapan,
  ),
  LanguageItem(
    code: 'pl',
    nativeName: 'Polski',
    englishName: 'Polish',
    flagAsset: AssetPaths.flagPoland,
  ),
  LanguageItem(
    code: 'nl',
    nativeName: 'Nederlands',
    englishName: 'Dutch',
    flagAsset: AssetPaths.flagNetherlands,
  ),
  LanguageItem(
    code: 'uk',
    nativeName: 'Українська',
    englishName: 'Ukrainian',
    flagAsset: AssetPaths.flagUkraine,
  ),
  LanguageItem(
    code: 'cs',
    nativeName: 'Čeština',
    englishName: 'Czech',
    flagAsset: AssetPaths.flagCzech,
  ),
  LanguageItem(
    code: 'tr',
    nativeName: 'Türkçe',
    englishName: 'Turkish',
    flagAsset: AssetPaths.flagTurkey,
  ),
  LanguageItem(
    code: 'sr',
    nativeName: 'Српски',
    englishName: 'Serbian',
    flagAsset: AssetPaths.flagSerbia,
  ),
];

