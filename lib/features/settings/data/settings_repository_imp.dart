import 'package:sound_center/database/shared_preferences/podcast_setting_storage.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';

class SettingsRepositoryImp implements SettingRepository {
  static final SettingsRepositoryImp _instance =
      SettingsRepositoryImp._internal();

  factory SettingsRepositoryImp() => _instance;

  SettingsRepositoryImp._internal();

  @override
  Map<String, String>? getPodcastIndexKeys() {
    return PodcastSettingStorage.getPodcastIndexKeys();
  }

  @override
  PodcastProvider getPodcastProvider() {
    return PodcastSettingStorage.getSavedProvider();
  }

  @override
  Future<void> setPodcastIndexKeys(String key, String secret) async {
    await PodcastSettingStorage.setPodcastIndexKeys(key, secret);
  }

  @override
  Future<void> setPodcastProvider(PodcastProvider provider) async {
    await PodcastSettingStorage.saveProvider(provider);
  }
}
