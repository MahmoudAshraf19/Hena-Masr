import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/supported_locales.dart';
import 'core/theme/theme.dart';
import 'features/language/presentation/screens/select_language_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  runZonedGuarded(() async {
    debugPrint('🚀 [HanaMasr Step 1/5] Initializing Flutter bindings...');
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('🔤 [HanaMasr Step 2/5] Enabling GoogleFonts runtime fetching...');
    GoogleFonts.config.allowRuntimeFetching = true;

    debugPrint('🎨 [HanaMasr Step 3/5] Loading ThemeController...');
    final themeController = await ThemeController.load();

    debugPrint('💾 [HanaMasr Step 4/5] Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();

    debugPrint('📱 [HanaMasr Step 5/5] Launching runApp with DevicePreview & ProviderScope...');
    runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: HanaMasrApp(themeController: themeController),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('❌ [HanaMasr CRITICAL ERROR] runZonedGuarded caught: $error');
    debugPrint('$stack');
  });
}

class HanaMasrApp extends ConsumerWidget {
  const HanaMasrApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    debugPrint('🏗️ [HanaMasr App] Building MaterialApp (Locale: ${currentLocale.languageCode})...');

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'هنا مصر',
          // DevicePreview integration with fallback to Riverpod locale
          locale: DevicePreview.locale(context) ?? currentLocale,
          builder: DevicePreview.appBuilder,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocales.supported,
          theme: AppTheme.light(currentLocale),
          darkTheme: AppTheme.dark(currentLocale),
          themeMode: themeController.mode,
          home: const _AppRoot(),
        );
      },
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _splashFinished = false;

  @override
  Widget build(BuildContext context) {
    // 1. Pharaonic 3D Splash Screen
    if (!_splashFinished) {
      debugPrint('🏺 [HanaMasr Navigator] Stage 1: Rendering SplashScreen...');
      return SplashScreen(
        onInitialized: () {
          debugPrint('✅ [HanaMasr Navigator] Splash finished! Navigating to SelectLanguageScreen...');
          if (mounted) {
            setState(() {
              _splashFinished = true;
            });
          }
        },
      );
    }

    // 2. Language Selection Screen
    debugPrint('🌐 [HanaMasr Navigator] Stage 2: Rendering SelectLanguageScreen...');
    return SelectLanguageScreen(
      onContinue: () {
        debugPrint('🎯 [HanaMasr Navigator] Language selected! Ready for next step.');
      },
    );
  }
}
