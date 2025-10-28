import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';

class PodcastRepositoryImp implements PodcastRepository {
  final AppDatabase database;

  PodcastRepositoryImp(this.database);

  @override
  Future<List<SubscriptionEntity>> getHome() async {
    final subs = await database.select(database.subscriptionTable).get();
    final models = subs.map((s) => SubscriptionEntity.fromDrift(s)).toList();
    return models;
  }

  @override
  Future<bool> subscribe(SubscriptionEntity podcast) async {
    final existing = await (database.select(
      database.subscriptionTable,
    )..where((tbl) => tbl.feedUrl.equals(podcast.feedUrl))).getSingleOrNull();
    if (existing != null) {
      return false;
    }
    await database.into(database.subscriptionTable).insert(podcast.toDrift());
    return true;
  }

  @override
  Future<PodcastEntity> find(String searchText, {bool retry = true}) async {
    Search search = Search();
    SearchResult results = await search.search(searchText, limit: 10);
    if (results.successful) {
      results.items.removeWhere(
        (item) => item.feedUrl == null || item.feedUrl!.trim().isEmpty,
      );
      return PodcastEntity(results.items);
    } else {
      if (retry) {
        return find(searchText, retry: false);
      } else {
        return PodcastEntity([]);
      }
    }
  }

  @override
  Future<Podcast> loadPodcastInfo(String feedUrl) async {
    var podcast = await Feed.loadFeed(url: feedUrl);
    return podcast;
  }
}
