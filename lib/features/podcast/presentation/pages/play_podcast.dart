import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/background_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/header.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/podcast_navigation.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/podcast_ops.dart';
import 'package:sound_center/shared/extensions/player_top_margin.dart';

class PlayPodcast extends StatelessWidget {
  const PlayPodcast({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Stack(
          children: [
            PodcastBackgroundImage(),
            Container(
              margin: EdgeInsets.only(
                top: 10,
              ).addPlayerPadding(isLandscape: isLandscape),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    PodcastOps(),
                    Expanded(
                      child: Flex(
                        direction: isLandscape
                            ? Axis.horizontal
                            : Axis.vertical,
                        spacing: 25,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: isLandscape ? 3 : 4,
                            child: PodcastHeader(),
                          ),
                          Expanded(
                            flex: isLandscape ? 4 : 2,
                            child: PodcastNavigation(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
