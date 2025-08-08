import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier(super.initialTheme);

  void setTheme(ThemeData theme) {
    state = theme;
  }

  void toggleTheme() {
    state = (state == lightMode) ? darkMode : lightMode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
  (ref) => ThemeNotifier(darkMode),
);
