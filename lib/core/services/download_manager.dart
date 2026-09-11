import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';

/// State یک دانلود کلاود که هیچ‌وقت از طریق `_downloader.enqueue()` وارد
/// موتور native نمی‌شه، پس نه در `downloader.database` رکورد داره و نه
/// pause/resume نیتیو پلاگین روش اثر داره. این کلاس جایگزین همون اطلاعاته.
class CloudDownloadState {
  final DownloadTask task;
  TaskStatus status;
  double progress;

  CloudDownloadState({
    required this.task,
    required this.status,
    required this.progress,
  });
}

/// کنترل‌کننده‌ی pause/resume واقعی برای دانلود دستی HLS. چون
/// `_downloader.pause/resume` فقط روی تسک‌های enqueue‌شده در موتور native
/// اثر داره، این کلاس همون رفتار رو در سطح اپلیکیشن پیاده می‌کنه: وقتی
/// pause بشه، ورکرهای در حال دانلود segment فعلی‌شون رو تموم می‌کنن ولی
/// segment بعدی رو شروع نمی‌کنن تا resume صدا زده بشه.
class _CloudPauseController {
  bool _paused = false;
  Completer<void>? _resumeCompleter;

  bool get isPaused => _paused;

  void pause() {
    if (_paused) return;
    _paused = true;
    _resumeCompleter = Completer<void>();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _resumeCompleter?.complete();
    _resumeCompleter = null;
  }

  Future<void> waitIfPaused() async {
    while (_paused) {
      await _resumeCompleter?.future;
    }
  }
}

class PodcastDownloader {
  static final FileDownloader _downloader = FileDownloader();

  static final StreamController<TaskUpdate> _updateController =
      StreamController<TaskUpdate>.broadcast();

  static Stream<TaskUpdate> get updates => _updateController.stream;

  static final Map<String, dynamic> _downloads = {};

  /// رجیستری در-حافظه‌ای state دانلودهای کلاود، کلید = "title-author".
  /// چون این تسک‌ها enqueue نمی‌شن، این تنها منبع صحتیه که ویجت‌ها
  /// می‌تونن هنگام باز شدن مجدد صفحه ازش پیشرفت فعلی رو بخونن.
  static final Map<String, CloudDownloadState> _cloudStates = {};
  static final Map<String, _CloudPauseController> _cloudPauseControllers = {};

  static CloudDownloadState? cloudStateForKey(String key) => _cloudStates[key];

  /// آیا تسک متعلق به گروه دانلود کلاود (دستی) هست یا خیر — برای اینکه
  /// UI بتونه تشخیص بده باید از `pauseCloudDownload`/`resumeCloudDownload`
  /// استفاده کنه یا از `pause`/`resume` عادی.
  static bool isCloudTask(DownloadTask task) => task.group == 'cloud';

  static void pauseCloudDownload(String key) {
    final state = _cloudStates[key];
    if (state == null) return;
    _cloudPauseControllers[key]?.pause();
    state.status = TaskStatus.paused;
    _updateController.add(TaskStatusUpdate(state.task, TaskStatus.paused));
  }

  static void resumeCloudDownload(String key) {
    final state = _cloudStates[key];
    if (state == null) return;
    _cloudPauseControllers[key]?.resume();
    state.status = TaskStatus.running;
    _updateController.add(TaskStatusUpdate(state.task, TaskStatus.running));
  }

  static Future<void> init() async {
    await _downloader.start();
    await _downloader.trackTasks();

    _downloader.updates.listen((u) {
      _updateController.add(u);
      if (u is TaskStatusUpdate) {
        final status = u;
        if (status.status == TaskStatus.canceled) {
          _downloader.database.deleteRecordWithId(u.task.taskId);
          return;
        }
      }
      onPodcastDownloadFinished(u);
    });
  }

  static void setupNotification() {
    String downloading = Intl.message("Downloading", name: "downloading");
    String downloadCompleted = Intl.message(
      "Download Completed",
      name: "downloadCompleted",
    );
    String downloadStopped = Intl.message(
      "Download Stopped",
      name: "downloadStopped",
    );
    String errorInDownload = Intl.message(
      "Error In Download",
      name: "errorInDownload",
    );
    _downloader.configureNotification(
      running: TaskNotification(downloading, '{filename}'),
      complete: TaskNotification(downloadCompleted, '{filename}'),
      paused: TaskNotification(downloadStopped, '{filename}'),
      error: TaskNotification(errorInDownload, '{filename}'),
      progressBar: true,
      tapOpensFile: true,
    );
  }

