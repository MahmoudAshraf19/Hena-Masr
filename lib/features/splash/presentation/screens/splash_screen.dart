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