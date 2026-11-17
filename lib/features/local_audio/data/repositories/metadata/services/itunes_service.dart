import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sound_center/features/local_audio/data/model/itunes_track.dart';

class ItunesService {
  final http.Client _clientInstance;

  ItunesService({http.Client? client})
    : _clientInstance = client ?? http.Client();

  Future<ItunesTrack?> checkItunes(
    String? title,
    String? artist,
    String? album,
  ) async {
    if ([title, artist, album].every((e) => e == null || e.trim().isEmpty)) {
      return null;
    }

    final term = [
      title,
      artist,
      album,
    ].where((e) => e != null && e.trim().isNotEmpty).join(' ');

    final uri = Uri.https('itunes.apple.com', '/search', {
      'term': term,
      'entity': 'song',
      'limit': '1',
    });

    try {
      final response = await _clientInstance.get(uri);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      if (results.isEmpty) return null;

      return ItunesTrack.fromJson(results.first as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
