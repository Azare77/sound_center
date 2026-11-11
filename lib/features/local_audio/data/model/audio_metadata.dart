import 'dart:typed_data';

import 'package:chromaprint/chromaprint.dart';

class AudioFingerprintResult {
  const AudioFingerprintResult({
    required this.fingerprint,
    required this.duration,
    required this.chromaprint,
  });

  final String fingerprint;
  final int duration;
  final Chromaprint chromaprint;
}

class AudioMetadata {
  String? title;
  String? album;
  String? albumArtist;

  List<String> artists = [];

  String? releaseYear;
  String? releaseDate;
  String? releaseCountry;
  String? releaseStatus;

  String? genre;
  List<String> genres = [];
  List<String> tags = [];

  List<String> albumGenres = [];
  List<String> albumTags = [];

  List<String> composers = [];
  List<String> lyricists = [];

  String? label;
  String? catalogNumber;
  String? barcode;
  String? format;

  int? trackNumber;
  int? totalTracks;

  String? cover;
  Uint8List? coverBytes;

  String? recordingMbid;
  String? releaseGroupMbid;
  String? releaseMbid;

  dynamic acoustid;
  dynamic score;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artists.join(', '),
      'artists': artists,
      'album': album,
      'albumArtist': albumArtist,
      'year': releaseYear,
      'releaseDate': releaseDate,
      'releaseCountry': releaseCountry,
      'releaseStatus': releaseStatus,
      'genre': genre,
      'genres': genres,
      'tags': tags,
      'albumGenres': albumGenres,
      'albumTags': albumTags,
      'composer': composers.join(', '),
      'lyricist': lyricists.join(', '),
      'composers': composers,
      'lyricists': lyricists,
      'label': label,
      'catalogNumber': catalogNumber,
      'barcode': barcode,
      'format': format,
      'trackNumber': trackNumber,
      'totalTracks': totalTracks,
      'cover': cover,
      'recordingMbid': recordingMbid,
      'releaseGroupMbid': releaseGroupMbid,
      'releaseMbid': releaseMbid,
      'acoustid': acoustid,
      'score': score,
    };
  }
}
