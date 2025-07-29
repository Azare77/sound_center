import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/local/audio.dart';
import 'package:sound_center/database/drift/mixin.dart';

class PlaylistTable extends Table with TableMixin {
  TextColumn get title => text()();

  IntColumn get order => integer()();

  IntColumn get audio => integer().references(LocalAudiosTable, #id)();
}
