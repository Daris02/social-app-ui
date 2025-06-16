import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    inversePrimary: Colors.grey[50],
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[100],
    displayColor: Colors.white,
  )
);
