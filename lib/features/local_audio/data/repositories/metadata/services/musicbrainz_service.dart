import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sound_center/core/constants/constants.dart';

class MusicBrainzService {
  static const String _baseUrl = 'musicbrainz.org';

  static const Duration _requestInterval = Duration(milliseconds: 1100);

  static DateTime? _lastRequestAt;

  static Future<void> _queue = Future<void>.value();

  final http.Client _client;

  MusicBrainzService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetch(
    String path,
    Map<String, String> query,
  ) async {
    final completer = Completer<Map<String, dynamic>>();

    final previous = _queue;

    final next = Completer<void>();

    _queue = next.future;

    try {
      await previous;

      final lastRequest = _lastRequestAt;

      if (lastRequest != null) {
        final elapsed = DateTime.now().difference(lastRequest);

        final remaining = _requestInterval - elapsed;

        if (remaining > Duration.zero) {
          await Future.delayed(remaining);
        }
      }

      _lastRequestAt = DateTime.now();

      final uri = Uri.https(_baseUrl, path, query);

      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'SoundCenter/$VERSION_NAME (contact: $REPO_ADDRESS)',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('MusicBrainz HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid MusicBrainz response');
      }

      completer.complete(data);
    } catch (e, stackTrace) {
      completer.completeError(e, stackTrace);
    } finally {
      next.complete();
    }

    return completer.future;
  }

  void dispose() {
    _client.close();
  }
}
