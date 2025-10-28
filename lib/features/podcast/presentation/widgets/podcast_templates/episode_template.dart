import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/util/date_util.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

class EpisodeTemplate extends StatelessWidget {
  const EpisodeTemplate({super.key, required this.episode});

  final Episode episode;

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final publishDate = episode.publicationDate != null
        ? toJalali(episode.publicationDate!)
        : '';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 10,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipOval(child: NetworkCacheImage(url: episode.imageUrl)),
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
                  style: TextStyle(fontSize: 16),
                ),
                if (publishDate.isNotEmpty)
                  Text(
                    publishDate,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
              ],
            ),
          ),
          Text(
            _formatDuration(episode.duration?.inMilliseconds ?? 0),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
