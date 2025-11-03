import 'dart:io';

import 'package:flutter/services.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

enum CoverSize { thumbnail, banner }

class AudioUtil {
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static final Map<String, Uint8List?> _coverCache = {};

  static Future<Uint8List?> getCover(
    int audioId, {
    CoverSize coverSize = CoverSize.thumbnail,
  }) async {
    if (Platform.isLinux) return null;
    final key = '$audioId-${coverSize.name}';
    if (_coverCache.containsKey(key)) return _coverCache[key];
    final Uint8List? cover = await _audioQuery.queryArtwork(
      audioId,
      ArtworkType.AUDIO,
      quality: 100,
      format: ArtworkFormat.PNG,
      size: coverSize == CoverSize.banner ? 600 : 100,
    );

    _coverCache[key] = cover;
    return cover;
  }

  static String convertTime(int input) {
    final duration = Duration(milliseconds: input);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return hours > 0
        ? "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";
  }
}
