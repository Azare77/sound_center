import 'dart:async';

import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudSource {
  final client = SoundcloudClient();

  Future<CloudEntity> search(String queryText, SearchFilter filter) async {
    final stream = client.search(
      queryText,
      searchFilter: filter,
      offset: 0,
      limit: 50,
    );
    final streamIterator = StreamIterator(stream);
    final tracks = [];
    final playlists = [];
    while (await streamIterator.moveNext()) {
      try {
        for (final result in streamIterator.current) {
          // Use pattern matching for mixed streams
          switch (result) {
            case final UserSearchResult _:
              continue;

            case final TrackSearchResult track:
              tracks.add(track);

            case final PlaylistSearchResult playlist:
              playlists.add(playlist);
          }
        }
      } catch (_) {
        continue;
      }
    }
    return CloudEntity(tracks: tracks, playlists: playlists);
  }
}
