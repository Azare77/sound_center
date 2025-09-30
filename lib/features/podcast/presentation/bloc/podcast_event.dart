part of 'podcast_bloc.dart';

sealed class PodcastEvent {}

class SearchPodcast extends PodcastEvent {
  final String query;

  SearchPodcast(this.query);
}

class GetLocalAudios extends PodcastEvent {}

class PlayAudio extends PodcastEvent {
  final int index;

  PlayAudio(this.index);
}

class PlayNextAudio extends PodcastEvent {}

class PlayPreviousAudio extends PodcastEvent {}

class AutoPlayNext extends PodcastEvent {
  final Episode audioEntity;

  AutoPlayNext(this.audioEntity);
}

class TogglePlay extends PodcastEvent {}
