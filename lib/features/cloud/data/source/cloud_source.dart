import 'dart:async';

import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudSource {
  final client = SoundcloudClient();
  static final Map<int, List<CloudTrack>> _playlistCache = {};

  Future<List<CloudTrack>> loadPlaylistTracks(int playlistId) async {
    final cached = _playlistCache[playlistId];
    if (cached != null) {
      return cached;
    }

    final tracks = client.playlists.getTracks(playlistId);
    final streamIterator = StreamIterator(tracks);

    final List<TrackSearchResult> trackList = [];

    while (await streamIterator.moveNext()) {
      try {
        for (final result in streamIterator.current) {
          switch (result) {
            case final Track track:
              trackList.add(
                TrackSearchResult(
                  id: track.id,
                  title: track.title,
                  artworkUrl: track.artworkUrl,
                  duration: track.duration,
                  caption: track.caption,
                  commentable: track.commentable,
                  commentCount: track.commentCount,
                  createdAt: track.createdAt,
                  description: track.description,
                  downloadCount: track.downloadCount,
                  fullDuration: track.fullDuration,
                  genre: track.genre,
                  labelName: track.labelName,
                  lastModified: track.lastModified,
                  license: track.license,
                  likesCount: track.likesCount,
                  permalinkUrl: track.permalinkUrl,
                  playbackCount: track.playbackCount,
                  purchaseTitle: track.purchaseTitle,
                  purchaseUrl: track.purchaseUrl,
                  repostsCount: track.repostsCount,
                  tagList: track.tagList,
                  waveformUrl: track.waveformUrl,
                  monetizationModel: track.monetizationModel,
                  policy: track.policy,
                  user: track.user,
                ),
              );
          }
        }
      } catch (_) {
        continue;
      }
    }
    final playableTracks = await _filterPlayableTracks(trackList);
    _playlistCache[playlistId] = playableTracks;
    return playableTracks;
  }

  Future<CloudEntity> search(String queryText, SearchFilter filter) async {
    try {
      final stream = client.search(
        queryText,
        searchFilter: filter,
        offset: 0,
        limit: 100,
      );
      final streamIterator = StreamIterator(stream);
      final List<TrackSearchResult> tracks = [];
      final List<CloudPlaylist> playlists = [];

      while (await streamIterator.moveNext()) {
        try {
          for (final result in streamIterator.current) {
            switch (result) {
              case final UserSearchResult _:
                continue;
              case final TrackSearchResult track:
                tracks.add(track);
              case final PlaylistSearchResult playlist:
                playlists.add(CloudPlaylist.fromPlaylistSearchResult(playlist));
            }
          }
        } catch (_) {
          continue;
        }
      }

      final playableTracks = await _filterPlayableTracks(tracks);
      return CloudEntity(tracks: playableTracks, playlists: playlists);
    } catch (_) {
      return CloudEntity(playlists: [], tracks: []);
    }
  }

  Future<List<CloudTrack>> _filterPlayableTracks(
    List<TrackSearchResult> tracks,
  ) async {
    if (tracks.isEmpty) return [];

    final ids = tracks.map((t) => t.id).toList();
    final metadataCheck = await client.tracks.hasPlayableTranscodingBatch(ids);
    final candidates = tracks
        .where((t) => metadataCheck[t.id] == true)
        .toList();
    return candidates.map(CloudTrack.fromTrackSearchResult).toList();
  }
}
