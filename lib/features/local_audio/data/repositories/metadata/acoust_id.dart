import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sound_center/features/local_audio/data/model/audio_metadata.dart';
import 'package:sound_center/features/local_audio/data/model/itunes_track.dart';
import 'package:sound_center/features/local_audio/data/repositories/metadata/metadata_parser.dart';
import 'package:sound_center/features/local_audio/data/repositories/metadata/services/acoustid_service.dart';
import 'package:sound_center/features/local_audio/data/repositories/metadata/services/cover_art_service.dart';
import 'package:sound_center/features/local_audio/data/repositories/metadata/services/itunes_service.dart';
import 'package:sound_center/features/local_audio/data/repositories/metadata/services/musicbrainz_service.dart';

class AcoustId {
  final AcoustIdService _acoustIdService;
  final MusicBrainzService _musicBrainzService;
  final CoverArtService _coverArtService;

  AcoustId({
    AcoustIdService? acoustIdService,
    MusicBrainzService? musicBrainzService,
    CoverArtService? coverArtService,
  }) : _acoustIdService = acoustIdService ?? AcoustIdService(),
       _musicBrainzService = musicBrainzService ?? MusicBrainzService(),
       _coverArtService = coverArtService ?? CoverArtService();

  Future<AudioMetadata?> lookupMetadata({
    required String fingerprint,
    required int duration,
    required Function(int) onStepChanged,
  }) async {
    onStepChanged.call(1);
    final (recordingResult, releaseResult) = await (
      _acoustIdService.lookup(
        fingerprint: fingerprint,
        duration: duration,
        meta: 'recordings',
      ),
      _acoustIdService.lookup(
        fingerprint: fingerprint,
        duration: duration,
        meta: 'releasegroups',
      ),
    ).wait;
    // Extract recording and release group
    final recording = MetadataParser.getFirstResult(
      recordingResult,
      'recordings',
    );

    final releaseGroup = MetadataParser.getFirstResult(
      releaseResult,
      'releasegroups',
    );
    if (recording.isEmpty || recording['id'] == null) {
      return null;
    }

    final metadata = AudioMetadata();
    // Basic metadata
    metadata.recordingMbid = recording['id'] as String?;
    metadata.releaseGroupMbid = releaseGroup['id'] as String?;

    metadata.title = recording['title'] as String?;
    metadata.album = releaseGroup['title'] as String?;

    metadata.artists = MetadataParser.extractNames(recording['artists']);

    metadata.acoustid = recordingResult['id'] ?? releaseResult['id'];

    metadata.score = recordingResult['score'] ?? releaseResult['score'];

    onStepChanged.call(2);
    await Future.wait([
      fetchRecordingMetadata(metadata),
      fetchReleaseGroupMetadata(metadata),
    ]);
    onStepChanged.call(3);
    await Future.wait([fetchReleaseMetadata(metadata), loadCoverArt(metadata)]);
    return metadata;
  }

  Future<void> fetchRecordingMetadata(AudioMetadata metadata) async {
    final mbid = metadata.recordingMbid;

    if (mbid == null) {
      return;
    }

    try {
      final data = await _musicBrainzService.fetch('/ws/2/recording/$mbid', {
        'inc': 'work-rels+artist-credits+isrcs+genres+tags+releases',
        'fmt': 'json',
      });

      metadata.genres = MetadataParser.extractNames(data['genres']);

      metadata.tags = MetadataParser.extractNames(data['tags']);

      if (metadata.genres.isNotEmpty) {
        metadata.genre = metadata.genres.join(",");
      }

      await _fetchWorkArtists(data, metadata);
    } catch (e) {
      debugPrint('Recording metadata error: $e');
    }
  }

  Future<void> _fetchWorkArtists(
    Map<String, dynamic> recordingData,
    AudioMetadata metadata,
  ) async {
    final relations = recordingData['relations'] as List? ?? [];

    for (final relation in relations) {
      if (relation is! Map) {
        continue;
      }

      if (relation['target-type'] != 'work') {
        continue;
      }

      final work = relation['work'];

      if (work is! Map) {
        continue;
      }

      final workMbid = work['id'] as String?;

      if (workMbid == null) {
        continue;
      }

      try {
        final workData = await _musicBrainzService.fetch(
          '/ws/2/work/$workMbid',
          {'inc': 'artist-rels', 'fmt': 'json'},
        );

        final workRelations = workData['relations'] as List? ?? [];

        for (final workRelation in workRelations) {
          if (workRelation is! Map) {
            continue;
          }

          final type = workRelation['type'];

          final artist = workRelation['artist'];

          if (artist is! Map) {
            continue;
          }

          final name = artist['name'] as String?;

          if (name == null || name.isEmpty) {
            continue;
          }

          if (type == 'composer') {
            metadata.composers.add(name);
          } else if (type == 'lyricist') {
            metadata.lyricists.add(name);
          }
        }
      } catch (e) {
        debugPrint('Work metadata error: $e');
      }
    }

    metadata.composers = metadata.composers.toSet().toList();
    metadata.lyricists = metadata.lyricists.toSet().toList();
  }

