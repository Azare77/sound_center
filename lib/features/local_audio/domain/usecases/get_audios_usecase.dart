import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class GetAudioUseCase implements UseCase {
  final AudioRepository _audioRepository;

  GetAudioUseCase(this._audioRepository);

  @override
  Future<List<AudioEntity>> call({
    params,
    AudioColumns orderBy = queryConstants,
    bool desc = defaultDesc,
  }) async {
    return await _audioRepository.getAudios(orderBy: orderBy, desc: desc);
  }

  Future<List<AudioEntity>> search({
    String? params,
    AudioColumns orderBy = queryConstants,
    bool desc = defaultDesc,
  }) async {
    return await _audioRepository.search(
      like: params,
      orderBy: orderBy,
      desc: desc,
    );
  }
}
