import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

abstract class CloudRepository {
  Future search(String queryText, SearchFilter filter);

  Future<List<CloudTrack>> getPlaybackHistory();

  Future<bool> addToHistory(CloudTrack track);

  Future<bool> removeFromHistory(CloudTrack track);

  Future<bool> clearHistory();
}
