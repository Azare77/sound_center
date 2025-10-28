import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/data/sources/storage.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepository implements AudioRepository {
  final LocalStorageSource _localStorageSource = LocalStorageSource();
  List<SongModel> allSongs = [];

  @override
  Future<List<AudioModel>> fetchLocalAudios({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    allSongs = await _localStorageSource.scanStorage();
    if (like != null && like.trim().isNotEmpty) {
      final query = like.toLowerCase().trim();
      allSongs = allSongs.where((song) {
        final title = song.title.toLowerCase();
        final artist = (song.artist ?? '').toLowerCase();
        final album = (song.album ?? '').toLowerCase();

        return title.contains(query) ||
            artist.contains(query) ||
            album.contains(query);
      }).toList();
    }
    allSongs = _sort(allSongs, orderBy, desc);
    return allSongs.map(AudioModel.fromSongModel).toList();
  }

  List<SongModel> _sort(List<SongModel> audios, AudioColumns order, bool desc) {
    audios.sort((a, b) {
      int compare = 0;
      switch (order) {
        case AudioColumns.id:
          compare = a.id.compareTo(b.id);
          break;
        case AudioColumns.createdAt:
          compare = (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
          break;
        case AudioColumns.title:
          compare = (a.title).toLowerCase().compareTo((b.title).toLowerCase());
          break;
        case AudioColumns.artist:
          compare = (a.artist ?? '').toLowerCase().compareTo(
            (b.artist ?? '').toLowerCase(),
          );
          break;

        case AudioColumns.album:
          compare = (a.album ?? '').toLowerCase().compareTo(
            (b.album ?? '').toLowerCase(),
          );
          break;

        case AudioColumns.duration:
          compare = (a.duration ?? 0).compareTo(b.duration ?? 0);
          break;
      }

      return desc ? -compare : compare;
    });

    return audios;
  }
}
