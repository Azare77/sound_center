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
  Future<List<AudioModel>> getAudios() async {
    List<AudioModel> audios = [];
    List<SongModel> songs = await _localStorageSource.scanStorage();
    songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    final database = AppDatabase();
    await updateDB(songs, database);
    List<LocalAudiosTableData> dbData = await (database.select(
      database.localAudiosTable,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();
    for (final item in dbData) {
      audios.add(AudioModel.fromSongModel(item));
    }
    return audios;
  }

  Future<void> updateDB(List<SongModel> songs, AppDatabase database) async {
    songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    final currentPaths = songs.map((s) => s.data).toSet();
    await (database.delete(
      database.localAudiosTable,
    )..where((tbl) => tbl.path.isNotIn(currentPaths))).go();

    final existingPaths = await database
        .select(database.localAudiosTable)
        .get()
        .then((rows) => rows.map((row) => row.path).toSet());

    final newSongs = songs.where((song) => !existingPaths.contains(song.data));
    final OnAudioQuery audioQuery = OnAudioQuery();
    for (final song in newSongs) {
      final art = await audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        quality: 100,
        format: ArtworkFormat.JPEG,
        size: 600,
      );
      DateTime date = DateTime.fromMillisecondsSinceEpoch(song.dateAdded ?? 0);
      await database
          .into(database.localAudiosTable)
          .insert(
            LocalAudiosTableCompanion.insert(
              title: song.title,
              path: song.data,
              duration: song.duration ?? 0,
              cover: Value(art),
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
  Future<List<AudioModel>> search({String? like}) async {
    final dbData = await LocalAudiosTable().search(input: like);
    return dbData.map((item) => AudioModel.fromSongModel(item)).toList();
  }
}
