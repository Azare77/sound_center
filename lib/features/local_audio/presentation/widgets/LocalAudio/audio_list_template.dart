import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart'
    as event;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_action_menu.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class AudioListTemplate extends StatefulWidget {
  const AudioListTemplate(
    this.audios, {
    super.key,
    this.multipleSelect = false,
    this.onAudioTap,
  });

  final List<AudioEntity> audios;
  final bool multipleSelect;
  final ValueChanged<AudioEntity>? onAudioTap;

  @override
  State<AudioListTemplate> createState() => _AudioListTemplateState();
}

class _AudioListTemplateState extends State<AudioListTemplate> {
  final _scrollController = ScrollController();
  final playerRepo = LocalPlayerRepositoryImp();

  final List<AudioEntity> selectedAudios = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void toggleAudio(AudioEntity audio) {
    setState(() {
      if (selectedAudios.contains(audio)) {
        selectedAudios.remove(audio);
      } else {
        selectedAudios.add(audio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = playerRepo.getCurrentAudio;

    if (widget.audios.isEmpty) {
      return Center(child: TextView(S.of(context).noAudio));
    }

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            child: ListView.builder(
              itemCount: widget.audios.length,
              controller: _scrollController,
              itemExtent: LIST_ITEM_HEIGHT,
              padding: const EdgeInsets.only(bottom: 120),
              itemBuilder: (context, index) {
                final audio = widget.audios[index];
                final isCurrent = currentAudio?.id == audio.id;
                final isSelected = selectedAudios.contains(audio);

                return Material(
                  key: ValueKey(audio.id),
                  color: isCurrent
                      ? ThemeManager.current.mediaColor
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (widget.multipleSelect) {
                        widget.onAudioTap?.call(audio);
                        toggleAudio(audio);
                      } else {
                        context.read<event.LocalBloc>().add(
                          event.PlayAudio(audios: widget.audios, index: index),
                        );
                      }
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AudioActionMenu(audio: audio),
                      );
                    },
                    child: AudioTemplate(
                      audioEntity: audio,
                      isMultiple: widget.multipleSelect,
                      isSelected: isSelected,
                      onChanged: (value) {
                        if (value == null) return;
                        widget.onAudioTap?.call(audio);
                        toggleAudio(audio);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
