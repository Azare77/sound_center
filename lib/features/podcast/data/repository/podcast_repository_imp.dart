import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';

class PodcastRepositoryImp implements PodcastRepository {
  @override
  Future<List<PodcastEntity>> getHome() {
    // TODO: implement getHome
    throw UnimplementedError();
  }

  @override
  Future<PodcastEntity> find(String searchText) async {
    Search search = Search();
    // search = Search(
    //   searchProvider: PodcastIndexProvider(
    //     key: 'EXDBALQGZKUFF9H6ZBCP',
    //     secret: "7vpySXwG\$CCr68Eh3ySehrvSeLmaCTG36YB8UEEE",
    //   ),
    // );
    SearchResult results = await search.search(searchText, limit: 10);
    if (results.successful) {
      return PodcastEntity(results.items);
    } else {
      return PodcastEntity([]);
    }
  }

  @override
  Future<Podcast> loadPodcastInfo(String feedUrl) async {
    var podcast = await Feed.loadFeed(url: feedUrl);
    return podcast;
  }
}
