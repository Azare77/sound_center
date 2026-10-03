import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/background_image.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_header.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_navigation.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/track_ops.dart';
import 'package:sound_center/shared/widgets/player/player_page.dart';

class PlayTrack extends StatelessWidget {
  const PlayTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayerPage(
      backgroundImage: CloudBackgroundImage(),
      playerOps: TrackOps(),
      header: TrackHeader(),
      navigation: TrackNavigation(),
      playerRepository: CloudPlayerRepositoryImp(),
    );
  }
}
