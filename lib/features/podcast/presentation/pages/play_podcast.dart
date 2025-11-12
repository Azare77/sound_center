import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/header.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/podcast_navigation.dart';

class PlayPodcast extends StatelessWidget {
  const PlayPodcast({super.key});

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
          children: [
            Expanded(flex: 4, child: PodcastHeader()),
            Expanded(flex: 2, child: PodcastNavigation()),
          ],
        ),
      ),
    );
  }
}
