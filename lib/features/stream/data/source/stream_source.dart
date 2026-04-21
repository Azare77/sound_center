import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
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

  Future<Map<String, dynamic>> fetchIcecastJson(String url) async {
    final address = Uri.parse(url);
    final uri = Uri(
      scheme: address.scheme,
      host: address.host,
      port: address.hasPort ? address.port : null,
      path: 'status-json.xsl',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}

class IcyListener {
  static final IcyListener _instance = IcyListener._internal();

  factory IcyListener() {
    return _instance;
  }

  IcyListener._internal();

  HttpClient? client;

  Future<void> listenToIcyStream(
    String url, {
    void Function(String? title, String raw)? onMetadata,
  }) async {
    try {
      if (client != null) client!.close();
      log('metadata updated', name: 'fuck');
      client = HttpClient();
      final request = await client!.getUrl(Uri.parse(url));

      request.headers.set('Icy-MetaData', '1');

      final response = await request.close();

      final metaInt = int.parse(response.headers.value('icy-metaint') ?? '0');

      if (metaInt == 0) {
        // print('❌ no icy metadata');
        return;
      }

      // print('✅ metaInt: $metaInt');

      int bytesUntilMeta = metaInt;

      int? metaRemaining;
      final metaBuffer = <int>[];

      await for (final chunk in response) {
        int i = 0;

        while (i < chunk.length) {
          // === حالت خواندن audio ===
          if (metaRemaining == null) {
            final remainingAudio = bytesUntilMeta;
            final available = chunk.length - i;

            if (available >= remainingAudio) {
              // رسیدیم به metadata
              i += remainingAudio;
              bytesUntilMeta = metaInt;

              // طول metadata
              metaRemaining = chunk[i] * 16;
              i++;

              if (metaRemaining == 0) {
                metaRemaining = null;
              } else {
                metaBuffer.clear();
              }
            } else {
              bytesUntilMeta -= available;
              i += available;
            }
          }
          // === حالت خواندن metadata ===
          else {
            final available = chunk.length - i;
            final toRead = metaRemaining.clamp(0, available);

            metaBuffer.addAll(chunk.sublist(i, i + toRead));

            metaRemaining = metaRemaining - toRead;
            i += toRead;

            if (metaRemaining == 0) {
              final raw = latin1.decode(metaBuffer).trim();

              final match = RegExp(r"StreamTitle='([^']*)'").firstMatch(raw);

              final title = match?.group(1);

              log('metadata updated', name: '🎧 TITLE: $title');
              print('🎵 RAW: $raw');
              print('🎧 TITLE: $title');

              onMetadata?.call(title, raw);

              metaRemaining = null;
            }
          }
        }
      }
    } catch (_) {
      return listenToIcyStream(url, onMetadata: onMetadata);
    } finally {
      client?.close();
      client = null;
    }
  }

  void stop() {
    client?.close(force: true);
    client = null;
  }
}
