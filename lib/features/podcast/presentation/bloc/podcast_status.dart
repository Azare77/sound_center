import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';

sealed class PodcastStatus {}

class LoadingPodcasts extends PodcastStatus {}

class PodcastResultStatus extends PodcastStatus {
  PodcastEntity podcasts;

  PodcastResultStatus({required this.podcasts});
}
