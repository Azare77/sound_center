import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class DownloadTable extends Table with TableMixin {
  TextColumn get guid => text()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  TextColumn get author => text().nullable()();

  TextColumn get imageUrl => text().nullable()();

  TextColumn get contentUrl => text()();

  IntColumn get length => integer()();

  IntColumn get duration => integer()();
}
