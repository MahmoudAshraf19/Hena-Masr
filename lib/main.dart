import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/localization/supported_locales.dart';
import 'core/theme/theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/zones/presentation/screens/zone_result_screen.dart';

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

class HanaMasrApp extends StatelessWidget {
  const HanaMasrApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ [HanaMasr App] Building MaterialApp (DevicePreview active)...');
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        const defaultLocale = Locale('ar');

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'هنا مصر',
          // DevicePreview integration
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocales.supported,
          theme: AppTheme.light(defaultLocale),
          darkTheme: AppTheme.dark(defaultLocale),
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
          debugPrint('✅ [HanaMasr Navigator] Splash finished! Transitioning directly to ZoneResultScreen...');
          if (mounted) {
            setState(() {
              _splashFinished = true;
            });
          }
        },
      );
    }

    // 2. Single simple screen: Location & Zone Result (bilingual in Arabic and English)
    debugPrint('📍 [HanaMasr Navigator] Stage 2: Rendering ZoneResultScreen...');
    return const ZoneResultScreen();
  }
}
