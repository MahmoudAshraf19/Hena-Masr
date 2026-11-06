import 'package:flutter/material.dart';

/// IBM Plex Sans Arabic for Arabic script, Inter for Latin / Foreign scripts.
abstract final class AppTypography {
  static const String arabicFontFamily = 'IBMPlexSansArabic';
  static const String latinFontFamily = 'Inter';

  static String fontFamily({required bool arabic}) =>
      arabic ? arabicFontFamily : latinFontFamily;

  static TextTheme textTheme({
    required Color color,
    required Color muted,
    required bool arabic,
  }) {
    final family = fontFamily(arabic: arabic);

    TextStyle s({
      required double size,
      required FontWeight weight,
      double? height,
      double? spacing,
      Color? c,
    }) =>
        TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: arabic ? 0 : spacing,
          color: c ?? color,
        );

    return TextTheme(
      displayLarge: s(
          size: 40, weight: FontWeight.w800, height: 1.15, spacing: -0.8),
      displayMedium: s(
          size: 34, weight: FontWeight.w800, height: 1.15, spacing: -0.6),
      displaySmall: s(
          size: 30, weight: FontWeight.w800, height: 1.2, spacing: -0.4),
      headlineLarge: s(
          size: 28, weight: FontWeight.w800, height: 1.2, spacing: -0.3),
      headlineMedium: s(
          size: 24, weight: FontWeight.w800, height: 1.25),
      headlineSmall: s(
          size: 20, weight: FontWeight.w800, height: 1.3),
      titleLarge:
          s(size: 18, weight: FontWeight.w800, height: 1.3),
      titleMedium:
          s(size: 16, weight: FontWeight.w600, height: 1.35),
      titleSmall:
          s(size: 14, weight: FontWeight.w600, height: 1.35),
      bodyLarge:
          s(size: 16, weight: FontWeight.w400, height: 1.5),
      bodyMedium:
          s(size: 14, weight: FontWeight.w400, height: 1.45),
      bodySmall: s(
          size: 12, weight: FontWeight.w400, height: 1.4, c: muted),
      labelLarge: s(
          size: 14, weight: FontWeight.w800, spacing: 0.1),
      labelMedium:
          s(size: 12, weight: FontWeight.w600, spacing: 0.1),
      labelSmall: s(
          size: 11, weight: FontWeight.w600, spacing: 0.2, c: muted),
    );
  }
}
