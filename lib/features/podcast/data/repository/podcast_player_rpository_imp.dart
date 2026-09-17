import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class PodcastPlayerRepositoryImp
    with NowPlayingNotifier<Episode?>
    implements PlayerRepository {
  static final PodcastPlayerRepositoryImp _instance =
      PodcastPlayerRepositoryImp._internal();

  factory PodcastPlayerRepositoryImp() {
    return _instance;
  }

  PodcastPlayerRepositoryImp._internal() {
    _playerService.setOnPodcastComplete(() => next());
    _playerService.setOnPodcastError(() => restart());
    _initialPlayerState();
  }

  bool isLoading() {
    return _playerService.isLoading();
  }

  final JustAudioService _playerService = JustAudioService();
  List<Episode> _episodes = [];

  Episode? _currentEpisode;

  Episode? get getCurrentEpisode => _currentEpisode;

  int index = 0;

  String feedUrl = "";

  final _positionController = StreamController<int>.broadcast();
  final _durationController = StreamController<int>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _episodeChangedController = StreamController<Episode?>.broadcast();

  Stream<Episode?> get episodeChangedStream => _episodeChangedController.stream;

  Stream<int> get positionStream => _positionController.stream;

  Stream<int> get durationStream => _durationController.stream;

  Stream<bool> get loadingStream => _loadingController.stream;

  late final PodcastBloc bloc;

  Future<void> init() async {
    try {
      if (PlayerStateStorage.getSource() != AudioSource.podcast) return;
      _currentEpisode = PlayerStateStorage.getLastEpisode();
      if (_currentEpisode == null) return;
      if (_episodes.isEmpty) _episodes = [_currentEpisode!];
      _playerService.setSourceByForce(AudioSource.podcast);
      _episodeChangedController.add(_currentEpisode);
      // make sure that loading widget will show
      await Future.delayed(Duration(milliseconds: 10));
      _loadingController.add(true);

      String key = _currentEpisode!.title.trim();
      if (_currentEpisode!.author != null) {
        key += "-${_currentEpisode!.author?.trim()}";
      }
      final String? cacheFile = await _chach(key);
      File? file;
      try {
        file = await NetworkCacheImage.getFile(_currentEpisode!.imageUrl);
      } catch (_) {}
      (audioHandler as JustAudioNotificationHandler).setMediaItemFromEpisode(
        _currentEpisode!,
        file?.uri,
      );
      index = 0;
      _episodes[index] = _currentEpisode!;
      bool res = await _playerService.setSource(
        _currentEpisode!.contentUrl!,
        AudioSource.podcast,
        cachedFilePath: cacheFile,
        onSourceSet: () => bloc.add(AutoPlayPodcast()),
      );
      if (res) {
        int position = PlayerStateStorage.getLastPosition();
        _playerService.seek(Duration(milliseconds: position));
      }
      bloc.add(AutoPlayPodcast());
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
    }
  }

  void _initialPlayerState() {
    _playerService.position.listen((pos) {
      _positionController.add(pos.inMilliseconds);
    });
    _playerService.processState.listen((state) {
      if (!hasSource()) return;
      bool loading = isLoading();
      _loadingController.add(loading);
      if (!loading && isPlaying()) _retryCount = 0;
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
    return _playerService.hasSource(AudioSource.podcast);
  }

  void setBloc(PodcastBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic episodes) {
    assert(episodes is List<Episode>);
    _episodes.clear();
    for (Episode episode in episodes) {
      _episodes.add(episode);
    }
  }

  List<Episode> getPlayList() {
    return _episodes;
  }

  @override
  Future<void> changeRepeatState() async {}

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int index, {bool direct = false}) async {
    _retryCount = 0;
    this.index = index;
    _currentEpisode = _episodes[index];
    _playerService.setSourceByForce(AudioSource.podcast);
    _episodeChangedController.add(_currentEpisode);
    // make sure that loading widget will show
    await Future.delayed(Duration(milliseconds: 10));
    _loadingController.add(true);

    String key = _currentEpisode!.title.trim();
    if (_currentEpisode!.author != null) {
      key += "-${_currentEpisode!.author?.trim()}";
    }
    final String? cacheFile = await _chach(key);
    File? file;
    try {
      file = await NetworkCacheImage.getFile(_currentEpisode!.imageUrl);
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromEpisode(
      _episodes[index],
      file?.uri,
    );
    bool allowToPlay = await _playerService.setSource(
      _episodes[index].contentUrl!,
      AudioSource.podcast,
      cachedFilePath: cacheFile,
      onSourceSet: () => bloc.add(AutoPlayPodcast()),
    );
    if (!allowToPlay) return;
    await PlayerStateStorage.saveLastEpisode(_currentEpisode!);
    await PlayerStateStorage.saveSource(AudioSource.podcast);
    await _playerService.play();
    bloc.add(AutoPlayPodcast());
  }

  Future<String?> _chach(String filename) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final String fullPath = '${baseDir.path}/Podcasts/$filename.mp3';
    final bool exists = await File(fullPath).exists();
    if (exists) {
      return fullPath;
    }
    return null;
  }

  @override
  Future<Episode> next() async {
    index = getIndex(true);
    await play(index);
    return _episodes[index];
  }

  @override
  Future<Episode> previous() async {
    index = getIndex(false);
    await play(index);
    return _episodes[index];
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
    _episodeChangedController.add(_currentEpisode);
    bloc.add(TogglePlay());
    await _playerService.togglePlaying();
  }

  @override
  Future<void> pause() async {
    if (_playerService.isPlaying()) await togglePlayState();
  }

  @override
  Future<void> resume() async {
    if (!_playerService.isPlaying()) await togglePlayState();
  }

  @override
  Future<void> stop() async {
    _retryCount = 0;
    _currentEpisode = null;
    _episodeChangedController.add(null);
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  int _retryCount = 0;

  Future<void> restart() async {
    _retryCount++;
    if (_retryCount > 3) {
      _retryCount = 0;
      await stop();
      return;
    }
    bool wasPlaying = _playerService.isPlaying();
    int position = _playerService.getCurrentPosition();
    await _playerService.release();
    await Future.delayed(Duration(milliseconds: 500));
    int currentRetry = _retryCount;
    await play(index);
    _retryCount = currentRetry;
    await seek(Duration(milliseconds: position));
    if (!wasPlaying) {
      await _playerService.togglePlaying();
    }
  }

  int getIndex(bool forward) {
    index = (index + (forward ? 1 : -1) + _episodes.length) % _episodes.length;
    return index;
  }
}
