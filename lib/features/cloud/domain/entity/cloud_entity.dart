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
  final DateTime createDate;

  CloudTrack({
    required this.id,
    required this.title,
    required this.duration,
    this.author,
    this.artworkUrl,
    required this.createDate,
  });

  factory CloudTrack.fromTrackSearchResult(TrackSearchResult track) {
    return CloudTrack(
      id: track.id,
      title: track.title,
      author: track.user.fullName,
      duration: track.duration.truncate(),
      artworkUrl: track.artworkUrl?.toString(),
      createDate: track.createdAt,
    );
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
