import 'dart:async';

enum AudioRepeatMode { repeatAll, repeatOne, noRepeat }

enum ShuffleMode { shuffle, noShuffle }

mixin NowPlayingNotifier<T> {
  final StreamController<T?> _nowPlayingController =
      StreamController<T?>.broadcast();

  Stream<T?> get nowPlayingChanges => _nowPlayingController.stream;

  void notifyNowPlayingChanged(T? value) {
    if (!_nowPlayingController.isClosed) {
      _nowPlayingController.add(value);
    }
  }

  void disposeNowPlayingNotifier() {
    _nowPlayingController.close();
  }
}

abstract class PlayerRepository {
  void setPlayList(dynamic episodes);

  int getCurrentPosition();

  Future<int> getDuration();

  Future<void> play(int index);

  Future<void> togglePlayState();

  Future<void> resume();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<dynamic> next();

  Future<dynamic> previous();

  Future<void> stop();

  Future<void> changeRepeatState();

  Future<void> changeShuffleState();
}
