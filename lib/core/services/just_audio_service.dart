import 'package:just_audio/just_audio.dart';

class JustAudioService {
  static JustAudioService? _instance;

  factory JustAudioService() {
    _instance ??= JustAudioService._internal();
    return _instance!;
  }

  JustAudioService._internal();

  void Function()? _onComplete;

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer getPlayer() {
    return _player;
  }

  Future<void> setSource(String path) async {
    await _player.setFilePath(path);
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

  Future<void> seek(int position) async {
    await _player.seek(Duration(milliseconds: position));
  }

  void setOnComplete(void Function() onComplete) {
    _onComplete = onComplete;
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onComplete?.call();
      }
    });
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

  void setRepeatMode() {}

  bool hasSource() {
    final duration = _player.duration;
    final processingState = _player.processingState;
    return duration != null || processingState != ProcessingState.idle;
  }
}
