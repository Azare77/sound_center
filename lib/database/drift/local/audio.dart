import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/database.dart';

import '../mixin.dart';

class LocalAudiosTable extends Table with TableMixin {
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

  Future<List<LocalAudiosTableData>> search({String? input}) async {
    final database = AppDatabase();

    List<LocalAudiosTableData> dbData =
        await (database.select(database.localAudiosTable)
              ..where(
                (tbl) => input != null
                    ? tbl.title.contains(input) | tbl.artist.contains(input)
                    : Constant(true),
              )
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
            .get();
    return dbData;
  }
}
