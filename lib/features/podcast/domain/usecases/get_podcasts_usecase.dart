import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';

class GetPodcastsUseCase implements UseCase {
  final PodcastRepository _audioRepository;

  GetPodcastsUseCase(this._audioRepository);

  @override
  Future<List<SubscriptionEntity>> call({
    params,
    AudioColumns orderBy = QUERY_DEFAULT_COLUMN_ORDER,
    bool desc = DEFAULT_DESC,
  }) async {
    return await _audioRepository.getHome();
  }

  Future<PodcastEntity> find(String searchText) async {
    return await _audioRepository.find(searchText);
  }

  Future<bool> subscribe(SubscriptionEntity podcast) async {
    return await _audioRepository.subscribe(podcast);
  }
}
