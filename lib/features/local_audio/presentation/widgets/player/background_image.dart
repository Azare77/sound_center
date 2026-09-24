import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/shared/widgets/blur_player_image.dart';

class LocalBackgroundImage extends StatelessWidget {
  const LocalBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final imp = LocalPlayerRepositoryImp();
    return BlocBuilder<LocalBloc, LocalState>(
      builder: (context, state) {
        Uint8List? img = imp.getCurrentAudio?.cover;
        return BlurPlayerImage(img: img, source: AudioSource.local);
      },
    );
  }
}
