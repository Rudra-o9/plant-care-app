import 'package:flutter/material.dart';

enum AppThemePreference { system, light, dark }

class AppThemeController extends ChangeNotifier {
  AppThemePreference _preference = AppThemePreference.system;

  AppThemePreference get preference => _preference;

  ThemeMode get themeMode {
    switch (_preference) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  void setPreference(AppThemePreference preference) {
    if (_preference == preference) return;
    _preference = preference;
    notifyListeners();
  }
}

final appThemeController = AppThemeController();
