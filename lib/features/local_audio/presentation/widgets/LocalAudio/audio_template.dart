import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioTemplate extends StatelessWidget {
  const AudioTemplate({super.key, required this.audioEntity});

  final AudioEntity audioEntity;

  @override
  Widget build(BuildContext context) {
    int duration = ((audioEntity.duration) / 1000).floor();
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    String secondsStr = seconds.toString().padLeft(2, '0');
    double size = 50;
    return ListTile(
      leading: SizedBox(
        width: size,
        child: ClipOval(
          child: audioEntity.cover != null
              ? Image.memory(
                  audioEntity.cover!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (ctx, ob, s) {
                    return SizedBox();
                  },
                )
              : Container(
                  color: Colors.red,
                  width: size,
                  height: size,
                  child: Icon(Icons.music_note, size: 20),
                ),
        ),
      ),
      title: Text(audioEntity.title, maxLines: 1),
      subtitle: Text(audioEntity.artist),
      trailing: Text("$minutes:$secondsStr"),
    );
  }

  DateTime getFormattedDate(int? timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  }
}
