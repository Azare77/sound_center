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
  final DateTime updateTime;
  final bool haveNewEpisode;

  SubscriptionEntity({
    this.podcastId,
    required this.feedUrl,
    required this.subscribedAt,
    required this.lastListenAt,
    required this.title,
    required this.totalEpisodes,
    required this.updateTime,
    required this.haveNewEpisode,
    this.author,
    this.artworkUrl,
  });

  factory SubscriptionEntity.fromDrift(SubscriptionTableData subscription) {
    return SubscriptionEntity(
      podcastId: subscription.podcastId,
      title: subscription.title,
      updateTime: subscription.updateTime,
      author: subscription.author,
      artworkUrl: subscription.artworkUrl,
      feedUrl: subscription.feedUrl,
      totalEpisodes: subscription.totalEpisodes,
      subscribedAt: subscription.subscribedAt,
      lastListenAt: subscription.lastListenAt,
      haveNewEpisode: subscription.haveNewEpisode,
    );
  }

  factory SubscriptionEntity.fromPodcast(
    String feedUrl,
    search.Podcast feedInfo,
  ) {
    List<search.Episode> episodes = feedInfo.episodes;
    DateTime updateTime = DateTime(1970);
    for (search.Episode episode in episodes) {
      if (episode.publicationDate == null) continue;
      if (episode.publicationDate!.isAfter(updateTime)) {
        updateTime = episode.publicationDate!;
      }
    }
    return SubscriptionEntity(
      podcastId: feedInfo.guid,
      title: feedInfo.title ?? "WTF",
      author: feedInfo.persons.firstOrNull?.name,
      artworkUrl: feedInfo.image,
      feedUrl: feedUrl,
      subscribedAt: DateTime.now(),
      lastListenAt: DateTime.now(),
      updateTime: updateTime,
      totalEpisodes: feedInfo.episodes.length,
      haveNewEpisode: false,
    );
  }

  SubscriptionTableCompanion toDrift() {
    return SubscriptionTableCompanion(
      podcastId: Value(podcastId),
      title: Value(title),
      updateTime: Value(updateTime),
      author: Value(author),
      artworkUrl: Value(artworkUrl),
      feedUrl: Value(feedUrl),
      subscribedAt: Value(subscribedAt),
      lastListenAt: Value(lastListenAt),
      totalEpisodes: Value(totalEpisodes),
      haveNewEpisode: Value(false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'podcastId': podcastId,
      'title': title,
      'author': author,
      'artworkUrl': artworkUrl,
      'feedUrl': feedUrl,
      'totalEpisodes': totalEpisodes,
      'subscribedAt': subscribedAt.toIso8601String(),
      'lastListenAt': lastListenAt.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'haveNewEpisode': haveNewEpisode,
    };
  }

  factory SubscriptionEntity.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntity(
      podcastId: json['podcastId'] as String?,
      title: json['title'] as String,
      author: json['author'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      feedUrl: json['feedUrl'] as String,
      totalEpisodes: json['totalEpisodes'] as int,
      subscribedAt: DateTime.parse(json['subscribedAt'] as String),
      lastListenAt: DateTime.parse(json['lastListenAt'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
      haveNewEpisode: json['haveNewEpisode'] as bool,
    );
  }
}
