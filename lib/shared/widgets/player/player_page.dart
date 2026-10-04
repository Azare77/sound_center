import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/extensions/player_top_margin.dart';
import 'package:sound_center/shared/widgets/player/play_queue.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({
    super.key,
    required this.backgroundImage,
    required this.playerOps,
    required this.header,
    required this.navigation,
    this.playerRepository,
  });

  final Widget backgroundImage;
  final Widget playerOps;
  final Widget header;
  final Widget navigation;
  final PlayerRepository? playerRepository;

  @override
  Widget build(BuildContext context) {
    int headerFlex = 4;
    int navigationFlex = 2;
    if (playerRepository is LocalPlayerRepositoryImp) {
      headerFlex = 7;
      navigationFlex = 5;
    }
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Stack(
          alignment: Alignment.center,
          children: [
            backgroundImage,
            Container(
              margin: EdgeInsets.only(
                top: 10,
              ).addPlayerPadding(isLandscape: isLandscape),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    playerOps,
                    Expanded(
                      child: Flex(
                        direction: isLandscape
                            ? Axis.horizontal
                            : Axis.vertical,
                        spacing: 25,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: isLandscape ? 3 : headerFlex,
                            child: header,
                          ),
                          Expanded(
                            flex: isLandscape ? 4 : navigationFlex,
                            child: navigation,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (playerRepository != null)
              Positioned(bottom: 10, child: PlayQueue(imp: playerRepository!)),
          ],
        );
      },
    );
  }
}
