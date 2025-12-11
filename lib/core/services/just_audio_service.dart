import 'dart:async';

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
  void Function()? _onPodcastComplete;
  void Function()? _onLoading;
  void Function()? _onReady;

  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: const Duration(seconds: 30),
        maxBufferDuration: const Duration(seconds: 60),
        bufferForPlaybackDuration: const Duration(seconds: 3),
        bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 5),
        backBufferDuration: const Duration(seconds: 20),
      ),
    ),
  );
  AudioSource? _source;

  // prevent re-entrant error handling loops
  bool _handlingError = false;

  AudioPlayer getPlayer() => _player;

  Stream<Duration> get position => _player.positionStream;

  Stream<Duration?> get duration => _player.durationStream;

  bool _loadingSource = false;

  bool get isLoadingSource => _loadingSource;

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
        if (_source == AudioSource.local) {
          _onComplete?.call();
        } else {
          _onPodcastComplete?.call();
        }
      } else if (state == ProcessingState.loading) {
        _onLoading?.call();
      } else if (state == ProcessingState.ready) {
        _onReady?.call();
      }
    });
  }

  // Public API to set a single source (will clear any managed playlist unless using setPlaylist)
  Future<bool> setSource(
    String path,
    AudioSource source, {
    String? cachedFilePath,
  }) async {
    try {
      if (_loadingSource) return false;
      _loadingSource = true;
      _source = source;
      if (source == AudioSource.local) {
        await _player.setFilePath(path);
      } else {
        if (cachedFilePath != null) {
          await _player.setFilePath(cachedFilePath);
        } else {
          await _player.setUrl(path);
        }
      }
      await _player.setSpeed(1.0);
      _loadingSource = false;
      return true;
    } catch (e) {
      _source = null;
      debugPrint('خطا در setSource: $e');
      _loadingSource = false;
      return false;
    }
  }

  Future<void> play() async => await _player.play();

  bool isPlaying() {
    return _player.playing;
  }

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

  double getSpeed() => _player.speed;

  void setOnComplete(void Function()? onComplete) {
    _onComplete = onComplete;
  }

  void setOnPodcastComplete(void Function()? onPodcastComplete) {
    _onPodcastComplete = onPodcastComplete;
  }

  void setOnLoading(void Function()? onLoading) {
    _onLoading = onLoading;
  }

  void setOnReady(void Function()? onReady) {
    _onReady = onReady;
  }

  bool isLoading() {
    return _player.processingState == ProcessingState.loading ||
        _player.processingState == ProcessingState.buffering;
  }

  int getCurrentPosition() {
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
    return true;
  }

  // ========= error handling & advancing logic =========
  Future<void> _handlePlaybackError(String error) async {
    if (_handlingError) {
      debugPrint('Already handling an error, skipping re-entry');
      return;
    }
    _handlingError = true;
    if (_source == AudioSource.local) {
      _onComplete?.call();
    } else {
      _onPodcastComplete?.call();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _handlingError = false;
  }
}
