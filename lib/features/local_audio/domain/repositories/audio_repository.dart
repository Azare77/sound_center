import 'package:sound_center/features/local_audio/data/model/audio.dart';

enum AudioColumns { audioId, createdAt, title, artist, album, duration }

abstract class AudioRepository {
  Future<List<AudioModel>> getAudios({
    required AudioColumns orderBy,
    required bool desc,
  });

  Future<List<AudioModel>> search({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  });
}
