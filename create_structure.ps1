<#
  Hena Masr — project scaffolding (Clean Architecture, feature-first)

  Prerequisite (once):
    flutter create --org com.henamasr --project-name hena_masr "D:\Hena Masr\Hena Masr App"

  Run:
    powershell -ExecutionPolicy Bypass -File .\create_structure.ps1
    powershell -ExecutionPolicy Bypass -File .\create_structure.ps1 -AddPackages

  Safe to re-run: existing files are never overwritten.
#>
param(
  [string]$ProjectRoot = "D:\Hena Masr\Hena Masr App",
  [switch]$AddPackages
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:Created = 0
$script:Skipped = 0

# ───────────────────────── helpers ─────────────────────────
function Ensure-Dir([string]$RelPath) {
  if (-not $RelPath) { return }
  $full = Join-Path $ProjectRoot $RelPath
  if (-not (Test-Path -LiteralPath $full)) {
    New-Item -ItemType Directory -Path $full -Force | Out-Null
  }
}

function Write-NewFile([string]$RelPath, [string]$Content = "") {
  $full = Join-Path $ProjectRoot $RelPath
  Ensure-Dir (Split-Path -Parent $RelPath)
  if (Test-Path -LiteralPath $full) { $script:Skipped++; return }
  [System.IO.File]::WriteAllText($full, $Content, $Utf8NoBom)
  $script:Created++
}

function New-Feature {
  param(
    [string]$Name,
    [string[]]$Entities = @(),
    [string[]]$Screens = @(),
    [string[]]$UseCases = @(),
    [switch]$NoData
  )
  $base = "lib\features\$Name"

  # presentation
  Ensure-Dir "$base\presentation\screens"
  Ensure-Dir "$base\presentation\widgets"
  Ensure-Dir "$base\presentation\providers"
  foreach ($s in $Screens) { Write-NewFile "$base\presentation\screens\$s.dart" }
  Write-NewFile "$base\presentation\providers\${Name}_providers.dart"

  if ($NoData) { return }

  # data + domain
  Ensure-Dir "$base\data\datasources"
  Ensure-Dir "$base\data\models"
  Ensure-Dir "$base\data\repositories"
  Ensure-Dir "$base\domain\entities"
  Ensure-Dir "$base\domain\repositories"
  Ensure-Dir "$base\domain\usecases"

  foreach ($e in $Entities) {
    Write-NewFile "$base\domain\entities\$e.dart"
    Write-NewFile "$base\data\models\${e}_model.dart"
  }
  Write-NewFile "$base\domain\repositories\${Name}_repository.dart"
  Write-NewFile "$base\data\repositories\${Name}_repository_impl.dart"
  Write-NewFile "$base\data\datasources\${Name}_remote_datasource.dart"
  Write-NewFile "$base\data\datasources\${Name}_local_datasource.dart"
  foreach ($u in $UseCases) { Write-NewFile "$base\domain\usecases\$u.dart" }
}

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot "pubspec.yaml"))) {
  Write-Host "WARNING: pubspec.yaml not found in '$ProjectRoot'. Run 'flutter create' first." -ForegroundColor Yellow
}

Write-Host "Creating Hena Masr structure in: $ProjectRoot\lib" -ForegroundColor Cyan

# ───────────────────────── root-level assets & config ─────────────────────────
foreach ($d in @(
  "assets\images", "assets\icons", "assets\fonts", "assets\google_fonts",
  "assets\lottie", "assets\seed", "test\core", "test\features", "integration_test"
)) { Ensure-Dir $d }

Write-NewFile "l10n.yaml" @'
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/generated
nullable-getter: false
'@

# ───────────────────────── entry points ─────────────────────────
Write-NewFile "lib\main.dart" @'
import 'package:hena_masr/bootstrap.dart';

Future<void> main() => bootstrap();
'@

Write-NewFile "lib\bootstrap.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hena_masr/app.dart';
import 'package:hena_masr/core/di/providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // After running `flutterfire configure`:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Once Plus Jakarta Sans + Cairo are bundled in assets/google_fonts:
  // GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HenaMasrApp(),
    ),
  );
}
'@

Write-NewFile "lib\app.dart" @'
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
'@

# ───────────────────────── l10n (ARB) ─────────────────────────
Write-NewFile "lib\l10n\app_en.arb" @'
{
  "@@locale": "en",
  "appName": "Hena Masr",
  "explore": "Explore",
  "map": "Map",
  "trips": "Trips",
  "saved": "Saved",
  "profile": "Profile",
  "gettingThere": "Getting there",
  "scamShield": "Scam shield",
  "fairPrice": "Fair price",
  "addToTrip": "Add to trip",
  "downloadOffline": "Download offline",
  "openInMaps": "Open route in Maps",
  "searchHint": "Search places, cities, tours",
  "language": "Language",
  "retry": "Retry",
  "noInternet": "No internet connection"
}
'@

