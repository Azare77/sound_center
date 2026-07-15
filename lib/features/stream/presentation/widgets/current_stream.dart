import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentStream extends StatefulWidget {
  const CurrentStream({super.key, required this.streamEntity});

  final dynamic streamEntity;

  @override
  State<CurrentStream> createState() => _CurrentAudioState();
}

class _CurrentAudioState extends State<CurrentStream> {
  final StreamPlayerRepositoryImp imp = StreamPlayerRepositoryImp();
  late bool isLoading;
  late String title;
  String? artist;
  Uint8List? cover;
  String? coverUrl;
  final double size = 50;

  void _updateStatus() async {
    await Future.delayed(Duration(milliseconds: 200));
    isLoading = imp.isLoading();
    if (isLoading) {
      _updateStatus();
      return;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    isLoading = imp.isLoading();
    final currentStream = imp.getCurrentStream;
    if (currentStream is AudioModel) {
      title = currentStream.title;
      if (title.isEmpty) title = 'Loading';
      artist = currentStream.artist;
      cover = currentStream.cover;
    } else if (currentStream is Source) {
      title = currentStream.title ?? 'Loading';
      coverUrl = currentStream.cover;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      _updateStatus();
    }
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: coverUrl != null
              ? NetworkCacheImage(url: coverUrl)
              : Image(
                  image: cover != null
                      ? MemoryImage(cover!)
                      : const AssetImage('assets/default-cover.png')
                            as ImageProvider,
                  width: size,
                  height: size,
                  fit: cover != null ? BoxFit.cover : BoxFit.scaleDown,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (ctx, error, stack) => Image.asset(
                    'assets/default-cover.png',
                    width: size,
                    height: size,
                    fit: BoxFit.scaleDown,
                    filterQuality: FilterQuality.high,
                  ),
                ),
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        artist ?? '',
        maxLines: 1,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
      trailing: PlayPauseButton(
        isLoading: isLoading,
        isPlaying: imp.isPlaying(),
        onPressed: () async {
          imp.togglePlayState();
        },
      ),
    );
  }
}
