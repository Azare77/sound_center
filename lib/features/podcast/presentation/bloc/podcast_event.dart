part of 'podcast_bloc.dart';

sealed class PodcastEvent {}

class SearchPodcast extends PodcastEvent {
  final String query;

  SearchPodcast(this.query);
}

class GetSubscribedPodcasts extends PodcastEvent {}

class SubscribeToPodcast extends PodcastEvent {
  final SubscriptionEntity podcast;

  SubscribeToPodcast(this.podcast);
}

class UpdateSubscribedPodcast extends PodcastEvent {
  final SubscriptionEntity podcast;

  UpdateSubscribedPodcast(this.podcast);
}

class UnsubscribeFromPodcast extends PodcastEvent {
  final String feedUrl;

  UnsubscribeFromPodcast(this.feedUrl);
}

class PlayPodcast extends PodcastEvent {
  final List<Episode> episodes;
  final int index;

  PlayPodcast({required this.episodes, required this.index});
}

class PlayNextPodcast extends PodcastEvent {}

class PlayPreviousPodcast extends PodcastEvent {}

class AutoPlayPodcast extends PodcastEvent {
  final Episode podcastEntity;

  AutoPlayPodcast(this.podcastEntity);
}

class TogglePlay extends PodcastEvent {}

//Download
class GetDownloadedEpisodes extends PodcastEvent {}

class DownloadEpisode extends PodcastEvent {
  DownloadedEpisodeEntity episode;

  DownloadEpisode(this.episode);
}