Write-NewFile "lib\l10n\app_ar.arb" @'
{
  "@@locale": "ar",
  "appName": "هنا مصر",
  "explore": "استكشف",
  "map": "الخريطة",
  "trips": "رحلاتي",
  "saved": "المحفوظات",
  "profile": "حسابي",
  "gettingThere": "طرق الوصول",
  "scamShield": "درع النصب",
  "fairPrice": "السعر العادل",
  "addToTrip": "أضف للرحلة",
  "downloadOffline": "تحميل أوفلاين",
  "openInMaps": "افتح المسار في الخرائط",
  "searchHint": "ابحث عن أماكن أو مدن أو جولات",
  "language": "اللغة",
  "retry": "إعادة المحاولة",
  "noInternet": "لا يوجد اتصال بالإنترنت"
}
'@

# ───────────────────────── core ─────────────────────────
# config / constants
Write-NewFile "lib\core\config\app_config.dart"
Write-NewFile "lib\core\config\env.dart"
Write-NewFile "lib\core\constants\app_constants.dart"
Write-NewFile "lib\core\constants\asset_paths.dart"
Write-NewFile "lib\core\constants\firestore_paths.dart"
Write-NewFile "lib\core\constants\storage_keys.dart" @'
abstract final class StorageKeys {
  static const String locale = 'locale';
  static const String themeMode = 'theme_mode';
  static const String onboardingDone = 'onboarding_done';
}
'@

# di
Write-NewFile "lib\core\di\providers.dart" @'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in bootstrap() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in bootstrap()'),
);
'@

# error
Write-NewFile "lib\core\error\exceptions.dart"
Write-NewFile "lib\core\error\failures.dart" @'
/// Domain-level errors. Messages are for logs only:
/// the UI maps each type to a localized string.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
'@

# extensions
Write-NewFile "lib\core\extensions\string_extensions.dart"
Write-NewFile "lib\core\extensions\iterable_extensions.dart"

# localization
Write-NewFile "lib\core\localization\supported_locales.dart" @'
import 'package:flutter/material.dart';

/// To add a language: add its ARB file in lib/l10n, add it here,
/// then run `flutter gen-l10n`.
abstract final class AppLocales {
  static const Locale ar = Locale('ar');
  static const Locale en = Locale('en');
  // static const Locale de = Locale('de');
  // static const Locale fr = Locale('fr');
  // static const Locale zh = Locale('zh');
  // static const Locale ru = Locale('ru');

  static const List<Locale> supported = [ar, en];
  static const Locale fallback = en;

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';

  static Locale fromCode(String? code) => supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => fallback,
      );
}
'@

Write-NewFile "lib\core\localization\locale_controller.dart" @'
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
'@

Write-NewFile "lib\core\localization\localized_text.dart" @'
import 'package:flutter/widgets.dart';

/// Multilingual content stored in Firestore / local DB, e.g.
/// { "ar": "أهرامات الجيزة", "en": "Pyramids of Giza" }
@immutable
class LocalizedText {
  const LocalizedText(this._values);

  const LocalizedText.empty() : _values = const {};

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      return LocalizedText(
        json.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    return const LocalizedText.empty();
  }

  final Map<String, String> _values;

  /// Requested language -> English -> any available -> empty.
  String resolve(Locale locale) =>
      _values[locale.languageCode] ??
      _values['en'] ??
      (_values.values.isEmpty ? '' : _values.values.first);

  String of(BuildContext context) => resolve(Localizations.localeOf(context));

  bool get isEmpty => _values.isEmpty;

  Map<String, String> toJson() => Map.of(_values);
}
'@

Write-NewFile "lib\core\localization\l10n_extension.dart" @'
import 'package:flutter/widgets.dart';

import 'package:hena_masr/l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
'@

# network / services / storage
Write-NewFile "lib\core\network\connectivity_service.dart"
Write-NewFile "lib\core\network\network_info.dart"
Write-NewFile "lib\core\services\location_service.dart"
Write-NewFile "lib\core\services\url_launcher_service.dart"
Write-NewFile "lib\core\services\notification_service.dart"
Write-NewFile "lib\core\services\analytics_service.dart"
Write-NewFile "lib\core\storage\local_storage.dart"
Write-NewFile "lib\core\storage\app_database.dart"
Ensure-Dir "lib\core\storage\tables"

# router
Write-NewFile "lib\core\router\route_names.dart" @'
abstract final class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String languageSelect = '/language';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String place = '/place/:id';
  static const String gettingThere = '/place/:id/getting-there';
  static const String map = '/map';
  static const String trips = '/trips';
  static const String tripDetails = '/trips/:id';
  static const String saved = '/saved';
  static const String offline = '/offline';
  static const String aiGuide = '/ai-guide';
  static const String emergency = '/emergency';
  static const String phrasebook = '/phrasebook';
  static const String settings = '/settings';
}
'@

Write-NewFile "lib\core\router\app_router.dart" @'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hena_masr/core/router/route_names.dart';
import 'package:hena_masr/features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Add routes as screens are built. Bottom tabs: StatefulShellRoute.
    ],
  );
});
'@
Write-NewFile "lib\core\router\route_guards.dart"

