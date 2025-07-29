part of 'local_bloc.dart';

sealed class LocalEvent {}

class GetLocalAudios extends LocalEvent {}

class PlayAudio extends LocalEvent {
  final int index;

  PlayAudio(this.index);
}

class PlayNextAudio extends LocalEvent {}

class PlayPreviousAudio extends LocalEvent {}

class AutoPlayNext extends LocalEvent {
  final int index;

  AutoPlayNext(this.index);
}

class TogglePlay extends LocalEvent {}

class Search extends LocalEvent {
  final String query;

  Search(this.query);
}
