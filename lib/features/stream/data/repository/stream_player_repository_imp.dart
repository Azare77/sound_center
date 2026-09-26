import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart' show IcyMetadata;
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/main.dart';
import 'package:sound_center/shared/Repository/base_player_repository.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class StreamPlayerRepositoryImp extends BasePlayerRepository {
  static final StreamPlayerRepositoryImp _instance =
      StreamPlayerRepositoryImp._internal();

  factory StreamPlayerRepositoryImp() {
    return _instance;
  }

  StreamPlayerRepositoryImp._internal() {
    super.playerService.setOnStreamComplete(() => restart());
    _initialPlayerState();
  }

  // final MpvService _playerService = MpvService();
  dynamic _currentStream;

  dynamic get getCurrentStream => _currentStream;

  final _streamChangedController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get streamChangedStream => _streamChangedController.stream;

  Timer? _updateTimer;
  StreamSubscription<IcyMetadata?>? _icySubscription;
  late final StreamBloc bloc;

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
    return super.playerService.hasSource(AudioSource.stream);
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
    _retryCount = 0;
    _currentStream = _playList[0];
    playerService.setSourceByForce(AudioSource.stream);
    _streamChangedController.add(_currentStream);
    // make sure that loading widget will show
    await Future.delayed(Duration(milliseconds: 20));
    loadingController.add(true);
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
      cover = stream.cover;
    }
    File? file;
    try {
      file = await NetworkCacheImage.getFile(cover);
    } catch (_) {}
    (audioHandler as JustAudioNotificationHandler).setMediaItemFromStream(
      url: url,
      title: title,
      cover: cover,
      duration: duration,
      cached: file?.uri,
    );
    bool allowToPlay = await super.playerService.setSource(
      url,
      AudioSource.stream,
    );
    if (!allowToPlay) return;
    await playerService.play();
  }

  @override
  Future<dynamic> next() async {}

  @override
  Future<dynamic> previous() async {}

  @override
  Future<void> togglePlayState() async {
    if (_currentStream is AudioModel) {
      await super.playerService.togglePlaying();
    } else {
      if (isPlaying()) {
        await stop();
      } else {
        bloc.add(PlayStream(_currentStream));
      }
    }
    _streamChangedController.add(_currentStream);
    bloc.add(TogglePlay());
  }

  @override
  Future<void> stop() async {
    _retryCount = 0;
    _cancelIcyListener();
    _updateTimer?.cancel();
    _updateTimer = null;
    _streamChangedController.add(null);
    await super.playerService.release();
    await Future.delayed(Duration(milliseconds: 100));
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
    await super.playerService.release();
    await Future.delayed(Duration(seconds: 1));
    int currentRetry = _retryCount;
    await play(0);
    _retryCount = currentRetry;
  }

  void addIcyMetadataListener(void Function(String? title) onTitle) {
    _icySubscription?.cancel();
    _icySubscription = super.playerService.icyMetadataStream.listen((metadata) {
      if (hasSource()) {
        onTitle(metadata?.info?.title ?? metadata?.headers?.name);
      }
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
      } else {
        _updateTimer?.cancel();
        _updateTimer = null;
      }
    });
  }
}
