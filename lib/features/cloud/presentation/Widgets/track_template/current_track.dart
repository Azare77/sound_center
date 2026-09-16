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
  late bool isLoading = false;

  StreamSubscription<bool>? _loadingSub;

  void _updateStatus() async {
    await Future.delayed(Duration(milliseconds: 50));
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
    _loadingSub = imp.loadingStream.listen((loading) {
      isLoading = loading;
      _updateStatus();
    });
    super.initState();
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      _updateStatus();
    }
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
        isLoading: isLoading,
        isPlaying: imp.isPlaying(),
        onPressed: () async {
          imp.togglePlayState();
        },
      ),
    );
  }
}
