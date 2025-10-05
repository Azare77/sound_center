

enum RepeatMode { repeatAll, repeatOne, noRepeat }

enum ShuffleMode { shuffle, noShuffle }

abstract class PlayerRepository {
  void setPlayList(dynamic episodes);

  Future<int> getCurrentPosition();

  Future<int> getDuration();

  Future<void> play(int index);

  Future<void> togglePlayState();

  Future<void> seek(Duration position);

  Future<dynamic> next();

  Future<dynamic> previous();

  Future<void> stop();

  Future<void> changeRepeatState();

  Future<void> changeShuffleState();
}
