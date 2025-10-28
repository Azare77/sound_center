import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioSource { local, online }

class JustAudioService {
  static JustAudioService? _instance;

  factory JustAudioService() {
    _instance ??= JustAudioService._internal();
    return _instance!;
  }

  JustAudioService._internal() {
    _init();
  }

  // Callbacks
  void Function()? _onComplete;
  void Function()? _onLoading;
  void Function()? _onReady;

  final AudioPlayer _player = AudioPlayer();
  AudioSource? _source;

  // prevent re-entrant error handling loops
  bool _handlingError = false;

  AudioPlayer getPlayer() => _player;

  void _init() {
    // listen for errors
    _player.playbackEventStream.listen((event) async {
      final playerError = event.errorMessage;
      if (playerError != null) {
        debugPrint(
          'JustAudioService: playback error -> ${event.errorCode} | ${event.errorMessage}',
        );
        await _handlePlaybackError(playerError);
      }
    });

    // forward processing state callbacks
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onComplete?.call();
      } else if (state == ProcessingState.loading) {
        _onLoading?.call();
      } else if (state == ProcessingState.ready) {
        _onReady?.call();
      }
    });
  }

  // Public API to set a single source (will clear any managed playlist unless using setPlaylist)
  Future<void> setSource(String path, AudioSource source) async {
    try {
      _source = source;
      if (source == AudioSource.local) {
        await _player.setFilePath(path);
        _player.setSpeed(1);
      } else {
        await _player.setUrl(path);
      }
    } catch (_) {
      _source == null;
    }
  }

  Future<void> play() async => await _player.play();

  Future<void> togglePlaying() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> release() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);

  void setOnComplete(
    void Function()? onComplete, {
    void Function()? onLoading,
    void Function()? onReady,
  }) {
    _onComplete = onComplete;
    _onLoading = onLoading;
    _onReady = onReady;
    // listeners already configured in _init()
  }

  bool isLoading() {
    return _player.processingState == ProcessingState.loading ||
        _player.processingState == ProcessingState.buffering;
  }

  Future<int> getCurrentPosition() async {
    final Duration currentPosition = _player.position;
    return currentPosition.inMilliseconds;
  }

  Future<int> getDuration() async {
    Duration? duration;
    while (duration == null) {
      duration = _player.duration;
      await Future.delayed(Duration(milliseconds: 10));
    }
    return duration.inMilliseconds;
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  bool hasSource(AudioSource source) {
    if (_source == null || _source != source) return false;
    if (_source == AudioSource.online) return true;
    final duration = _player.duration;
    final processingState = _player.processingState;
    return duration != null || processingState != ProcessingState.idle;
  }

  // ========= error handling & advancing logic =========
  Future<void> _handlePlaybackError(String error) async {
    if (_handlingError) {
      debugPrint('Already handling an error, skipping re-entry');
      return;
    }
    _handlingError = true;
    _onComplete?.call();
    await Future.delayed(const Duration(milliseconds: 200));
    _handlingError = false;
  }
}
