import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/core/constants/constants.dart';

import 'local/playlist.dart';
import 'podcast/download.dart';
import 'podcast/subscription.dart';

part 'database.g.dart';

// @DriftDatabase(tables: [LocalAudiosTable, PlaylistTable])
@DriftDatabase(tables: [PlaylistTable, SubscriptionTable, DownloadTable])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnectionSync());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnectionSync() {
    // Call the synchronous method to get the database path
    final dbPath = getDatabasePath();
    return driftDatabase(
      name: 'audio_db',
      native: DriftNativeOptions(databaseDirectory: () async => dbPath),
    );
  }

  static Future<String> getDatabasePath() async {
    if (Platform.isLinux) {
      // Get the home directory for Linux
      final homeDir = Directory(Platform.environment['HOME']!);
      // Create the .config/app_name directory
      final configDir = Directory(
        p.join(homeDir.path, '.config', APP_CONFIG_FOLDER_LINUX),
      );
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      // Return the path for the database file
      return p.join(configDir.path);
    } else {
      // For other platforms, use the application documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      return documentsDir.path;
    }
  }
}
