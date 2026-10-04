import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart'
    as event;
import 'package:sound_center/features/local_audio/presentation/util/multi_select_controller.dart';
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

  /// حالت مالتی‌سلکتِ تحمیلیِ بیرونی (مثلاً هنگام انتخاب آهنگ برای ساخت
  /// پلی‌لیست). این حالت کاملاً مستقل از MultiSelectController سراسری است
  /// و رفتار قبلی‌اش دست‌نخورده باقی مانده.
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

    if (widget.multipleSelect) {
      // حالت تحمیلی بیرونی: دقیقاً همان رفتار قبلی، بدون تغییر.
      return _buildList(
        context,
        currentAudio,
        isSelected: (a) => selectedAudios.contains(a),
        isMultiple: true,
        onItemTap: (audio, index) {
          widget.onAudioTap?.call(audio);
          toggleAudio(audio);
        },
        onItemLongPress: (audio) => showDialog(
          context: context,
          builder: (_) => AudioActionMenu(audio: audio),
        ),
      );
    }

    // حالت عادیِ صفحه: به کنترلر سراسری مالتی‌سلکت وصل می‌شود.
    // دو تا ValueListenableBuilder لازم است: یکی برای روشن/خاموش بودنِ حالت
    // انتخاب (multiSelect)، یکی برای خودِ ست انتخاب‌شده‌ها (selected) — در
    // غیر این صورت toggle شدن یک آیتم باعث rebuild چک‌باکس‌ها نمی‌شود.
    return ValueListenableBuilder<bool>(
      valueListenable: MultiSelectController.multiSelect,
      builder: (context, active, _) => ValueListenableBuilder<Set<Object>>(
        valueListenable: MultiSelectController.selected,
        builder: (context, _, __) => _buildList(
          context,
          currentAudio,
          isSelected: MultiSelectController.isSelected,
          isMultiple: active,
          onItemTap: (audio, index) {
            if (active) {
              MultiSelectController.toggle(audio);
            } else {
              context.read<event.LocalBloc>().add(
                event.PlayAudio(audios: widget.audios, index: index),
              );
            }
          },
          onItemLongPress: (audio) {
            if (active) return; // حین انتخاب، long-press کاری انجام نمی‌دهد
            MultiSelectController.enable(audio); // req 1
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AudioEntity? currentAudio, {
    required bool Function(AudioEntity) isSelected,
    required bool isMultiple,
    required void Function(AudioEntity audio, int index) onItemTap,
    required void Function(AudioEntity audio) onItemLongPress,
  }) {
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

                return Material(
                  key: ValueKey(audio.id),
                  color: isCurrent
                      ? ThemeManager.current.mediaColor
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => onItemTap(audio, index),
                    onLongPress: () => onItemLongPress(audio),
                    child: AudioTemplate(
                      audioEntity: audio,
                      isMultiple: isMultiple,
                      isSelected: isSelected(audio),
                      onChanged: (value) {
                        if (value == null) return;
                        onItemTap(audio, index);
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
