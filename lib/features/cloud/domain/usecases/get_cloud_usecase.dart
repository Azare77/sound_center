import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/domain/repository/cloud_repository.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class GetCloudUseCase implements UseCase {
  final CloudRepository _cloudRepository;

  GetCloudUseCase(this._cloudRepository);

  @override
  Future call({params}) async {}

  Future<CloudEntity> search({
    required String queryText,
    required SearchFilter filter,
  }) async {
    return await _cloudRepository.search(queryText, filter);
  }

  Future<List<CloudTrack>> getPlaybackHistory() async {
    return await _cloudRepository.getPlaybackHistory();
  }

  Future<bool> addToHistory(CloudTrack track) async {
    return await _cloudRepository.addToHistory(track);
  }

  Future<bool> removeFromHistory(CloudTrack track) async {
    return await _cloudRepository.removeFromHistory(track);
  }

  Future<bool> clearHistory() async {
    return await _cloudRepository.clearHistory();
  }
}
