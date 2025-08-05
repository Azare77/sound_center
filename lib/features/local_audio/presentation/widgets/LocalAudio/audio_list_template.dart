import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart'
    as event;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class AudioListTemplate extends StatelessWidget {
  const AudioListTemplate(this.audios, {super.key});

  final List<AudioEntity> audios;

  @override
  Widget build(BuildContext context) {
    final currentAudio = LocalPlayerRepositoryImp().getCurrentAudio;

    if (audios.isEmpty) return const Center(child: TextView("NO AUDIO!!"));

    return ListView.builder(
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        final isCurrent = currentAudio?.id == audio.id;
        return Container(
          color: isCurrent ? Color(0x1D1BF1D8) : null,
          child: InkWell(
            onTap: () =>
                context.read<event.LocalBloc>().add(event.PlayAudio(index)),
            child: AudioTemplate(audioEntity: audio),
          ),
        );
      },
    );
  }
}
