import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';

class PodcastDownloader {
  static final FileDownloader _downloader = FileDownloader();

  // یک StreamController مرکزی برای انتشار آپدیت‌ها
  static final StreamController<TaskUpdate> _updateController =
      StreamController<TaskUpdate>.broadcast();

  /// استریم عمومی برای گوش دادن در ویجت‌ها
  static Stream<TaskUpdate> get updates => _updateController.stream;

  /// مقداردهی اولیهٔ دانلودر
  static Future<void> init() async {
    await _downloader.start();
    await _downloader.trackTasks();

    // فقط یک بار به stream اصلی پکیج گوش بده
    _downloader.updates.listen((u) {
      _updateController.add(u);
    });

    _downloader.configureNotification(
      running: const TaskNotification('در حال دانلود', 'فایل: {filename}'),
      complete: const TaskNotification('دانلود کامل شد', 'فایل: {filename}'),
      paused: const TaskNotification('متوقف شد', 'فایل: {filename}'),
      error: const TaskNotification('خطا', 'فایل: {filename}'),
      progressBar: true,
      tapOpensFile: true,
    );
  }

  /// شروع دانلود اپیزود جدید
  static Future<DownloadTask?> downloadEpisode(String url, String title) async {
    final directory = await _ensureDirectory();

    final task = DownloadTask(
      url: url,
      filename: '$title.mp3',
      directory: directory,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 3,
      allowPause: true,
      group: 'podcasts',
    );

    final success = await _downloader.enqueue(task);
    return success ? task : null;
  }

  /// اطمینان از ساخت مسیر ذخیره‌سازی Podcasts
  static Future<String> _ensureDirectory() async {
    final dir = await getDownloadsDirectory();
    if (dir != null) {
      final podcastDir = Directory('${dir.path}/Podcasts');
      if (!await podcastDir.exists()) {
        await podcastDir.create(recursive: true);
      }
      return 'Podcasts';
    }
    return 'Podcasts';
  }

  /// متدهای کنترلی
  static Future<void> pause(DownloadTask task) => _downloader.pause(task);

  static Future<bool> resume(DownloadTask task) => _downloader.resume(task);

  static Future<void> cancel(DownloadTask task) => _downloader.cancel(task);
}
