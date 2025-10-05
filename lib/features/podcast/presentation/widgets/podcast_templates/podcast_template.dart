import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/shared/widgets/loading.dart';

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
        child: ClipOval(
          child: artwork != null
              ? FastCachedImage(
                  url: artwork,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (ctx, ob, s) {
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    );
                  },
                  loadingBuilder: (context, progress) {
                    return Loading();
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
      title: Text(podcast.trackName ?? '', maxLines: 1),
      subtitle: Text(podcast.artistName ?? ''),
    );
  }

  DateTime getFormattedDate(int? timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  }
}
