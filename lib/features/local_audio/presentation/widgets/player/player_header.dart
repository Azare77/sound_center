import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/header_image.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class PlayerHeader extends StatefulWidget {
  const PlayerHeader({super.key});

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  late final PageController controller;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
    return BlocBuilder<LocalBloc, LocalState>(
      builder: (BuildContext context, LocalState state) {
        final LocalAudioStatus status = state.status as LocalAudioStatus;
        AudioEntity song = status.currentAudio!;
        List<AudioEntity> currentPlayList = LocalPlayerRepositoryImp()
            .getPlayList();
        _jumpToCorrectPage(currentPlayList, song);
        return SizedBox(
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8 - 10,
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
              TextView(song.title, maxLines: 1, textAlign: TextAlign.center),
              TextView(song.artist, maxLines: 1, textAlign: TextAlign.center),
            ],
          ),
        );
      },
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
}
