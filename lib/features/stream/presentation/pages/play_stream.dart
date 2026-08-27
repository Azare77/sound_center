import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_header.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_navigation.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_ops.dart';

class PlayStream extends StatelessWidget {
  const PlayStream({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Container(
          margin: EdgeInsets.only(top: 10, bottom: isLandscape ? 5 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                StreamOps(),
                Expanded(
                  child: Flex(
                    direction: isLandscape ? Axis.horizontal : Axis.vertical,
                    spacing: 25,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isLandscape ? 3 : 4,
                        child: StreamHeader(),
                      ),
                      Expanded(
                        flex: isLandscape ? 4 : 2,
                        child: StreamNavigation(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
