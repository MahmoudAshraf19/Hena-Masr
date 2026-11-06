import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/asset_paths.dart';
import 'core/di/providers.dart';
import 'core/localization/supported_locales.dart';
import 'core/theme/theme.dart';
import 'features/settings/presentation/screens/about_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/zones/domain/entities/zone.dart';
import 'features/zones/presentation/providers/zone_providers.dart';
import 'features/zones/presentation/screens/zone_verification_screen.dart';
import 'features/zones/presentation/widgets/zone_confirmation_banner.dart';
import 'features/zones/presentation/widgets/zone_selector_pill.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Offline-first: use bundled fonts only (see README).
    GoogleFonts.config.allowRuntimeFetching = false;

    final themeController = await ThemeController.load();
    final prefs = await SharedPreferences.getInstance();

    runApp(
      DevicePreview(
        // The device frame is a development tool: enabled for web debug mode
        enabled: kIsWeb && !kReleaseMode,
        builder: (context) => ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: HanaMasrApp(themeController: themeController),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught Zone Error: $error');
    debugPrint('$stack');
  });
}

class HanaMasrApp extends StatelessWidget {
  const HanaMasrApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // Active app locale
        const locale = Locale('ar');

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'هنا مصر',
          locale: locale,
          builder: DevicePreview.appBuilder,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocales.supported,
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
  bool _splashFinished = false;
  bool _zoneConfirmed = false;

  @override
  Widget build(BuildContext context) {
    // 1. Pharaonic 3D Splash Screen with background location warmup
    if (!_splashFinished) {
      return SplashScreen(
        onInitialized: () {
          setState(() {
            _splashFinished = true;
          });
        },
      );
    }

    // 2. Zone & Location Verification Screen (GPS coords, assigned zone, and % confidence)
    if (!_zoneConfirmed) {
      return ZoneVerificationScreen(
        onConfirmed: () {
          setState(() {
            _zoneConfirmed = true;
          });
        },
      );
    }

    // 3. Main Application Experience
    return const _DemoScreen();
  }
}

class _DemoScreen extends ConsumerWidget {
  const _DemoScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneState = ref.watch(currentZoneProvider).value;
    final match = zoneState?.match;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final currentZoneName = match != null
        ? (isArabic
            ? (match.highlight?.nameAr ?? match.locality?.nameAr ?? match.district?.nameAr ?? match.governorate.nameAr)
            : (match.highlight?.nameEn ?? match.locality?.nameEn ?? match.district?.nameEn ?? match.governorate.nameEn))
        : (isArabic ? 'أهرامات الجيزة' : 'Giza Pyramids');
    final currentGovName = match != null
        ? (isArabic
            ? '${match.governorate.nameAr}${match.district != null && match.highlight != null ? ' • ${match.district!.nameAr}' : ''}'
            : '${match.governorate.nameEn}${match.district != null && match.highlight != null ? ' • ${match.district!.nameEn}' : ''}')
        : (isArabic ? 'الجيزة' : 'Giza');

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
            const SizedBox(width: 8),
            const Text('هنا مصر'),
          ],
        ),
        actions: [
          const ZoneSelectorPill(),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'عن التطبيق ومصادر البيانات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
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
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const SizedBox(height: 12),

          // Border/Accuracy Confirmation Banner (Conditional)
          const ZoneConfirmationBanner(),

          // Hero Zone Feature Card
          Card(
            color: context.hena.heroSurface,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.hena.onHeroSurface.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentGovName,
                          style: context.text.labelMedium?.copyWith(
                            color: context.hena.onHeroSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        zoneState?.source == ZoneSource.manual
                            ? Icons.edit_location_rounded
                            : Icons.my_location_rounded,
                        color: context.hena.onHeroSurface.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentZoneName,
                    style: context.text.headlineMedium?.copyWith(
                      color: context.hena.onHeroSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isArabic
                        ? 'دليلك الشامل لزيارة المعالم وأسعار المواصلات العادلة'
                        : 'Your complete guide for landmarks and fair transit pricing',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.hena.onHeroSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confidence Percentage Badge with Click to Re-verify
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ZoneVerificationScreen(
                            onConfirmed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Text(
                            isArabic
                                ? 'نسبة دقة ومطابقة الزون: ${match?.confidencePercentage ?? 95}% (عرض التفاصيل)'
                                : 'Zone Accuracy: ${match?.confidencePercentage ?? 95}% (Details)',
                            style: context.text.labelSmall?.copyWith(
                              color: context.hena.onHeroSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_left_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: Text(isArabic ? 'أضف للرحلة' : 'Add to Trip'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: Text(
              isArabic
                  ? 'تحميل خريطة $currentGovName أوفلاين'
                  : 'Download $currentGovName Offline Pack',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.shield_outlined, color: context.hena.carnelianText, size: 22),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'درع النصب والأسعار العادلة' : 'Scam Shield & Fair Prices',
                style: context.text.titleMedium?.copyWith(
                  color: context.hena.carnelianText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
            child: ListTile(
              leading: Icon(Icons.local_taxi_rounded, color: context.hena.gold),
              title: Text(
                isArabic ? 'أجرة التاكسي / أوبر المعتمدة' : 'Fair Taxi / Ride Fare',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isArabic
                    ? 'متوسط السعر العادل في $currentZoneName'
                    : 'Average fair price in $currentZoneName',
              ),
              trailing: Text(
                '40 - 70 EGP',
                style: TextStyle(
                  color: context.hena.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
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
