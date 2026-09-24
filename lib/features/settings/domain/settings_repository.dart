import 'dart:ui';

import 'package:sound_center/shared/theme/themes.dart';

enum PodcastProvider { itunes, podcatIndex }

enum PlayerStyle { solid, blur }

abstract class SettingRepository {
  Future<void> setPodcastProvider(PodcastProvider provider);

  PodcastProvider getPodcastProvider();

  Future<void> setPodcastIndexKeys(String key, String secret);

  Map<String, String>? getPodcastIndexKeys();

  Future<void> setLocale(Locale locale);

  Locale getLocale();

  Future<void> setTheme(String themeName);

  String getTheme();

  Future<void> saveCustomThemes(List<AppThemeData> themes);

  List<AppThemeData> getCustomThemes();

  bool getNotificationState();

  Future<void> setNotificationState(bool persist);

  PlayerStyle getPlayerStyle();

  Future<void> setPlayerStyle(PlayerStyle style);
}
