import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

enum AudioColumns { id, createdAt, title, artist, album, duration }

abstract class AudioRepository {
  Future<List<AudioModel>> fetchLocalAudios({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  });

  Future<bool> deleteAudio(AudioEntity filepath);
}
