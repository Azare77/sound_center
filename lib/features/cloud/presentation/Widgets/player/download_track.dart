import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:background_downloader/background_downloader.dart';
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
  late final String _key;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<CloudBloc>(context);
    downloader = FileDownloader();
    _key = "${widget.track.title.trim()}-${widget.track.author.trim()}";
    _loadTask();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  /// دانلودهای کلاود هیچ‌وقت با `_downloader.enqueue()` وارد موتور native
  /// نمی‌شن (نگاه کنید به `PodcastDownloader.downloadCloudTrack`)، پس هیچ
  /// رکوردی در `downloader.database` براشون وجود نداره. منبع صحت واقعی
  /// همون رجیستری در-حافظه‌ای `PodcastDownloader.cloudStateForKey` هست که
  /// در طول عمر اپ زنده می‌مونه و با باز/بسته شدن این ویجت پاک نمی‌شه.
  Future<void> _loadTask() async {
    final Directory baseDir = await getTemporaryDirectory();
    fullPath = '${baseDir.path}/Cloud/$_key.mp3';

    final cloudState = PodcastDownloader.cloudStateForKey(_key);
    if (cloudState != null) {
      _task = cloudState.task;
      _progress = cloudState.progress;
      _isRunning = cloudState.status == TaskStatus.running;
      _listen();
      if (mounted) setState(() {});
      return;
    }

    // اگه دانلودی در حال اجرا در حافظه نیست، فقط بررسی کن که فایل نهایی
    // قبلاً کامل دانلود شده یا نه (مثلاً بعد از kill کامل اپ).
    final bool exists = await File(fullPath).exists();
    if (exists) {
      _task = null;
      _progress = 1.0;
      _isRunning = false;
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

  /// دانلود کلاود (گروه 'cloud') هیچ‌وقت enqueue نشده، پس pause/resume نیتیو
  /// (`PodcastDownloader.pause`/`resume`) روش اثر نداره و همیشه resume را
  /// fail می‌کنه و از صفر دوباره شروع می‌شه. برای این گروه باید از
  /// `pauseCloudDownload`/`resumeCloudDownload` استفاده کرد که واقعاً روی
  /// حلقه‌ی دانلود دستی HLS اثر می‌ذاره و segmentهای دانلودشده رو حفظ می‌کنه.
  void _toggle() async {
    final isCloud = PodcastDownloader.isCloudTask(_task!);

    if (isCloud) {
      if (_isRunning) {
        PodcastDownloader.pauseCloudDownload(_key);
      } else {
        PodcastDownloader.resumeCloudDownload(_key);
      }
      return;
    }

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
