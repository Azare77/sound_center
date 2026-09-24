import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/shared/widgets/blur_player_image.dart';

class CloudBackgroundImage extends StatelessWidget {
  const CloudBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final imp = CloudPlayerRepositoryImp();
    return BlocBuilder<CloudBloc, CloudState>(
      builder: (context, state) {
        String? img = imp.getCurrentTrack?.artworkUrl;
        return BlurPlayerImage(img: img, source: AudioSource.cloud);
      },
    );
  }
}
