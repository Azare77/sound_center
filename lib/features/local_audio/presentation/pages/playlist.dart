import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/list_header.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/action_bar.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/add_audio_to_playlist_dialog.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/create_playlist_dialog.dart';
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
  StreamSubscription<AudioEntity?>? _audioSub;
  bool multipleSelect = false;
  final List<AudioEntity> selectedAudios = [];
  late String title;

  @override
  void initState() {
    title = widget.playlist.title;
    super.initState();
    imp = LocalPlayerRepositoryImp();
    bloc = BlocProvider.of<LocalBloc>(context);
    audios = List<AudioEntity>.from(widget.playlist.audios);
    _audioSub = imp.audioChangedStream.listen((ms) async {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _audioSub?.cancel();
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
              scrolledUnderElevation: 0,
              leading: multipleSelect
                  ? IconButton(
                      onPressed: exitMultipleSelect,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
            body: Column(
              // Header is already compact in landscape (see ListHeader),
              // so the extra gap between sections isn't needed there.
              spacing: isLandscape ? 4 : 10,
              children: [
                ListHeader(
                  title: title,
                  playlistRename: () async {
                    String? res = await showDialog(
                      context: context,
                      builder: (_) => CreatePlaylistDialog(
                        playlistId: widget.playlist.id,
                        title: title,
                      ),
                    );
                    if (res != null && res.isNotEmpty) {
                      setState(() {
                        title = res;
                      });
                    }
                  },
                  audios: audios,
                  category: Category.playlists,
                ),
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
                    // CurrentMedia is a shorter bar in landscape (it's a
                    // mini-player), so the FAB doesn't need to clear as
                    // much space above the bottom edge there.
                    padding: EdgeInsets.only(bottom: isLandscape ? 70 : 100),
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
                          audios.addAll(
                            inserted.where(
                              (audio) => !audios.any(
                                (existing) => existing.id == audio.id,
                              ),
                            ),
                          );
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
