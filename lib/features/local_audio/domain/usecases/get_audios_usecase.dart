import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class GetAudioUseCase implements UseCase {
  final AudioRepository _audioRepository;

  GetAudioUseCase(this._audioRepository);

  @override
  Future<List<AudioEntity>> call({
    params,
    AudioColumns orderBy = QUERY_DEFAULT_COLUMN_ORDER,
    bool desc = QUERY_DEFAULT_DESC,
  }) async {
    return await _audioRepository.fetchLocalAudios(
      orderBy: orderBy,
      desc: desc,
    );
  }

  Future<List<AudioEntity>> search({
    String? params,
    AudioColumns orderBy = QUERY_DEFAULT_COLUMN_ORDER,
    bool desc = QUERY_DEFAULT_DESC,
  }) async {
    return await _audioRepository.fetchLocalAudios(
      like: params,
      orderBy: orderBy,
      desc: desc,
    );
  }

  Future<bool> deleteAudio(AudioEntity audio) async {
    return await _audioRepository.deleteAudio(audio);
  }

  Future<List<PlaylistEntity>> getPlaylists() async {
    return await _audioRepository.getPlaylists();
  }

  Future<bool> createPlaylist(PlaylistEntity playlist) async {
    return await _audioRepository.createPlaylist(playlist);
  }

  Future<bool> addToPlaylist(int playlistId, int audioId) async {
    return await _audioRepository.addToPlaylist(playlistId, audioId);
  }

  Future<bool> removeFromPlaylist(int playlistId, int audioId) async {
    return await _audioRepository.removeFromPlaylist(playlistId, audioId);
  }

  Future<bool> changeOrder(int playlistId, int itemId, int newOrder) async {
    return await _audioRepository.changePlaylistItemOrder(
      playlistId,
      itemId,
      newOrder,
    );
  }

  Future<List<AudioEntity>> getFavorites() async {
    return await _audioRepository.getFavoriteAudios();
  }

  Future<bool> fave(int audioId) async {
    return await _audioRepository.faveAudio(audioId);
  }

  Future<bool> unfave(int audioId) async {
    return await _audioRepository.unfaveAudio(audioId);
  }
}
