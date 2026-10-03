import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_audio_repository.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/categories.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

enum CoverSize { thumbnail, banner }

class AudioUtil {
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static final Map<String, Uint8List?> _coverCache = {};
  static final repo = LocalAudioRepository();
  static List<AudioEntity> allAudios = [];

  static Future<Uint8List?> getCover(
    int audioId, {
    CoverSize coverSize = CoverSize.thumbnail,
  }) async {
    if (Platform.isLinux) return null;
    final key = '$audioId-${coverSize.name}';
    if (_coverCache.containsKey(key)) return _coverCache[key];
    final Uint8List? cover = await _audioQuery.queryArtwork(
      audioId,
      ArtworkType.AUDIO,
      quality: 100,
      format: ArtworkFormat.JPEG,
      size: coverSize == CoverSize.banner ? 600 : 100,
    );

    _coverCache[key] = cover;
    return cover;
  }

  static Uint8List? getLinuxCover(File file) {
    final metadata = readMetadata(file, getImage: true);
    return metadata.pictures.firstOrNull?.bytes;
  }

  static String convertSeekBarTime(int input) {
    return _covert(input);
  }

  static String convertTime(int input) {
    if (input == 0) return '';
    return _covert(input);
  }

  static String _covert(int input) {
    final duration = Duration(milliseconds: input);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return hours > 0
        ? "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";
  }

  static Future<List<T>> groupSongs<T>({
    required List<AudioEntity> allSongs,
    required String? Function(AudioEntity song) key,
    required T Function(
      String name,
      int duration,
      int totalAudios,
      int totalAlbums,
    )
    builder,
  }) async {
    final grouped = <String, List<AudioEntity>>{};

    for (final song in allSongs) {
      final name = key(song)?.trim();

      if (name == null || name.isEmpty) continue;

      grouped.putIfAbsent(name, () => []).add(song);
    }

    final result = <T>[];
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    for (final entry in entries) {
      final songs = entry.value;

      final duration = songs.fold<int>(
        0,
        (total, song) => total + (song.duration),
      );

      final totalAudios = songs.length;

      final totalAlbums = songs
          .map((song) => song.album.trim())
          .where((album) => album.isNotEmpty)
          .toSet()
          .length;
      result.add(builder(entry.key, duration, totalAudios, totalAlbums));
    }

    return result;
  }

  static List<FolderEntity> groupSongsByFolder({
    required List<AudioEntity> allSongs,
  }) {
    final grouped = <String, List<AudioEntity>>{};

    for (final song in allSongs) {
      final folder = File(song.path).parent.path;
      grouped.putIfAbsent(folder, () => []).add(song);
    }

    final result = grouped.entries.map((entry) {
      final songs = entry.value;

      final totalLength = songs.fold<int>(
        0,
        (total, song) => total + song.duration,
      );

      final name = Directory(entry.key).path.split(Platform.pathSeparator).last;

      return FolderEntity(
        name: name,
        totalAudios: songs.length,
        totalLength: totalLength,
      );
    }).toList();

    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return result;
  }

  static List<AudioEntity> sort(
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

  static Future<bool> isFavorite(int audioId) async {
    return await repo.isFavorite(audioId);
  }
}
