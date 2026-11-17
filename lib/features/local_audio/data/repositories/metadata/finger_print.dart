import 'dart:io';
import 'dart:typed_data';

import 'package:audio_decoder/audio_decoder.dart';
import 'package:chromaprint/chromaprint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show BackgroundIsolateBinaryMessenger, RootIsolateToken;
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/features/local_audio/data/model/audio_metadata.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

const _targetSampleRate = 11025;
const _targetChannels = 1;

class FingerprintService {
  static Future<AudioFingerprintResult> generateFingerprint(
    AudioEntity audio,
  ) async {
    final rootToken = RootIsolateToken.instance;
    if (rootToken == null) {
      throw StateError(
        'RootIsolateToken is not available — this function must be called from the main isolate.',
      );
    }

    final decoded = await compute(
      _decodeAndResampleIsolateEntry,
      _DecodeRequest(audioPath: audio.path, rootIsolateToken: rootToken),
    );

    final cp = Chromaprint();
    try {
      cp.start(decoded.sampleRate, decoded.channels);
      cp.feed(decoded.samples);
      cp.finish();

      final fingerprint = cp.getFingerprint();

      return AudioFingerprintResult(
        fingerprint: fingerprint,
        duration: decoded.durationSeconds,
        chromaprint: cp,
      );
    } catch (_) {
      cp.dispose();
      rethrow;
    }
  }
}

class _DecodeRequest {
  final String audioPath;
  final RootIsolateToken rootIsolateToken;

  _DecodeRequest({required this.audioPath, required this.rootIsolateToken});
}

class _DecodedPcmResult {
  final Int16List samples;
  final int sampleRate;
  final int channels;
  final int durationSeconds;

  _DecodedPcmResult({
    required this.samples,
    required this.sampleRate,
    required this.channels,
    required this.durationSeconds,
  });
}

Future<_DecodedPcmResult> _decodeAndResampleIsolateEntry(
  _DecodeRequest request,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(request.rootIsolateToken);

  final tempDir = await getTemporaryDirectory();
  final workDir = await tempDir.createTemp('fingerprint_');
  try {
    final wavPath = '${workDir.path}/audio.wav';
    await AudioDecoder.convertToWav(
      request.audioPath,
      wavPath,
      sampleRate: _targetSampleRate,
      channels: _targetChannels,
      bitDepth: 16,
    );
    final wavBytes = await File(wavPath).readAsBytes();
    final pcm = _decodeWavBytes(wavBytes);

    return _DecodedPcmResult(
      samples: pcm.samples,
      sampleRate: pcm.sampleRate,
      channels: pcm.channels,
      durationSeconds: pcm.duration.inSeconds,
    );
  } finally {
    await workDir.delete(recursive: true);
  }
}

// تابع ساده برای خواندن PCM از فایل WAV (جایگزین decodeAudio از audio_decode)
PcmAudio _decodeWavBytes(Uint8List wavBytes) {
  // WAV header استاندارد 44 بایت است (برای PCM 16-bit)
  // در صورت نیاز به دقت بیشتر، هدر را پارس کنید
  final dataOffset = _findDataChunkOffset(wavBytes);
  final samples = Int16List.sublistView(
    wavBytes.buffer.asInt16List(),
    dataOffset ~/ 2,
  );

  return PcmAudio(
    samples: samples,
    sampleRate: _targetSampleRate,
    channels: _targetChannels,
  );
}

int _findDataChunkOffset(Uint8List wavBytes) {
  // جستجوی چانک "data" در هدر WAV
  for (var i = 12; i < wavBytes.length - 8; i++) {
    if (wavBytes[i] == 0x64 && // 'd'
        wavBytes[i + 1] == 0x61 && // 'a'
        wavBytes[i + 2] == 0x74 && // 't'
        wavBytes[i + 3] == 0x61) {
      // 'a'
      return i + 8; // داده‌ها بعد از شناسه چانک و اندازه شروع می‌شوند
    }
  }
  return 44; // پیش‌فرض: هدر استاندارد 44 بایتی
}

// کلاس ساده PcmAudio برای جایگزینی audio_decode
class PcmAudio {
  final Int16List samples;
  final int sampleRate;
  final int channels;

  PcmAudio({
    required this.samples,
    required this.sampleRate,
    required this.channels,
  });

  Duration get duration =>
      Duration(seconds: samples.length ~/ (sampleRate * channels));
}
