import 'package:drift/drift.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:sound_center/database/drift/database.dart';

class SubscriptionEntity {
  final String? podcastId;
  final String title;
  final String? author;
  final String? artworkUrl;
  final String feedUrl;
  final int totalEpisodes;
  final DateTime subscribedAt;
  final DateTime lastListenAt;
  bool haveNewEpisode;

  SubscriptionEntity({
    this.podcastId,
    required this.feedUrl,
    required this.subscribedAt,
    required this.lastListenAt,
    required this.title,
    required this.totalEpisodes,
    this.haveNewEpisode = false,
    this.author,
    this.artworkUrl,
  });

  factory SubscriptionEntity.fromDrift(SubscriptionTableData subscription) {
    return SubscriptionEntity(
      podcastId: subscription.podcastId,
      title: subscription.title,
      author: subscription.author,
      artworkUrl: subscription.artworkUrl,
      feedUrl: subscription.feedUrl,
      totalEpisodes: subscription.totalEpisodes,
      subscribedAt: subscription.subscribedAt,
      lastListenAt: subscription.lastListenAt,
    );
  }

  factory SubscriptionEntity.fromPodcast(
    String feedUrl,
    search.Podcast feedInfo,
  ) {
    return SubscriptionEntity(
      podcastId: feedInfo.guid,
      title: feedInfo.title ?? "WTF",
      author: feedInfo.persons.firstOrNull?.name,
      artworkUrl: feedInfo.image,
      feedUrl: feedUrl,
      subscribedAt: DateTime.now(),
      lastListenAt: DateTime.now(),
      totalEpisodes: feedInfo.episodes.length,
    );
  }

  SubscriptionTableCompanion toDrift() {
    return SubscriptionTableCompanion(
      podcastId: Value(podcastId),
      title: Value(title),
      author: Value(author),
      artworkUrl: Value(artworkUrl),
      feedUrl: Value(feedUrl),
      subscribedAt: Value(subscribedAt),
      lastListenAt: Value(lastListenAt),
      totalEpisodes: Value(totalEpisodes),
    );
  }
}
