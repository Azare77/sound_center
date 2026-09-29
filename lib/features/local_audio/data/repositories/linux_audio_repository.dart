import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepositoryLinux implements AudioRepository {
  List<AudioModel> allSongs = [];

  @override
  Future<List<AudioModel>> fetchLocalAudios({
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

        allSongs.add(
          AudioModel(
            id: i,
            path: file.path,
            uri: file.uri.path,
            title: metadata.title ?? file.path.split('/').last,
            duration: metadata.duration?.inMilliseconds ?? 0,
            album: metadata.album ?? '',
            genre: metadata.genres.firstOrNull ?? '',
            dateAdded: DateTime.now(),
            trackNum: metadata.trackNumber ?? 0,
            isPodcast: false,
            isAlarm: false,
            artist: metadata.artist ?? '',
            cover: metadata.pictures.firstOrNull?.bytes,
          ),
        );
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

    allSongs = _sort(allSongs, orderBy, desc);

    return allSongs;
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

  List<AudioModel> _sort(
    List<AudioModel> audios,
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

  @override
  Future<bool> deleteAudio(AudioEntity audio) async {
    final file = File(audio.path);

    if (await file.exists()) {
      await file.delete();
      return true;
    }

    return false;
  }
}
