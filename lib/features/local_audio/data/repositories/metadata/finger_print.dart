import 'dart:io';
import 'dart:typed_data';

import 'package:audio_decode/audio_decode.dart';
import 'package:audio_decoder/audio_decoder.dart';
import 'package:chromaprint/chromaprint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show BackgroundIsolateBinaryMessenger, RootIsolateToken;
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/features/local_audio/data/model/audio_metadata.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

// AcoustID & Chromaprint standards
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
  final bool usedFastPath;

  _DecodedPcmResult({
    required this.samples,
    required this.sampleRate,
    required this.channels,
    required this.durationSeconds,
    required this.usedFastPath,
  });
}

Future<_DecodedPcmResult> _decodeAndResampleIsolateEntry(
  _DecodeRequest request,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(request.rootIsolateToken);

  final sourceBytes = await File(request.audioPath).readAsBytes();

  PcmAudio pcm;
  var usedFastPath = true;
  try {
    pcm = decodeAudio(sourceBytes);
  } on AudioDecodeException {
    // for unsupported formats by audio_decode (like FLAC, M4A/AAC, WMA, AIFF...)
    usedFastPath = false;
    pcm = await _decodeViaNativePlugin(request.audioPath);
  }

  if (usedFastPath &&
      (pcm.sampleRate != _targetSampleRate ||
          pcm.channels != _targetChannels)) {
    pcm = resample(pcm.toMono(), _targetSampleRate);
  }

  return _DecodedPcmResult(
    samples: pcm.samples,
    sampleRate: pcm.sampleRate,
    channels: pcm.channels,
    durationSeconds: pcm.duration.inSeconds,
    usedFastPath: usedFastPath,
  );
}

Future<PcmAudio> _decodeViaNativePlugin(String sourcePath) async {
  final tempDir = await getTemporaryDirectory();
  final workDir = await tempDir.createTemp('fingerprint_');
  try {
    final wavPath = '${workDir.path}/audio.wav';
    await AudioDecoder.convertToWav(
      sourcePath,
      wavPath,
      sampleRate: _targetSampleRate,
      channels: _targetChannels,
      bitDepth: 16,
    );
    final wavBytes = await File(wavPath).readAsBytes();
    return decodeAudio(wavBytes);
  } finally {
    await workDir.delete(recursive: true);
  }
}
