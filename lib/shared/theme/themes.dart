import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  factory AppThemeData.fromSeed({
    required String id,
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color thumbColor,
    required Color appBarBackground,
    required Color shadowColor,
    required Color mediaColor,
    required Color iconColor,
  }) {
    return _buildTheme(
      id: id,
      brightness: brightness,
      scaffoldBackground: scaffoldBackground,
      thumbColor: thumbColor,
      appBarBackground: appBarBackground,
      shadowColor: shadowColor,
      mediaColor: mediaColor,
      iconColor: iconColor,
    );
  }
}

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
    return allThemes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => dark,
    );
  }

  static void addCustomTheme(AppThemeData theme) =>
      _customThemes[theme.id] = theme;

  static void removeCustomTheme(String id) => _customThemes.remove(id);

  static AppThemeData? getTheme(String id) {
    for (AppThemeData theme in allThemes) {
      if (theme.id == id) return theme;
    }
    return null;
  }

  static List<AppThemeData> get allCustomThemes =>
      _customThemes.values.toList();

  static List<AppThemeData> get allThemes => [
    dark,
    green,
    purple,
    ..._customThemes.values,
  ];
}

AppThemeData _buildDarkTheme() {
  return _buildTheme(
    id: 'dark',
    brightness: Brightness.dark,
    scaffoldBackground: const Color(0xFF11121f),
    appBarBackground: const Color(0xff202138),
    thumbColor: const Color(0xFFFFFFFF),
    shadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xff202138),
    iconColor: Colors.black,
  );
}

AppThemeData _buildGreenTheme() {
  return _buildTheme(
    id: 'green',
    brightness: Brightness.light,
    scaffoldBackground: const Color(0xfff1f8dc),
    thumbColor: const Color(0xff03c893),
    appBarBackground: const Color(0xff86E7B8),
    shadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xff9ff3c7),
    iconColor: Colors.black,
  );
}

AppThemeData _buildPurpleTheme() {
  return _buildTheme(
    id: 'purple',
    brightness: Brightness.dark,
    scaffoldBackground: const Color(0xff6d0f8f),
    thumbColor: const Color(0xffab1c4b),
    appBarBackground: const Color(0xffab1c4b),
    shadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xffab1c4b),
    iconColor: Colors.white,
  );
}

AppThemeData _buildTheme({
  required String id,
  required Brightness brightness,
  required Color scaffoldBackground,
  required Color thumbColor,
  required Color appBarBackground,
  required Color shadowColor,
  required Color mediaColor,
  required Color iconColor,
}) {
  return AppThemeData(
    id: id,
    themeData: ThemeData(
      fontFamily: "Vazir",
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: appBarBackground,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        shadowColor: shadowColor,
        backgroundColor: appBarBackground,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 1,
        activeTrackColor: thumbColor,
        thumbColor: thumbColor,
        inactiveTrackColor: thumbColor,
      ),
      iconTheme: IconThemeData(color: iconColor),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(iconColor)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scaffoldBackground,
      ),
    ),
    mediaColor: mediaColor,
  );
}
