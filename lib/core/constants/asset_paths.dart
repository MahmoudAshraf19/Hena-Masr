abstract final class AssetPaths {
  static const String appLogo = 'assets/icons/app_logo.png';
  static const String ankhIcon = 'assets/icons/ankh.svg';

  // 15 Country Flags for Supported Languages
  static const String flagEgypt = 'assets/icons/flags/flag-egypt.jpg';
  static const String flagBritain = 'assets/icons/flags/flag-britain.jpg';
  static const String flagRussia = 'assets/icons/flags/flag-russia.jpg';
  static const String flagGermany = 'assets/icons/flags/flag-germany.jpg';
  static const String flagItaly = 'assets/icons/flags/flag-italy.jpg';
  static const String flagFrance = 'assets/icons/flags/flag-france.jpg';
  static const String flagPoland = 'assets/icons/flags/flag-poland.jpg';
  static const String flagSpain = 'assets/icons/flags/flag-spain.jpg';
  static const String flagChina = 'assets/icons/flags/flag-china.jpg';
  static const String flagNetherlands = 'assets/icons/flags/flag-netherlands.jpg';
  static const String flagUkraine = 'assets/icons/flags/flag-ukraine.jpg';
  static const String flagCzech = 'assets/icons/flags/flag-czech-.jpg';
  static const String flagTurkey = 'assets/icons/flags/flag-turkey.jpg';
  static const String flagSerbia = 'assets/icons/flags/flag-serbia.jpg';
  static const String flagJapan = 'assets/icons/flags/flag-japan.jpg';

  /// Helper to get flag asset path for any language ISO code
  static String flagForLanguage(String languageCode) {
    return switch (languageCode) {
      'ar' => flagEgypt,
      'en' => flagBritain,
      'ru' => flagRussia,
      'de' => flagGermany,
      'it' => flagItaly,
      'fr' => flagFrance,
      'pl' => flagPoland,
      'es' => flagSpain,
      'zh' => flagChina,
      'nl' => flagNetherlands,
      'uk' => flagUkraine,
      'cs' => flagCzech,
      'tr' => flagTurkey,
      'sr' => flagSerbia,
      'ja' => flagJapan,
      _ => flagBritain,
    };
  }

  // Splash, Language & Onboarding
  static const String splashImage = 'assets/images/splash/splash.png';
  static const String selectLanguageBg = 'assets/images/select_language/select_language.png';
  static const String onboarding1 = 'assets/images/onboarding/onboarding1.png';
  static const String onboarding2 = 'assets/images/onboarding/onboarding2.png';
  static const String onboarding3 = 'assets/images/onboarding/onboarding3.png';

  // Geo Data
  static const String egyptZones = 'assets/data/egypt_zones.json';
  static const String egyptLocalities = 'assets/data/egypt_localities.json';
}
