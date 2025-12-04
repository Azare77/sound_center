part of 'podcast_bloc.dart';

sealed class PodcastEvent {}

class ShowLoading extends PodcastEvent {}

class SearchPodcast extends PodcastEvent {
  final String query;

  SearchPodcast(this.query);
}

class GetSubscribedPodcasts extends PodcastEvent {}

class CheckPodcastUpdates extends PodcastEvent {
  final Completer<void>? refreshCompleter;

  CheckPodcastUpdates(this.refreshCompleter);
}

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

class AutoPlayPodcast extends PodcastEvent {}

class TogglePlay extends PodcastEvent {}

//Download
class GetDownloadedEpisodes extends PodcastEvent {}

class DownloadEpisode extends PodcastEvent {
  DownloadedEpisodeEntity episode;

  DownloadEpisode(this.episode);
}
