// theme_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// نوع تم‌های پیش‌فرض اپ
enum PresetTheme { dark, green, purple }

class AppThemeData {
  final String id;
  final String? displayName;
  final ThemeData themeData;
  final Color mediaColor;

  const AppThemeData({
    required this.id,
    this.displayName,
    required this.themeData,
    required this.mediaColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// مدیریت کامل تم‌های اپ (Singleton)
class ThemeManager {
  ThemeManager._();

  static final AppThemeData dark = _buildDarkTheme();
  static final AppThemeData green = _buildGreenTheme();
  static final AppThemeData purple = _buildPurpleTheme();

  static final Map<String, AppThemeData> _customThemes = {};

  static AppThemeData current = dark;

  static AppThemeData fromPreset(PresetTheme preset) => switch (preset) {
    PresetTheme.dark => dark,
    PresetTheme.green => green,
    PresetTheme.purple => purple,
  };

  static AppThemeData fromId(String themeId) {
    if (themeId.startsWith('custom:')) {
      final id = themeId.substring(7);
      return _customThemes[id] ?? dark;
    }
    return switch (themeId) {
      'green' => green,
      'purple' => purple,
      _ => dark,
    };
  }

  static void addCustomTheme(AppThemeData theme) =>
      _customThemes[theme.id] = theme;

  static void removeCustomTheme(String id) => _customThemes.remove(id);

  static AppThemeData? getCustomTheme(String id) => _customThemes[id];

  static List<AppThemeData> get allCustomThemes =>
      _customThemes.values.toList();

  static List<AppThemeData> get allThemes => [
    dark,
    green,
    purple,
    ..._customThemes.values,
  ];
}

// ---------------------------------------------------------------------------
// ساخت تم‌های پیش‌فرض (یک بار و فقط اینجا)
// ---------------------------------------------------------------------------

AppThemeData _buildDarkTheme() => AppThemeData(
  id: 'dark',
  themeData: ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff202138),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF11121f),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: Color(0xff202138),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 1,
      activeTrackColor: Colors.white,
      thumbColor: Colors.white,
      inactiveTrackColor: Colors.white24,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
  ),
  mediaColor: const Color(0xff202138),
);

AppThemeData _buildGreenTheme() => AppThemeData(
  id: 'green',
  themeData: ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff86E7B8),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xfff3ffe9),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: Color(0xff86E7B8),
      foregroundColor: Colors.black87,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 1,
      activeTrackColor: Color(0xff03c893),
      thumbColor: Color(0xff03c893),
      inactiveTrackColor: Color(0x3303c893),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xfff3ffe9),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(Colors.black),
      ),
    ),
  ),
  mediaColor: const Color(0xff9ff3c7),
);

AppThemeData _buildPurpleTheme() => AppThemeData(
  id: 'purple',
  themeData: ThemeData(
    fontFamily: "Vazir",
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff1e2493),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xff4b4f9b),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      shadowColor: Color(0xFF601410),
      backgroundColor: Color(0xff1e2493),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 1,
      activeTrackColor: Color(0xff0814ec),
      thumbColor: Color(0xff0814ec),
      inactiveTrackColor: Color(0x330814ec),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xff4b4f9b),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
  ),
  mediaColor: const Color(0xff363dea),
);
