import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<PodcastEntity>> getHome();

  Future<PodcastEntity> find(String searchText);

  Future<Podcast> loadPodcastInfo(String feedUrl);
}
