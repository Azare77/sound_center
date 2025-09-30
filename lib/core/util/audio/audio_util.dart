import 'dart:io';
import 'dart:typed_data';

import 'package:on_audio_query_forked/on_audio_query.dart';

enum CoverSize { thumbnail, banner }

class AudioUtil {
  // 1. تعریف نمونه singleton
  static final AudioUtil _instance = AudioUtil._internal();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // 2. سازنده خصوصی
  AudioUtil._internal();

  // 3. سازنده factory برای برگردوندن همون instance
  factory AudioUtil() {
    return _instance;
  }

  Future<Uint8List?> getCover(
    int audioId, {
    CoverSize coverSize = CoverSize.thumbnail,
  }) async {
    if (Platform.isLinux) return null;
    Uint8List? cover = await _audioQuery.queryArtwork(
      audioId,
      ArtworkType.AUDIO,
      quality: 100,
      format: ArtworkFormat.JPEG,
      size: coverSize == CoverSize.banner ? 600 : 100,
    );
    return cover;
  }
}
