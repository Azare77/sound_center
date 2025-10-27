import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/mixin.dart';

class DownloadTable extends Table with TableMixin {
  TextColumn get episodeId => text()();

  TextColumn get title => text()();

  TextColumn get audioUrl => text()();

  TextColumn get localFilePath => text()();

  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get podcastFeedUrl => text()();
}
