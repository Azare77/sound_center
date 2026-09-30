import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class PlaylistTable extends Table with TableMixin {
  TextColumn get title => text()();

  IntColumn get order => integer()();
}

class PlaylistItemTable extends Table with TableMixin {
  IntColumn get playlistId => integer().references(PlaylistTable, #id)();

  IntColumn get audioId => integer()();

  IntColumn get order => integer()();
}
