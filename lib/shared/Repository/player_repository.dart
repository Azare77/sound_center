import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

enum RepeatMode { repeatAll, repeatOne, noRepeat }

enum ShuffleMode { shuffle, noShuffle }

abstract class PlayerRepository {
  void setPlayList(dynamic audios);

  Future<int> getCurrentPosition();

  Future<int> getDuration();

  Future<void> play(int index);

  Future<void> togglePlayState();

  Future<void> seek(double position);

  Future<AudioEntity> next();

  Future<AudioEntity> previous();

  Future<void> stop();

  Future<void> changeRepeatState();

  Future<void> changeShuffleState();
}
