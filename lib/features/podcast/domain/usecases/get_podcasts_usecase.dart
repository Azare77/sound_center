import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
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
    bool desc = QUERY_DEFAULT_DESC,
  }) async {
    return await _audioRepository.getHome();
  }

  Future<PodcastEntity> find(String searchText) async {
    return await _audioRepository.find(searchText);
  }

  Future<bool> subscribe(SubscriptionEntity podcast) async {
    return await _audioRepository.subscribe(podcast);
  }

  Future<bool> updateSubscribedPodcast(SubscriptionEntity podcast) async {
    return await _audioRepository.updateSubscribedPodcast(podcast);
  }

  Future<List<SubscriptionEntity>> haveUpdate() async {
    return await _audioRepository.haveUpdate();
  }

  Future<bool> unsubscribe(String feedUrl) async {
    return await _audioRepository.unsubscribe(feedUrl);
  }

  Future<bool> downloadEpisode(DownloadedEpisodeEntity episode) async {
    return await _audioRepository.downloadEpisode(episode);
  }

  Future<bool> deleteEpisode(String guid) async {
    return await _audioRepository.deleteEpisode(guid);
  }

  Future<List<Episode>> getDownloadedEpisodes() async {
    return await _audioRepository.getDownloadedEpisodes();
  }
}
