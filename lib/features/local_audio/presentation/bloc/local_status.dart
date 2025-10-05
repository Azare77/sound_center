import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

sealed class LocalStatus {}

class LoadingLocalAudios extends LocalStatus {}

class LocalAudioStatus extends LocalStatus {
  List<AudioEntity> audios;

  // AudioEntity? currentAudio;

  LocalAudioStatus({required this.audios});
}
