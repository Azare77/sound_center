import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class LocalAudioRepositoryLinux implements AudioRepository {
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

    final List<File> audioFiles = await _scanAudioFiles(musicDir);
    List<AudioModel> files = [];
    AudioMetadata metadata;
    for (int i = 0; i < audioFiles.length; i++) {
      File file = audioFiles[i];
      try {
        metadata = readMetadata(file, getImage: true);
      } catch (e) {
        e.runtimeType;
        continue;
      }
      AudioModel audioModel = AudioModel(
        id: i,
        path: file.path,
        uri: file.uri.path,
        title: metadata.title ?? file.path.split("/").last,
        duration: metadata.duration?.inMilliseconds ?? 0,
        album: metadata.album ?? "",
        genre: "",
        dateAdded: DateTime.now(),
        trackNum: metadata.trackNumber ?? 0,
        isPodcast: false,
        isAlarm: false,
        artist: metadata.artist ?? "",
        cover: metadata.pictures.firstOrNull?.bytes,
      );

      files.add(audioModel);
    }
    if (like != null) {
      files = files.where((song) {
        final title = song.title.toLowerCase();
        final artist = (song.artist).toLowerCase();
        final album = (song.album).toLowerCase();
        return title.contains(like) ||
            artist.contains(like) ||
            album.contains(like);
      }).toList();
    }
    final sortedFiles = _sort(files, orderBy, desc);
    return sortedFiles;
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
          compare = (a.dateAdded).compareTo(b.dateAdded);
          break;
        case AudioColumns.title:
          compare = (a.title).toLowerCase().compareTo((b.title).toLowerCase());
          break;
        case AudioColumns.artist:
          compare = (a.artist).toLowerCase().compareTo(
            (b.artist).toLowerCase(),
          );
          break;

        case AudioColumns.album:
          compare = (a.album).toLowerCase().compareTo((b.album).toLowerCase());
          break;

        case AudioColumns.duration:
          compare = (a.duration).compareTo(b.duration);
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
