part of 'podcast_bloc.dart';

class PodcastState {
  PodcastStatus status;

  PodcastState(this.status);

  PodcastState copyWith(PodcastStatus status) {
    return PodcastState(status);
  }
}
