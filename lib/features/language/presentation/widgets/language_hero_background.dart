import 'package:flutter/material.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/theme/app_colors.dart';

/// Full-screen background artwork for the language selection screen.
/// Perfectly aligned with splash framing to eliminate any jarring visual cuts.
class LanguageHeroBackground extends StatelessWidget {
  const LanguageHeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AssetPaths.selectLanguageBg,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
        ),
        // Soft top shade for status bar readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.basalt.withValues(alpha: 0.50),
                AppColors.basalt.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35],
            ),
          ),
        ),
      ],
    );
  }
}

