import 'package:android_media_store/android_media_store.dart';
import 'package:on_audio_query/on_audio_query.dart';
// import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class LocalStorageSource {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final _androidMediaStore = AndroidMediaStore.instance;

  Future<List<SongModel>> scanStorage() async {
    return await _audioQuery.querySongs();
  }

  Future<bool> deleteAudio(AudioEntity audio) async {
    try {
      final res = await _androidMediaStore.deleteMediaFile(audio.uri!);
      return res;
    } catch (e) {
      return false;
    }
  }
}
