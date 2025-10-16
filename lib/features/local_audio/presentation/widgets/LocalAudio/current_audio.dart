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

  @override
  void initState() {
    audioId = widget.audioEntity.id;
    cover = widget.audioEntity.cover;
    if (cover == null) getCover();
    super.initState();
  }

  void getCover() async {
    audioId = widget.audioEntity.id;
    cover = await AudioUtil().getCover(audioId, coverSize: CoverSize.thumbnail);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (audioId != widget.audioEntity.id) getCover();
    final borderRadios = Radius.circular(20);
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xFF25212D),
        borderRadius: BorderRadius.only(
          topLeft: borderRadios,
          topRight: borderRadios,
        ),
      ),
      padding: EdgeInsetsGeometry.only(bottom: 20),
      child: ListTile(
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
          child: ClipOval(
            child: Image(
              image: cover != null
                  ? MemoryImage(cover!)
                  : const AssetImage('assets/logo.png') as ImageProvider,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (ctx, error, stack) => Image.asset(
                'assets/logo.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        title: Text(widget.audioEntity.title, maxLines: 1),
        subtitle: Text(widget.audioEntity.artist, maxLines: 1),
        trailing: PlayPauseButton(
          isPlaying: LocalPlayerRepositoryImp().isPlaying(),
          onPressed: () async {
            await LocalPlayerRepositoryImp().togglePlayState();
          },
        ),
      ),
    );
  }
}
