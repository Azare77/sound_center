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
  int index = 0;
  late final LocalBloc bloc;

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource();
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

  @override
  Future<void> changeRepeatState(RepeatMode mode) {
    // TODO: implement changeRepeatState
    throw UnimplementedError();
  }

  @override
  Future<void> changeShuffleState(ShuffleMode mode) {
    // TODO: implement changeShuffleState
    throw UnimplementedError();
  }

  @override
  Future<void> play(int index) async {
    this.index = index;
    await _playerService.setSource(audios[index].path);
    _playerService.play();
    (audioHandler as JustAudioNotificationHandler).setMediaItemFrom(
      audios[index],
    );
  }

  @override
  Future<int> next() async {
    if (index + 1 == audios.length) {
      index = 0;
    } else {
      index++;
    }
    await play(index);
    bloc.add(AutoPlayNext(index));
    return index;
  }

  @override
  Future<int> previous() async {
    if (index == 0) {
      index = audios.length - 1;
    } else {
      index--;
    }
    await play(index);
    bloc.add(AutoPlayNext(index));
    return index;
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
}
