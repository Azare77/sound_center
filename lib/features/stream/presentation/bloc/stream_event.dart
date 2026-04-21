part of 'stream_bloc.dart';

sealed class StreamEvent {}

class LoadStream extends StreamEvent {
  final String streamUrl;

  LoadStream(this.streamUrl);
}

class StreamStaticFile extends StreamEvent {
  final String url;

  StreamStaticFile(this.url);

  AudioModel toAudio() {
    return AudioModel(
      id: -1,
      path: url,
      title: '',
      duration: 0,
      album: '',
      genre: '',
      trackNum: 0,
      isPodcast: false,
      isAlarm: false,
      artist: '',
      dateAdded: DateTime.now(),
    );
  }
}

class LoadStaticFileInfo extends StreamEvent {
  final AudioModel audio;

  LoadStaticFileInfo(this.audio);
}

class PlayStream extends StreamEvent {
  final Source stream;

  PlayStream(this.stream);
}

class UpdateStreamInfo extends StreamEvent {
  final IcecastStream stream;
  final Source source;

  UpdateStreamInfo(this.stream, this.source);
}

class TogglePlay extends StreamEvent {}

class AutoPlayStream extends StreamEvent {}
