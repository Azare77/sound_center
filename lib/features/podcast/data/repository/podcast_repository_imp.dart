import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/source/podcast_source.dart';
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
    final subs = await getSubs();
    final podcasts = await compute(_checkSubscriptionsForUpdates, subs);
    PodcastSource.setCache(podcasts);

    final models = <SubscriptionEntity>[];
    final updates = <SubscriptionEntity>[];

    for (final sub in subs) {
      final entity = SubscriptionEntity.fromDrift(sub);
      final podcast = podcasts[sub.feedUrl];
      if (podcast == null) continue;

      final latestTime = _getLastEpisodeDate(podcast.episodes);

      final hasNewEpisodes = podcast.episodes.length != entity.totalEpisodes;
      final needToUpdate = !sub.updateTime.isAtSameMomentAs(latestTime);

      if (hasNewEpisodes || needToUpdate) {
        updates.add(entity);
      }

      models.add(entity);
    }

    if (updates.isNotEmpty) {
      await database.batch((batch) {
        for (final item in updates) {
          batch.update(
            database.subscriptionTable,
            SubscriptionTableCompanion(
              updateTime: drift.Value(item.updateTime),
              haveNewEpisode: const drift.Value(true),
            ),
            where: (t) => t.feedUrl.equals(item.feedUrl),
          );
        }
      });
    }

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
    SearchResult results = await PodcastSource.search(searchText);
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
    var podcast = await PodcastSource.loadPodcastInfo(feedUrl);
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

Future<Map<String, Podcast>> _checkSubscriptionsForUpdates(
  List<SubscriptionTableData> feeds,
) async {
  Map<String, Podcast> podcastCache = {};
  final futures = feeds.map((feed) async {
    try {
      final podcast = await Feed.loadFeed(url: feed.feedUrl);
      podcastCache[feed.feedUrl] = podcast;
    } catch (_) {}
  });
  await Future.wait(futures);
  return podcastCache;
}
