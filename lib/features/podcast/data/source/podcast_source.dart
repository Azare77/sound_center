import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/shared_preferences/podcast_setting_storage.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';

class PodcastSource {
  static final Map<String, Podcast> _podcastCache = {};
  static final Map<String, DateTime> _cachedTime = {};

  static Future<SearchResult> search(String searchText) async {
    Search search = Search();
    PodcastProvider provider = PodcastSettingStorage.getSavedProvider();
    if (provider == PodcastProvider.podcatIndex) {
      Map<String, String>? podcastIndexInfo =
          PodcastSettingStorage.getPodcastIndexKeys();
      if (podcastIndexInfo != null) {
        search = Search(
          searchProvider: PodcastIndexProvider(
            key: podcastIndexInfo['key']!,
            secret: podcastIndexInfo['secret']!,
          ),
        );
      }
    }
    SearchResult results = await search.search(searchText, limit: 10);
    return results;
  }

  static Future<Podcast> loadPodcastInfo(
    String feedUrl,
    bool force, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final cached = _podcastCache[feedUrl];
    if (!force && cached != null) {
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
}
