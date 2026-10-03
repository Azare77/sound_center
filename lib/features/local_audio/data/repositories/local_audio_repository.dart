import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/core/util/permission/permission_handler.dart';
import 'package:sound_center/features/local_audio/data/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/data/sources/storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepository extends AudioRepositoryImp {
  final LocalStorageSource _localStorageSource = LocalStorageSource();
  List<SongModel> allSongs = [];
  final PermissionHandler handler = PermissionHandler();

  @override
  Future<List<AudioEntity>> fetchLocalAudios({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    try {
      await handler.requestPermission(PermissionType.audio);
      await handler.requestPermission(PermissionType.notification);
      await handler.requestPermission(PermissionType.storage);
      bool isStorageGranted = await handler.checkPermission(
        PermissionType.storage,
      );
      bool isAudioGranted = await handler.checkPermission(PermissionType.audio);
      if (!(isStorageGranted || isAudioGranted)) return [];
      allSongs = await _localStorageSource.scanStorage();
      allSongs = allSongs.where((song) => !(song.isAlarm ?? false)).toList();
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

      List<AudioEntity> allAudios = allSongs
          .map(AudioEntity.fromSongModel)
          .toList();
      allAudios = super.sort(allAudios, orderBy, desc);
      AudioUtil.allAudios = allAudios;
      return allAudios;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> deleteAudio(AudioEntity audio) async {
    final res = await _localStorageSource.deleteAudio(audio);
    if (!res) return false;
    return await super.removeAudioFromAllPlaylists(audio.id);
  }
}
