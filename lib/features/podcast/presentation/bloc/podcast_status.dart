import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';

sealed class PodcastStatus {}

class LoadingPodcasts extends PodcastStatus {}

class SubscribedPodcasts extends PodcastStatus {
  final List<SubscriptionEntity> podcasts;

  SubscribedPodcasts(this.podcasts);
}

class PodcastResultStatus extends PodcastStatus {
  PodcastEntity podcasts;

  PodcastResultStatus({required this.podcasts});
}

class DownloadedEpisodesStatus extends PodcastStatus {
  final List<Episode> episodes;

  DownloadedEpisodesStatus(this.episodes);
}
