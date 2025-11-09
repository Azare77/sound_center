import 'package:drift/drift.dart' as drift;
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';

class PodcastRepositoryImp implements PodcastRepository {
  final AppDatabase database;

  PodcastRepositoryImp(this.database);

  Future<List<SubscriptionTableData>> getSubs() async {
    final subs =
        await (database.select(database.subscriptionTable)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.updateTime,
                mode: drift.OrderingMode.desc,
              ),
            ]))
            .get();
    return subs;
  }

  @override
  Future<List<SubscriptionEntity>> getHome() async {
    final subs = await getSubs();
    final models = subs.map((s) => SubscriptionEntity.fromDrift(s)).toList();
    return models;
  }

  @override
  Future<List<SubscriptionEntity>> haveUpdate() async {
    List<SubscriptionTableData> subs = await getSubs();
    List<SubscriptionEntity> models = subs
        .map((s) => SubscriptionEntity.fromDrift(s))
        .toList();
    final futures = models.map((SubscriptionEntity item) async {
      try {
        final podcast = await loadPodcastInfo(item.feedUrl);
        item.haveNewEpisode = podcast.episodes.length != item.totalEpisodes;
        DateTime updateTime = _getLastEpisodeDate(podcast.episodes);
        item.updateTime = updateTime;
        await (database.update(
          database.subscriptionTable,
        )..where((tbl) => tbl.feedUrl.equals(item.feedUrl))).write(
          SubscriptionTableCompanion(updateTime: drift.Value(updateTime)),
        );
      } catch (e) {
        item.haveNewEpisode = false;
      }
    });
    await Future.wait(futures);
    return _sortByUpdateTimeDesc(models);
  }

  @override
  Future<bool> subscribe(SubscriptionEntity podcast) async {
    bool exists = await isSubscribed(podcast.feedUrl);
    if (exists) return false;
    await database.into(database.subscriptionTable).insert(podcast.toDrift());
    return true;
  }

  @override
  Future<bool> updateSubscribedPodcast(SubscriptionEntity podcast) async {
    final exists = await isSubscribed(podcast.feedUrl);
    if (!exists) {
      return false;
    }
    await (database.update(database.subscriptionTable)
          ..where((tbl) => tbl.feedUrl.equals(podcast.feedUrl)))
        .write(podcast.toDrift());
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

  Future<bool> isSubscribed(String feedUrl) async {
    final existing = await (database.select(
      database.subscriptionTable,
    )..where((tbl) => tbl.feedUrl.equals(feedUrl))).getSingleOrNull();
    if (existing != null) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> unsubscribe(String feedUrl) async {
    await (database.delete(
      database.subscriptionTable,
    )..where((tbl) => tbl.feedUrl.equals(feedUrl))).go();
    return true;
  }

  @override
  Future<bool> downloadEpisode(DownloadedEpisodeEntity episode) async {
    await database.into(database.downloadTable).insert(episode.toDrift());
    return true;
  }

  @override
  Future<List<Episode>> getDownloadedEpisodes() async {
    final subs = await database.select(database.downloadTable).get();
    final List<Episode> episodes = subs
        .map((s) => DownloadedEpisodeEntity.fromDrift(s).toEpisode())
        .toList();
    return episodes;
  }

  DateTime _getLastEpisodeDate(List<Episode> episodes) {
    DateTime updateTime = DateTime(1970);
    for (Episode episode in episodes) {
      if (episode.publicationDate == null) continue;
      if (episode.publicationDate!.isAfter(updateTime)) {
        updateTime = episode.publicationDate!;
      }
    }
    return updateTime;
  }

  List<SubscriptionEntity> _sortByUpdateTimeDesc(
    List<SubscriptionEntity> list,
  ) {
    list.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return list;
  }
}
