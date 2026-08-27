import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/header_image.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PlayerHeader extends StatefulWidget {
  const PlayerHeader({super.key});

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  late final PageController controller;
  int _currentIndex = 0;
  bool _isScrolling = false;
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

  void onScrollEnd() async {
    _isScrolling = false;
    await Future.delayed(Duration(milliseconds: 250));
    if (_isScrolling) return;
    int page = controller.page?.round() ?? 0;
    int change = page - _currentIndex;
    if (change == 0) return;
    if (imp.isShuffle()) {
      imp.shuffleIndex += change;
      imp.play(imp.shuffleList[imp.shuffleIndex]);
    } else {
      imp.index += change;
      imp.play(imp.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalBloc, LocalState>(
      builder: (BuildContext context, LocalState state) {
        AudioEntity song = imp.getCurrentAudio!;
        currentPlayList = imp.getPlayList();
        _currentIndex = imp.isShuffle() ? imp.shuffleIndex : imp.index;
        _jumpToCorrectPage();
        final slider = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollStartNotification) {
              _isScrolling = true;
            }
            if (notification is ScrollEndNotification) {
              onScrollEnd();
            }
            return false;
          },
          child: PageView.builder(
            controller: controller,
            restorationId: song.title,
            itemCount: currentPlayList.length,
            itemBuilder: (BuildContext context, int index) {
              AudioEntity audio = currentPlayList[index];
              return HeaderImage(
                key: ValueKey(audio.id),
                id: audio.id,
                cover: audio.cover,
              );
            },
          ),
        );
        final orientation = MediaQuery.orientationOf(context);
        return Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            orientation == Orientation.landscape
                ? Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 1, child: slider),
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8 - 30,
                    child: slider,
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
        );
      },
    );
  }

  void _jumpToCorrectPage() {
    if (controller.hasClients) {
      _isScrolling = true;
      controller.jumpToPage(_currentIndex);
      _isScrolling = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        _isScrolling = true;
        controller.jumpToPage(_currentIndex);
        _isScrolling = false;
      }
    });
  }
}
