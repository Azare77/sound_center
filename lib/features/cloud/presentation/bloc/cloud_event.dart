part of 'cloud_bloc.dart';

sealed class CloudEvent {}

class LoadHistory extends CloudEvent {}

class PlayTrack extends CloudEvent {
  final List<CloudTrack> tracks;
  final int index;

  PlayTrack({required this.tracks, required this.index});
}

class PlayNextTrack extends CloudEvent {}

class PlayPreviousTrack extends CloudEvent {}

class AutoPlay extends CloudEvent {}

class TogglePlay extends CloudEvent {}

class SearchCloud extends CloudEvent {
  final String queryText;
  final SearchFilter filter;

  SearchCloud({required this.queryText, required this.filter});
}

class RemoveFromHistory extends CloudEvent {
  final CloudTrack track;

  RemoveFromHistory({required this.track});
}

class ClearHistory extends CloudEvent {}
