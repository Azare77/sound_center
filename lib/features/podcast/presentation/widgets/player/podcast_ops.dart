import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/shared/widgets/handler.dart';
import 'package:sound_center/shared/widgets/speed_dialog.dart';

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
            showDialog(
              context: context,
              builder: (_) => SpeedDialog(imp: playerRepository),
            );
          },
          icon: Icon(Icons.speed_rounded),
        ),
        Handler(),
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
