import 'dart:convert';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';

class AudioEntity {
  AudioEntity({
    required this.id,
    required this.path,
    required this.title,
    required this.duration,
    required this.artist,
    required this.album,
    required this.genre,
    required this.trackNum,
    required this.isPodcast,
    required this.isAlarm,
    required this.dateAdded,
    this.uri,
    this.cover,
  });

  final int id;
  final String? uri;
  final String path;
  final String title;
  final int duration;
  final String album;
  final String artist;
  final String genre;
  final int trackNum;
  final bool isPodcast;
  final bool isAlarm;
  final DateTime dateAdded;
  Uint8List? cover;

  AudioEntity copyWith({
    int? id,
    String? uri,
    String? path,
    String? title,
    int? duration,
    String? album,
    String? artist,
    String? genre,
    int? trackNum,
    bool? isPodcast,
    bool? isAlarm,
    DateTime? dateAdded,
    Uint8List? cover,
  }) {
    return AudioEntity(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      trackNum: trackNum ?? this.trackNum,
      isPodcast: isPodcast ?? this.isPodcast,
      isAlarm: isAlarm ?? this.isAlarm,
      dateAdded: dateAdded ?? this.dateAdded,
      cover: cover ?? this.cover,
    );
  }

  factory AudioEntity.fromSongModel(SongModel song) {
    return AudioEntity(
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
      album: song.album == "<unknown>" || song.album == null ? "" : song.album!,
      genre: song.genre == "<unknown>" || song.genre == null ? "" : song.genre!,
      artist: song.artist == "<unknown>" || song.artist == null
          ? ""
          : song.artist!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uri': uri,
      'path': path,
      'title': title,
      'duration': duration,
      'album': album,
      'artist': artist,
      'genre': genre,
      'trackNum': trackNum,
      'isPodcast': isPodcast,
      'isAlarm': isAlarm,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory AudioEntity.fromJson(Map<String, dynamic> json) {
    return AudioEntity(
      id: json['id'] as int,
      uri: json['uri'] as String?,
      path: json['path'] as String,
      title: json['title'] as String,
      duration: json['duration'] as int,
      album: json['album'] as String,
      artist: json['artist'] as String,
      genre: json['genre'] as String,
      trackNum: json['trackNum'] as int,
      isPodcast: json['isPodcast'] as bool,
      isAlarm: json['isAlarm'] as bool,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      cover: json['cover'] != null
          ? base64Decode(json['cover'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path;

  @override
  int get hashCode => id.hashCode;
}
