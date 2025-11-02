import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioModel extends AudioEntity {
  AudioModel({
    required super.id,
    required super.path,
    required super.title,
    required super.duration,
    required super.album,
    required super.genre,
    required super.trackNum,
    required super.isPodcast,
    required super.isAlarm,
    required super.artist,
    required super.dateAdded,
    super.uri,
    super.cover,
  });

  factory AudioModel.fromSongModel(SongModel song) {
    return AudioModel(
      id: song.id,
      uri: song.uri,
      path: song.data,
      title: song.title,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(
        (song.dateAdded ?? 0) * 1000,
      ),
      duration: song.duration ?? 0,
      trackNum: song.track ?? 0,
      isPodcast: song.isPodcast ?? false,
      isAlarm: song.isAlarm ?? false,
      cover: null,
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
