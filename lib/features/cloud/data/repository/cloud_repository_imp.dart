import 'package:drift/drift.dart' as drift;
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

  Future<List<CloudHistoryTableData>> _getSubs() async {
    final subs =
        await (_appDatabase.select(_appDatabase.cloudHistoryTable)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.id,
                mode: drift.OrderingMode.desc,
              ),
            ]))
            .get();
    return subs;
  }

  @override
  Future<List<CloudTrack>> getPlaybackHistory() async {
    final subs = await _getSubs();
    final models = subs.map((s) => CloudTrack.fromDrift(s)).toList();
    return models;
  }

  Future<bool> isOnHistory(int trackId) async {
    final existing = await (_appDatabase.select(
      _appDatabase.cloudHistoryTable,
    )..where((tbl) => tbl.trackId.equals(trackId))).getSingleOrNull();
    if (existing != null) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> addToHistory(CloudTrack track) async {
    bool existed = await isOnHistory(track.id);
    if (existed) return true;
    await _appDatabase
        .into(_appDatabase.cloudHistoryTable)
        .insert(track.toDrift());
    return true;
  }

  @override
  Future<bool> removeFromHistory(CloudTrack track) async {
    await (_appDatabase.delete(
      _appDatabase.cloudHistoryTable,
    )..where((r) => r.trackId.equals(track.id))).go();
    return true;
  }

  @override
  Future<bool> clearHistory() async {
    await (_appDatabase.delete(_appDatabase.cloudHistoryTable)).go();
    return true;
  }
}
