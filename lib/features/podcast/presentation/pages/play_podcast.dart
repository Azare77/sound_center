import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/background_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/header.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/podcast_navigation.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/podcast_ops.dart';
import 'package:sound_center/shared/widgets/player/player_page.dart';

class PlayPodcast extends StatelessWidget {
  const PlayPodcast({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayerPage(
      backgroundImage: PodcastBackgroundImage(),
      playerOps: PodcastOps(),
      header: PodcastHeader(),
      navigation: PodcastNavigation(),
      playerRepository: PodcastPlayerRepositoryImp(),
    );
  }
}
