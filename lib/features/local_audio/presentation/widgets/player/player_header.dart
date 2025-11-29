import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/header_image.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PlayerHeader extends StatefulWidget {
  const PlayerHeader({super.key});

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  late final PageController controller;

  int currentIndex = 0;
  List<AudioEntity> currentPlayList = [];
  late final LocalPlayerRepositoryImp imp;

  @override
  void initState() {
    super.initState();
    imp = LocalPlayerRepositoryImp();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScrollEnd() {
    int page = controller.page?.round() ?? 0;
    int change = page - currentIndex;
    for (int i = 0; i < change.abs(); i++) {
      BlocProvider.of<LocalBloc>(
        context,
      ).add(change > 0 ? PlayNextAudio() : PlayPreviousAudio());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BlocBuilder<LocalBloc, LocalState>(
        builder: (BuildContext context, LocalState state) {
          // final LocalAudioStatus status = state.status as LocalAudioStatus;
          final AudioEntity song = imp.getCurrentAudio!;
          currentPlayList = imp.getPlayList();
          _jumpToCorrectPage(currentPlayList, song);
          return SizedBox(
            child: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MediaControllerButton(
                      width: 50,
                      height: 50,
                      onPressed: () => _delete(),
                      svg: "assets/icons/trash-can.svg",
                    ),
                    SizedBox(
                      width: 40,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                    ),
                    MediaControllerButton(
                      width: 50,
                      height: 50,
                      onPressed: () async {
                        if (!Platform.isLinux) {
                          await SharePlus.instance.share(
                            ShareParams(files: [XFile(song.path)]),
                          );
                        }
                      },
                      svg: "assets/icons/share.svg",
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8 - 30,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollEndNotification) {
                        onScrollEnd();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: controller,
                      itemCount: currentPlayList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HeaderImage(img: currentPlayList[index].cover);
                      },
                    ),
                  ),
                ),
                ScrollingText(
                  song.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                ScrollingText(
                  song.artist,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _jumpToCorrectPage(List<AudioEntity> currentPlayList, AudioEntity song) {
    for (var entry in currentPlayList.asMap().entries) {
      if (entry.value.id == song.id) {
        currentIndex = entry.key;
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpToPage(currentIndex);
      }
    });
  }

  void _delete() async {
    bool res =
        await showDialog(context: context, builder: (_) => ConfirmDialog()) ??
        false;
    if (res) {
      BlocProvider.of<LocalBloc>(
        // ignore: use_build_context_synchronously
        context,
      ).add(DeleteAudio(imp.getCurrentAudio!));
    }
  }
}
