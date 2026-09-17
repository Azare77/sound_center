import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
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
  StreamSubscription<CloudTrack?>? _trackSub;

  void _updateStatus(bool loading) async {
    if (mounted && isLoading != loading) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  @override
  void initState() {
    isLoading = imp.isLoading();
    _loadingSub = imp.loadingStream.listen((loading) {
      _updateStatus(loading);
    });
    super.initState();
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    _trackSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudBloc, CloudState>(
      builder: (BuildContext context, CloudState state) {
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
            isPlaying: imp.isPlaying(),
            onPressed: () async {
              imp.togglePlayState();
            },
          ),
        );
      },
    );
  }
}
