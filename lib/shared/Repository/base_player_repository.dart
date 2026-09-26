import 'dart:async';

import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

abstract class BasePlayerRepository extends PlayerRepository {
  BasePlayerRepository() {
    _initialize();
  }

  final JustAudioService _playerService = JustAudioService();
  static bool _initialized = false;

  void _initialize() {
    if (_initialized) return;
    _initialized = true;
    _playerService.position.listen((pos) {
      positionController.add(pos.inMilliseconds);
    });
    _playerService.duration.listen((dur) {
      if (dur != null) {
        durationController.add(dur.inMilliseconds);
      }
    });
    _playerService.playingStream.listen((playing) {
      playingController.add(playing);
    });
  }

  JustAudioService get playerService => _playerService;

  final positionController = StreamController<int>.broadcast();
  final durationController = StreamController<int>.broadcast();
  final loadingController = StreamController<bool>.broadcast();
  final playingController = StreamController<bool>.broadcast();

  Stream<bool> get playingStream => playingController.stream;

  Stream<int> get positionStream => positionController.stream;

  Stream<int> get durationStream => durationController.stream;

  Stream<bool> get loadingStream => loadingController.stream;

  bool isPlaying() {
    return _playerService.isPlaying();
  }

  @override
  Future<void> pause() async {
    if (_playerService.isPlaying()) await togglePlayState();
  }

  @override
  Future<void> resume() async {
    if (_playerService.isPlaying()) await togglePlayState();
  }

  bool isLoading() {
    return _playerService.isLoading();
  }

  @override
  int getCurrentPosition() {
    int currentPosition = _playerService.getCurrentPosition();
    return currentPosition;
  }

  @override
  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }

  @override
  Future<int> getDuration() async {
    int duration = await _playerService.getDuration();
    return duration;
  }

  @override
  double getSpeed() {
    return _playerService.getSpeed();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await playerService.setSpeed(speed);
  }
}