  static Future<DownloadTask?> downloadEpisode(Episode episode) async {
    final directory = await _ensureDirectory();
    String key = episode.title.trim();
    if (episode.author != null) {
      key += "-${episode.author?.trim()}";
    }
    _downloads['$key.mp3'] = episode;
    final task = DownloadTask(
      url: episode.contentUrl!,
      filename: episode.title,
      directory: directory,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 3,
      allowPause: true,
      group: 'podcasts',
      metaData: '$key.mp3',
    );
    final success = await _downloader.enqueue(task);
    return success ? task : null;
  }

  /// دانلود ترک ابری با فرمت m3u8 و انتقال آن به حافظه اشتراکی موسیقی.
  ///
  /// این تسک هیچ‌وقت با `_downloader.enqueue()` وارد موتور native نمی‌شه؛
  /// دانلود واقعی به‌صورت دستی توسط [HlsDownloader] انجام می‌شه. برای
  /// pause/resume واقعی از `pauseCloudDownload`/`resumeCloudDownload`
  /// استفاده کنید، نه از `pause`/`resume` (که فقط روی تسک‌های native
  /// enqueue‌شده کار می‌کنن).
  static Future<DownloadTask?> downloadCloudTrack(
    CloudTrack track,
    String m3u8Url,
  ) async {
    String key = track.title.trim();
    key += "-${track.author.trim()}";
    print("🚀 [PodcastDownloader] شروع متد و بازگشت فوری تسک");

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/Cloud/$key.mp3';
    await Directory('${tempDir.path}/Cloud').create(recursive: true);

    _downloads['$key.mp3'] = track;

    final task = DownloadTask(
      url: m3u8Url,
      filename: '$key.mp3',
      directory: 'Cloud',
      baseDirectory: BaseDirectory.temporary,
      group: 'cloud',
      metaData: '$key.mp3',
    );

    _cloudStates[key] = CloudDownloadState(
      task: task,
      status: TaskStatus.running,
      progress: 0.0,
    );
    _cloudPauseControllers[key] = _CloudPauseController();

    _runAsyncDownload(task, m3u8Url, tempPath, key);

    return task;
  }

