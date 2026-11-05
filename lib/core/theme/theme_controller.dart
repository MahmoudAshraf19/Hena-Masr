import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds and persists the user's theme choice (system / light / dark).
class ThemeController extends ChangeNotifier {
  ThemeController._(this._prefs, this._mode);

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    return ThemeController._(prefs, mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }
}
