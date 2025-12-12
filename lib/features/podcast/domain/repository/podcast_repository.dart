// ignore_for_file: constant_identifier_names

import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';

enum PodcastOrder { AZ, ZA, NEWEST, OLDEST }

abstract class PodcastRepository {
  Future<List<SubscriptionEntity>> getHome();

  Future<List<SubscriptionEntity>> haveUpdate();

  Future<bool> subscribe(SubscriptionEntity podcast);

  Future<bool> updateSubscribedPodcast(SubscriptionEntity podcast);

  Future<bool> unsubscribe(String feedUrl);

  Future<List<Episode>> getDownloadedEpisodes();

  Future<bool> downloadEpisode(DownloadedEpisodeEntity episode);

  Future<bool> deleteEpisode(String guid);

  Future<PodcastEntity> find(String searchText);

  Future<Podcast> loadPodcastInfo(String feedUrl);
}