  static void _runAsyncDownload(
    DownloadTask task,
    String m3u8Url,
    String tempPath,
    String key,
  ) async {
    _updateController.add(TaskStatusUpdate(task, TaskStatus.running));
    _cloudStates[key]?.status = TaskStatus.running;
    final pauseController = _cloudPauseControllers[key];

    try {
      print("⏳ [PodcastDownloader] شروع دانلود سگمنت‌ها به صورت آسنکرون...");
      final file = await HlsDownloader.downloadAndMux(
        m3u8Url: m3u8Url,
        outputPath: tempPath,
        waitIfPaused: pauseController?.waitIfPaused,
        onProgress: (progress) {
          print("📊 درصد پیشرفت ارسال شده به استریم: $progress");
          _cloudStates[key]?.progress = progress;
          _updateController.add(TaskProgressUpdate(task, progress));
        },
      );

      print("pass Download");
      if (!await file.exists()) {
        throw Exception("فایل صوتی به درستی دانلود یا ادغام نشده است.");
      }

      String? newFilePath;

      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final musicDir = await getApplicationDocumentsDirectory();
        final destDir = Directory('${musicDir.path}/soundCenter');
        await destDir.create(recursive: true);

        // 🔄 Find a unique filename on Desktop by auto-incrementing
        int counter = 1;
        String uniquePath = '${destDir.path}/$key.mp3';
        while (await File(uniquePath).exists()) {
          uniquePath = '${destDir.path}/$key ($counter).mp3';
          counter++;
        }

        final targetFile = File(uniquePath);
        await file.copy(targetFile.path);
        newFilePath = targetFile.path;
        print("💾 Unique file saved on Desktop: $newFilePath");
      } else {
        // 🔄 Prepare a unique local temporary file name before moving to Scoped Storage on Mobile
        int counter = 1;
        String uniqueTempPath = file.path;

        final fileDir = file.parent.path;
        while (await File(uniqueTempPath).exists() && counter > 1) {
          uniqueTempPath = '$fileDir/$key ($counter).mp3';
          counter++;
        }

        File fileToMove = file;
        if (counter > 1) {
          fileToMove = await file.rename(uniqueTempPath);
        }

        newFilePath = await _downloader.moveFileToSharedStorage(
          fileToMove.path,
          SharedStorage.audio,
          directory: 'soundCenter',
        );
      }

      print("newFilePath : $newFilePath");

      if (newFilePath != null) {
        _cloudStates[key]?.status = TaskStatus.complete;
        _cloudStates[key]?.progress = 1.0;
        _updateController.add(TaskStatusUpdate(task, TaskStatus.complete));
        _updateController.add(TaskProgressUpdate(task, 1.0));

        if (await file.exists()) {
          await file.delete();
        }
      } else {
        _cloudStates[key]?.status = TaskStatus.failed;
        _updateController.add(TaskStatusUpdate(task, TaskStatus.failed));
      }
      final bloc = BlocProvider.of<LocalBloc>(NAVIGATOR_KEY.currentContext!);
      bloc.add(GetLocalAudios());
      print("Finish");
    } catch (e) {
      print("❌ خطا در دانلود پس‌زمینه کلاود: $e");
      _cloudStates[key]?.status = TaskStatus.failed;
      _updateController.add(TaskStatusUpdate(task, TaskStatus.failed));
    } finally {
      _cloudPauseControllers.remove(key);
    }
  }

  static Future<String> _ensureDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final podcastDir = Directory('${dir.path}/Podcasts');
    if (!await podcastDir.exists()) {
      await podcastDir.create(recursive: true);
    }
    return 'Podcasts';
  }

  static Future<void> pause(DownloadTask task) => _downloader.pause(task);

  static Future<bool> resume(DownloadTask task) => _downloader.resume(task);

  static Future<void> cancel(DownloadTask task) async {
    _downloader.cancel(task);
    _downloader.database.deleteRecordWithId(task.taskId);

    if (isCloudTask(task)) {
      final key = _cloudStates.entries
          .where((e) => e.value.task.taskId == task.taskId)
          .map((e) => e.key)
          .firstOrNull;
      if (key != null) {
        _cloudPauseControllers.remove(key);
        _cloudStates.remove(key);
      }
    }
  }

  /// وقتی یک دانلود کلاود کامل شد و کاربر فایل رو مصرف کرد (یا هر زمان
  /// دیگه‌ای که لازم شد)، می‌تونید state رو از رجیستری پاک کنید تا حافظه
  /// بیخودی رشد نکنه. صدا زدنش اختیاریه.
  static void clearCloudState(String key) {
    _cloudStates.remove(key);
    _cloudPauseControllers.remove(key);
  }

  static void onPodcastDownloadFinished(TaskUpdate update) async {
    if (update is! TaskStatusUpdate) return;
    if (update.status != TaskStatus.complete) return null;
    final task = update.task;
    if (task is! DownloadTask) return null;
    final baseDirectory = await getApplicationDocumentsDirectory();
    final path = "${baseDirectory.path}/${task.directory}/${task.filename}";
    final file = File(path);
    if (!await file.exists()) return null;
    final title = task.metaData as String?;
    if (title == null || title.isEmpty) return null;
    final safeName = title;
    final newPath = '${file.parent.path}/$safeName';
    if (file.path != newPath) {
      await file.rename(newPath);
    }
    Episode? episode = _downloads[task.metaData];
    BuildContext? context = NAVIGATOR_KEY.currentContext;

    if (episode != null && context != null) {
      final bloc = BlocProvider.of<PodcastBloc>(NAVIGATOR_KEY.currentContext!);
      final downloadEntity = DownloadedEpisodeEntity.fromEpisode(
        _downloads[task.metaData]!,
      );
      bloc.add(DownloadEpisode(downloadEntity));
      _downloads.remove(task.metaData);
    }
  }
}

