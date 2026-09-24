import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/player/header_image.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class TrackHeader extends StatefulWidget {
  const TrackHeader({super.key});

  @override
  State<TrackHeader> createState() => _TrackHeaderState();
}

class _TrackHeaderState extends State<TrackHeader> {
  late final PageController controller;
  final GlobalKey _sliderKey = GlobalKey();
  int currentIndex = 0;
  List<CloudTrack> currentPlayList = [];
  bool _isScrolling = false;
  late final CloudPlayerRepositoryImp playerRepository;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    playerRepository = CloudPlayerRepositoryImp();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScrollEnd() async {
    _isScrolling = false;
    await Future.delayed(Duration(milliseconds: 250));
    if (!mounted || _isScrolling) return;
    int page = controller.page?.round() ?? currentIndex;
    int change = page - currentIndex;
    if (change == 0) return;
    playerRepository.index += change;
    playerRepository.play(playerRepository.index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BlocBuilder<CloudBloc, CloudState>(
        builder: (BuildContext context, CloudState state) {
          CloudTrack? currentTrack = playerRepository.getCurrentTrack;
          currentPlayList = playerRepository.getPlayList();
          currentIndex = playerRepository.index;
          _jumpToCorrectPage();
          final slider = NotificationListener<ScrollNotification>(
            key: _sliderKey,
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
              itemCount: currentPlayList.length,
              itemBuilder: (BuildContext context, int index) {
                CloudTrack track = currentPlayList[index];
                return TrackHeaderImage(url: track.artworkUrl);
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
                currentTrack?.title ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              ScrollingText(
                currentTrack?.author ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          );
        },
      ),
    );
  }

  void _jumpToCorrectPage() {
    if (controller.hasClients) {
      _isScrolling = true;
      controller.jumpToPage(currentIndex);
      _isScrolling = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        _isScrolling = true;
        controller.jumpToPage(currentIndex);
        _isScrolling = false;
      }
    });
  }
}