# theme (copy your theme files here)
Ensure-Dir "lib\core\theme"
Write-NewFile "lib\core\theme\theme_mode_controller.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/storage_keys.dart';
import 'package:hena_masr/core/di/providers.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(sharedPreferencesProvider).getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(StorageKeys.themeMode, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
'@

# utils
Write-NewFile "lib\core\utils\result.dart" @'
import 'package:hena_masr/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
'@
Write-NewFile "lib\core\utils\logger.dart"
Write-NewFile "lib\core\utils\debouncer.dart"
Write-NewFile "lib\core\utils\formatters.dart"
Write-NewFile "lib\core\utils\validators.dart"

# shared widgets
foreach ($w in @(
  "app_button", "app_loading", "app_error_view", "app_empty_view",
  "app_network_image", "app_chip", "section_header", "offline_banner"
)) { Write-NewFile "lib\core\widgets\$w.dart" }

# ───────────────────────── features ─────────────────────────
Write-NewFile "lib\features\splash\presentation\screens\splash_screen.dart" @'
import 'package:flutter/material.dart';

import 'package:hena_masr/core/localization/l10n_extension.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          context.l10n.appName,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }
}
'@

New-Feature -Name "splash" -NoData -Screens @("splash_screen")

New-Feature -Name "onboarding" -NoData -Screens @(
  "onboarding_screen", "language_select_screen"
)

New-Feature -Name "shell" -NoData -Screens @("main_shell_screen")

New-Feature -Name "home" -NoData -Screens @("home_screen")

New-Feature -Name "places" `
  -Entities @("place", "city", "category", "place_media", "ticket_price", "opening_hours") `
  -Screens @("explore_screen", "place_details_screen", "search_screen", "city_places_screen") `
  -UseCases @("get_featured_places", "get_places_by_city", "get_place_details",
              "search_places", "get_cities", "get_categories")

New-Feature -Name "transport" `
  -Entities @("transport_option", "route_info") `
  -Screens @("getting_there_screen") `
  -UseCases @("get_transport_options", "open_route_in_maps")

New-Feature -Name "map" `
  -Entities @("map_marker") `
  -Screens @("map_screen") `
  -UseCases @("get_nearby_places")

New-Feature -Name "trip_planner" `
  -Entities @("trip", "trip_day", "trip_stop") `
  -Screens @("trips_screen", "trip_details_screen", "create_trip_screen") `
  -UseCases @("create_trip", "generate_itinerary", "add_place_to_trip", "get_trips", "delete_trip")

New-Feature -Name "offline_packs" `
  -Entities @("offline_pack") `
  -Screens @("offline_manager_screen") `
  -UseCases @("get_available_packs", "download_pack", "delete_pack", "watch_download_progress")

New-Feature -Name "scam_shield" `
  -Entities @("scam_tip", "fair_price") `
  -Screens @("scam_shield_screen") `
  -UseCases @("get_scam_tips_for_place", "get_fair_prices")

New-Feature -Name "ai_guide" `
  -Entities @("chat_message") `
  -Screens @("ai_guide_screen") `
  -UseCases @("send_message", "get_chat_history")

New-Feature -Name "favorites" `
  -Entities @("favorite") `
  -Screens @("favorites_screen") `
  -UseCases @("toggle_favorite", "get_favorites")

New-Feature -Name "emergency" `
  -Entities @("emergency_contact") `
  -Screens @("emergency_screen") `
  -UseCases @("get_emergency_contacts")

New-Feature -Name "phrasebook" `
  -Entities @("phrase") `
  -Screens @("phrasebook_screen") `
  -UseCases @("get_phrases")

New-Feature -Name "auth" `
  -Entities @("app_user") `
  -Screens @("login_screen") `
  -UseCases @("sign_in_anonymously", "sign_in_with_google", "sign_out", "get_current_user")

New-Feature -Name "settings" -NoData -Screens @(
  "settings_screen", "language_settings_screen", "theme_settings_screen", "about_screen"
)

# ───────────────────────── optional: packages ─────────────────────────
if ($AddPackages) {
  Push-Location $ProjectRoot
  try {
    Write-Host "Adding packages..." -ForegroundColor Cyan
    flutter pub add flutter_localizations --sdk=flutter
    flutter pub add flutter_riverpod go_router equatable intl logger `
      firebase_core firebase_auth cloud_firestore `
      shared_preferences drift drift_flutter path_provider `
      connectivity_plus cached_network_image google_fonts `
      flutter_map latlong2 geolocator url_launcher
    flutter pub add dev:build_runner dev:drift_dev dev:mocktail
  }
  finally { Pop-Location }
}

# ───────────────────────── summary ─────────────────────────
Write-Host ""
Write-Host "Done. Created: $($script:Created) files, skipped (already exist): $($script:Skipped)" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Copy your theme files into lib\core\theme (app_theme.dart, app_colors.dart, ...)"
Write-Host "  2. pubspec.yaml -> under 'flutter:' add:  generate: true"
Write-Host "  3. flutter pub get"
Write-Host "  4. flutter gen-l10n"
Write-Host "  5. flutter run"