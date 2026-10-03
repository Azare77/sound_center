import 'dart:async';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/cloud_item_template.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episode_template.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/glass.dart';
import 'package:sound_center/shared/widgets/handler.dart';

class PlayQueue extends StatelessWidget {
  const PlayQueue({super.key, required this.imp});

  final PlayerRepository imp;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final coverType = SettingsRepositoryImp().getPlayerStyle();
    Widget item;
    return InkWell(
      onTap: () {
        if (coverType == PlayerStyle.solid) {
          item = Queue(imp: imp);
        } else {
          item = Glass(
            color: ThemeManager.current.scaffoldBackground,
            opacity: ThemeManager.current.opacity + 0.2,
            borderRadius: 25,
            onlyTopBorderRadius: true,
            child: Queue(imp: imp),
          );
        }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          requestFocus: false,
          backgroundColor: coverType == PlayerStyle.solid
              ? null
              : Colors.transparent,
          constraints: BoxConstraints(minWidth: size.width),
          builder: (context) {
            return SizedBox(
              height: MediaQuery.heightOf(context) * 0.8,
              child: item,
            );
          },
        );
      },
      child: SizedBox(
        width: size.width,
        child: Column(
          spacing: 2,
          children: [
            SvgPicture.asset(
              "assets/icons/show-queue.svg",
              height: 15,
              width: 15,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            Text(S.of(context).playQueue),
          ],
        ),
      ),
    );
  }
}

class Queue extends StatefulWidget {
  const Queue({super.key, required this.imp});

  final PlayerRepository imp;

  @override
  State<Queue> createState() => _QueueState();
}

class _QueueState extends State<Queue> {
  final ScrollController _scrollController = ScrollController();

  LocalPlayerRepositoryImp? local;
  PodcastPlayerRepositoryImp? podcast;
  CloudPlayerRepositoryImp? cloud;

  StreamSubscription? sub;

  late List queue;

  AudioEntity? currentAudio;
  Episode? currentEpisode;
  CloudTrack? currentTrack;

  @override
  void initState() {
    super.initState();

    if (widget.imp is LocalPlayerRepositoryImp) {
      local = widget.imp as LocalPlayerRepositoryImp;
      queue = local!.shuffleMode == ShuffleMode.shuffle
          ? local!.shuffledAudios
          : local!.audios;

      sub = local!.audioChangedStream.listen((_) {
        if (mounted) setState(() {});
      });
    } else if (widget.imp is PodcastPlayerRepositoryImp) {
      podcast = widget.imp as PodcastPlayerRepositoryImp;
      queue = podcast!.episodes;

      sub = podcast!.episodeChangedStream.listen((_) {
        if (mounted) setState(() {});
      });
    } else if (widget.imp is CloudPlayerRepositoryImp) {
      cloud = widget.imp as CloudPlayerRepositoryImp;
      queue = cloud!.tracks;

      sub = cloud!.trackChangedStream.listen((_) {
        if (mounted) setState(() {});
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToCurrent();
      }
    });
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;

    final int index;

    if (local != null) {
      final current = local!.getCurrentAudio;
      if (current == null) return;

      final list = local!.shuffleMode == ShuffleMode.shuffle
          ? local!.shuffledAudios
          : local!.audios;

      index = list.indexWhere((audio) => audio.id == current.id);
    } else if (podcast != null) {
      final current = podcast!.getCurrentEpisode;
      if (current == null) return;

      index = podcast!.episodes.indexWhere(
        (episode) => episode.guid == current.guid,
      );
    } else {
      final current = cloud!.getCurrentTrack;
      if (current == null) return;

      index = cloud!.tracks.indexWhere((track) => track.id == current.id);
    }

    if (index == -1) return;

    const itemHeight = LIST_ITEM_HEIGHT;
    final viewportHeight = _scrollController.position.viewportDimension;

    final offset = index * itemHeight - (viewportHeight - itemHeight) / 2;

    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (local != null) {
      queue = local!.shuffleMode == ShuffleMode.shuffle
          ? local!.shuffledAudios
          : local!.audios;
      currentAudio = local!.getCurrentAudio;
    } else if (podcast != null) {
      queue = podcast!.episodes;
      currentEpisode = podcast!.getCurrentEpisode;
    } else if (cloud != null) {
      queue = cloud!.tracks;
      currentTrack = cloud!.getCurrentTrack;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        spacing: 20,
        children: [
          Handler(),
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              buildDefaultDragHandles: false,
              itemCount: queue.length,
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
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  if (local != null) {
                    local!.reorderQueue(oldIndex, newIndex);
                  } else if (podcast != null) {
                    podcast!.reorderQueue(oldIndex, newIndex);
                  } else if (cloud != null) {
                    cloud!.reorderQueue(oldIndex, newIndex);
                  }
                });
              },
              itemBuilder: (context, index) {
                final item = queue[index];
                return queueListItem(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget queueListItem(dynamic item, int index) {
    Color color = Colors.transparent;
    Widget content = const SizedBox.shrink();
    GestureTapCallback? onTap;
    String key = "key";
    if (item is AudioEntity) {
      color = currentAudio?.id == item.id
          ? ThemeManager.current.mediaColor
          : Colors.transparent;
      content = AudioTemplate(audioEntity: item);
      int correctIndex = local!.shuffleMode == ShuffleMode.shuffle
          ? local!.shuffleList[index]
          : index;
      onTap = () => local!.play(correctIndex);
      key = "${item.id}-$index";
    }

    if (item is Episode) {
      color = currentEpisode?.guid == item.guid
          ? ThemeManager.current.mediaColor
          : Colors.transparent;
      content = EpisodeTemplate(episode: item);
      onTap = () => podcast!.play(index, direct: true);
      key = "${item.guid}-$index";
    }

    if (item is CloudTrack) {
      color = currentTrack?.id == item.id
          ? ThemeManager.current.mediaColor
          : Colors.transparent;
      content = CloudItemTemplate(item: item);
      onTap = () => cloud!.play(index, direct: true);
      key = "${item.id}-$index";
    }

    return Material(
      key: ValueKey(key),
      color: color,
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
            child: InkWell(onTap: onTap, child: content),
          ),
        ],
      ),
    );
  }
}
