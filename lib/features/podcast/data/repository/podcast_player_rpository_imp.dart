import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
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
    // _playerService.setOnComplete(() => next());
    _initialPlayerState();
  }

  final JustAudioService _playerService = JustAudioService();
  final List<Episode> _episodes = [];

  Episode? _currentEpisode;

  Episode? get getCurrentEpisode => _currentEpisode;

  // List<int> _shuffle = [];
  int index = 0;

  // int shuffleIndex = 0;
  RepeatMode repeatMode = RepeatMode.repeatAll;

  // ShuffleMode shuffleMode = ShuffleMode.noShuffle;
  late final PodcastBloc bloc;

  void _initialPlayerState() {
    repeatMode = PlayerStateStorage.getRepeatMode();
    // shuffleMode = PlayerStateStorage.getShuffleMode();
  }

  bool isPlaying() {
    return _playerService.getPlayer().playing;
  }

  bool hasSource() {
    return _playerService.hasSource(AudioSource.online);
  }

  bool isShuffle() {
    return false;
    // return shuffleMode == ShuffleMode.shuffle;
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
    // if (shuffleMode == ShuffleMode.noShuffle) return _episodes;
    // return _shuffle.map((i) => _episodes[i]).toList();
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
    // if (shuffleMode == ShuffleMode.shuffle) {
    //   shuffleMode = ShuffleMode.noShuffle;
    //   _shuffle = [];
    // } else {
    //   _shuffleAudios();
    // }
    // await PlayerStateStorage.saveShuffleMode(shuffleMode);
  }

  // void _shuffleAudios() {
  // shuffleMode = ShuffleMode.shuffle;
  // shuffleIndex = 0;
  // _shuffle = List.generate(_episodes.length, (i) => i)..shuffle();
  // _shuffle.insert(0, index);
  // }

  @override
  Future<void> play(int index, {bool direct = false}) async {
    this.index = index;
    _currentEpisode = _episodes[index];
    // if (direct && shuffleMode == ShuffleMode.shuffle) {
    //   _shuffleAudios();
    // }
    bloc.add(AutoPlayPodcast(_currentEpisode!));
    await _playerService.setSource(
      _episodes[index].contentUrl!,
      AudioSource.online,
    );
    _playerService.play();
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromEpisode(
      _episodes[index],
    );
  }

  @override
  Future<Episode> next() async {
    // index = getIndex(true);
    // await play(index);
    // bloc.add(AutoPlayNext(audios[index]));
    return _episodes[index];
  }

  @override
  Future<Episode> previous() async {
    index = getIndex(false);
    await play(index);
    // bloc.add(AutoPlayNext(audios[index]));
    return _episodes[index];
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
    _currentEpisode = null;
    await _playerService.release();
    bloc.add(TogglePlay());
  }

  int getIndex(bool forward) {
    // bool isShuffle = shuffleMode == ShuffleMode.shuffle;
    if (repeatMode == RepeatMode.repeatOne) {
      // if (isShuffle) {
      //   return _shuffle[shuffleIndex];
      // } else {
      return index;
      // }
    }
    // if (isShuffle) {
    //   shuffleIndex =
    //       (shuffleIndex + (forward ? 1 : -1) + _shuffle.length) %
    //       _shuffle.length;
    //   return _shuffle[shuffleIndex];
    // } else {
    index = (index + (forward ? 1 : -1) + _episodes.length) % _episodes.length;
    return index;
    // }
  }
}