  Future<void> fetchReleaseGroupMetadata(AudioMetadata metadata) async {
    final mbid = metadata.releaseGroupMbid;

    if (mbid == null) {
      return;
    }

    try {
      final data = await _musicBrainzService.fetch(
        '/ws/2/release-group/$mbid',
        {'inc': 'releases+genres+tags', 'fmt': 'json'},
      );

      metadata.albumGenres = MetadataParser.extractNames(data['genres']);

      metadata.albumTags = MetadataParser.extractNames(data['tags']);

      final releases = data['releases'] as List? ?? [];

      final datedReleases = releases
          .whereType<Map>()
          .where(
            (release) =>
                release['date'] is String &&
                (release['date'] as String).isNotEmpty,
          )
          .toList();

      // Prefer official releases, then earliest date.
      datedReleases.sort((a, b) {
        final aOfficial = a['status'] == 'Official';
        final bOfficial = b['status'] == 'Official';

        if (aOfficial != bOfficial) {
          return aOfficial ? -1 : 1;
        }

        return (a['date'] as String).compareTo(b['date'] as String);
      });

      if (datedReleases.isEmpty) {
        return;
      }

      final selectedRelease = datedReleases.first;

      metadata.releaseMbid = selectedRelease['id'] as String?;
      metadata.releaseDate = selectedRelease['date'] as String?;
      metadata.releaseStatus = selectedRelease['status'] as String?;
      metadata.releaseCountry = selectedRelease['country'] as String?;

      final date = metadata.releaseDate;

      if (date != null && date.length >= 4) {
        metadata.releaseYear = date.substring(0, 4);
      }
    } catch (e) {
      debugPrint('Release Group error: $e');
    }
  }

  Future<void> fetchReleaseMetadata(AudioMetadata metadata) async {
    final releaseMbid = metadata.releaseMbid;
    final recordingMbid = metadata.recordingMbid;

    if (releaseMbid == null) {
      return;
    }

    try {
      final data = await _musicBrainzService.fetch(
        '/ws/2/release/$releaseMbid',
        {'inc': 'labels+media+recordings+artist-credits', 'fmt': 'json'},
      );

      // Album artist
      final credits = data['artist-credit'] as List? ?? [];

      metadata.albumArtist = MetadataParser.getArtistCredit(credits);

      // Barcode
      metadata.barcode = data['barcode'] as String?;

      // Label and catalog number
      final labelInfo = data['label-info'] as List? ?? [];

      if (labelInfo.isNotEmpty && labelInfo.first is Map) {
        final firstLabel = labelInfo.first as Map;

        final labelData = firstLabel['label'];

        if (labelData is Map) {
          metadata.label = labelData['name'] as String?;
        }

        metadata.catalogNumber = firstLabel['catalog-number'] as String?;
      }

      // Media and tracks
      final media = data['media'] as List? ?? [];

      metadata.totalTracks = 0;

      for (final medium in media) {
        if (medium is! Map) {
          continue;
        }

        final tracks = medium['tracks'] as List? ?? [];

        metadata.totalTracks = (metadata.totalTracks ?? 0) + tracks.length;

        // First available format
        metadata.format ??= medium['format'] as String?;

        // Find matching track
        for (final track in tracks) {
          if (track is! Map) {
            continue;
          }

          final trackRecording = track['recording'];

          if (trackRecording is! Map) {
            continue;
          }

          if (trackRecording['id'] == recordingMbid) {
            metadata.trackNumber =
                MetadataParser.parseTrackNumber(track['number']) ??
                MetadataParser.parseTrackNumber(track['position']);
          }
        }
      }
    } catch (e) {
      debugPrint('Release details error: $e');
    }
  }

  Future<void> loadCoverArt(AudioMetadata metadata) async {
    try {
      metadata.cover = await _coverArtService.getCover(
        releaseMbid: metadata.releaseMbid,
        releaseGroupMbid: metadata.releaseGroupMbid,
      );

      metadata.cover ??= await _coverArtService.checkItunes(
        metadata.title,
        metadata.artists.firstOrNull,
        metadata.album,
      );

      if (metadata.cover == null) return;

      metadata.coverBytes = await _coverArtService.loadCoverArtBytes(
        metadata.cover!,
      );
    } catch (e) {
      debugPrint('Cover Art error: $e');
    }
  }

  Future<AudioMetadata?> lookupItunesMetadata(
    String? title,
    String? artist,
    String? album,
  ) async {
    ItunesTrack? track = await ItunesService().checkItunes(
      title,
      artist,
      album,
    );
    if (track == null) return null;
    AudioMetadata metadata = AudioMetadata();
    metadata.title = track.trackName;
    metadata.albumArtist = track.artistName;
    metadata.album = track.collectionName;
    metadata.artists = track.albumArtistName?.split(',') ?? [];
    metadata.genre = track.primaryGenreName;
    metadata.releaseYear = track.releaseYear?.toString();
    metadata.coverBytes = await loadItunesCoverArt(
      metadata.title,
      metadata.albumArtist,
      metadata.album,
    );
    return metadata;
  }

  Future<Uint8List?> loadItunesCoverArt(
    String? title,
    String? artist,
    String? album,
  ) async {
    try {
      final url = await _coverArtService.checkItunes(title, artist, album);
      if (url == null) return null;
      return await _coverArtService.loadCoverArtBytes(url);
    } catch (e) {
      debugPrint('Cover Art error: $e');
    }
    return null;
  }

  void dispose() {
    _acoustIdService.dispose();
    _musicBrainzService.dispose();
    _coverArtService.dispose();
  }
}
