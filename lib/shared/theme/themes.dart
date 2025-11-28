// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}

// تم تاریک
class DarkTheme implements AppTheme {
  final Color scaffoldBackground = const Color(0xFF11121f);
  final Color thumbColor = const Color(0xFFFFFFFF);
  final Color appBarBackground = const Color(0xff202138);

  @override
  ThemeData get themeData => ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff202138),
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(Color(0xbe20213a)),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 1,
      activeTickMarkColor: thumbColor,
      activeTrackColor: thumbColor,
      thumbColor: thumbColor,
    ),
    scaffoldBackgroundColor: scaffoldBackground,
    iconTheme: IconThemeData(color: Colors.white),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
    ),
  );

  @override
  Color get mediaColor => const Color(0xff202138);
}

// تم سبز
class GreenTheme implements AppTheme {
  final Color scaffoldBackground = const Color(0xffdde7b1);
  final Color thumbColor = const Color(0xff03c893);
  final Color appBarBackground = const Color(0xff86E7B8);

  @override
  ThemeData get themeData => ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appBarBackground,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: const Color(0xFF601410),
      backgroundColor: appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(Color(0xbe20213a)),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 1,
      activeTickMarkColor: thumbColor,
      activeTrackColor: thumbColor,
      thumbColor: thumbColor,
    ),
    scaffoldBackgroundColor: scaffoldBackground,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: scaffoldBackground),
    iconTheme: IconThemeData(color: Colors.black),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.black)),
    ),
  );

  @override
  Color get mediaColor => const Color(0xff86E7B8);
}
