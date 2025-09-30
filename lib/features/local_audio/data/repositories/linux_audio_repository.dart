import 'dart:io';

import 'package:drift/drift.dart';
// import 'package:metadata_god/metadata_god.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/database/drift/local/audio.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepositoryLinux implements AudioRepository {
  final AppDatabase database = AppDatabase();

  @override
  Future<List<AudioModel>> getAudios({
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) return [];

    final musicDir = Directory('$homeDir/Music');
    if (!await musicDir.exists()) return [];

    final List<File> audioFiles = await _scanAudioFiles(musicDir);
    await updateDB(audioFiles);

    final dbData = await LocalAudiosTable().search(
      orderBy: orderBy,
      desc: desc,
    );
    return dbData.map((item) => AudioModel.fromSongModel(item)).toList();
  }

  Future<List<File>> _scanAudioFiles(Directory dir) async {
    const audioExtensions = ['.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a'];
    final List<File> files = [];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File &&
          audioExtensions.any(
            (ext) => entity.path.toLowerCase().endsWith(ext),
          )) {
        files.add(entity);
      }
    }

    return files;
  }

  Future<void> updateDB(List<File> files) async {
    final currentPaths = files.map((f) => f.path).toSet();

    await (database.delete(
      database.localAudiosTable,
    )..where((tbl) => tbl.path.isNotIn(currentPaths))).go();

    final existingPaths = await database
        .select(database.localAudiosTable)
        .get()
        .then((rows) => rows.map((row) => row.path).toSet());

    final newFiles = files.where((file) => !existingPaths.contains(file.path));

    for (final file in newFiles) {
      final metadata = await _readMetadata(file);
      final stat = await file.stat();

      await database
          .into(database.localAudiosTable)
          .insert(
            LocalAudiosTableCompanion.insert(
              audioId: Value(0),
              title: metadata.title ?? file.uri.pathSegments.last,
              path: file.path,
              duration: metadata.duration ?? 0,
              cover: Value(metadata.cover),
              artist: Value(metadata.artist),
              album: Value(metadata.album),
              genre: Value(metadata.genre),
              isPodcast: Value(false),
              createdAt: Value(stat.modified),
            ),
          );
    }
  }

  Future<MetadataResult> _readMetadata(File file) async {
    try {
      FileStat fileStat = await file.stat();
      String? title = "فایل";
      String? artist = "آرتیست";
      String? album = "آلبوم";
      String? genre = "ژانر";
      int? duration = 8585;
      Uint8List? cover;

      return MetadataResult(
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        duration: duration,
        cover: cover,
      );
    } catch (e) {
      return MetadataResult();
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

class MetadataResult {
  final String? title;
  final String? artist;
  final String? album;
  final String? genre;
  final int? duration;
  final Uint8List? cover;

  MetadataResult({
    this.title,
    this.artist,
    this.album,
    this.genre,
    this.duration,
    this.cover,
  });
}
