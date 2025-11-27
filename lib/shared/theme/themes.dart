// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

enum AppThemes { dark, green }

// کلاس پایه برای همه تم‌ها
abstract class AppTheme {
  static AppTheme? _current;

  static AppTheme get current {
    return _current ??= DarkTheme();
  }

  static set current(AppTheme theme) {
    _current = theme;
  }

  ThemeData get themeData;

  Color get mediaColor;

  Color get svgColor;
}

// تم تاریک
class DarkTheme implements AppTheme {
  @override
  ThemeData get themeData => ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: Color(0xff202138),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(Color(0xbe20213a)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 1,
      activeTickMarkColor: Color(0xFFFFFFFF),
      activeTrackColor: Color(0xFFFFFFFF),
      thumbColor: Color(0xFFFFFFFF),
    ),
    scaffoldBackgroundColor: const Color(0xFF11121f),
    colorScheme: const ColorScheme(
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
    iconTheme: IconThemeData(color: Colors.white),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
    ),
  );

  @override
  Color get mediaColor => const Color(0xff202138);

  @override
  Color get svgColor => Colors.white;
}

// تم سبز
class GreenTheme implements AppTheme {
  @override
  ThemeData get themeData => ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: Color(0xff86E7B8),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(Color(0xbe20213a)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 1,
      activeTickMarkColor: Color(0xff03c893),
      activeTrackColor: Color(0xff03c893),
      thumbColor: Color(0xff03c893),
    ),
    scaffoldBackgroundColor: const Color(0xffdde7b1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: const Color(0xffdde7b1),
    ),
    iconTheme: IconThemeData(color: Colors.black),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.black)),
    ),
  );

  @override
  Color get mediaColor => const Color(0xff86E7B8);

  @override
  Color get svgColor => Colors.black;
}
