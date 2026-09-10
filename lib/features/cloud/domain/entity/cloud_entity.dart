import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudEntity {
  List<CloudTrack> tracks;
  List<CloudPlaylist> playlists;

  CloudEntity({required this.tracks, required this.playlists});
}

class CloudTrack {
  final int id;
  final String title;
  final String? author;
  final String? artworkUrl;
  final int duration;
  final int playCount;
  final DateTime createDate;

  CloudTrack({
    required this.id,
    required this.title,
    required this.duration,
    this.author,
    this.artworkUrl,
    required this.createDate,
    required this.playCount,
  });

  factory CloudTrack.fromTrackSearchResult(TrackSearchResult track) {
    return CloudTrack(
      id: track.id,
      title: track.title,
      author: track.user.fullName,
      duration: track.duration.truncate(),
      artworkUrl: track.artworkUrl?.toString(),
      createDate: track.createdAt,
      playCount: track.playbackCount.truncate(),
    );
  }

  factory CloudTrack.fromJson(Map<String, dynamic> json) {
    return CloudTrack(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      duration: json['duration'] as int,
      playCount: json['playCount'] as int,
      createDate: DateTime.parse(json['createDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'artworkUrl': artworkUrl,
      'duration': duration,
      'playCount': playCount,
      'createDate': createDate.toIso8601String(),
    };
  }
}

class CloudPlaylist {
  final int id;
  final String title;
  final String? author;
  final String? artworkUrl;
  final DateTime createDate;

  CloudPlaylist({
    required this.id,
    required this.title,
    this.author,
    this.artworkUrl,
    required this.createDate,
  });

  factory CloudPlaylist.fromPlaylistSearchResult(
    PlaylistSearchResult playlist,
  ) {
    return CloudPlaylist(
      id: playlist.id,
      title: playlist.title,
      author: playlist.user.fullName,
      artworkUrl: playlist.artworkUrl?.toString(),
      createDate: playlist.createdAt,
    );
  }
}
