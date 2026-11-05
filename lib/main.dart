import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/asset_paths.dart';
import 'core/localization/supported_locales.dart';
import 'core/theme/theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first: use bundled fonts only (see README).
  GoogleFonts.config.allowRuntimeFetching = false;

  final themeController = await ThemeController.load();
  runApp(HanaMasrApp(themeController: themeController));
}

class HanaMasrApp extends StatelessWidget {
  const HanaMasrApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // Replace with your locale controller.
        const locale = Locale('ar');

        return MaterialApp(
          title: 'هنا مصر',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(locale),
          darkTheme: AppTheme.dark(locale),
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
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SplashScreen(
        onInitialized: () {
          setState(() {
            _initialized = true;
          });
        },
      );
    }

    return const _DemoScreen();
  }
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.appLogo,
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            const Text('هنا مصر'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'إعادة تشغيل Splash Screen',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, anim, secondaryAnim) => SplashScreen(
                    onInitialized: () => Navigator.of(context).pop(),
                  ),
                  transitionsBuilder: (context, anim, secondaryAnim, child) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Card(
            color: context.hena.heroSurface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'أهرامات الجيزة',
                style: context.text.headlineMedium
                    ?.copyWith(color: context.hena.onHeroSurface),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: () {}, child: const Text('أضف للرحلة')),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: () {}, child: const Text('تحميل أوفلاين')),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'درع النصب',
            style: context.text.titleMedium
                ?.copyWith(color: context.hena.carnelianText),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'استكشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'الخريطة',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            label: 'رحلاتي',
          ),
        ],
      ),
    );
  }
}
