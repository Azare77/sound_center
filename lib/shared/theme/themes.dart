// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

ThemeData DEFAULT_THEME = ThemeData(
  fontFamily: "Vazir",
  brightness: Brightness.dark,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(Color(0xFFE7AC2E)),
    ),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF27734F),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E0E9),
  ),
);

ThemeData DARK_THEME = ThemeData(
  fontFamily: "Vazir",
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    elevation: 2,
    centerTitle: true,
    shadowColor: Color(0xFF601410),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(Color(0xFFE7AC2E)),
    ),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xff202138),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF11121f),
    onSurface: Color(0xFFE6E0E9),
  ),
);
