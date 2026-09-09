import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';

sealed class CloudStatus {}

class LoadingCloud extends CloudStatus {}

class CloudHistory extends CloudStatus {
  final CloudEntity history;

  CloudHistory(this.history);
}

class SearchResultStatus extends CloudStatus {
  CloudEntity searchResult;

  SearchResultStatus({required this.searchResult});
}
