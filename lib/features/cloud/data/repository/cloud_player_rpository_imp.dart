import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudPlayerRepositoryImp implements PlayerRepository {
  static final CloudPlayerRepositoryImp _instance =
      CloudPlayerRepositoryImp._internal();

  factory CloudPlayerRepositoryImp() {
    return _instance;
  }

  CloudPlayerRepositoryImp._internal() {
    _playerService.setOnCloudComplete(() => next());
    _initialPlayerState();
  }

  bool isLoading() {
    return _playerService.isLoading();
  }

  final JustAudioService _playerService = JustAudioService();
  List<CloudTrack> _tracks = [];

  CloudTrack? _currentTrack;

  CloudTrack? get getCurrentTrack => _currentTrack;

  int index = 0;

  final _positionController = StreamController<int>.broadcast();
  final _durationController = StreamController<int>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _trackChangedController = StreamController<CloudTrack?>.broadcast();

  Stream<CloudTrack?> get trackChangedStream => _trackChangedController.stream;

  Stream<int> get positionStream => _positionController.stream;

  Stream<int> get durationStream => _durationController.stream;

  Stream<bool> get loadingStream => _loadingController.stream;

  late final CloudBloc bloc;

  final sc = SoundcloudClient();

  Future<void> init() async {
    try {
      if (PlayerStateStorage.getSource() != AudioSource.cloud) return;
      _currentTrack = PlayerStateStorage.getLastCloudTrack();
      if (_currentTrack == null) return;
      if (_tracks.isEmpty) _tracks = [_currentTrack!];
      index = 0;
      _tracks[index] = _currentTrack!;
      _playerService.setSourceByForce(AudioSource.cloud);
      _trackChangedController.add(_currentTrack);
      bloc.add(AutoPlay());
      File? file;
      try {
        file = await NetworkCacheImage.customCacheManager.getSingleFile("");
      } catch (_) {}
      (audioHandler as JustAudioNotificationHandler).setMediaItemFromCloud(
        _currentTrack!,
        file?.uri,
      );

      final String? streamUrl = await getTrackUrl(_currentTrack!);
      if (streamUrl == null || !hasSource()) return;
      bool res = await _playerService.setSource(
        streamUrl,
        AudioSource.cloud,
        onSourceSet: () => bloc.add(AutoPlay()),
      );
      if (res) {
        int position = PlayerStateStorage.getLastPosition();
        _playerService.seek(Duration(milliseconds: position));
      }
      bloc.add(AutoPlay());
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
    }
  }

  void _initialPlayerState() {
    _playerService.position.listen((pos) {
      _positionController.add(pos.inMilliseconds);
    });
    _playerService.processState.listen((state) {
      bool loading = isLoading();
      _loadingController.add(loading);
    });
    _playerService.duration.listen((dur) {
      if (dur != null) {
        _durationController.add(dur.inMilliseconds);
      }
    });
  }

  bool isPlaying() {
    return _playerService.isPlaying();
  }

  bool hasSource() {
    return _playerService.hasSource(AudioSource.cloud);
  }

  void setBloc(CloudBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic episodes) {
    assert(episodes is List);
    _tracks.clear();
    for (var track in episodes) {
      _tracks.add(track);
    }
  }

  List<CloudTrack> getPlayList() {
    return _tracks;
  }

  @override
  Future<void> changeRepeatState() async {}

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int index, {bool direct = false}) async {
    this.index = index;
    _currentTrack = _tracks[index];
    _playerService.setSourceByForce(AudioSource.cloud);
    _trackChangedController.add(_currentTrack);
    bloc.add(AutoPlay());
    File? file;
    try {
      file = await NetworkCacheImage.customCacheManager.getSingleFile(
        _currentTrack!.artworkUrl?.toString() ?? '',
      );
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromCloud(
      _tracks[index],
      file?.uri,
    );
    await _playerService.pause();
    final String? trackUrl = await getTrackUrl(_currentTrack!);
    if (trackUrl == null || !hasSource()) return;
    bool allowToPlay = await _playerService.setSource(
      trackUrl,
      AudioSource.cloud,
      onSourceSet: () => bloc.add(AutoPlay()),
    );
    if (!allowToPlay) return;
    await PlayerStateStorage.saveLastCloudTrack(_currentTrack!);
    await PlayerStateStorage.saveSource(AudioSource.cloud);
    await _playerService.play();
    bloc.add(AutoPlay());
    unawaited(_precacheAdjacentTracks(index));
  }

  @override
  Future next() async {
    index = getIndex(true);
    await play(index);
    return _tracks[index];
  }

  @override
  Future previous() async {
    index = getIndex(false);
    await play(index);
    return _tracks[index];
  }

  @override
  int getCurrentPosition() {
    int currentPosition = _playerService.getCurrentPosition();
    return currentPosition;
  }

  @override
  Future<int> getDuration() async {
    int duration = await _playerService.getDuration();
    return duration;
  }

  @override
  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _playerService.setSpeed(speed);
  }

  double getSpeed() {
    return _playerService.getSpeed();
  }

  @override
  Future<void> togglePlayState() async {
    _trackChangedController.add(_currentTrack);
    bloc.add(TogglePlay());
    await _playerService.togglePlaying();
  }

  @override
  Future<void> stop() async {
    _currentTrack = null;
    _trackChangedController.add(null);
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  int getIndex(bool forward) {
    index = (index + (forward ? 1 : -1) + _tracks.length) % _tracks.length;
    return index;
  }

  Future<void> _precacheAdjacentTracks(int index) async {
    final List<Future<void>> tasks = [];
    // آهنگ قبلی
    if (index > 0) {
      tasks.add(getTrackUrl(_tracks[index - 1]).then((_) {}));
    }
    // آهنگ بعدی
    if (index < _tracks.length - 1) {
      tasks.add(getTrackUrl(_tracks[index + 1]).then((_) {}));
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  final Map<int, String> _urlCache = {};
  final Map<int, DateTime> _cachedTime = {};

  static const _kUrlTtl = Duration(minutes: 5);

  Future<String?> getTrackUrl(CloudTrack track) async {
    try {
      final cached = _urlCache[track.id];
      final cachedTime = _cachedTime[track.id];
      if (cached != null &&
          cachedTime != null &&
          DateTime.now().difference(cachedTime) < _kUrlTtl) {
        return cached;
      }

      final streams = await sc.tracks.getStreams(track.id);
      if (streams.isEmpty) {
        debugPrint('No transcodings returned for track ${track.id}');
        return null;
      }

      final streamInfo = streams.firstWhere(
        (s) => s.container.toLowerCase() == 'mp3',
        orElse: () => streams.first,
      );

      _urlCache[track.id] = streamInfo.url;
      _cachedTime[track.id] = DateTime.now();
      return streamInfo.url;
    } catch (e, st) {
      debugPrint('getTrackUrl failed: $e\n$st');
      return null;
    }
  }
}
