import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/background_image.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/player_header.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/player_navigation.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/player_ops.dart';
import 'package:sound_center/shared/widgets/player/player_page.dart';

class PlayAudio extends StatelessWidget {
  const PlayAudio({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayerPage(
      backgroundImage: LocalBackgroundImage(),
      playerOps: PlayerOps(),
      header: PlayerHeader(),
      navigation: PlayerNavigation(),
      playerRepository: LocalPlayerRepositoryImp(),
    );
  }
}
