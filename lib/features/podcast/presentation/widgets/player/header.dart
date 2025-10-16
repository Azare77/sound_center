import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/header_image.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastHeader extends StatefulWidget {
  const PodcastHeader({super.key});

  @override
  State<PodcastHeader> createState() => _PodcastHeaderState();
}

class _PodcastHeaderState extends State<PodcastHeader> {
  late final PageController controller;
  int currentIndex = 0;
  List<Episode> currentPlayList = [];

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
    for (int i = 0; i < change.abs(); i++) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (BuildContext context, PodcastState state) {
          // final PodcastResultStatus status =
          //     state.status as PodcastResultStatus;
          Episode episode = PodcastPlayerRepositoryImp().getCurrentEpisode!;
          currentPlayList = PodcastPlayerRepositoryImp().getPlayList();
          _jumpToCorrectPage(currentPlayList, episode);
          return Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      return PodcastHeaderImage(url: episode.imageUrl);
                    },
                  ),
                ),
              ),
              ScrollingText(
                episode.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              if (episode.author != null)
                ScrollingText(
                  episode.author!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
            ],
          );
        },
      ),
    );
  }

  void _jumpToCorrectPage(List<Episode> currentPlayList, Episode song) {
    for (var entry in currentPlayList.asMap().entries) {
      if (entry.value.contentUrl == song.contentUrl) {
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
