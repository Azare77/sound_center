import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

abstract class CloudRepository {
  Future search(String queryText, SearchFilter filter);
}
