import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/background_image.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_header.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_navigation.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_ops.dart';
import 'package:sound_center/shared/extensions/player_top_margin.dart';

class PlayTrack extends StatelessWidget {
  const PlayTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Stack(
          children: [
            CloudBackgroundImage(),
            Container(
              margin: EdgeInsets.only(
                top: 10,
              ).addPlayerPadding(isLandscape: isLandscape),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    TrackOps(),
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
                            child: TrackHeader(),
                          ),
                          Expanded(
                            flex: isLandscape ? 4 : 2,
                            child: TrackNavigation(),
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
