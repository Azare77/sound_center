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
  final double size = 50;

  @override
  void initState() {
    super.initState();
    cover = widget.audioEntity.cover;
    if (cover == null) getCover();
  }

  Future<void> getCover() async {
    cover = await AudioUtil.getCover(
      widget.audioEntity.id,
      coverSize: CoverSize.thumbnail,
    );
    if (!mounted) return;
    if (mounted && cover != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: size,
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
      trailing: Text(AudioUtil.convertTime(widget.audioEntity.duration)),
    );
  }
}
