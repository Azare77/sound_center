import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

sealed class LocalStatus {}

class LoadingLocalAudios extends LocalStatus {}

class LocalAudioStatus extends LocalStatus {
  List<AudioEntity> audios;

  LocalAudioStatus({required this.audios});
}

class LocalFavoriteStatus extends LocalStatus {
  List<AudioEntity> audios;

  LocalFavoriteStatus({required this.audios});
}

class LocalPlayListsStatus extends LocalStatus {
  List<LocalPlayList> playlists;

  LocalPlayListsStatus({required this.playlists});
}

class LocalCategoryStatus extends LocalStatus {
  final Category category;
  final List items;

  LocalCategoryStatus({required this.category, required this.items});
}
