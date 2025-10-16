import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioTemplate extends StatefulWidget {
  const AudioTemplate({super.key, required this.audioEntity});

  final AudioEntity audioEntity;

  @override
  State<AudioTemplate> createState() => _AudioTemplateState();
}

class _AudioTemplateState extends State<AudioTemplate> {
  Uint8List? cover;

  @override
  void initState() {
    cover = widget.audioEntity.cover;
    if (cover == null) getCover();
    super.initState();
  }

  Future<void> getCover() async {
    cover = await AudioUtil().getCover(
      widget.audioEntity.id,
      coverSize: CoverSize.thumbnail,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double size = 50;
    return ListTile(
      leading: SizedBox(
        width: size,
        child: ClipOval(
          child: cover != null
              ? Image.memory(
                  cover!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (ctx, ob, s) {
                    if (widget.audioEntity.title.contains("Kami")) {
                      print(s);
                      print(cover!.lengthInBytes);
                    }
                    return SizedBox();
                  },
                )
              : SizedBox(
                  width: size,
                  height: size,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
        ),
      ),
      title: Text(widget.audioEntity.title, maxLines: 1),
      subtitle: Text(widget.audioEntity.artist),
      trailing: convertTime(widget.audioEntity.duration),
    );
  }

  Widget convertTime(int input) {
    final duration = Duration(milliseconds: input);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final timeStr = hours > 0
        ? "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";

    return Text(timeStr);
  }
}
