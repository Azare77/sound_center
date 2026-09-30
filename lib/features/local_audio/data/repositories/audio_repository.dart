import 'package:drift/drift.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

abstract class AudioRepositoryImp implements AudioRepository {
  final AppDatabase database = AppDatabase();

  Future<List<FavoriteTableData>> getFavorites() async {
    final subs =
        await (database.select(database.favoriteTable)..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return subs;
  }

  Future<bool> isFavorite(int audioId) async {
    final existing = await (database.select(
      database.favoriteTable,
    )..where((tbl) => tbl.audioId.equals(audioId))).getSingleOrNull();
    if (existing != null) {
      return true;
    }
    return false;
  }

  @override
  Future<List<AudioEntity>> getFavoriteAudios() async {
    final subs = await getFavorites();

    final createdAtMap = {for (final sub in subs) sub.audioId: sub.createdAt};

    final res = AudioUtil.allAudios
        .where((audio) => createdAtMap.containsKey(audio.id))
        .map((audio) => audio.copyWith(dateAdded: createdAtMap[audio.id]!))
        .toList();
    final order = LocalOrderStorage.getSavedColumn();
    final desc = LocalOrderStorage.getSavedDesc();
    return sort(res, order, desc);
  }

  @override
  Future<bool> faveAudio(int audioId) async {
    if (await isFavorite(audioId)) return true;
    await database
        .into(database.favoriteTable)
        .insert(FavoriteTableCompanion(audioId: Value(audioId)));
    return true;
  }

  @override
  Future<bool> unfaveAudio(int audioId) async {
    if (!await isFavorite(audioId)) return false;
    await (database.delete(
      database.favoriteTable,
    )..where((tbl) => tbl.audioId.equals(audioId))).go();
    return true;
  }

  Future<List<PlaylistTableData>> _getPlaylists() async {
    final subs =
        await (database.select(database.playlistTable)..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return subs;
  }

  @override
  Future<List<PlayListEntity>> getPlaylists() async {
    final List<PlayListEntity> result = [];
    final subs = await _getPlaylists();
    for (PlaylistTableData item in subs) {
      final items = await _getPlayListItems(item.id);
      final audios = AudioUtil.allAudios
          .where((audio) => items.any((item) => item.audioId == audio.id))
          .toList();
      result.add(PlayListEntity.fromDrift(item, audios));
    }
    return result;
  }

  @override
  Future<bool> createPlaylist(PlayListEntity playlist) async {
    await database.into(database.playlistTable).insert(playlist.toDrift());
    return true;
  }

  @override
  Future<bool> deletePlaylist(int playlistId) async {
    return database.transaction(() async {
      await (database.delete(
        database.playlistItemTable,
      )..where((t) => t.playlistId.equals(playlistId))).go();

      final deleted = await (database.delete(
        database.playlistTable,
      )..where((t) => t.id.equals(playlistId))).go();

      return deleted > 0;
    });
  }

  Future<List<PlaylistItemTableData>> _getPlayListItems(int playlistId) async {
    return await (database.select(database.playlistItemTable)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.order, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<bool> isAudioInPlaylist({
    required int playlistId,
    required int audioId,
  }) async {
    final item =
        await (database.select(database.playlistItemTable)..where(
              (t) =>
                  t.playlistId.equals(playlistId) & t.audioId.equals(audioId),
            ))
            .getSingleOrNull();

    return item != null;
  }

  @override
  Future<bool> addToPlaylist({
    required int playlistId,
    required int audioId,
  }) async {
    if (await isAudioInPlaylist(audioId: audioId, playlistId: playlistId)) {
      return true;
    }

    final items = await (database.select(
      database.playlistItemTable,
    )..where((t) => t.playlistId.equals(playlistId))).get();

    await database
        .into(database.playlistItemTable)
        .insert(
          PlaylistItemTableCompanion(
            playlistId: Value(playlistId),
            audioId: Value(audioId),
            order: Value(items.length),
          ),
        );

    return true;
  }

  Future<bool> changePlaylistItemOrder({
    required int playlistId,
    required int itemId,
    required int newOrder,
  }) async {
    final items =
        await (database.select(database.playlistItemTable)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();

    final oldIndex = items.indexWhere((item) => item.id == itemId);

    if (oldIndex == -1) return false;

    final targetIndex = newOrder.clamp(0, items.length - 1);

    if (oldIndex == targetIndex) return true;

    final reordered = [...items];
    final item = reordered.removeAt(oldIndex);
    reordered.insert(targetIndex, item);

    await database.transaction(() async {
      for (var i = 0; i < reordered.length; i++) {
        await (database.update(database.playlistItemTable)
              ..where((t) => t.id.equals(reordered[i].id)))
            .write(PlaylistItemTableCompanion(order: Value(i)));
      }
    });

    return true;
  }

  @override
  Future<bool> removeFromPlaylist({
    required int playlistId,
    required int itemId,
  }) async {
    return database.transaction(() async {
      final item =
          await (database.select(database.playlistItemTable)..where(
                (t) => t.id.equals(itemId) & t.playlistId.equals(playlistId),
              ))
              .getSingleOrNull();

      if (item == null) {
        return false;
      }

      final deleted =
          await (database.delete(database.playlistItemTable)..where(
                (t) => t.id.equals(itemId) & t.playlistId.equals(playlistId),
              ))
              .go();

      if (deleted == 0) {
        return false;
      }

      return true;
    });
  }

  Future<bool> removeAudioFromAllPlaylists({required int audioId}) async {
    return database.transaction(() async {
      final items = await (database.select(
        database.playlistItemTable,
      )..where((t) => t.audioId.equals(audioId))).get();

      if (items.isEmpty) {
        return false;
      }

      final deleted = await (database.delete(
        database.playlistItemTable,
      )..where((t) => t.audioId.equals(audioId))).go();

      if (deleted == 0) {
        return false;
      }

      return true;
    });
  }

  List<AudioEntity> sort(
    List<AudioEntity> audios,
    AudioColumns order,
    bool desc,
  ) {
    audios.sort((a, b) {
      int compare = 0;

      switch (order) {
        case AudioColumns.id:
          compare = a.id.compareTo(b.id);
          break;
        case AudioColumns.createdAt:
          compare = a.dateAdded.compareTo(b.dateAdded);
          break;
        case AudioColumns.title:
          compare = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case AudioColumns.artist:
          compare = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          break;
        case AudioColumns.album:
          compare = a.album.toLowerCase().compareTo(b.album.toLowerCase());
          break;
        case AudioColumns.duration:
          compare = a.duration.compareTo(b.duration);
          break;
      }

      return desc ? -compare : compare;
    });

    return audios;
  }
}
