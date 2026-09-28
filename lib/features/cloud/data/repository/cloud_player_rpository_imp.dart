import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/base_player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudPlayerRepositoryImp extends BasePlayerRepository {
  static final CloudPlayerRepositoryImp _instance =
      CloudPlayerRepositoryImp._internal();

  factory CloudPlayerRepositoryImp() {
    return _instance;
  }

  CloudPlayerRepositoryImp._internal() {
    super.playerService.setOnCloudComplete(() => next());
    _initialPlayerState();
  }

  List<CloudTrack> tracks = [];

  CloudTrack? _currentTrack;

  CloudTrack? get getCurrentTrack => _currentTrack;

  int index = 0;

  final _trackChangedController = StreamController<CloudTrack?>.broadcast();

  Stream<CloudTrack?> get trackChangedStream => _trackChangedController.stream;

  late final CloudBloc bloc;

  final sc = SoundcloudClient();

  Future<void> init() async {
    try {
      if (PlayerStateStorage.getSource() != AudioSource.cloud) return;
      _currentTrack = PlayerStateStorage.getLastCloudTrack();
      if (_currentTrack == null) return;
      if (tracks.isEmpty) tracks = [_currentTrack!];
      index = 0;
      tracks[index] = _currentTrack!;
      super.playerService.setSourceByForce(AudioSource.cloud);
      _trackChangedController.add(_currentTrack);
      // make sure that loading widget will show
      await Future.delayed(Duration(milliseconds: 20));
      loadingController.add(true);
      File? file;
      try {
        file = await NetworkCacheImage.getFile(
          _currentTrack!.artworkUrl?.toString(),
        );
      } catch (_) {}
      (audioHandler as JustAudioNotificationHandler).setMediaItemFromCloud(
        _currentTrack!,
        file?.uri,
      );

      final String? streamUrl = await getTrackUrl(_currentTrack!);
      if (streamUrl == null || !hasSource()) {
        await stop();
        _trackChangedController.add(null);
        return;
      }
      bool res = await super.playerService.setSource(
        streamUrl,
        AudioSource.cloud,
      );
      if (res) {
        int position = PlayerStateStorage.getLastPosition();
        super.playerService.seek(Duration(milliseconds: position));
      }
      bloc.add(AddToHistory(track: _currentTrack!));
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
    }
  }

  void _initialPlayerState() {
    super.playerService.processState.listen((state) {
      if (!hasSource()) return;
      bool loading = isLoading();
      loadingController.add(loading);
    });
  }

  void setBloc(CloudBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic episodes) {
    assert(episodes is List);
    tracks.clear();
    for (var track in episodes) {
      tracks.add(track);
    }
  }

  List<CloudTrack> getPlayList() {
    return tracks;
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, track);

    if (_currentTrack != null) {
      index = tracks.indexWhere((track) => track.id == _currentTrack!.id);
    }
  }

  @override
  Future<void> changeRepeatState() async {}

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int index, {bool direct = false}) async {
    this.index = index;
    _currentTrack = tracks[index];
    super.playerService.setSourceByForce(AudioSource.cloud);
    _trackChangedController.add(_currentTrack);
    bloc.add(AddToHistory(track: _currentTrack!));
    // make sure that loading widget will show
    await Future.delayed(Duration(milliseconds: 20));
    loadingController.add(true);
    File? file;
    try {
      file = await NetworkCacheImage.getFile(
        _currentTrack!.artworkUrl?.toString(),
      );
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromCloud(
      tracks[index],
      file?.uri,
    );
    await super.playerService.pause();
    final String? trackUrl = await getTrackUrl(_currentTrack!);
    if (trackUrl == null || !hasSource()) {
      await stop();
      super.playerService.setSourceByForce(null);
      _trackChangedController.add(null);
      return;
    }
    bool allowToPlay = await super.playerService.setSource(
      trackUrl,
      AudioSource.cloud,
    );
    if (!allowToPlay) return;
    await PlayerStateStorage.saveLastCloudTrack(_currentTrack!);
    await PlayerStateStorage.saveSource(AudioSource.cloud);
    await super.playerService.play();
    unawaited(_precacheAdjacentTracks(index));
  }

  @override
  Future next() async {
    index = getIndex(true);
    await play(index);
    return tracks[index];
  }

  @override
  Future previous() async {
    index = getIndex(false);
    await play(index);
    return tracks[index];
  }

  @override
  Future<void> togglePlayState() async {
    _trackChangedController.add(_currentTrack);
    bloc.add(TogglePlay());
    await super.playerService.togglePlaying();
  }

  @override
  Future<void> stop() async {
    _currentTrack = null;
    _trackChangedController.add(null);
    await super.playerService.release();
    bloc.add(TogglePlay());
  }

  int getIndex(bool forward) {
    index = (index + (forward ? 1 : -1) + tracks.length) % tracks.length;
    return index;
  }

  Future<void> _precacheAdjacentTracks(int index) async {
    final List<Future<void>> tasks = [];
    // آهنگ قبلی
    if (index > 0) {
      tasks.add(getTrackUrl(tracks[index - 1]).then((_) {}));
    }
    // آهنگ بعدی
    if (index < tracks.length - 1) {
      tasks.add(getTrackUrl(tracks[index + 1]).then((_) {}));
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

      final streams = await sc.tracks
          .getStreams(track.id)
          .timeout(const Duration(seconds: 20));
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

  @override
  bool hasSource() {
    return super.playerService.hasSource(AudioSource.cloud);
  }
}
