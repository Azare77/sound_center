import 'package:sound_center/core/constants/player_modes.dart';

abstract class PlayerRepository {
  void setPlayList(dynamic audios);

  Future<int> getCurrentPosition();

  Future<int> getDuration();

  Future<void> play(int index);

  Future<void> togglePlayState();

  Future<void> seek(double position);

  Future<int> next();

  Future<int> previous();

  Future<void> stop();

  Future<void> changeRepeatState(RepeatMode mode);

  Future<void> changeShuffleState(ShuffleMode mode);
}
