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
    if (subs.isEmpty) return [];
    final models = await compute(_checkSubscriptionsForUpdatesIsolate, subs);
    final toUpdate = models.where((m) => m.needsDatabaseUpdate).toList();
    if (toUpdate.isNotEmpty) {
      await database.batch((batch) {
        for (final item in toUpdate) {
          batch.update(
            database.subscriptionTable,
            SubscriptionTableCompanion(
              updateTime: drift.Value(item.updateTime),
            ),
            where: (t) => t.feedUrl.equals(item.feedUrl),
          );
        }
      });
    }
    return models;
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
  Future<Podcast> loadPodcastInfo(String feedUrl, {bool force = false}) async {
    var podcast = await PodcastSource.loadPodcastInfo(feedUrl, force);
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
}

Future<List<SubscriptionEntity>> _checkSubscriptionsForUpdatesIsolate(
  List<SubscriptionTableData> subscriptions,
) async {
  final futures = subscriptions.map((s) async {
    final item = SubscriptionEntity.fromDrift(s);
    try {
      final Podcast podcast = await PodcastSource.loadPodcastInfo(
        item.feedUrl,
        true,
      );

      final DateTime latestEpisodeTime = podcast.episodes.fold<DateTime>(
        DateTime(1970),
        (prev, ep) =>
            ep.publicationDate != null && ep.publicationDate!.isAfter(prev)
            ? ep.publicationDate!
            : prev,
      );

      final bool hasNewEpisodes = podcast.episodes.length != item.totalEpisodes;
      final bool needsDatabaseUpdate = !s.updateTime.isAtSameMomentAs(
        latestEpisodeTime,
      );

      item
        ..haveNewEpisode = hasNewEpisodes
        ..updateTime = latestEpisodeTime
        ..needsDatabaseUpdate = needsDatabaseUpdate;
    } catch (e) {
      item.haveNewEpisode = false;
      item.needsDatabaseUpdate = false;
    }
    return item;
  }).toList();
  final results = await Future.wait(futures);
  results.sort((a, b) => b.updateTime.compareTo(a.updateTime));
  return results;
}
