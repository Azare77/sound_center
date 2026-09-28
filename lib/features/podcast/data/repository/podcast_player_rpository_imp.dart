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
import 'package:sound_center/shared/Repository/base_player_repository.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class PodcastPlayerRepositoryImp extends BasePlayerRepository
    with NowPlayingNotifier<Episode?> {
  static final PodcastPlayerRepositoryImp _instance =
      PodcastPlayerRepositoryImp._internal();

  factory PodcastPlayerRepositoryImp() {
    return _instance;
  }

  PodcastPlayerRepositoryImp._internal() {
    super.playerService.setOnPodcastComplete(() => next());
    super.playerService.setOnPodcastError(() => restart());
    _initialPlayerState();
  }

  List<Episode> episodes = [];

  Episode? _currentEpisode;

  Episode? get getCurrentEpisode => _currentEpisode;

  int index = 0;

  String feedUrl = "";

  final _episodeChangedController = StreamController<Episode?>.broadcast();

  Stream<Episode?> get episodeChangedStream => _episodeChangedController.stream;

  late final PodcastBloc bloc;

  Future<void> init() async {
    try {
      if (PlayerStateStorage.getSource() != AudioSource.podcast) return;
      _currentEpisode = PlayerStateStorage.getLastEpisode();
      if (_currentEpisode == null) return;
      if (episodes.isEmpty) episodes = [_currentEpisode!];
      super.playerService.setSourceByForce(AudioSource.podcast);
      _episodeChangedController.add(_currentEpisode);
      // make sure that loading widget will show
      await Future.delayed(Duration(milliseconds: 20));
      loadingController.add(true);

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
      episodes[index] = _currentEpisode!;
      bool res = await super.playerService.setSource(
        _currentEpisode!.contentUrl!,
        AudioSource.podcast,
        cachedFilePath: cacheFile,
      );
      if (res) {
        int position = PlayerStateStorage.getLastPosition();
        super.playerService.seek(Duration(milliseconds: position));
      }
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
    }
  }

  void _initialPlayerState() {
    super.playerService.processState.listen((state) {
      if (!hasSource()) return;
      bool loading = isLoading();
      loadingController.add(loading);
      if (!loading && isPlaying()) _retryCount = 0;
    });
  }

  @override
  bool hasSource() {
    return super.playerService.hasSource(AudioSource.podcast);
  }

  void setBloc(PodcastBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic episodes) {
    assert(episodes is List<Episode>);
    this.episodes.clear();
    for (Episode episode in episodes) {
      this.episodes.add(episode);
    }
  }

  List<Episode> getPlayList() {
    return episodes;
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final episode = episodes.removeAt(oldIndex);
    episodes.insert(newIndex, episode);

    if (_currentEpisode != null) {
      index = episodes.indexWhere(
        (episode) => episode.guid == _currentEpisode!.guid,
      );
    }
  }

  @override
  Future<void> changeRepeatState() async {}

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int index, {bool direct = false}) async {
    _retryCount = 0;
    this.index = index;
    _currentEpisode = episodes[index];
    super.playerService.setSourceByForce(AudioSource.podcast);
    _episodeChangedController.add(_currentEpisode);
    // make sure that loading widget will show
    await Future.delayed(Duration(milliseconds: 20));
    loadingController.add(true);

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
      episodes[index],
      file?.uri,
    );
    bool allowToPlay = await super.playerService.setSource(
      episodes[index].contentUrl!,
      AudioSource.podcast,
      cachedFilePath: cacheFile,
    );
    if (!allowToPlay) return;
    await PlayerStateStorage.saveLastEpisode(_currentEpisode!);
    await PlayerStateStorage.saveSource(AudioSource.podcast);
    await super.playerService.play();
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
    return episodes[index];
  }

  @override
  Future<Episode> previous() async {
    index = getIndex(false);
    await play(index);
    return episodes[index];
  }

  @override
  Future<void> togglePlayState() async {
    _episodeChangedController.add(_currentEpisode);
    bloc.add(TogglePlay());
    await super.playerService.togglePlaying();
  }

  @override
  Future<void> stop() async {
    _retryCount = 0;
    _currentEpisode = null;
    _episodeChangedController.add(null);
    await super.playerService.release();
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
    bool wasPlaying = super.playerService.isPlaying();
    int position = super.playerService.getCurrentPosition();
    await super.playerService.release();
    await Future.delayed(Duration(milliseconds: 500));
    int currentRetry = _retryCount;
    await play(index);
    _retryCount = currentRetry;
    await seek(Duration(milliseconds: position));
    if (!wasPlaying) {
      await super.playerService.togglePlaying();
    }
  }

  int getIndex(bool forward) {
    index = (index + (forward ? 1 : -1) + episodes.length) % episodes.length;
    return index;
  }
}
