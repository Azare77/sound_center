import 'package:on_audio_query_forked/on_audio_query.dart';

class LocalStorageSource {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModel>> scanStorage() async {
    return await _audioQuery.querySongs();
  }
}
