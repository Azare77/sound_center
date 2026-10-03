import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/playlist/action_bar.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/playlist/add_audio_to_playlist_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key, required this.playlist});

  final PlaylistEntity playlist;

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final ScrollController _scrollController = ScrollController();

  late List<AudioEntity> audios;
  late final LocalBloc bloc;
  late final LocalPlayerRepositoryImp imp;

  bool multipleSelect = false;
  final List<AudioEntity> selectedAudios = [];

  @override
  void initState() {
    super.initState();
    imp = LocalPlayerRepositoryImp();
    bloc = BlocProvider.of<LocalBloc>(context);
    audios = List<AudioEntity>.from(widget.playlist.audios);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void enterMultipleSelect(AudioEntity audio) {
    setState(() {
      multipleSelect = true;

      if (!selectedAudios.contains(audio)) {
        selectedAudios.add(audio);
      }
    });
  }

  void exitMultipleSelect() {
    if (!multipleSelect) return;

    setState(() {
      multipleSelect = false;
      selectedAudios.clear();
    });
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

  Widget _buildHeader() {
    ColorScheme cs = Theme.of(context).colorScheme;
    TextTheme tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).appBarTheme.backgroundColor!,
            Theme.of(
              context,
            ).appBarTheme.backgroundColor!.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.tertiary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  color: cs.onPrimary,
                  size: 30,
                ),
              ),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${S.of(context).tracks} : ${audios.length}',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            spacing: 10,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: audios.isEmpty
                      ? null
                      : () => bloc.add(PlayAudio(audios: audios, index: 0)),
                  label: Text(S.of(context).play),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: audios.isEmpty
                      ? null
                      : () {
                          final shuffled = List<AudioEntity>.from(audios)
                            ..shuffle();
                          bloc.add(PlayAudio(audios: shuffled, index: 0));
                        },
                  label: Text(S.of(context).shufflePlay),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: cs.onPrimaryContainer,
                    side: BorderSide(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList() {
    return ReorderableListView.builder(
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      itemCount: audios.length,
      itemExtent: LIST_ITEM_HEIGHT,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, c) {
            final t = Curves.easeOut.transform(animation.value);
            final scale = lerpDouble(1, 1.03, t)!;
            return Transform.scale(
              scale: scale,
              child: Material(
                color: Colors.transparent,
                elevation: lerpDouble(0, 8, t)!,
                shadowColor: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                child: c,
              ),
            );
          },
          child: child,
        );
      },

      padding: const EdgeInsets.only(bottom: 120),
      onReorderItem: (oldIndex, newIndex) {
        if (multipleSelect) return;

        bloc.add(
          ChangePlaylistOrder(
            playlistId: widget.playlist.id,
            itemId: audios[oldIndex].id,
            newOrder: newIndex,
          ),
        );

        setState(() {
          final item = audios.removeAt(oldIndex);
          audios.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final audio = audios[index];
        final isCurrent = imp.getCurrentAudio?.id == audio.id;
        if (multipleSelect) {
          return Material(
            key: ValueKey(audio.id),
            color: isCurrent
                ? ThemeManager.current.mediaColor
                : Colors.transparent,
            child: InkWell(
              onTap: () => toggleAudio(audio),
              child: AudioTemplate(
                key: ValueKey(audio.id),
                audioEntity: audio,
                isMultiple: true,
                isSelected: selectedAudios.contains(audio),
                onChanged: (_) => toggleAudio(audio),
              ),
            ),
          );
        }

        return queueListItem(
          audio,
          index,
          onLongPress: () => enterMultipleSelect(audio),
          onTap: () => bloc.add(PlayAudio(audios: audios, index: index)),
          isCurrent: imp.getCurrentAudio?.id == audio.id,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): exitMultipleSelect,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: !multipleSelect,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            exitMultipleSelect();
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: multipleSelect
                  ? IconButton(
                      onPressed: exitMultipleSelect,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
            body: Column(
              spacing: 10,
              children: [
                _buildHeader(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: multipleSelect ? 30 : 0,
                  curve: Curves.easeOut,
                  child: ActionBar(
                    playlistId: widget.playlist.id,
                    audios: selectedAudios,
                    onDeleted: () {
                      final deletedIds = selectedAudios
                          .map((e) => e.id)
                          .toSet();
                      audios.removeWhere(
                        (audio) => deletedIds.contains(audio.id),
                      );
                      selectedAudios.clear();
                      multipleSelect = false;
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildAudioList(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CurrentMedia(key: const Key('playlist')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: multipleSelect
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final List<AudioEntity>? inserted = await showDialog(
                          context: context,
                          builder: (_) => AddAudioToPlaylistDialog(
                            playlistId: widget.playlist.id,
                          ),
                        );

                        if (inserted == null || inserted.isEmpty) {
                          return;
                        }

                        setState(() {
                          audios.addAll(inserted);
                        });
                      },
                      child: const Icon(Icons.add_rounded),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget queueListItem(
  AudioEntity item,
  int index, {
  required GestureTapCallback onTap,
  required GestureTapCallback onLongPress,
  required bool isCurrent,
}) {
  return Material(
    key: ValueKey((item.id, index)),
    color: isCurrent ? ThemeManager.current.mediaColor : Colors.transparent,
    child: Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: SizedBox(
            width: 40,
            height: LIST_ITEM_HEIGHT,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: const Icon(Icons.drag_indicator_rounded),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: AudioTemplate(audioEntity: item),
          ),
        ),
      ],
    ),
  );
}
