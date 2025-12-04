import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalOrderStorage {
  static AudioColumns getSavedColumn() {
    final String? name = Storage.instance.prefs.getString('order');
    return AudioColumns.values.firstWhere(
      (e) => e.name == name,
      orElse: () => QUERY_DEFAULT_COLUMN_ORDER,
    );
  }

  static bool getSavedDesc() {
    final bool? desc = Storage.instance.prefs.getBool('desc');
    return desc ?? DEFAULT_DESC;
  }
}
