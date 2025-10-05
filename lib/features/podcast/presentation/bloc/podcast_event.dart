part of 'podcast_bloc.dart';

sealed class PodcastEvent {}

class SearchPodcast extends PodcastEvent {
  final String query;

  SearchPodcast(this.query);
}

class GetLocalPodcast extends PodcastEvent {}

class PlayPodcast extends PodcastEvent {
  final Episode episode;

  PlayPodcast(this.episode);
}

class PlayNextPodcast extends PodcastEvent {}

class PlayPreviousPodcast extends PodcastEvent {}

class AutoPlayNext extends PodcastEvent {
  final Episode podcastEntity;

  AutoPlayNext(this.podcastEntity);
}

class TogglePlay extends PodcastEvent {}
