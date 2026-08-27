import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/speed_dialog.dart';

class PodcastOps extends StatelessWidget {
  const PodcastOps({super.key});

  @override
  Widget build(BuildContext context) {
    final playerRepository = PodcastPlayerRepositoryImp();
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
        IconButton(
          onPressed: () async {
            final params = {
              'podcast': playerRepository.feedUrl,
              'guid': playerRepository.getCurrentEpisode!.guid,
            };
            final uri = Uri(
              scheme: 'https',
              host: 'azare77.github.io',
              path: '/podcast',
              queryParameters: params,
            );
            await SharePlus.instance.share(ShareParams(uri: uri));
          },
          icon: Icon(Icons.share_rounded),
        ),
      ],
    );
  }
}
