import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class FavoriteTable extends Table with TableMixin {
  IntColumn get audioId => integer().unique()();
}
