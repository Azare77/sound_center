import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/core/util/date_util.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/download_button.dart';

class EpisodeTemplate extends StatelessWidget {
  const EpisodeTemplate({
    super.key,
    required this.episode,
    this.isDownloaded = false,
  });

  final Episode episode;

  final bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    final publishDate = episode.publicationDate != null
        ? toJalali(episode.publicationDate!)
        : '';
    final TextStyle infoTextStyle = TextStyle(
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 10,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: NetworkCacheImage(
                url: episode.imageUrl,
                fit: episode.imageUrl != null ? BoxFit.cover : BoxFit.scaleDown,
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  spacing: 30,
                  children: [
                    if (publishDate.isNotEmpty)
                      Text(publishDate, maxLines: 1, style: infoTextStyle),
                    Text(
                      AudioUtil.convertTime(
                        episode.duration?.inMilliseconds ?? 0,
                      ),
                      style: infoTextStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isDownloaded) DownloadButton(episode: episode),
        ],
      ),
    );
  }
}
