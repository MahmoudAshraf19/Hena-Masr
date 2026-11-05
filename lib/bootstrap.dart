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