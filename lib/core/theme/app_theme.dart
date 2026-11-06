import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for Hena Masr.
///
/// Usage:
/// ```dart
/// theme: AppTheme.light(locale),
/// darkTheme: AppTheme.dark(locale),
/// ```
abstract final class AppTheme {
  static ThemeData light([Locale? locale]) => _build(
        brightness: Brightness.light,
        scheme: _lightScheme,
        hena: HenaColors.light,
        arabic: locale?.languageCode == 'ar',
      );

  static ThemeData dark([Locale? locale]) => _build(
        brightness: Brightness.dark,
        scheme: _darkScheme,
        hena: HenaColors.dark,
        arabic: locale?.languageCode == 'ar',
      );

  // ───────────────────────── Color schemes ─────────────────────────

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lapis,
    onPrimary: AppColors.white,
    primaryContainer: Color(0xFFDCE4F5),
    onPrimaryContainer: AppColors.lapis,
    secondary: AppColors.turquoise,
    onSecondary: AppColors.basalt,
    secondaryContainer: Color(0xFFD3EFEC),
    onSecondaryContainer: Color(0xFF0F4F4B),
    tertiary: AppColors.gold,
    onTertiary: AppColors.basalt,
    tertiaryContainer: Color(0xFFF6E6C3),
    onTertiaryContainer: Color(0xFF4A3510),
    error: AppColors.carnelian,
    onError: AppColors.white,
    errorContainer: Color(0xFFF6D9D7),
    onErrorContainer: Color(0xFF6B1512),
    surface: AppColors.papyrus,
    onSurface: AppColors.basalt,
    onSurfaceVariant: AppColors.mutedLight,
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.sand,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.papyrusLight,
    surfaceContainer: AppColors.papyrusDeep,
    surfaceContainerHigh: AppColors.sandSoft,
    surfaceContainerHighest: AppColors.sand,
    inverseSurface: AppColors.basalt,
    onInverseSurface: AppColors.papyrus,
    inversePrimary: AppColors.lapisLight,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.lapisLight,
    onPrimary: AppColors.basalt,
    primaryContainer: AppColors.lapis,
    onPrimaryContainer: Color(0xFFDCE4F5),
    secondary: AppColors.turquoise,
    onSecondary: AppColors.basalt,
    secondaryContainer: Color(0xFF14504C),
    onSecondaryContainer: Color(0xFFB7ECE7),
    tertiary: AppColors.gold,
    onTertiary: AppColors.basalt,
    tertiaryContainer: Color(0xFF5A4318),
    onTertiaryContainer: Color(0xFFF6E6C3),
    error: AppColors.carnelianLight,
    onError: AppColors.basalt,
    errorContainer: Color(0xFF6B1512),
    onErrorContainer: Color(0xFFF6D9D7),
    surface: AppColors.basalt,
    onSurface: AppColors.papyrus,
    onSurfaceVariant: AppColors.mutedDark,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    surfaceContainerLowest: AppColors.darkLowest,
    surfaceContainerLow: AppColors.darkLow,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkHigh,
    surfaceContainerHighest: AppColors.darkHighest,
    inverseSurface: AppColors.papyrus,
    onInverseSurface: AppColors.basalt,
    inversePrimary: AppColors.lapis,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  // ───────────────────────── Builder ─────────────────────────

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required HenaColors hena,
    required bool arabic,
  }) {
    final isDark = brightness == Brightness.dark;
    final text = AppTypography.textTheme(
      color: scheme.onSurface,
      muted: scheme.onSurfaceVariant,
      arabic: arabic,
    );
    const stadium = StadiumBorder();

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: color, width: width),
        );

    final navUnselected = isDark
        ? scheme.onSurfaceVariant
        : AppColors.papyrus.withValues(alpha: 0.75);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily(arabic: arabic),
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: text,
      primaryTextTheme: text,
      extensions: <ThemeExtension<dynamic>>[hena],
      splashFactory: InkSparkle.splashFactory,
      dividerColor: scheme.outlineVariant,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // Main CTA: gold + basalt text (one per screen).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: hena.gold,
          foregroundColor: hena.onGold,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: stadium,
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hena.gold,
          foregroundColor: hena.onGold,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          elevation: 0,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: stadium,
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: stadium,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          shape: stadium,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: inputBorder(scheme.outlineVariant),
        enabledBorder: inputBorder(scheme.outlineVariant),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
      ),

      // Selected chip = primary fill (lapis in light, lapis tint in dark).
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outlineVariant),
        shape: stadium,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: text.labelMedium?.copyWith(fontSize: 13),
        secondaryLabelStyle:
            text.labelMedium?.copyWith(fontSize: 13, color: scheme.onPrimary),
      ),

      // Floating-pill style bottom navigation (lapis in light mode).
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? scheme.surfaceContainer : AppColors.lapis,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
            isDark ? scheme.surfaceContainerHighest : AppColors.lapisSoft,
        indicatorShape: stadium,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? hena.gold : navUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            color: selected ? hena.gold : navUnselected,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: hena.gold,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: isDark ? AppColors.lapis : hena.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.white
                : scheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? hena.turquoiseText
                : scheme.surfaceContainerHighest),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.transparent
                : scheme.outline),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary
                : Colors.transparent),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: hena.turquoiseText,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: hena.turquoiseText,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: hena.gold,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
