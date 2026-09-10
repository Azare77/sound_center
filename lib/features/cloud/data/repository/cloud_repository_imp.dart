import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/cloud/data/source/cloud_source.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

import '../../domain/repository/cloud_repository.dart';

class CloudRepositoryImp implements CloudRepository {
  final AppDatabase _appDatabase;

  CloudRepositoryImp(this._appDatabase);

  final CloudSource _source = CloudSource();

  Future<List<CloudTrack>> loadPlaylistTracks(CloudPlaylist playlist) async {
    List<CloudTrack> tracks = await _source.loadPlaylistTracks(playlist.id);
    tracks.sort((f, s) => f.id.compareTo(s.id));
    return tracks;
  }

  @override
  Future<CloudEntity> search(String queryText, SearchFilter filter) async {
    return await _source.search(queryText, filter);
  }
}
