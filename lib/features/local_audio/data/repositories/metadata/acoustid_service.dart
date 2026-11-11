import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';

class AcoustIdService {
  final http.Client _clientInstance;

  AcoustIdService({http.Client? client})
    : _clientInstance = client ?? http.Client();

  Future<Map<String, dynamic>> lookup({
    required String fingerprint,
    required int duration,
    required String meta,
  }) async {
    final uri = Uri.https('api.acoustid.org', '/v2/lookup');

    final body = {
      'client': AppSettingStorage.getAcoustIdApikey(),
      'fingerprint': fingerprint,
      'duration': duration.toString(),
      'meta': meta,
    };

    final response = await _clientInstance.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Encoding': 'gzip',
      },
      body: gzip.encode(
        utf8.encode(
          Uri(
            queryParameters: body.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          ).query,
        ),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('AcoustID HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception('AcoustID error: ${data['error'] ?? data}');
    }

    final results = data['results'] as List? ?? [];

    if (results.isEmpty) {
      return {};
    }

    return Map<String, dynamic>.from(results.first);
  }

  void dispose() {
    _clientInstance.close();
  }
}
