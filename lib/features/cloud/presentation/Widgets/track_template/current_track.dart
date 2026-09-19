import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class CurrentTrack extends StatefulWidget {
  const CurrentTrack({super.key, required this.track});

  final CloudTrack track;

  @override
  State<CurrentTrack> createState() => _CurrentTrackState();
}

class _CurrentTrackState extends State<CurrentTrack> {
  final CloudPlayerRepositoryImp imp = CloudPlayerRepositoryImp();
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
            url: widget.track.artworkUrl?.toString(),
            fit: widget.track.artworkUrl?.toString() != null
                ? BoxFit.cover
                : BoxFit.scaleDown,
          ),
        ),
      ),
      title: Text(
        widget.track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.track.author,
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
        key: ValueKey(widget.track.title),
        isLoading: isLoading,
        isPlaying: isPlaying,
        onPressed: () async {
          imp.togglePlayState();
        },
      ),
    );
  }
}
