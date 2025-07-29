import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/player_header.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/player_navigation.dart';

class PlayAudio extends StatelessWidget {
  const PlayAudio({super.key, required this.song});

  final AudioEntity song;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          spacing: 25,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [PlayerHeader(), PlayerNavigation()],
        ),
      ),
    );
  }
}
