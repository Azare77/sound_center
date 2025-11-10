import 'dart:convert';
import 'dart:typed_data';

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
