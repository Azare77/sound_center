import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/speed_dialog.dart';

class TrackOps extends StatelessWidget {
  const TrackOps({super.key});

  @override
  Widget build(BuildContext context) {
    final playerRepository = CloudPlayerRepositoryImp();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            showDialog(context: context, builder: (_) => SpeedDialog());
          },
          icon: Icon(Icons.speed_rounded),
        ),
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
        IconButton(onPressed: () async {}, icon: Icon(Icons.share_rounded)),
      ],
    );
  }
}
