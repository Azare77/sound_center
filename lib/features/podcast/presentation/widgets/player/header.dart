import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/description.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/header_image.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastHeader extends StatefulWidget {
  const PodcastHeader({super.key});

  @override
  State<PodcastHeader> createState() => _PodcastHeaderState();
}

class _PodcastHeaderState extends State<PodcastHeader> {
  late final PageController controller;
  final GlobalKey _sliderKey = GlobalKey();
  int currentIndex = 0;
  List<Episode> currentPlayList = [];
  bool _isScrolling = false;
  late final PodcastPlayerRepositoryImp playerRepository;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    playerRepository = PodcastPlayerRepositoryImp();
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
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (BuildContext context, PodcastState state) {
          Episode currentEpisode = playerRepository.getCurrentEpisode!;
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
                Episode episode = currentPlayList[index];
                return PodcastHeaderImage(url: episode.imageUrl);
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
                currentEpisode.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              ScrollingText(
                currentEpisode.author ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => Description(
                      description:
                          playerRepository.getCurrentEpisode!.description,
                    ),
                  );
                },
                child: Text(S.of(context).description),
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
