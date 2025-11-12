import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/pages/play_audio.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentAudio extends StatefulWidget {
  const CurrentAudio({super.key, required this.audioEntity});

  final AudioEntity audioEntity;

  @override
  State<CurrentAudio> createState() => _CurrentAudioState();
}

class _CurrentAudioState extends State<CurrentAudio> {
  Uint8List? cover;
  late int audioId;
  final double size = 50;
  final LocalPlayerRepositoryImp imp = LocalPlayerRepositoryImp();

  @override
  void initState() {
    audioId = widget.audioEntity.id;
    cover = widget.audioEntity.cover;
    if (cover == null) getCover();
    super.initState();
  }

  void getCover() async {
    audioId = widget.audioEntity.id;
    cover = await AudioUtil.getCover(audioId, coverSize: CoverSize.thumbnail);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (audioId != widget.audioEntity.id) getCover();
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          requestFocus: true,
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          builder: (_) => PlayAudio(),
        );
      },
      leading: SizedBox(
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: cover != null
                ? MemoryImage(cover!)
                : const AssetImage('assets/logo.png') as ImageProvider,
            width: size,
            height: size,
            fit: cover != null ? BoxFit.cover : BoxFit.scaleDown,
            filterQuality: FilterQuality.high,
            errorBuilder: (ctx, error, stack) => Image.asset(
              'assets/logo.png',
              width: size,
              height: size,
              fit: BoxFit.scaleDown,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
      title: Text(
        widget.audioEntity.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.audioEntity.artist, maxLines: 1),
      trailing: PlayPauseButton(
        isPlaying: imp.isPlaying(),
        onPressed: () async {
          await imp.togglePlayState();
        },
      ),
    );
  }
}
