import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';

abstract class PodcastRepository {
  Future<List<SubscriptionEntity>> getHome();

  Future<bool> subscribe(SubscriptionEntity podcast);

  Future<PodcastEntity> find(String searchText);

  Future<Podcast> loadPodcastInfo(String feedUrl);
}
