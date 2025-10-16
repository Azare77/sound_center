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
    this.cover,
  });

  final int id;
  final String path;
  final String title;
  final int duration;
  final String album;
  final String artist;
  final String genre;
  final int trackNum;
  final bool isPodcast;
  final bool isAlarm;
  Uint8List? cover;
}
