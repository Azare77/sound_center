import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/pages/play_audio.dart';

class CurrentAudio extends StatelessWidget {
  const CurrentAudio({super.key, required this.audioEntity});

  final AudioEntity audioEntity;

  @override
  Widget build(BuildContext context) {
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
          child: audioEntity.cover != null
              ? ClipOval(
                  child: Image.memory(
                    audioEntity.cover!,
                    width: 50,
                    height: 50,
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Icon(Icons.music_note, size: 20),
        ),
        title: Text(audioEntity.title, maxLines: 1),
        subtitle: Text(audioEntity.artist),
        trailing: IconButton(
          onPressed: () {
            LocalPlayerRepositoryImp().togglePlayState();
          },
          icon: Icon(
            LocalPlayerRepositoryImp().isPlaying()
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
