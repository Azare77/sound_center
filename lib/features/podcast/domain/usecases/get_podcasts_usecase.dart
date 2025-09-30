import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';

class GetPodcastsUseCase implements UseCase {
  final PodcastRepository _audioRepository;

  GetPodcastsUseCase(this._audioRepository);

  @override
  Future<List<PodcastEntity>> call({
    params,
    AudioColumns orderBy = queryConstants,
    bool desc = defaultDesc,
  }) async {
    return await _audioRepository.getHome();
  }

  Future<PodcastEntity> find(String searchText) async {
    return await _audioRepository.find(searchText);
  }
}
