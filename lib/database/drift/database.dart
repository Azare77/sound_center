import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/database/drift/local/audio.dart';

import 'local/playlist.dart';

part 'database.g.dart';

@DriftDatabase(tables: [LocalAudiosTable, PlaylistTable])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'audio_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
      ),
    );
  }
}
