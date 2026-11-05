import 'package:flutter/material.dart';

/// Hena Masr raw color tokens.
/// Brand colors come from the "Egyptian Heritage" palette.
/// Derived colors exist only to keep contrast accessible (WCAG AA).
abstract final class AppColors {
  // ───────── Brand ─────────
  /// Lapis lazuli — identity / primary.
  static const Color lapis = Color(0xFF1F3A73);

  /// Gold — main action / highlight.
  static const Color gold = Color(0xFFD4A24C);

  /// Faience turquoise — secondary.
  static const Color turquoise = Color(0xFF2BA39B);

  /// Carnelian — warning / alert / Scam Shield.
  static const Color carnelian = Color(0xFFB8322E);

  /// Papyrus — light background.
  static const Color papyrus = Color(0xFFF5EEDC);

  /// Sand — secondary surfaces and borders.
  static const Color sand = Color(0xFFE6D3A8);

  /// Basalt — text, and the dark-mode background.
  static const Color basalt = Color(0xFF17202A);

  // ───────── Derived (contrast helpers) ─────────
  static const Color white = Color(0xFFFFFFFF);

  /// Lapis tint, readable on Basalt (dark-mode primary).
  static const Color lapisLight = Color(0xFF9DB4E8);

  /// Slightly brighter lapis for selected states on a lapis bar.
  static const Color lapisSoft = Color(0xFF2E4D93);

  /// Turquoise darkened for TEXT / icons on light backgrounds.
  static const Color turquoiseDeep = Color(0xFF1B7F79);

  /// Carnelian lightened for text on Basalt.
  static const Color carnelianLight = Color(0xFFEA8681);

  static const Color success = Color(0xFF2E8B57);
  static const Color successLight = Color(0xFF6CC79A);

  // ───────── Light neutrals ─────────
  static const Color papyrusLight = Color(0xFFFBF7EC);
  static const Color papyrusDeep = Color(0xFFF0E7D0);
  static const Color sandSoft = Color(0xFFEDE0BE);
  static const Color mutedLight = Color(0xFF4A5560);
  static const Color outlineLight = Color(0xFF9A8E70);

  // ───────── Dark neutrals (built on Basalt) ─────────
  static const Color darkLowest = Color(0xFF121A22);
  static const Color darkLow = Color(0xFF1B2530);
  static const Color darkSurface = Color(0xFF1F2A36);
  static const Color darkHigh = Color(0xFF263341);
  static const Color darkHighest = Color(0xFF2E3C4D);
  static const Color darkOutlineVariant = Color(0xFF3A4858);
  static const Color darkOutline = Color(0xFF6B7889);
  static const Color mutedDark = Color(0xFFA9B3BF);
}
