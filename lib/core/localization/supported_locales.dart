import 'package:flutter/material.dart';

/// Supported locales for Hena Masr.
abstract final class AppLocales {
  static const Locale ar = Locale('ar');
  static const Locale en = Locale('en');
  static const Locale ru = Locale('ru');
  static const Locale de = Locale('de');
  static const Locale it = Locale('it');
  static const Locale fr = Locale('fr');
  static const Locale pl = Locale('pl');
  static const Locale es = Locale('es');
  static const Locale zh = Locale('zh');
  static const Locale nl = Locale('nl');
  static const Locale uk = Locale('uk');
  static const Locale cs = Locale('cs');
  static const Locale tr = Locale('tr');
  static const Locale sr = Locale('sr');
  static const Locale ja = Locale('ja');

  static const List<Locale> supported = [
    ar,
    en,
    ru,
    de,
    it,
    fr,
    pl,
    es,
    zh,
    nl,
    uk,
    cs,
    tr,
    sr,
    ja,
  ];

  static const Locale fallback = en;

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';

  static Locale fromCode(String? code) => supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => fallback,
      );

  static String getNativeName(Locale locale) {
    return switch (locale.languageCode) {
      'ar' => 'العربية',
      'en' => 'English',
      'ru' => 'Русский',
      'de' => 'Deutsch',
      'it' => 'Italiano',
      'fr' => 'Français',
      'pl' => 'Polski',
      'es' => 'Español',
      'zh' => '中文',
      'nl' => 'Nederlands',
      'uk' => 'Українська',
      'cs' => 'Čeština',
      'tr' => 'Türkçe',
      'sr' => 'Српски',
      'ja' => '日本語',
      _ => locale.languageCode,
    };
  }
}
