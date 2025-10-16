import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

class PodcastTemplate extends StatelessWidget {
  const PodcastTemplate({super.key, required this.podcast});

  final Item podcast;

  String? getArtwork() {
    if (podcast.bestArtworkUrl != null) {
      return podcast.bestArtworkUrl;
    } else if (podcast.artworkUrl600 != null) {
      return podcast.artworkUrl600;
    } else if (podcast.artworkUrl100 != null) {
      return podcast.artworkUrl100;
    } else if (podcast.artworkUrl60 != null) {
      return podcast.artworkUrl60;
    } else if (podcast.artworkUrl30 != null) {
      return podcast.artworkUrl30;
    } else if (podcast.artworkUrl != null) {
      return podcast.artworkUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String? artwork = getArtwork();
    double size = 50;
    return ListTile(
      leading: SizedBox(
        width: size,
        child: ClipOval(child: NetworkCacheImage(url: artwork)),
      ),
      title: Text(podcast.trackName ?? '', maxLines: 1),
      subtitle: Text(podcast.artistName ?? '', maxLines: 1),
    );
  }
}
