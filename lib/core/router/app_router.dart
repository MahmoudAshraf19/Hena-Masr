import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hena_masr/features/language/presentation/screens/select_language_screen.dart';
import 'package:hena_masr/features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/select-language',
        builder: (context, state) => const SelectLanguageScreen(),
      ),
    ],
  );
});
