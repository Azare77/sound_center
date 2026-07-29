import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart' show IcyMetadata;
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class StreamPlayerRepositoryImp implements PlayerRepository {
  static final StreamPlayerRepositoryImp _instance =
      StreamPlayerRepositoryImp._internal();

  factory StreamPlayerRepositoryImp() {
    return _instance;
  }

  StreamPlayerRepositoryImp._internal() {
    _playerService.setOnStreamComplete(() => restart());
    _initialPlayerState();
  }

  bool isLoading() {
    return _playerService.isLoading();
  }

  final JustAudioService _playerService = JustAudioService();

  // final MpvService _playerService = MpvService();
  dynamic _currentStream;

  dynamic get getCurrentStream => _currentStream;

  final _positionController = StreamController<int>.broadcast();
  final _durationController = StreamController<int>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();

  Stream<int> get positionStream => _positionController.stream;

  Stream<int> get durationStream => _durationController.stream;

  Stream<bool> get loadingStream => _loadingController.stream;

  Timer? _updateTimer;
  StreamSubscription<IcyMetadata?>? _icySubscription;
  late final StreamBloc bloc;

  void _initialPlayerState() {
    _playerService.position.listen((pos) {
      _positionController.add(pos.inMilliseconds);
    });
    _playerService.processState.listen((state) {
      _loadingController.add(isLoading());
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
    return _playerService.hasSource(AudioSource.stream);
  }

  void setBloc(StreamBloc bloc) {
    this.bloc = bloc;
  }

  var _playList = [];

  @override
  void setPlayList(dynamic stream) {
    _playList = [stream];
  }

  List getPlayList() {
    return _playList;
  }

  void updateCurrentFileInfo(AudioModel audio) {
    _currentStream = audio;
    _playList[0] = audio;
    updateNotification();
  }

  void updateCurrentStreamInfo(Source source) {
    _currentStream = source;
    _playList[0] = source;
    updateNotification();
  }

  void updateNotification() async {
    final item = _currentStream;
    late String url;
    late String title;
    String? artist;
    dynamic cover;
    int? duration;
    if (item is AudioModel) {
      url = item.path;
      title = item.title;
      artist = item.artist;
      duration = await getDuration();
    } else if (item is Source) {
      url = item.listenUrl;
      title = item.title ?? "";
      cover = item.cover;
    }
    cover = item.cover;
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromStream(
      url: url,
      title: title,
      artist: artist,
      cover: cover,
      duration: Duration(milliseconds: duration ?? 0),
    );
  }

  @override
  Future<void> changeRepeatState() async {}

  @override
  Future<void> changeShuffleState() async {}

  @override
  Future<void> play(int _, {bool direct = false}) async {
    _currentStream = _playList[0];
    late final String url;
    late final String title;
    Duration? duration;
    dynamic cover;
    if (_currentStream is AudioModel) {
      final audio = (_currentStream as AudioModel);
      url = audio.path;
      title = audio.title;
      cover = audio.cover;
      duration = Duration(milliseconds: audio.duration);
      (_currentStream as AudioModel).duration;
    } else if (_currentStream is Source) {
      final stream = (_currentStream as Source);
      url = stream.listenUrl;
      title = stream.title ?? '';
      cover = stream.cover ?? '';
    }
    File? file;
    try {
      file = await NetworkCacheImage.customCacheManager.getSingleFile(cover);
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromStream(
      url: url,
      title: title,
      cover: cover,
      duration: duration,
      cached: file?.uri,
    );
    await _playerService.setSource(
      url,
      AudioSource.stream,
      onSourceSet: () => bloc.add(AutoPlayStream()),
    );

    await _playerService.play();
    bloc.add(AutoPlayStream());
  }

  @override
  Future<dynamic> next() async {}

  @override
  Future<dynamic> previous() async {}

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
    if (_currentStream is AudioModel) {
      await _playerService.togglePlaying();
      bloc.add(TogglePlay());
      return;
    }
    if (isPlaying()) {
      await stop();
      bloc.add(TogglePlay());
    } else {
      bloc.add(PlayStream(_currentStream));
    }
  }

  @override
  Future<void> stop() async {
    _cancelIcyListener();
    _updateTimer?.cancel();
    _updateTimer = null;
    await _playerService.release();
    await Future.delayed(Duration(milliseconds: 100));
    bloc.add(TogglePlay());
  }

  Future<void> restart() async {
    await _playerService.release();
    await Future.delayed(Duration(seconds: 1));
    bloc.add(AutoPlayStream());
    await play(0);
  }

  void addIcyMetadataListener(void Function(String? title) onTitle) {
    _icySubscription?.cancel();
    _icySubscription = _playerService.icyMetadataStream.listen((metadata) {
      onTitle(metadata?.info?.title ?? metadata?.headers?.name);
    });
  }

  void _cancelIcyListener() {
    _icySubscription?.cancel();
    _icySubscription = null;
  }

  Future<void> addMetadataListener(Function onMetadata) async {
    if (_updateTimer != null) {
      _updateTimer?.cancel();
      _updateTimer = null;
    }
    if (hasSource() && (_currentStream is Source)) onMetadata.call();
    _updateTimer = Timer.periodic(Duration(seconds: 10), (_) {
      if (hasSource() && (_currentStream is Source)) {
        // onMetadata.call();
      } else {
        _updateTimer?.cancel();
        _updateTimer = null;
      }
    });
  }
}
