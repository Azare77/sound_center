import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/generated/l10n.dart';

enum AudioColumns { id, createdAt, title, artist, album, duration }

enum Category {
  allSongs,
  favorites,
  playlists,
  artists,
  albums,
  genres,
  folders,
}

extension CategoryL10n on Category {
  String title(BuildContext context) {
    final s = S.of(context);
    return switch (this) {
      Category.allSongs => s.categoryAllSongs,
      Category.favorites => s.categoryFavorites,
      Category.playlists => s.categoryPlaylists,
      Category.artists => s.categoryArtists,
      Category.albums => s.categoryAlbums,
      Category.genres => s.categoryGenres,
      Category.folders => s.categoryFolders,
    };
  }
}

abstract class AudioRepository {
  Future<List<AudioEntity>> fetchLocalAudios({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  });

  Future<bool> deleteAudio(AudioEntity filepath);

  Future<List<AudioEntity>> getFavoriteAudios();

  Future<bool> faveAudio(int audioId);

  Future<bool> unfaveAudio(int audioId);

  Future<List<PlayListEntity>> getPlaylists();

  Future<bool> createPlaylist(PlayListEntity playlist);

  Future<bool> deletePlaylist(int id);

  Future<bool> addToPlaylist({required int playlistId, required int audioId});

  Future<bool> removeFromPlaylist({
    required int playlistId,
    required int itemId,
  });
}
