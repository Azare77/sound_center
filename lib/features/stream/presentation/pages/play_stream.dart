import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/background_image.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_header.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_navigation.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_ops.dart';
import 'package:sound_center/shared/widgets/player/player_page.dart';

class PlayStream extends StatelessWidget {
  const PlayStream({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayerPage(
      backgroundImage: StreamBackgroundImage(),
      playerOps: StreamOps(),
      header: StreamHeader(),
      navigation: StreamNavigation(),
      playerRepository: StreamPlayerRepositoryImp(),
    );
  }
}
