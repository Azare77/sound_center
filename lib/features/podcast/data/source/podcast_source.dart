import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';

class PodcastSource {
  static final Map<String, Podcast> _podcastCache = {};
  static final Map<String, DateTime> _cachedTime = {};

  static Future<SearchResult> search(String searchText) async {
    Search search = Search();
    PodcastProvider provider = AppSettingStorage.getSavedProvider();
    if (provider == PodcastProvider.podcatIndex) {
      Map<String, String>? podcastIndexInfo =
          AppSettingStorage.getPodcastIndexKeys();
      if (podcastIndexInfo != null) {
        search = Search(
          searchProvider: PodcastIndexProvider(
            key: podcastIndexInfo['key']!,
            secret: podcastIndexInfo['secret']!,
          ),
        );
      }
    }
    SearchResult results = await search.search(searchText, limit: 50);
    return results;
  }

  static Future<Podcast> loadPodcastInfo(
    String feedUrl, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      final cachedTime = _cachedTime[feedUrl]!;
      if (DateTime.now().difference(cachedTime) < ttl) {
        return cached;
      }
    }

    final podcast = await Feed.loadFeed(url: feedUrl);
    _podcastCache[feedUrl] = podcast;
    _cachedTime[feedUrl] = DateTime.now();
    return podcast;
  }

  static void setCache(Map<String, Podcast> podcasts) {
    podcasts.forEach((feed, podcast) {
      _podcastCache[feed] = podcast;
      _cachedTime[feed] = DateTime.now();
    });
  }
}
