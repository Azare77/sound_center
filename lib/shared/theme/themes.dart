import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PresetTheme { dark, green, light }

class AppThemeData {
  final String id;
  final ThemeData themeData;
  final Color mediaColor;

  const AppThemeData({
    required this.id,
    required this.themeData,
    required this.mediaColor,
  });

  Map<String, dynamic> toJsonForStorage() {
    return {
      'id': id,
      'brightness': themeData.brightness.name,
      'scaffoldBackground': themeData.scaffoldBackgroundColor.toARGB32(),
      'thumbColor': (themeData.sliderTheme.thumbColor ?? Colors.white)
          .toARGB32(),
      'appBarBackground':
          (themeData.appBarTheme.backgroundColor ?? Colors.white).toARGB32(),
      'appBarShadowColor':
          (themeData.appBarTheme.shadowColor ?? Colors.transparent).toARGB32(),
      'mediaColor': mediaColor.toARGB32(),
      'iconColor': (themeData.iconTheme.color ?? Colors.white).toARGB32(),
    };
  }

  factory AppThemeData.fromJsonForStorage(Map<String, dynamic> json) {
    return AppThemeData.fromSeed(
      id: json['id'],
      brightness: json['brightness'] == 'dark'
          ? Brightness.dark
          : Brightness.light,
      scaffoldBackground: Color(json['scaffoldBackground']),
      thumbColor: Color(json['thumbColor']),
      appBarBackground: Color(json['appBarBackground']),
      appBarShadowColor: Color(json['appBarShadowColor']),
      mediaColor: Color(json['mediaColor']),
      iconColor: Color(json['iconColor']),
    );
  }

  factory AppThemeData.fromSeed({
    required String id,
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color thumbColor,
    required Color appBarBackground,
    required Color appBarShadowColor,
    required Color mediaColor,
    required Color iconColor,
  }) {
    return _buildTheme(
      id: id,
      brightness: brightness,
      scaffoldBackground: scaffoldBackground,
      thumbColor: thumbColor,
      appBarBackground: appBarBackground,
      appBarShadowColor: appBarShadowColor,
      mediaColor: mediaColor,
      iconColor: iconColor,
    );
  }
}

class ThemeManager {
  ThemeManager._();

  static final AppThemeData dark = _buildDarkTheme();
  static final AppThemeData green = _buildGreenTheme();
  static final AppThemeData light = _buildLightTheme();

  static final Map<String, AppThemeData> _customThemes = {};

  static AppThemeData current = dark;

  static AppThemeData fromPreset(PresetTheme preset) => switch (preset) {
    PresetTheme.dark => dark,
    PresetTheme.green => green,
    PresetTheme.light => light,
  };

  static AppThemeData fromId(String themeId) {
    return allThemes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => dark,
    );
  }

  static AppThemeData? getCustomTheme(String id) => _customThemes[id];

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
    light,
    green,
    ..._customThemes.values,
  ];
}

AppThemeData _buildDarkTheme() {
  return _buildTheme(
    id: 'dark',
    brightness: Brightness.dark,
    scaffoldBackground: const Color(0xFF11121f),
    appBarBackground: const Color(0xff202138),
    thumbColor: const Color(0xFF0F9ED2),
    appBarShadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xff202138),
    iconColor: Colors.white,
  );
}

AppThemeData _buildGreenTheme() {
  return _buildTheme(
    id: 'green',
    brightness: Brightness.light,
    scaffoldBackground: const Color(0xfff1f8dc),
    thumbColor: const Color(0xff03c893),
    appBarBackground: const Color(0xff86E7B8),
    appBarShadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xff9ff3c7),
    iconColor: Colors.black,
  );
}

AppThemeData _buildLightTheme() {
  return _buildTheme(
    id: 'light',
    brightness: Brightness.light,
    scaffoldBackground: Colors.grey.shade200,
    thumbColor: const Color(0xff183054),
    appBarBackground: const Color(0xfff5ffd6),
    appBarShadowColor: const Color(0xFF601410),
    mediaColor: const Color(0xfff1f8dc),
    iconColor: Colors.black,
  );
}

AppThemeData _buildTheme({
  required String id,
  required Brightness brightness,
  required Color scaffoldBackground,
  required Color thumbColor,
  required Color appBarBackground,
  required Color appBarShadowColor,
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
        shadowColor: appBarShadowColor,
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
