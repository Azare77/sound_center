import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';

class PodcastDownloader {
  static final FileDownloader _downloader = FileDownloader();

  static final StreamController<TaskUpdate> _updateController =
      StreamController<TaskUpdate>.broadcast();

  static Stream<TaskUpdate> get updates => _updateController.stream;

  static final Map<String, Episode> _downloads = {};

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

  static Future<void> pause(DownloadTask task) => _downloader.pause(task);

  static Future<bool> resume(DownloadTask task) => _downloader.resume(task);

  static Future<void> cancel(DownloadTask task) async {
    _downloader.cancel(task);
    _downloader.database.deleteRecordWithId(task.taskId);
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
