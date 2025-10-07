import 'package:just_audio/just_audio.dart';

enum AudioSource { local, online }

class JustAudioService {
  static JustAudioService? _instance;

  factory JustAudioService() {
    _instance ??= JustAudioService._internal();
    return _instance!;
  }

  JustAudioService._internal();

  void Function()? _onComplete;
  void Function()? _onLoading;
  void Function()? _onReady;

  final AudioPlayer _player = AudioPlayer();
  AudioSource? _source;

  AudioPlayer getPlayer() {
    return _player;
  }

  Future<void> setSource(String path, AudioSource source) async {
    try {
      _source = source;
      if (source == AudioSource.local) {
        await _player.setFilePath(path);
      } else {
        await _player.setUrl(path);
      }
    } catch (_) {
      _source == null;
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> togglePlaying() async {
    switch (_player.playing) {
      case true:
        await _player.pause();
        break;
      case false:
        await _player.play();
        break;
    }
  }

  Future<void> release() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void setOnComplete(
    void Function()? onComplete, {
    void Function()? onLoading,
    void Function()? onReady,
  }) {
    _onComplete = onComplete;
    _onLoading = onLoading;
    _onReady = onReady;
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onComplete?.call();
      }
      if (state == ProcessingState.loading) {
        _onLoading?.call();
      }
      if (state == ProcessingState.ready) {
        _onReady?.call();
      }
    });
  }

  bool isLoading() {
    return _player.processingState == ProcessingState.loading ||
        _player.processingState == ProcessingState.buffering;
  }

  Future<int> getCurrentPosition() async {
    Duration currentPosition = _player.position;
    return currentPosition.inMilliseconds;
  }

  Future<int> getDuration() async {
    Duration? duration;
    while (duration == null) {
      duration = _player.duration;
      await Future.delayed(Duration(milliseconds: 10));
    }
    return duration.inMilliseconds;
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  bool hasSource(AudioSource source) {
    if (_source == null || _source != source) return false;
    final duration = _player.duration;
    final processingState = _player.processingState;
    return duration != null || processingState != ProcessingState.idle;
  }
}
