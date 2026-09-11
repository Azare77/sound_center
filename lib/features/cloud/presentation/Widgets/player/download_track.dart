import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:background_downloader/background_downloader.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';

class DownloadTrack extends StatefulWidget {
  final CloudTrack track;

  const DownloadTrack({super.key, required this.track});

  @override
  State<DownloadTrack> createState() => _DownloadTrackState();
}

class _DownloadTrackState extends State<DownloadTrack> {
  DownloadTask? _task;
  double _progress = 0.0;
  bool _isRunning = false;
  StreamSubscription? _sub;
  late final FileDownloader downloader;
  late final CloudBloc bloc;
  final CloudPlayerRepositoryImp imp = CloudPlayerRepositoryImp();
  late final String fullPath;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<CloudBloc>(context);
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
    String key = widget.track.title.trim();
    key += "-${widget.track.author.trim()}";
    final records = await downloader.database.allRecords();
    final url = await imp.getTrackUrl(imp.getCurrentTrack!);
    final Directory baseDir = await getTemporaryDirectory();
    fullPath = '${baseDir.path}/Cloud/$key.mp3';
    final record = records.firstWhereOrNull(
      (r) => r.task is DownloadTask && (r.task as DownloadTask).url == url,
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
    final url = await imp
        .getTrackUrl(imp.getCurrentTrack!)
        .timeout(const Duration(seconds: 10));
    if (url == null) return;
    final task = await PodcastDownloader.downloadCloudTrack(widget.track, url);

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
        if (u is TaskProgressUpdate) _progress = clampDouble(u.progress, 0, 1);
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

  Icon get _icon {
    if (_task == null) return const Icon(Icons.download_rounded);
    if (_progress >= 1) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green);
    }
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
            print(_task);
            if (_task == null) {
              _start();
            } else if (_progress >= 1) {
              return;
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
