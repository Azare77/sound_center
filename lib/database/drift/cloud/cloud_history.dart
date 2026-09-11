import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class CloudHistoryTable extends Table with TableMixin {
  IntColumn get trackId => integer()();

  TextColumn get title => text()();

  TextColumn get author => text()();

  DateTimeColumn get uploadedAt => dateTime()();

  TextColumn get artworkUrl => text().nullable()();

  IntColumn get playbackCount => integer()();

  IntColumn get duration => integer()();
}
