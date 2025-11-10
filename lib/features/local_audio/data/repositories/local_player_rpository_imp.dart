import 'package:flutter/widgets.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class LocalPlayerRepositoryImp implements PlayerRepository {
  static final LocalPlayerRepositoryImp _instance =
      LocalPlayerRepositoryImp._internal();

  factory LocalPlayerRepositoryImp() {
    return _instance;
  }

  LocalPlayerRepositoryImp._internal() {
    _playerService.setOnComplete(() => next());
    _initialPlayerState();
  }

  final JustAudioService _playerService = JustAudioService();

  void init() async {
    try {
      audios.map((item) async {
        AudioUtil.getCover(item.id, coverSize: CoverSize.thumbnail);
        AudioUtil.getCover(item.id, coverSize: CoverSize.banner);
      });
      if (PlayerStateStorage.getSource() != AudioSource.local) return;
      _currentAudio = PlayerStateStorage.getLastAudio();
      if (_currentAudio == null) return;
      if (shuffleMode == ShuffleMode.shuffle) _shuffleAudios();
      await _playerService.setSource(_currentAudio!.path, AudioSource.local);
      int position = PlayerStateStorage.getLastPosition();
      await _playerService.seek(Duration(milliseconds: position));
      _currentAudio!.cover = await AudioUtil.getCover(
        _currentAudio!.id,
        coverSize: CoverSize.banner,
      );
      index = audios.indexWhere((a) => a.id == _currentAudio!.id);
      audios[index] = _currentAudio!;
      (audioHandler as JustAudioNotificationHandler).setMediaItemFrom(
        _currentAudio!,
      );
    } catch (e, st) {
      debugPrint('init() failed: $e\n$st');
      _currentAudio = null;
    }
  }

  List<AudioEntity> audios = [];

  AudioEntity? _currentAudio;

  AudioEntity? get getCurrentAudio => _currentAudio;
  List<int> _shuffle = [];
  int index = 0;
  int shuffleIndex = 0;
  RepeatMode repeatMode = RepeatMode.repeatAll;
  ShuffleMode shuffleMode = ShuffleMode.noShuffle;
  late final LocalBloc bloc;

  void _initialPlayerState() {
    repeatMode = PlayerStateStorage.getRepeatMode();
    shuffleMode = PlayerStateStorage.getShuffleMode();
  }

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource(AudioSource.local);
  }

  bool isShuffle() {
    return shuffleMode == ShuffleMode.shuffle;
  }

  void setBloc(LocalBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic tracks) {
    assert(tracks is List<AudioEntity>);
    audios.clear();
    for (AudioEntity track in tracks) {
      audios.add(track);
    }
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
    _currentAudio = audios[index];
    if (direct && shuffleMode == ShuffleMode.shuffle) {
      _shuffleAudios();
    }
    if (audios[index].cover == null) {
      audios[index].cover = await AudioUtil.getCover(
        _currentAudio!.id,
        coverSize: CoverSize.banner,
      );
    }
    await _playerService.setSource(audios[index].path, AudioSource.local);
    _playerService.play();
    bloc.add(AutoPlayNext());
    (audioHandler as JustAudioNotificationHandler).setMediaItemFrom(
      audios[index],
    );
    _loadChunk(index);
    PlayerStateStorage.saveLastAudio(_currentAudio!);
    PlayerStateStorage.saveSource(AudioSource.local);
  }

  @override
  Future<AudioEntity> next() async {
    index = _getIndex(true);
    await play(index);
    return audios[index];
  }

  @override
  Future<AudioEntity> previous() async {
    index = _getIndex(false);
    await play(index);
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
    _currentAudio = null;
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  Future<void> removeAudio(AudioEntity audio) async {
    int removedIndex = audios.indexOf(audio);
    if (removedIndex == -1) return;
    audios.removeAt(removedIndex);
    if (audios.isEmpty) {
      index = 0;
      return;
    }
    if (index >= audios.length) {
      index = audios.length - 1;
    }
    final bool isShuffle = shuffleMode == ShuffleMode.shuffle;
    if (isShuffle) {
      _shuffle.removeWhere((i) => i == removedIndex);
      for (int i = 0; i < _shuffle.length; i++) {
        if (_shuffle[i] > removedIndex) {
          _shuffle[i] -= 1;
        }
      }
      if (shuffleIndex >= _shuffle.length) {
        shuffleIndex = 0;
      }
    }
    if (_currentAudio == audio) {
      await play(isShuffle ? _shuffle[shuffleIndex] : index);
    }
  }

  int _getIndex(bool forward) {
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

  Future<void> _loadChunk(int index) async {
    int start = (index - 5).clamp(0, audios.length - 1);
    int end = (index + 5).clamp(0, audios.length - 1);
    List<int> indices;
    if (isShuffle() && _shuffle.isNotEmpty) {
      start = (shuffleIndex - 5).clamp(0, _shuffle.length - 1);
      end = (shuffleIndex + 5).clamp(0, _shuffle.length - 1);
      indices = _shuffle.sublist(start, end + 1);
    } else {
      indices = List.generate(end - start + 1, (i) => start + i);
    }
    for (final i in indices) {
      final audio = audios[i];
      audio.cover ??= await AudioUtil.getCover(
        audio.id,
        coverSize: CoverSize.banner,
      );
      audios[i] = audio;
    }
  }
}
