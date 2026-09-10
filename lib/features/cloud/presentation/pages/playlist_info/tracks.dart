import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/cloud_item_template.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class Tracks extends StatefulWidget {
  const Tracks({super.key, required this.tracks, this.bestImageUrl});

  final List<CloudTrack> tracks;
  final String? bestImageUrl;

  @override
  State<Tracks> createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final CloudPlayerRepositoryImp imp = CloudPlayerRepositoryImp();
  CloudTrack? currentTrack;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudBloc>(context).stream.listen((state) {
      if (currentTrack?.id != imp.getCurrentTrack?.id && mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    currentTrack = imp.getCurrentTrack;
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        CloudTrack track = widget.tracks[index];
        final isCurrent = currentTrack?.id == track.id;
        return Container(
          key: ValueKey(track.id),
          height: LIST_ITEM_HEIGHT,
          color: isCurrent ? Color(0x1D1BF1D8) : Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {});
              BlocProvider.of<CloudBloc>(
                context,
              ).add(PlayTrack(tracks: widget.tracks, index: index));
            },
            child: CloudItemTemplate(item: track),
          ),
        );
      }, childCount: widget.tracks.length),
    );
  }
}
