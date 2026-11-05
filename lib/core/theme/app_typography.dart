import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Plus Jakarta Sans for Latin scripts, Cairo for Arabic.
abstract final class AppTypography {
  static TextTheme textTheme({
    required Color color,
    required Color muted,
    required bool arabic,
  }) {
    final base = arabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.plusJakartaSansTextTheme();

    TextStyle? s(
      TextStyle? t, {
      required double size,
      required FontWeight weight,
      double? height,
      double? spacing,
      Color? c,
    }) =>
        t?.copyWith(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: arabic ? 0 : spacing,
          color: c ?? color,
        );

    return base.copyWith(
      displayLarge: s(base.displayLarge,
          size: 40, weight: FontWeight.w800, height: 1.15, spacing: -0.8),
      displayMedium: s(base.displayMedium,
          size: 34, weight: FontWeight.w800, height: 1.15, spacing: -0.6),
      displaySmall: s(base.displaySmall,
          size: 30, weight: FontWeight.w800, height: 1.2, spacing: -0.4),
      headlineLarge: s(base.headlineLarge,
          size: 28, weight: FontWeight.w800, height: 1.2, spacing: -0.3),
      headlineMedium: s(base.headlineMedium,
          size: 24, weight: FontWeight.w800, height: 1.25),
      headlineSmall: s(base.headlineSmall,
          size: 20, weight: FontWeight.w800, height: 1.3),
      titleLarge:
          s(base.titleLarge, size: 18, weight: FontWeight.w800, height: 1.3),
      titleMedium:
          s(base.titleMedium, size: 16, weight: FontWeight.w600, height: 1.35),
      titleSmall:
          s(base.titleSmall, size: 14, weight: FontWeight.w600, height: 1.35),
      bodyLarge:
          s(base.bodyLarge, size: 16, weight: FontWeight.w400, height: 1.5),
      bodyMedium:
          s(base.bodyMedium, size: 14, weight: FontWeight.w400, height: 1.45),
      bodySmall: s(base.bodySmall,
          size: 12, weight: FontWeight.w400, height: 1.4, c: muted),
      labelLarge: s(base.labelLarge,
          size: 14, weight: FontWeight.w800, spacing: 0.1),
      labelMedium:
          s(base.labelMedium, size: 12, weight: FontWeight.w600, spacing: 0.1),
      labelSmall: s(base.labelSmall,
          size: 11, weight: FontWeight.w600, spacing: 0.2, c: muted),
    );
  }
}