class HlsDownloader {
  /// دانلود کامل یک استریم HLS با متد دانلود موازی برای افزایش سرعت چشمگیر.
  ///
  /// [waitIfPaused] در ابتدای هر iteration ورکر await می‌شه؛ اگه pause شده
  /// باشه، ورکر همون‌جا معلق می‌مونه تا resume صدا زده بشه، بدون این‌که
  /// segmentهایی که تا اون لحظه دانلود شدن از دست برن.
  static Future<File> downloadAndMux({
    required String m3u8Url,
    required String outputPath,
    required Function(double) onProgress,
    Future<void> Function()? waitIfPaused,
  }) async {
    print('🌐 [HlsDownloader] دریافت مانیفست m3u8...');
    final playlistResp = await http.get(Uri.parse(m3u8Url));
    if (playlistResp.statusCode != 200) {
      throw Exception('دریافت پلی‌لیست ناموفق بود: ${playlistResp.statusCode}');
    }
    final lines = const LineSplitter().convert(playlistResp.body);

    String? initUrl;
    final segmentUrls = <String>[];

    for (final line in lines) {
      if (line.startsWith('#EXT-X-MAP:URI=')) {
        final match = RegExp(r'URI="([^"]+)"').firstMatch(line);
        if (match != null) initUrl = match.group(1);
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        segmentUrls.add(line);
      }
    }

    if (initUrl == null || segmentUrls.isEmpty) {
      throw Exception('پلی‌لیست معتبر نیست یا سگمنتی پیدا نشد');
    }

    print(
      '📦 [HlsDownloader] تعداد کل سگمنت‌ها: ${segmentUrls.length}. شروع دانلود موازی...',
    );

    // ۱) دانلود فورا و مستقیم Init Segment
    final initBytes = await _fetchBytes(initUrl);
    onProgress(0.05);

    // ۲) تعریف آرایه برای نگهداری سگمنت‌های دانلود شده با حفظ ترتیب دیسک
    final downloadedSegments = List<List<int>?>.filled(
      segmentUrls.length,
      null,
    );
    int completedCount = 0;

    // ۳) تنظیم میزان همزمانی (مثلا دانلود همزمان 8 سگمنت با هم)
    const int maxConcurrentDownloads = 8;
    int currentTaskIndex = 0;

    // تابع کمکی برای مدیریت صف موازی
    Future<void> worker() async {
      while (currentTaskIndex < segmentUrls.length) {
        // اگه pause شده، همین‌جا معلق می‌مونه تا resume بشه؛ segment بعدی
        // رو شروع نمی‌کنه ولی segmentهای در حال دانلود فعلی رو کنسل نمی‌کنه.
        await waitIfPaused?.call();

        final index = currentTaskIndex++;
        final url = segmentUrls[index];

        try {
          final bytes = await _fetchBytes(url);
          downloadedSegments[index] = bytes;
          completedCount++;

          // آپدیت درصد پیشرفت به صورت زنده
          double progressRatio =
              0.05 + (completedCount / segmentUrls.length) * 0.95;
          onProgress(progressRatio);
        } catch (e) {
          print('❌ خطا در دانلود سگمنت شماره $index: $e');
          rethrow;
        }
      }
    }

    // شروع کار ورکرها به صورت همزمان
    final workers = List.generate(maxConcurrentDownloads, (_) => worker());

    // انتظار برای اتمام دانلود تمام سگمنت‌ها
    await Future.wait(workers);

    // ۴) نوشتن همگی در فایل خروجی به ترتیب کاملا درست مانیفست
    print(
      '💾 [HlsDownloader] تمام پارت‌ها دانلود شدند. در حال سرهم‌بندی (Mux) روی دیسک...',
    );
    final outFile = File(outputPath);
    final sink = outFile.openWrite();

    try {
      sink.add(initBytes); // اول ftyp+moov
      for (final segmentBytes in downloadedSegments) {
        if (segmentBytes != null) {
          sink.add(segmentBytes);
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
      print('✨ [HlsDownloader] فایل نهایی با موفقیت ساخته شد.');
    }

    return outFile;
  }

  static Future<List<int>> _fetchBytes(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('دانلود سگمنت ناموفق: (${resp.statusCode})');
    }
    return resp.bodyBytes;
  }
}
