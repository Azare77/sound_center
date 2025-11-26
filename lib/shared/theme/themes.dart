// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

enum AppThemes { dark, green }

// کلاس پایه برای همه تم‌ها
abstract class AppTheme {
  static AppTheme? _current;

  // تم فعلی رو برمی‌گردونه - هر جا که بخوای استفاده کن
  static AppTheme get current {
    return _current ??= DarkTheme(); // اولین بار دارک لود میشه
  }

  // ست کردن تم جدید (مثلاً وقتی کاربر عوض کرد)
  static set current(AppTheme theme) {
    _current = theme;
  }

  // این‌ها رو همه تم‌ها باید داشته باشن
  ThemeData get themeData;

  Color get mediaColor; // رنگ مخصوص مدیا (مثل نوار پخش موزیک)
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
  );

  @override
  Color get mediaColor => const Color(0xff202138);
}

// تم سبز
class GreenTheme implements AppTheme {
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
  );

  @override
  Color get mediaColor => const Color(0xff03c893);
}
