import 'package:sound_center/core/constants/player_modes.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
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
  }

  final JustAudioService _playerService = JustAudioService();
  final List<AudioEntity> audios = [];
  List<int> _shuffle = [];
  int index = 0;
  int shuffleIndex = 0;
  RepeatMode repeatMode = RepeatMode.repeatAll;
  ShuffleMode shuffleMode = ShuffleMode.noShuffle;
  late final LocalBloc bloc;

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource();
  }

  bool isShuffle() {
    return shuffleMode == ShuffleMode.shuffle;
  }

  void setBloc(LocalBloc bloc) {
    this.bloc = bloc;
  }

  @override
  void setPlayList(dynamic audios) {
    assert(audios is List<AudioEntity>);
    this.audios.clear();
    for (AudioEntity audioEntity in audios) {
      this.audios.add(audioEntity);
    }
  }

  List<AudioEntity> getPlayList() {
    return audios;
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
  }

  @override
  Future<void> changeShuffleState() async {
    shuffleIndex = 0;
    if (shuffleMode == ShuffleMode.shuffle) {
      shuffleMode = ShuffleMode.noShuffle;
      _shuffle = [];
    } else {
      shuffleMode = ShuffleMode.shuffle;
      _shuffle = List.generate(audios.length, (i) => i)..shuffle();
      _shuffle[0] = index;
    }
  }

  @override
  Future<void> play(int index) async {
    this.index = index;
    await _playerService.setSource(audios[index].path);
    _playerService.play();
    bloc.add(AutoPlayNext(audios[index]));
    (audioHandler as JustAudioNotificationHandler).setMediaItemFrom(
      audios[index],
    );
  }

  @override
  Future<AudioEntity> next() async {
    index = getIndex(true);
    await play(index);
    bloc.add(AutoPlayNext(audios[index]));
    return audios[index];
  }

  @override
  Future<AudioEntity> previous() async {
    index = getIndex(false);
    await play(index);
    bloc.add(AutoPlayNext(audios[index]));
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
  Future<void> seek(double position) async {
    int duration = await _playerService.getDuration();
    int newPosition = (position * duration).floor();
    _playerService.seek(newPosition);
  }

  Future<void> seekNotif(Duration duration) async {
    _playerService.seek(duration.inMilliseconds);
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
    if (shuffleMode == ShuffleMode.shuffle) {
      shuffleIndex =
          (shuffleIndex + (forward ? 1 : -1) + _shuffle.length) %
          _shuffle.length;
      return _shuffle[shuffleIndex];
    } else {
      index = (index + (forward ? 1 : -1) + audios.length) % audios.length;
      return index;
    }
  }
}
