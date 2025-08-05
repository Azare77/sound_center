import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class PlayerStateStorage {
  static ShuffleMode getShuffleMode() {
    final String? shuffleMode = Storage.instance.prefs.getString('shuffle');
    return ShuffleMode.values.firstWhere(
      (e) => e.name == shuffleMode,
      orElse: () => ShuffleMode.noShuffle,
    );
  }

  static RepeatMode getRepeatMode() {
    final String? repeatMode = Storage.instance.prefs.getString('repeat');
    return RepeatMode.values.firstWhere(
      (e) => e.name == repeatMode,
      orElse: () => RepeatMode.repeatAll,
    );
  }

  static Future<void> saveShuffleMode(ShuffleMode mode) async {
    await Storage.instance.prefs.setString("shuffle", mode.name);
  }

  static Future<void> saveRepeatMode(RepeatMode mode) async {
    await Storage.instance.prefs.setString("repeat", mode.name);
  }
}
