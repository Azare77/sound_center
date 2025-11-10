import 'dart:convert';

import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';

class PodcastSettingStorage {
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
