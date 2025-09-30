import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioModel extends AudioEntity {
  AudioModel({
    required super.id,
    required super.audioId,
    required super.path,
    required super.title,
    required super.duration,
    required super.album,
    required super.genre,
    required super.trackNum,
    required super.isPodcast,
    required super.isAlarm,
    required super.artist,
    super.cover,
  });

  factory AudioModel.fromSongModel(LocalAudiosTableData song) {
    return AudioModel(
      id: song.id,
      audioId: song.audioId,
      path: song.path,
      title: song.title,
      duration: song.duration,
      trackNum: song.trackNum ?? 0,
      isPodcast: song.isPodcast,
      isAlarm: song.isAlarm,
      cover: song.cover,
      album: song.album == "<unknown>" || song.album == null
          ? "Who Knows"
          : song.album!,
      genre: song.genre == "<unknown>" || song.genre == null
          ? "Who Knows"
          : song.genre!,
      artist: song.artist == "<unknown>" || song.artist == null
          ? "Who Knows"
          : song.artist!,
    );
  }
}
