import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';

class DownloadButton extends StatefulWidget {
  final Episode episode;

  const DownloadButton({super.key, required this.episode});

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  DownloadTask? _task;
  double _progress = 0.0;
  bool _isRunning = false;
  StreamSubscription? _sub;
  late final FileDownloader downloader;

  @override
  void initState() {
    super.initState();
    downloader = FileDownloader();
    _loadTask();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  Future<void> _loadTask() async {
    final List<TaskRecord> records = await downloader.database.allRecords();

    final record = records.firstWhereOrNull(
      (r) =>
          r.task is DownloadTask &&
          (r.task as DownloadTask).url == widget.episode.contentUrl &&
          (r.task as DownloadTask).filename == '${widget.episode.title}.mp3',
    );

    if (record != null) {
      final DownloadTask task = record.task as DownloadTask;
      final Directory baseDir = await getApplicationDocumentsDirectory();

      // مسیر نهایی فایل
      final String fullPath =
          '${baseDir.path}/${task.directory}/${task.filename}';

      // 🔍 چک وجود فایل روی دیسک
      final bool exists = await File(fullPath).exists();

      if (!exists && record.progress >= 1) {
        // 🚮 حذف رکورد از دیتابیس چون فایل وجود ندارد
        await downloader.database.deleteRecordsWithIds([task.taskId]);
        debugPrint("🧹 ${task.filename} ** $fullPath");
        return;
      }

      // ✅ در غیر این صورت، رکورد معتبر است → مقداردهی کن
      _task = task;
      _progress = record.progress;
      _isRunning = record.status == TaskStatus.running;
      _listen();
      if (mounted) setState(() {});
    }
  }

  /// شروع دانلود جدید
  Future<void> _start() async {
    final task = await PodcastDownloader.downloadEpisode(
      widget.episode.contentUrl!,
      widget.episode.title,
    );

    if (task != null) {
      _task = task;
      _isRunning = true;
      _listen();
      if (mounted) setState(() {});
    }
  }

  /// گوش دادن به آپدیت‌های دانلود
  void _listen() {
    _sub?.cancel();
    _sub = PodcastDownloader.updates.listen((u) {
      if (u.task.taskId != _task?.taskId) return;
      if (!mounted) return; // ✅ جلوگیری از setState بعد از dispose

      setState(() {
        // if (u is TaskProgressUpdate) _progress = u.progress;
        if (u is TaskProgressUpdate && u.progress > _progress) {
          _progress = u.progress;
        }
        if (u is TaskStatusUpdate) {
          _isRunning = u.status == TaskStatus.running;
          if (u.status == TaskStatus.complete) {
            _progress = 1.0;
            final DownloadedEpisodeEntity downloadEntity =
                DownloadedEpisodeEntity.fromEpisode(widget.episode);
            final DownloadEpisode event = DownloadEpisode(downloadEntity);
            BlocProvider.of<PodcastBloc>(context).add(event);
          }
        }
      });
    });
  }

  /// تغییر وضعیت بین pause و resume
  void _toggle() async {
    if (_isRunning) {
      PodcastDownloader.pause(_task!);
    } else {
      bool res = await PodcastDownloader.resume(_task!);
      if (!res) {
        await downloader.database.deleteRecordsWithIds([_task!.taskId]);
        _start();
      }
    }
  }

  /// انتخاب آیکن مناسب با وضعیت دانلود
  Icon get _icon {
    if (_task == null) return const Icon(Icons.arrow_downward_rounded);
    if (_progress >= 1) return const Icon(Icons.check, color: Colors.green);
    return Icon(_isRunning ? Icons.pause : Icons.play_arrow);
  }

  @override
  Widget build(BuildContext context) {
    if (_progress >= 1) return SizedBox.shrink();
    return Stack(
      alignment: Alignment.center,
      children: [
        // دایره progress
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: _progress, // 0.0 تا 1.0
            strokeWidth: 2,
            color: Colors.amber, // رنگ دلخواه
            backgroundColor: Colors.grey.shade300, // رنگ پس‌زمینه
          ),
        ),

        // دکمه دانلود / ادامه / توقف
        IconButton(
          iconSize: 20,
          onPressed: _task == null ? _start : _toggle,
          icon: _icon,
        ),
      ],
    );
  }
}
