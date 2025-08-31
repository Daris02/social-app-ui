import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';

enum AppThemeMode { claire, sombre, system }

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightMode) {
    _loadTheme();
  }

  AppThemeMode _currentMode = AppThemeMode.system;

  AppThemeMode get currentMode => _currentMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 2;
    _currentMode = AppThemeMode.values[themeIndex];
    _updateThemeFromMode();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _currentMode = mode;
    _updateThemeFromMode();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void _updateThemeFromMode() {
    switch (_currentMode) {
      case AppThemeMode.claire:
        state = lightMode;
        break;
      case AppThemeMode.sombre:
        state = darkMode;
        break;
      case AppThemeMode.system:
        state = WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? darkMode
            : lightMode;
        break;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
  (ref) => ThemeNotifier(),
);
