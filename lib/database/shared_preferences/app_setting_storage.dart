import 'dart:convert';
import 'dart:ui';

import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/shared/theme/themes.dart';

class AppSettingStorage {
  static Future<void> saveCustomThemes(List<AppThemeData> themes) async {
    String jsonString = jsonEncode(
      themes.map((t) => t.toJsonForStorage()).toList(),
    );
    await Storage.instance.prefs.setString('customThemes', jsonString);
  }

  static List<AppThemeData> getCustomThemes() {
    List<AppThemeData> themes = [];
    String? jsonString = Storage.instance.prefs.getString('customThemes');
    if (jsonString == null) return themes;
    List<dynamic> jsonList = jsonDecode(jsonString);
    for (var jsonItem in jsonList) {
      themes.add(AppThemeData.fromJsonForStorage(jsonItem));
    }
    return themes;
  }

  static String getTheme() {
    final String? theme = Storage.instance.prefs.getString('theme');
    return theme ?? PresetTheme.dark.name;
  }

  static Future<void> saveTheme(String theme) async {
    await Storage.instance.prefs.setString('theme', theme);
  }

  static Locale getLocale() {
    final String? locale = Storage.instance.prefs.getString('locale');
    if (locale == null) return Locale("en");
    return Locale(locale);
  }

  static Future<void> saveLocale(Locale locale) async {
    await Storage.instance.prefs.setString('locale', locale.languageCode);
  }

  static PodcastProvider getSavedProvider() {
    final String? provider = Storage.instance.prefs.getString('provider');
    return PodcastProvider.values.firstWhere(
      (e) => e.name == provider,
      orElse: () => PodcastProvider.itunes,
    );
  }

  static Future<void> saveProvider(PodcastProvider provider) async {
    await Storage.instance.prefs.setString('provider', provider.name);
  }

  static Map<String, String>? getPodcastIndexKeys() {
    String? jsonString = Storage.instance.prefs.getString('podcastIndexInfo');
    if (jsonString == null) return null;
    Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  static Future<void> setPodcastIndexKeys(String key, String secret) async {
    Map<String, String> podcastIndexInfo = {"key": key, "secret": secret};
    String jsonString = jsonEncode(podcastIndexInfo);
    await Storage.instance.prefs.setString('podcastIndexInfo', jsonString);
  }
}
