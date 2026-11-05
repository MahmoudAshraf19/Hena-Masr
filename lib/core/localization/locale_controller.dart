import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/storage_keys.dart';
import 'package:hena_masr/core/di/providers.dart';
import 'package:hena_masr/core/localization/supported_locales.dart';

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(StorageKeys.locale);
    // First launch: follow the device language when supported.
    final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return AppLocales.fromCode(saved ?? device);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(StorageKeys.locale, locale.languageCode);
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);