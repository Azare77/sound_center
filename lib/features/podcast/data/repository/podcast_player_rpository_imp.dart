import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class PodcastPlayerRepositoryImp implements PlayerRepository {
  static final PodcastPlayerRepositoryImp _instance =
      PodcastPlayerRepositoryImp._internal();

  factory PodcastPlayerRepositoryImp() {
    return _instance;
  }

  PodcastPlayerRepositoryImp._internal() {
    _playerService.setOnPodcastComplete(() => next());
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

  RepeatMode repeatMode = RepeatMode.repeatAll;
  final _positionController = StreamController<int>.broadcast();
  final _durationController = StreamController<int>.broadcast();

  Stream<int> get positionStream => _positionController.stream;

  Stream<int> get durationStream => _durationController.stream;

  late final PodcastBloc bloc;

  Future<void> init() async {
    try {
      if (PlayerStateStorage.getSource() != AudioSource.online) return;
      _currentEpisode = PlayerStateStorage.getLastEpisode();
      if (_currentEpisode == null) return;
      if (_episodes.isEmpty) _episodes = [_currentEpisode!];
      final String? cacheFile = await _chach(_currentEpisode!.title);
      File? file;
      try {
        file = await NetworkCacheImage.customCacheManager.getSingleFile("");
      } catch (_) {}
      (audioHandler as JustAudioNotificationHandler).setMediaItemFromEpisode(
        _currentEpisode!,
        file?.uri,
      );
      _playerService
          .setSource(
            _currentEpisode!.contentUrl!,
            AudioSource.online,
            cachedFilePath: cacheFile,
          )
          .then((res) {
            if (res) {
              int position = PlayerStateStorage.getLastPosition();
              _playerService.seek(Duration(milliseconds: position));
            } else {
              _currentEpisode = null;
              bloc.add(AutoPlayPodcast());
            }
          });
      index = 0;
      _episodes[index] = _currentEpisode!;
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
      _currentEpisode = null;
    }
  }

  void _initialPlayerState() {
    repeatMode = PlayerStateStorage.getRepeatMode();
    _playerService.position.listen((pos) {
      _positionController.add(pos.inMilliseconds);
    });

    _playerService.duration.listen((dur) {
      if (dur != null) {
        _durationController.add(dur.inMilliseconds);
      }
    });
  }

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource(AudioSource.online);
  }

  bool isShuffle() {
    return false;
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
  Future<void> changeRepeatState() async {
    switch (repeatMode) {
      case RepeatMode.noRepeat:
        repeatMode = RepeatMode.repeatAll;
        break;
      case RepeatMode.repeatAll:
        repeatMode = RepeatMode.repeatOne;
        break;
      case RepeatMode.repeatOne:
        repeatMode = RepeatMode.noRepeat;
        break;
    }
    await PlayerStateStorage.saveRepeatMode(repeatMode);
  }

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int index, {bool direct = false}) async {
    this.index = index;
    _currentEpisode = _episodes[index];
    final String? cacheFile = await _chach(_currentEpisode!.title);
    File? file;
    try {
      file = await NetworkCacheImage.customCacheManager.getSingleFile("");
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromEpisode(
      _episodes[index],
      file?.uri,
    );
    bloc.add(AutoPlayPodcast());
    await _playerService.setSource(
      _episodes[index].contentUrl!,
      AudioSource.online,
      cachedFilePath: cacheFile,
    );
    _playerService.play();
    bloc.add(AutoPlayPodcast());
    PlayerStateStorage.saveLastEpisode(_currentEpisode!);
    PlayerStateStorage.saveSource(AudioSource.online);
  }

  Future<String?> _chach(String filename) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();

    // مسیر نهایی فایل
    final String fullPath = '${baseDir.path}/Podcasts/$filename.mp3';

    // 🔍 چک وجود فایل روی دیسک
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
    bloc.add(TogglePlay());
    await _playerService.togglePlaying();
  }

  @override
  Future<void> stop() async {
    _currentEpisode = null;
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  int getIndex(bool forward) {
    if (repeatMode == RepeatMode.repeatOne) {
      return index;
    }

    index = (index + (forward ? 1 : -1) + _episodes.length) % _episodes.length;
    return index;
  }
}
