import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/util/date_util.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

class EpisodeTemplate extends StatelessWidget {
  const EpisodeTemplate({super.key, required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    String? publishDate = "";
    if (episode.publicationDate != null) {
      publishDate = toJalali(episode.publicationDate!);
    }
    String? artwork = episode.imageUrl;
    double size = 50;
    return ListTile(
      leading: SizedBox(
        width: size,
        child: ClipOval(child: NetworkCacheImage(url: artwork)),
      ),
      title: Text(episode.title, maxLines: 1),
      subtitle: Text(
        publishDate,
        maxLines: 1,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: convertTime(episode.duration?.inMilliseconds ?? 0),
    );
  }

  Widget convertTime(int input) {
    final duration = Duration(milliseconds: input);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final timeStr = hours > 0
        ? "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";

    return Text(timeStr);
  }
}
