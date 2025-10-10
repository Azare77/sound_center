import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/description.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Description(
                        description: PodcastPlayerRepositoryImp()
                            .getCurrentEpisode!
                            .description,
                      ),
                    );
                  },
                  child: Text("Description"),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            Expanded(flex: 3, child: PodcastHeader()),
            Expanded(flex: 2, child: PodcastNavigation()),
          ],
        ),
      ),
    );
  }
}
