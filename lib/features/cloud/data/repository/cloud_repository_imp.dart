import 'package:sound_center/features/cloud/data/source/cloud_source.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

import '../../domain/repository/cloud_repository.dart';

class CloudRepositoryImp implements CloudRepository {
  final CloudSource _source = CloudSource();

  @override
  Future<CloudEntity> search(String queryText, SearchFilter filter) {
    return _source.search(queryText, filter);
  }
}
