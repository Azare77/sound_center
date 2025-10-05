import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/pages/play_podcast.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentPodcast extends StatelessWidget {
  const CurrentPodcast({super.key, required this.episode});

  final Episode episode;

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
            builder: (_) => PlayPodcast(),
          );
        },
        leading: SizedBox(
          width: 50,
          child: ClipOval(child: NetworkCacheImage(url: episode.imageUrl)),
        ),
        title: Text(episode.title, maxLines: 1),
        subtitle: Text(episode.author ?? "Who Knows"),
        trailing: PlayPauseButton(
          isLoading: PodcastPlayerRepositoryImp().isLoading(),
          isPlaying: PodcastPlayerRepositoryImp().isPlaying(),
          onPressed: () async {
            PodcastPlayerRepositoryImp().togglePlayState();
          },
        ),
      ),
    );
  }
}
