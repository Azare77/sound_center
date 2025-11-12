import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/pages/play_podcast.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentPodcast extends StatefulWidget {
  const CurrentPodcast({super.key, required this.episode});

  final Episode episode;

  @override
  State<CurrentPodcast> createState() => _CurrentPodcastState();
}

class _CurrentPodcastState extends State<CurrentPodcast> {
  final PodcastPlayerRepositoryImp imp = PodcastPlayerRepositoryImp();
  late bool isLoading;

  void _updateStatus() async {
    await Future.delayed(Duration(milliseconds: 200));
    isLoading = imp.isLoading();
    if (isLoading) {
      _updateStatus();
      return;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    isLoading = imp.isLoading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      _updateStatus();
    }
    return ListTile(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkCacheImage(
            url: widget.episode.imageUrl,
            fit: widget.episode.imageUrl != null
                ? BoxFit.cover
                : BoxFit.scaleDown,
          ),
        ),
      ),
      title: Text(
        widget.episode.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.episode.author ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PlayPauseButton(
        isLoading: isLoading,
        isPlaying: imp.isPlaying(),
        onPressed: () async {
          imp.togglePlayState();
        },
      ),
    );
  }
}
