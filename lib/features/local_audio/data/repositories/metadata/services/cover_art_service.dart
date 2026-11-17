import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

class CoverArtService {
  final http.Client _client;

  CoverArtService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getCover({
    String? releaseMbid,
    String? releaseGroupMbid,
  }) async {
    if (releaseMbid != null) {
      final cover = await _checkCover('/release/$releaseMbid/front-500');

      if (cover != null) {
        return cover;
      }
    }

    if (releaseGroupMbid != null) {
      final cover = await _checkCover(
        '/release-group/$releaseGroupMbid/front-500',
      );

      if (cover != null) {
        return cover;
      }
    }

    return null;
  }

  Future<Uint8List?> loadCoverArtBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      return null;
    } catch (e) {
      debugPrint('Cover Art error: $e');
      return null;
    }
  }

  Future<String?> _checkCover(String path) async {
    final uri = Uri.https('coverartarchive.org', path);

    try {
      final response = await _client.head(uri);

      if (response.statusCode == 200) {
        return uri.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<String?> checkItunes(
    String? title,
    String? artist,
    String? album,
  ) async {
    if ((artist == null || artist.trim().isEmpty) &&
        (title == null || title.trim().isEmpty) &&
        (album == null || album.trim().isEmpty)) {
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
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      if (results.isEmpty) return null;

      final artworkUrl = results.first['artworkUrl100'] as String?;
      if (artworkUrl == null) return null;

      return artworkUrl.replaceAll('100x100bb', '600x600bb');
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
