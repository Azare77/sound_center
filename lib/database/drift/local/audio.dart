import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

import '../mixin.dart';

class LocalAudiosTable extends Table with TableMixin {
  IntColumn get audioId => integer().clientDefault(() => 0)();

  TextColumn get title => text()();

  IntColumn get duration => integer()();

  TextColumn get artist => text().nullable()();

  TextColumn get album => text().nullable()();

  Column<Uint8List> get cover => blob().nullable()();

  TextColumn get genre => text().nullable()();

  IntColumn get trackNum => integer().nullable()();

  TextColumn get path => text().unique()();

  BoolColumn get isPodcast => boolean().clientDefault(() => false)();

  BoolColumn get isAlarm => boolean().clientDefault(() => false)();

  Future<List<LocalAudiosTableData>> search({
    String? input,
    required AudioColumns orderBy,
    required bool desc,
  }) async {
    final db = AppDatabase();
    final query = db.select(db.localAudiosTable);
    if (input?.isNotEmpty == true) {
      query.where(
        (t) =>
            t.title.contains(input!) |
            t.artist.contains(input) |
            t.album.contains(input),
      );
    }
    final columnSelector = {
      AudioColumns.createdAt: (t) => t.createdAt,
      AudioColumns.title: (t) => t.title,
      AudioColumns.artist: (t) => t.artist,
      AudioColumns.album: (t) => t.album,
      AudioColumns.duration: (t) => t.duration,
    }[orderBy]!;

    query.orderBy([
      (t) => OrderingTerm(
        expression: columnSelector(t),
        mode: desc ? OrderingMode.desc : OrderingMode.asc,
      ),
    ]);

    return await query.get();
  }
}
