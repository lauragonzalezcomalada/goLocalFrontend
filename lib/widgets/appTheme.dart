import 'package:flutter/material.dart';

class AppTheme {
  static const Color naranja_light = Color.fromRGBO(250, 147, 57, 1);
  static const Color fucsia = Color.fromRGBO(250, 57, 211, 1);
  static const Color logo = Color.fromRGBO(250, 80, 57, 1);
  static const Color naranja_strong = Color.fromRGBO(250, 114, 57, 1);
  static const Color rosa = const Color.fromRGBO(250, 62, 100, 1);
  static const Color cardColor = const Color.fromRGBO(252, 110, 75, 0.966);

  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromRGBO(245, 72, 66, 1),
      fontFamily: 'BarlowCondensed',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(245, 72, 66, 1),
      ).copyWith(
        primary: const Color.fromRGBO(245, 72, 66, 1),
        secondary: const Color.fromRGBO(250, 147, 57, 1),
      ),
      useMaterial3: true);
}
