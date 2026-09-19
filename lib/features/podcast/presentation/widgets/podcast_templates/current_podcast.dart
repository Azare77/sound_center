import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentPodcast extends StatefulWidget {
  const CurrentPodcast({super.key, required this.episode});

  final Episode episode;

  @override
  State<CurrentPodcast> createState() => _CurrentPodcastState();
}

class _CurrentPodcastState extends State<CurrentPodcast> {
  final PodcastPlayerRepositoryImp imp = PodcastPlayerRepositoryImp();
  bool isLoading = false;
  bool isPlaying = false;

  StreamSubscription<bool>? _loadingSub;
  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    isLoading = imp.isLoading();
    isPlaying = imp.isPlaying();
    _loadingSub = imp.loadingStream.listen((loading) {
      if (mounted && isLoading != loading) setState(() => isLoading = loading);
    });
    _playingSub = imp.playingStream.listen((playing) {
      if (mounted && isPlaying != playing) setState(() => isPlaying = playing);
    });
    super.initState();
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    _playingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
      trailing: PlayPauseButton(
        isLoading: isLoading,
        isPlaying: isPlaying,
        onPressed: () async {
          imp.togglePlayState();
        },
      ),
    );
  }
}
