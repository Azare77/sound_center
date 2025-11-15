import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:sound_center/core/util/permission/permission_handler.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/data/sources/storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepository implements AudioRepository {
  final LocalStorageSource _localStorageSource = LocalStorageSource();
  List<SongModel> allSongs = [];
  final PermissionHandler handler = PermissionHandler();

  @override
  Future<List<AudioModel>> fetchLocalAudios({
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
      allSongs = _sort(allSongs, orderBy, desc);
      return allSongs.map(AudioModel.fromSongModel).toList();
    } catch (_) {
      return [];
    }
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

  @override
  Future<bool> deleteAudio(AudioEntity audio) async {
    return await _localStorageSource.deleteAudio(audio);
  }
}
