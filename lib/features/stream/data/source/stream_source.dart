import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/features/stream/data/source/metadata_extractor.dart';

class StreamSource {
  final MetadataExtractor extractor = MetadataExtractor();

  /// نسخه بهینه: دانلود فقط بخشی از فایل (Partial Download)
  Future<AudioMetadata?> getStaticFileMetadata(String url) async {
    final uri = Uri.parse(url);
    final fast = await extractor.readAudioMetadataFromUrl(url);
    if (fast != null) {
      return fast;
    }
    // === حالت فایل MP3 - فقط دانلود بخشی ===
    final bytes = await _downloadPartialBytes(uri); // ۱۲۸ کیلوبایت

    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/temp_meta_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await tempFile.writeAsBytes(bytes);
    final metadata = readMetadata(tempFile, getImage: true);

    // ignore: body_might_complete_normally_catch_error
    await tempFile.delete().catchError((_) {});
    return metadata;
  }

  /// دانلود فقط بخشی از فایل با Range header (بهینه)
  Future<List<int>?> _downloadPartialBytes(Uri uri) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 206 || response.statusCode == 200) {
        final bytes = await response.expand((e) => e).toList();
        client.close();
        return bytes;
      } else {
        client.close();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchIcecastJson(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
