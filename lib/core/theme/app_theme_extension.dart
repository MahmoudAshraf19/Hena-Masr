import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Brand colors that don't map cleanly to Material's ColorScheme.
/// Access: `context.hena.gold`
@immutable
class HenaColors extends ThemeExtension<HenaColors> {
  const HenaColors({
    required this.gold,
    required this.onGold,
    required this.turquoise,
    required this.onTurquoise,
    required this.turquoiseText,
    required this.carnelian,
    required this.carnelianText,
    required this.sand,
    required this.success,
    required this.heroSurface,
    required this.onHeroSurface,
  });

  /// Main CTA background (always paired with [onGold]).
  final Color gold;
  final Color onGold;

  /// Secondary accent fills (chips, progress, toggles).
  final Color turquoise;
  final Color onTurquoise;

  /// Turquoise variant safe for text/icons on the current background.
  final Color turquoiseText;

  /// Warning fills (Scam Shield banners).
  final Color carnelian;

  /// Warning variant safe for text/icons on the current background.
  final Color carnelianText;

  final Color sand;
  final Color success;

  /// Big feature cards (e.g. the featured place).
  final Color heroSurface;
  final Color onHeroSurface;

  static const HenaColors light = HenaColors(
    gold: AppColors.gold,
    onGold: AppColors.basalt,
    turquoise: AppColors.turquoise,
    onTurquoise: AppColors.basalt,
    turquoiseText: AppColors.turquoiseDeep,
    carnelian: AppColors.carnelian,
    carnelianText: AppColors.carnelian,
    sand: AppColors.sand,
    success: AppColors.success,
    heroSurface: AppColors.lapis,
    onHeroSurface: AppColors.papyrus,
  );

  static const HenaColors dark = HenaColors(
    gold: AppColors.gold,
    onGold: AppColors.basalt,
    turquoise: AppColors.turquoise,
    onTurquoise: AppColors.basalt,
    turquoiseText: AppColors.turquoise,
    carnelian: AppColors.carnelian,
    carnelianText: AppColors.carnelianLight,
    sand: AppColors.sand,
    success: AppColors.successLight,
    heroSurface: AppColors.lapis,
    onHeroSurface: AppColors.papyrus,
  );

  @override
  HenaColors copyWith({
    Color? gold,
    Color? onGold,
    Color? turquoise,
    Color? onTurquoise,
    Color? turquoiseText,
    Color? carnelian,
    Color? carnelianText,
    Color? sand,
    Color? success,
    Color? heroSurface,
    Color? onHeroSurface,
  }) =>
      HenaColors(
        gold: gold ?? this.gold,
        onGold: onGold ?? this.onGold,
        turquoise: turquoise ?? this.turquoise,
        onTurquoise: onTurquoise ?? this.onTurquoise,
        turquoiseText: turquoiseText ?? this.turquoiseText,
        carnelian: carnelian ?? this.carnelian,
        carnelianText: carnelianText ?? this.carnelianText,
        sand: sand ?? this.sand,
        success: success ?? this.success,
        heroSurface: heroSurface ?? this.heroSurface,
        onHeroSurface: onHeroSurface ?? this.onHeroSurface,
      );

  @override
  HenaColors lerp(ThemeExtension<HenaColors>? other, double t) {
    if (other is! HenaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HenaColors(
      gold: l(gold, other.gold),
      onGold: l(onGold, other.onGold),
      turquoise: l(turquoise, other.turquoise),
      onTurquoise: l(onTurquoise, other.onTurquoise),
      turquoiseText: l(turquoiseText, other.turquoiseText),
      carnelian: l(carnelian, other.carnelian),
      carnelianText: l(carnelianText, other.carnelianText),
      sand: l(sand, other.sand),
      success: l(success, other.success),
      heroSurface: l(heroSurface, other.heroSurface),
      onHeroSurface: l(onHeroSurface, other.onHeroSurface),
    );
  }
}
