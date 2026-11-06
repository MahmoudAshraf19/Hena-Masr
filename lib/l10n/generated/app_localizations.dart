import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pl'),
    Locale('ru'),
    Locale('sr'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
  ];

  String get appName;
  String get explore;
  String get map;
  String get trips;
  String get saved;
  String get profile;
  String get gettingThere;
  String get scamShield;
  String get fairPrice;
  String get addToTrip;
  String get downloadOffline;
  String get openInMaps;
  String get searchHint;
  String get language;
  String get retry;
  String get noInternet;
  String get chooseLanguageTitle;
  String get chooseLanguageSubtitle;
  String get continueAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'nl',
    'pl',
    'ru',
    'sr',
    'tr',
    'uk',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr(locale.toString());
    case 'cs': return AppLocalizationsCs(locale.toString());
    case 'de': return AppLocalizationsDe(locale.toString());
    case 'en': return AppLocalizationsEn(locale.toString());
    case 'es': return AppLocalizationsEs(locale.toString());
    case 'fr': return AppLocalizationsFr(locale.toString());
    case 'it': return AppLocalizationsIt(locale.toString());
    case 'ja': return AppLocalizationsJa(locale.toString());
    case 'nl': return AppLocalizationsNl(locale.toString());
    case 'pl': return AppLocalizationsPl(locale.toString());
    case 'ru': return AppLocalizationsRu(locale.toString());
    case 'sr': return AppLocalizationsSr(locale.toString());
    case 'tr': return AppLocalizationsTr(locale.toString());
    case 'uk': return AppLocalizationsUk(locale.toString());
    case 'zh': return AppLocalizationsZh(locale.toString());
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".'
  );
}
