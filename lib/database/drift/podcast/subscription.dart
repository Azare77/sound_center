import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class SubscriptionTable extends Table with TableMixin {
  TextColumn get podcastId =>
      text().nullable().unique()(); // id از iTunes یا PodcastIndex
  TextColumn get title => text()();

  TextColumn get author => text().nullable()();

  TextColumn get artworkUrl => text().nullable()();

  TextColumn get feedUrl => text()();

  IntColumn get totalEpisodes => integer().withDefault(const Constant(0))();

  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get haveNewEpisode =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get updateTime => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get lastListenAt =>
      dateTime().withDefault(currentDateAndTime)();
}
