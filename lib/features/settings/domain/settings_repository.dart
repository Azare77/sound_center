import 'dart:ui';

enum PodcastProvider { itunes, podcatIndex }

abstract class SettingRepository {
  Future<void> setPodcastProvider(PodcastProvider provider);

  PodcastProvider getPodcastProvider();

  Future<void> setPodcastIndexKeys(String key, String secret);

  Map<String, String>? getPodcastIndexKeys();

  Future<void> setLocale(Locale locale);

  Locale getLocale();
}
