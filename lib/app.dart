import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/localization/l10n_extension.dart';
import 'package:hena_masr/core/localization/locale_controller.dart';
import 'package:hena_masr/core/router/app_router.dart';
import 'package:hena_masr/core/theme/app_theme.dart';
import 'package:hena_masr/core/theme/theme_mode_controller.dart';
import 'package:hena_masr/l10n/generated/app_localizations.dart';

class HenaMasrApp extends ConsumerWidget {
  const HenaMasrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}