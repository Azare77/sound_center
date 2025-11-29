import 'dart:ui';

import 'package:sound_center/database/shared_preferences/podcast_setting_storage.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';

class SettingsRepositoryImp implements SettingRepository {
  static final SettingsRepositoryImp _instance =
      SettingsRepositoryImp._internal();

  factory SettingsRepositoryImp() => _instance;

  SettingsRepositoryImp._internal();

  @override
  Map<String, String>? getPodcastIndexKeys() {
    return AppSettingStorage.getPodcastIndexKeys();
  }

  @override
  PodcastProvider getPodcastProvider() {
    return AppSettingStorage.getSavedProvider();
  }

  @override
  Future<void> setPodcastIndexKeys(String key, String secret) async {
    await AppSettingStorage.setPodcastIndexKeys(key, secret);
  }

  @override
  Future<void> setPodcastProvider(PodcastProvider provider) async {
    await AppSettingStorage.saveProvider(provider);
  }

  @override
  Locale getLocale() {
    return AppSettingStorage.getLocale();
  }

  @override
  Future<void> setLocale(Locale locale) async {
    AppSettingStorage.saveLocale(locale);
  }

  @override
  String getTheme() {
    return AppSettingStorage.getTheme();
  }

  @override
  Future<void> setTheme(String themeName) async {
    AppSettingStorage.saveTheme(themeName);
  }
}
