import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class GetAudioUseCase implements UseCase {
  final AudioRepository _audioRepository;

  GetAudioUseCase(this._audioRepository);

  @override
  Future<List<AudioEntity>> call({params}) async {
    return await _audioRepository.getAudios();
  }

  Future<List<AudioEntity>> search(String? params) async {
    return await _audioRepository.search(like: params);
  }
}
