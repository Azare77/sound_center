import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/download_track.dart';

class TrackOps extends StatelessWidget {
  const TrackOps({super.key});

  @override
  Widget build(BuildContext context) {
    final playerRepository = CloudPlayerRepositoryImp();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DownloadTrack(track: playerRepository.getCurrentTrack!),
        SizedBox(
          width: 40,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            final track = playerRepository.getCurrentTrack!;
            await SharePlus.instance.share(ShareParams(uri: track.shareLink));
          },
          icon: Icon(Icons.share_rounded),
        ),
      ],
    );
  }
}
