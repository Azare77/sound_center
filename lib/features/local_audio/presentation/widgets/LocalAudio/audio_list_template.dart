import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart'
    as event;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class AudioListTemplate extends StatelessWidget {
  AudioListTemplate(this.audios, {super.key});

  final List<AudioEntity> audios;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final currentAudio = LocalPlayerRepositoryImp().getCurrentAudio;
    if (audios.isEmpty) return const Center(child: TextView("NO AUDIO!!"));

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: DraggableScrollbar.rrect(
        controller: _scrollController,
        backgroundColor: Colors.blueAccent,
        labelTextBuilder: (offset) {
          final itemIndex = (offset / 70).floor();
          if (itemIndex < 0 || itemIndex >= audios.length) {
            return const Text('');
          }
          final title = audios[itemIndex].title;
          final label = title.isNotEmpty ? title[0].toUpperCase() : '#';
          return Text(label);
        },
        child: ListView.builder(
          itemCount: audios.length,
          controller: _scrollController,
          itemBuilder: (context, index) {
            final audio = audios[index];
            final isCurrent = currentAudio?.id == audio.id;
            return Container(
              height: 70,
              color: isCurrent ? Color(0x1D1BF1D8) : null,
              child: InkWell(
                onTap: () =>
                    context.read<event.LocalBloc>().add(event.PlayAudio(index)),
                child: AudioTemplate(audioEntity: audio),
              ),
            );
          },
        ),
      ),
    );
  }
}
