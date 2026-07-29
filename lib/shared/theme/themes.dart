import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PresetTheme { dark, green, light }

class AppThemeData {
  final String id;
  final Brightness brightness;
  final Color scaffoldBackground;
  final Color thumbColor;
  final Color appBarBackground;
  final Color appBarShadowColor;
  final Color iconColor;
  final Color mediaColor;

  const AppThemeData({
    required this.id,
    required this.mediaColor,
    required this.brightness,
    required this.scaffoldBackground,
    required this.thumbColor,
    required this.appBarBackground,
    required this.appBarShadowColor,
    required this.iconColor,
  });

  Map<String, dynamic> toJsonForStorage() {
    return {
      'id': id,
      'brightness': brightness.name,
      'scaffoldBackground': scaffoldBackground.toARGB32(),
      'thumbColor': (thumbColor).toARGB32(),
      'appBarBackground': (appBarBackground).toARGB32(),
      'appBarShadowColor': (appBarShadowColor).toARGB32(),
      'mediaColor': mediaColor.toARGB32(),
      'iconColor': (iconColor).toARGB32(),
    };
  }

  factory AppThemeData.fromJsonForStorage(Map<String, dynamic> json) {
    return AppThemeData(
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

  AppThemeData copyWith({
    String? id,
    Brightness? brightness,
    Color? scaffoldBackground,
    Color? thumbColor,
    Color? appBarBackground,
    Color? appBarShadowColor,
    Color? iconColor,
    Color? mediaColor,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      brightness: brightness ?? this.brightness,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      thumbColor: thumbColor ?? this.thumbColor,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarShadowColor: appBarShadowColor ?? this.appBarShadowColor,
      iconColor: iconColor ?? this.iconColor,
      mediaColor: mediaColor ?? this.mediaColor,
    );
  }
}

extension AppThemeDataCompare on AppThemeData {
  bool isEquivalent(AppThemeData other) {
    return brightness == other.brightness &&
        scaffoldBackground == other.scaffoldBackground &&
        thumbColor == other.thumbColor &&
        appBarBackground == other.appBarBackground &&
        appBarShadowColor == other.appBarShadowColor &&
        iconColor == other.iconColor &&
        mediaColor == other.mediaColor;
  }
}

class ThemeManager {
  ThemeManager._();

  static final AppThemeData dark = _buildDarkTheme();
  static final AppThemeData green = _buildGreenTheme();
  static final AppThemeData light = _buildLightTheme();

  static final Map<String, AppThemeData> _customThemes = {};

  static Locale _locale = Locale("en");

  static AppThemeData _current = dark;

  static AppThemeData get current => _current;

  static AppThemeData fromId(String themeId) {
    AppThemeData theme = allThemes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => _current,
    );

    return theme;
  }

  static ThemeData getThemeData(AppThemeData theme) {
    return ThemeData(
      fontFamily: _getFontFamily(),
      brightness: theme.brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.appBarBackground,
        brightness: theme.brightness,
      ),
      scaffoldBackgroundColor: theme.scaffoldBackground,
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        shadowColor: theme.appBarShadowColor,
        backgroundColor: theme.appBarBackground,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: theme.brightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 1,
        activeTrackColor: theme.thumbColor,
        inactiveTrackColor: theme.thumbColor,
        thumbColor: theme.thumbColor,
      ),
      iconTheme: IconThemeData(color: theme.iconColor),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(theme.iconColor),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.scaffoldBackground,
      ),
    );
  }

  static AppThemeData? getCustomTheme(String id) => _customThemes[id];

  static void addCustomTheme(AppThemeData theme) =>
      _customThemes[theme.id] = theme;

  static void removeCustomTheme(String id) => _customThemes.remove(id);

  static void setTheme(String themeId, Locale locale) {
    _locale = locale;
    _current = fromId(themeId);
  }

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

  static bool isEquivalent(AppThemeData other) {
    return allThemes.any(
      (theme) =>
          theme.brightness == other.brightness &&
          theme.scaffoldBackground == other.scaffoldBackground &&
          theme.thumbColor == other.thumbColor &&
          theme.appBarBackground == other.appBarBackground &&
          theme.appBarShadowColor == other.appBarShadowColor &&
          theme.iconColor == other.iconColor &&
          theme.mediaColor == other.mediaColor,
    );
  }
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
    brightness: brightness,
    appBarBackground: appBarBackground,
    appBarShadowColor: appBarBackground,
    iconColor: iconColor,
    scaffoldBackground: scaffoldBackground,
    thumbColor: thumbColor,
    mediaColor: mediaColor,
  );
}

String _getFontFamily() {
  switch (ThemeManager._locale.languageCode) {
    case "fa":
      return "Vazir";
    default:
      return "VazirEn";
  }
}
