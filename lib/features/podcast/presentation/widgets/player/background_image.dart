import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/shared/widgets/blur_player_image.dart';

class PodcastBackgroundImage extends StatelessWidget {
  const PodcastBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final imp = PodcastPlayerRepositoryImp();
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        String? img = imp.getCurrentEpisode?.imageUrl;
        return BlurPlayerImage(img: img, source: AudioSource.podcast);
      },
    );
  }
}
