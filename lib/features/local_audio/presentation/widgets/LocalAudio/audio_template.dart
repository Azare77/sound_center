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
    getCover();
    super.initState();
  }

  Future<void> getCover() async {
    cover = await AudioUtil().getCover(
      widget.audioEntity.audioId,
      coverSize: CoverSize.thumbnail,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int duration = ((widget.audioEntity.duration) / 1000).floor();
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    String secondsStr = seconds.toString().padLeft(2, '0');
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
      trailing: Text("$minutes:$secondsStr"),
    );
  }

  DateTime getFormattedDate(int? timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  }
}
