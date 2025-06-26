import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromRGBO(162, 68, 29, 1),
    fontFamily: 'BarlowCondensed',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(162, 68, 29, 1),
    ).copyWith(secondary: const Color.fromRGBO(255, 194, 69, 1),),useMaterial3: true
  );
}
