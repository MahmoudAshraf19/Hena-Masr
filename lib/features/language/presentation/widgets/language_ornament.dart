import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/app_colors.dart';

/// Thin gold rule with a centred diamond — Egyptian-inspired aesthetic divider.
class LanguageOrnament extends StatelessWidget {
  const LanguageOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 34,
      height: 1,
      color: AppColors.gold.withValues(alpha: 0.55),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(width: 10),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: 6, height: 6, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        line,
      ],
    );
  }
}
