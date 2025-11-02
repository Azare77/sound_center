import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/core/util/date_util.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
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
          String label = _getLabel(widget.audios[itemIndex]);
          return Text(label, maxLines: 1);
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

  String _getLabel(AudioEntity audio) {
    final AudioColumns currentColumn = LocalOrderStorage.getSavedColumn();
    String label = '';
    switch (currentColumn) {
      case AudioColumns.id:
        label = toJalali(audio.dateAdded).substring(0, 7);
        break;
      case AudioColumns.createdAt:
        label = toJalali(audio.dateAdded).substring(0, 7);
        break;
      case AudioColumns.title:
        label = audio.title.isNotEmpty ? audio.title[0].toUpperCase() : '#';
        break;
      case AudioColumns.artist:
        label = audio.title.isNotEmpty ? audio.artist[0].toUpperCase() : '#';
        break;
      case AudioColumns.album:
        label = audio.album.isNotEmpty ? audio.album : '#';
        break;
      case AudioColumns.duration:
        label = AudioUtil.convertTime(audio.duration);
        break;
    }
    return label;
  }
}
