import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  HenaColors get hena => Theme.of(this).extension<HenaColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
