import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/shared/widgets/blur_player_image.dart';

class StreamBackgroundImage extends StatelessWidget {
  const StreamBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final imp = StreamPlayerRepositoryImp();
    return BlocBuilder<StreamBloc, StreamState>(
      builder: (context, state) {
        final currentStream = imp.getCurrentStream;
        if (currentStream is AudioModel) {
          return BlurPlayerImage(
            img: currentStream.cover,
            source: AudioSource.local,
          );
        } else {
          return BlurPlayerImage(
            img: currentStream.cover,
            source: AudioSource.stream,
          );
        }
      },
    );
  }
}
