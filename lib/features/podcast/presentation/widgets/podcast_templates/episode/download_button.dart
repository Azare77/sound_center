import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

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
  late final PodcastBloc bloc;

  late final String fullPath;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<PodcastBloc>(context);
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
    final records = await downloader.database.allRecords();
    final Directory baseDir = await getApplicationDocumentsDirectory();
    fullPath = '${baseDir.path}/Podcasts/${widget.episode.title}.mp3';
    final record = records.firstWhereOrNull(
      (r) =>
          r.task is DownloadTask &&
          (r.task as DownloadTask).url == widget.episode.contentUrl,
    );

    if (record != null) {
      final DownloadTask task = record.task as DownloadTask;
      final bool exists = await File(fullPath).exists();
      if (!exists && record.progress == 1) {
        await downloader.database.deleteRecordWithId(task.taskId);
        _task = null;
        _progress = 0.0;
        _isRunning = false;
        if (mounted) setState(() {});
        return;
      }

      _task = task;
      _progress = record.progress;
      _isRunning = record.status == TaskStatus.running;
      _listen();
      if (mounted) setState(() {});
    }
  }

  Future<void> _start() async {
    final task = await PodcastDownloader.downloadEpisode(widget.episode);

    if (task != null) {
      _task = task;
      _isRunning = true;
      _listen();
      if (mounted) setState(() {});
    }
  }

  void _listen() {
    _sub?.cancel();
    _sub = PodcastDownloader.updates.listen((u) {
      if (u.task.taskId != _task?.taskId) return;
      if (!mounted) return;

      setState(() {
        if (u is TaskProgressUpdate) _progress = max(u.progress, _progress);
        if (u is TaskStatusUpdate) {
          _isRunning = u.status == TaskStatus.running;
          _progress = u.status == TaskStatus.complete ? 1.0 : _progress;
        }
      });
    });
  }

  bool _retrying = false;

  void _toggle() async {
    if (_isRunning) {
      PodcastDownloader.pause(_task!);
    } else {
      if (_retrying) return;

      bool res = await PodcastDownloader.resume(_task!);
      if (!res) {
        _retrying = true;
        await downloader.database.deleteRecordWithId(_task!.taskId);
        await _start();
        _retrying = false;
      }
    }
  }

  Future<void> _delete() async {
    bool confirmed =
        await showDialog(context: context, builder: (_) => ConfirmDialog()) ??
        false;
    if (!confirmed) return;
    final file = File(fullPath);
    if (await file.exists()) await file.delete();
    bloc.add(DeleteDownloadedEpisode(widget.episode.guid));
    if (_task != null) {
      await downloader.database.deleteRecordWithId(_task!.taskId);
    }
    _task = null;
    _progress = 0.0;
    _isRunning = false;
    if (mounted) setState(() {});
  }

  Icon get _icon {
    if (_task == null) return const Icon(Icons.download_rounded);
    if (_progress >= 1) return const Icon(Icons.delete_rounded);
    return Icon(_isRunning ? Icons.pause : Icons.play_arrow);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_progress != 1.0)
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(value: _progress, strokeWidth: 2),
          ),
        IconButton(
          iconSize: 20,
          onPressed: () {
            if (_task == null) {
              _start();
            } else if (_progress >= 1) {
              _delete();
            } else {
              _toggle();
            }
          },
          icon: _icon,
        ),
      ],
    );
  }
}
