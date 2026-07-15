import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class StreamSubscriptionTable extends Table with TableMixin {
  TextColumn get title => text()();

  TextColumn get url => text()();

  DateTimeColumn get startAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isOnline => boolean().withDefault(const Constant(true))();

  TextColumn get cover => text().nullable()();

  TextColumn get fullData => text().nullable()();
}
