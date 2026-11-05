import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hena_masr/app.dart';
import 'package:hena_masr/core/di/providers.dart';
import 'package:hena_masr/core/utils/logger.dart';
import 'package:hena_masr/firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first: disable dynamic network font fetching
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Firebase (fail-safe for offline development)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully for eliyasx (hena-masar).');
  } catch (e, stack) {
    AppLogger.warning('Firebase initialization skipped or failed: $e', e, stack);
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HenaMasrApp(),
    ),
  );
}
