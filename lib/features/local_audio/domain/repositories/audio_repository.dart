import 'package:sound_center/features/local_audio/data/model/audio.dart';

abstract class AudioRepository {
  Future<List<AudioModel>> getAudios();

  Future<List<AudioModel>> search({String? like});
}
