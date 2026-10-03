import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/playlist/action_bar.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/playlist/add_audio_to_playlist_dialog.dart';

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

  bool multipleSelect = false;
  final List<AudioEntity> selectedAudios = [];

  @override
  void initState() {
    super.initState();

    bloc = BlocProvider.of<LocalBloc>(context);
    audios = List<AudioEntity>.from(widget.playlist.audios);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // دیگه نیازی به ذخیره/بازگردانی دستیِ offset نیست، چون ویجتِ لیست
  // دیگه هیچ‌وقت dispose/remount نمی‌شه و ScrollPosition خودش حفظ می‌مونه.
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

  // نکتهٔ کلیدی: به‌جای سوییچ بین دو نوع ویجت مختلف (ListView.builder و
  // ReorderableListView.builder)، همیشه همون یک ReorderableListView.builder
  // رو نگه می‌داریم و فقط itemBuilder و رفتار reorder رو شرطی می‌کنیم.
  // چون runtimeType و موقعیت ویجت در تری عوض نمی‌شه، Element و در نتیجه
  // ScrollPosition وصل‌شده به _scrollController هیچ‌وقت dispose نمی‌شه،
  // پس پرش به بالا موقع تغییر حالت کلاً رخ نمی‌ده.
  Widget _buildAudioList() {
    return ReorderableListView.builder(
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      itemCount: audios.length,
      itemExtent: LIST_ITEM_HEIGHT,
      proxyDecorator: (child, index, animation) {
        return Material(color: Colors.transparent, elevation: 0, child: child);
      },
      padding: const EdgeInsets.only(bottom: 120),
      onReorderItem: (oldIndex, newIndex) {
        // موقع انتخاب چندتایی، drag handle اصلاً رندر نمی‌شه (پایین‌تر)
        // پس این callback عملاً قابل فراخوانی نیست، اما به‌خاطر ایمنی نگهش می‌داریم.
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

        if (multipleSelect) {
          return Material(
            key: ValueKey(audio.id),
            color: Colors.transparent,
            child: InkWell(
              onTap: () => toggleAudio(audio),
              child: AudioTemplate(
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
              title: Text(widget.playlist.title),
              leading: multipleSelect
                  ? IconButton(
                      onPressed: exitMultipleSelect,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
            body: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: multipleSelect ? 50 : 0,
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
}) {
  return Material(
    key: ValueKey((item.id, index)),
    color: Colors.transparent,
    child: Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: SizedBox(
            width: 60,
            height: LIST_ITEM_HEIGHT,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: const Center(child: Icon(Icons.drag_handle)),
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
