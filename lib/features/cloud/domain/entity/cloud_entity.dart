import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudEntity {
  List<TrackSearchResult> tracks;
  List<PlaylistSearchResult> playlists;

  CloudEntity({required this.tracks, required this.playlists});
}
