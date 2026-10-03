import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/data/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepositoryLinux extends AudioRepositoryImp {
  List<AudioEntity> allSongs = [];

  @override
  Future<List<AudioEntity>> fetchLocalAudios({
    String? like,
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) return [];

    final musicDir = Directory('$homeDir/Music');
    if (!await musicDir.exists()) return [];

    final audioFiles = await _scanAudioFiles(musicDir);

    allSongs = [];

    for (int i = 0; i < audioFiles.length; i++) {
      final file = audioFiles[i];

      try {
        final metadata = readMetadata(file, getImage: true);
        final title = metadata.title ?? file.path.split('/').last;
        final artist = metadata.artist ?? '';
        final album = metadata.album ?? '';
        final duration = metadata.duration?.inMilliseconds ?? 0;
        final fileSize = file.lengthSync();
        allSongs.add(
          AudioEntity(
            id: generateStableId(title, artist, album, duration, fileSize),
            path: file.path,
            uri: file.uri.path,
            title: title,
            duration: duration,
            album: album,
            genre: metadata.genres.firstOrNull ?? '',
            dateAdded: metadata.file.lastModifiedSync(),
            trackNum: metadata.trackNumber ?? 0,
            isPodcast: false,
            isAlarm: false,
            artist: artist,
            cover: metadata.pictures.firstOrNull?.bytes,
          ),
        );
        AudioUtil.allAudios = allSongs;
      } catch (_) {
        continue;
      }
    }

    if (like != null && like.trim().isNotEmpty) {
      final query = like.toLowerCase().trim();

      allSongs = allSongs.where((song) {
        final title = song.title.toLowerCase();
        final artist = song.artist.toLowerCase();
        final album = song.album.toLowerCase();

        return title.contains(query) ||
            artist.contains(query) ||
            album.contains(query);
      }).toList();
    }

    allSongs = super.sort(allSongs, orderBy, desc);

    return allSongs;
  }

  int generateStableId(
    String title,
    String artist,
    String album,
    int durationMs,
    int fileSize,
  ) {
    final key = '${title}_${artist}_${album}_${durationMs}_$fileSize';
    final bytes = utf8.encode(key);
    final digest = md5.convert(bytes);
    return digest.bytes.take(4).fold(0, (prev, byte) => (prev << 8) | byte);
  }

  Future<List<File>> _scanAudioFiles(Directory dir) async {
    const audioExtensions = ['.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a'];

    final files = <File>[];

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

  @override
  Future<bool> deleteAudio(AudioEntity audio) async {
    final file = File(audio.path);

    if (await file.exists()) {
      await super.removeAudioFromAllPlaylists(audio.id);
      await file.delete();
      return true;
    }

    return false;
  }
}
