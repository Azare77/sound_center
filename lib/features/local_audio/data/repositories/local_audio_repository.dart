import 'package:drift/drift.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/database/drift/local/audio.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/data/sources/storage.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepository implements AudioRepository {
  final LocalStorageSource _localStorageSource = LocalStorageSource();

  @override
  Future<List<AudioModel>> getAudios({
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    List<SongModel> songs = await _localStorageSource.scanStorage();
    songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    final database = AppDatabase();
    await updateDB(songs, database);
    final dbData = await LocalAudiosTable().search(
      orderBy: orderBy,
      desc: desc,
    );
    return dbData.map((item) => AudioModel.fromSongModel(item)).toList();
  }

  Future<void> updateDB(List<SongModel> songs, AppDatabase database) async {
    songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    final currentIds = songs.map((s) => s.id).toSet();
    await (database.delete(
      database.localAudiosTable,
    )..where((tbl) => tbl.audioId.isNotIn(currentIds))).go();

    final existingIds = await database
        .select(database.localAudiosTable)
        .get()
        .then((rows) => rows.map((row) => row.audioId).toSet());
    final newSongs = songs.where((song) => !existingIds.contains(song.id));
    for (final song in newSongs) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(song.dateAdded ?? 0);
      await database
          .into(database.localAudiosTable)
          .insert(
            LocalAudiosTableCompanion.insert(
              title: song.title,
              audioId: Value(song.id),
              path: song.data,
              duration: song.duration ?? 0,
              cover: Value(null),
              artist: Value(song.artist),
              album: Value(song.album),
              genre: Value(song.genre),
              isPodcast: Value(song.isPodcast ?? false),
              createdAt: Value(date),
            ),
          );
    }
  }

  @override
  Future<List<AudioModel>> search({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    final dbData = await LocalAudiosTable().search(
      input: like,
      orderBy: orderBy,
      desc: desc,
    );
    return dbData.map((item) => AudioModel.fromSongModel(item)).toList();
  }
}
