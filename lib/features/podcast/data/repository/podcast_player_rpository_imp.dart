import 'package:flutter/cupertino.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class PodcastPlayerRepositoryImp implements PlayerRepository {
  static final PodcastPlayerRepositoryImp _instance =
      PodcastPlayerRepositoryImp._internal();

  factory PodcastPlayerRepositoryImp() {
    return _instance;
  }

  PodcastPlayerRepositoryImp._internal() {
    _playerService.setOnComplete(() => next());
    _initialPlayerState();
  }

  final JustAudioService _playerService = JustAudioService();
  List<AudioEntity> audios = [];

  AudioEntity? _currentAudio;

  AudioEntity? get getCurrentAudio => _currentAudio;
  List<int> _shuffle = [];
  int index = 0;
  int shuffleIndex = 0;
  bool _initialized = false;
  RepeatMode repeatMode = RepeatMode.repeatAll;
  ShuffleMode shuffleMode = ShuffleMode.noShuffle;
  late final PodcastBloc bloc;

  void _initialPlayerState() {
    repeatMode = PlayerStateStorage.getRepeatMode();
    shuffleMode = PlayerStateStorage.getShuffleMode();
  }

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource();
  }

  bool isShuffle() {
    return shuffleMode == ShuffleMode.shuffle;
  }

  void setBloc(PodcastBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic audios) {
    assert(audios is List<AudioEntity>);
    this.audios.clear();
    for (AudioEntity audioEntity in audios) {
      this.audios.add(audioEntity);
    }
    _preloadCoversInBackground();
  }

  List<AudioEntity> getPlayList() {
    if (shuffleMode == ShuffleMode.noShuffle) return audios;
    return _shuffle.map((i) => audios[i]).toList();
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
  Future<void> changeShuffleState() async {
    if (shuffleMode == ShuffleMode.shuffle) {
      shuffleMode = ShuffleMode.noShuffle;
      _shuffle = [];
    } else {
      _shuffleAudios();
    }
    await PlayerStateStorage.saveShuffleMode(shuffleMode);
  }

  void _shuffleAudios() {
    shuffleMode = ShuffleMode.shuffle;
    shuffleIndex = 0;
    _shuffle = List.generate(audios.length, (i) => i)..shuffle();
    _shuffle.insert(0, index);
  }

  @override
  Future<void> play(int index, {bool direct = false}) async {
    this.index = index;
    if (direct && shuffleMode == ShuffleMode.shuffle) {
      _shuffleAudios();
    }
    if (!_initialized && audios[index].cover == null) {
      _loadChunk(index);
    }
    await _playerService.setSource(audios[index].path, AudioSource.local);
    _playerService.play();
    // bloc.add(AutoPlayNext(audios[index]));
    (audioHandler as JustAudioNotificationHandler).setMediaItemFrom(
      audios[index],
    );
    _currentAudio = audios[index];
  }

  @override
  Future<AudioEntity> next() async {
    index = getIndex(true);
    await play(index);
    // bloc.add(AutoPlayNext(audios[index]));
    return audios[index];
  }

  @override
  Future<AudioEntity> previous() async {
    index = getIndex(false);
    await play(index);
    // bloc.add(AutoPlayNext(audios[index]));
    return audios[index];
  }

  @override
  Future<int> getCurrentPosition() async {
    int currentPosition = await _playerService.getCurrentPosition();
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

  @override
  Future<void> togglePlayState() async {
    bloc.add(TogglePlay());
    await _playerService.togglePlaying();
  }

  @override
  Future<void> stop() async {
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  int getIndex(bool forward) {
    bool isShuffle = shuffleMode == ShuffleMode.shuffle;
    if (repeatMode == RepeatMode.repeatOne) {
      if (isShuffle) {
        return _shuffle[shuffleIndex];
      } else {
        return index;
      }
    }
    if (isShuffle) {
      shuffleIndex =
          (shuffleIndex + (forward ? 1 : -1) + _shuffle.length) %
          _shuffle.length;
      return _shuffle[shuffleIndex];
    } else {
      index = (index + (forward ? 1 : -1) + audios.length) % audios.length;
      return index;
    }
  }

  Future<void> _preloadCoversInBackground() async {
    for (final audio in audios) {
      try {
        final cover = await AudioUtil().getCover(
          audio.audioId,
          coverSize: CoverSize.banner,
        );
        if (cover != null) {
          audio.cover = cover;
        }
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        debugPrint("Error loading cover for ${audio.id}: $e");
      }
    }
    _initialized = true;
  }

  Future<void> _loadChunk(int index) async {
    final start = (index - 5).clamp(0, audios.length - 1);
    final end = (index + 5).clamp(0, audios.length - 1);
    for (int i = start; i <= end; i++) {
      final audio = audios[i];
      if (audio.cover == null) {
        final cover = await AudioUtil().getCover(
          audio.audioId,
          coverSize: CoverSize.banner,
        );
        audio.cover = cover;
      }
    }
  }
}
