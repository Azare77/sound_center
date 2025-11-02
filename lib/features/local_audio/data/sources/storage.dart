import 'package:media_store_plus/media_store_plus.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class LocalStorageSource {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModel>> scanStorage() async {
    return await _audioQuery.querySongs();
  }

  Future<bool> deleteAudio(AudioEntity audio) async {
    try {
      final res = await MediaStore().deleteFileUsingUri(uriString: audio.uri!);
      return res;
    } catch (e) {
      return false;
    }
  }
}
