import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (audios.isNotEmpty) {
      return ListView.builder(
        itemCount: audios.length,
        itemBuilder: (context, index) {
          final audio = audios[index];
          return InkWell(
            onTap: () {
              BlocProvider.of<event.LocalBloc>(
                context,
              ).add(event.PlayAudio(index));
            },
            child: AudioTemplate(audioEntity: audio),
          );
        },
      );
    }

    return Center(child: TextView("NO AUDIO!!"));
  }
}
