import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart'
    as event;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class AudioListTemplate extends StatefulWidget {
  const AudioListTemplate(this.audios, {super.key});

  final List<AudioEntity> audios;

  @override
  State<AudioListTemplate> createState() => _AudioListTemplateState();
}

class _AudioListTemplateState extends State<AudioListTemplate> {
  final _scrollController = ScrollController();
  final playerRepo = LocalPlayerRepositoryImp();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = playerRepo.getCurrentAudio;
    if (widget.audios.isEmpty) {
      return const Center(child: TextView("NO AUDIO!!"));
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: DraggableScrollbar.rrect(
        controller: _scrollController,
        backgroundColor: Colors.blueAccent,
        labelTextBuilder: (offset) {
          final itemIndex = (offset / LIST_ITEM_HEIGHT).floor();
          if (itemIndex < 0 || itemIndex >= widget.audios.length) {
            return const Text('');
          }
          final title = widget.audios[itemIndex].title;
          final label = title.isNotEmpty ? title[0].toUpperCase() : '#';
          return Text(label);
        },
        child: ListView.builder(
          itemCount: widget.audios.length,
          controller: _scrollController,
          itemExtent: LIST_ITEM_HEIGHT,
          itemBuilder: (context, index) {
            final audio = widget.audios[index];
            final isCurrent = currentAudio?.id == audio.id;
            return Material(
              key: ValueKey(audio.id),
              color: isCurrent ? Color(0x1D1BF1D8) : Colors.transparent,
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
