import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class SubscriptionTable extends Table with TableMixin {
  TextColumn get podcastId => text().unique()(); // id از iTunes یا PodcastIndex
  TextColumn get title => text()();

  TextColumn get author => text().nullable()();

  TextColumn get artworkUrl => text().nullable()();

  TextColumn get feedUrl => text()();

  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get lastListenAt =>
      dateTime().withDefault(currentDateAndTime)();
}
