import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/episodes.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/podcast_info.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastDetail extends StatefulWidget {
  const PodcastDetail({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  Podcast? podcast;

  void getEpisodes({bool retry = true}) async {
    try {
      podcast = await Feed.loadFeed(url: widget.feedUrl);
      if (podcast?.image == null) {}
    } on PodcastFailedException catch (_) {
      podcast = null;
    } catch (_) {
      podcast = null;
    } finally {
      if (podcast == null) {
        if (retry) {
          getEpisodes(retry: false);
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    getEpisodes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: podcast == null
          ? Loading()
          : Column(
              spacing: 5,
              children: [
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(child: ScrollingText(podcast!.title ?? "")),
                    ElevatedButton(
                      onPressed: () {
                        SubscriptionEntity sub = SubscriptionEntity.fromPodcast(
                          widget.feedUrl,
                          podcast!,
                        );
                        BlocProvider.of<PodcastBloc>(
                          context,
                        ).add(SubscribeToPodcast(sub));
                      },
                      child: Text("I'm into it"),
                    ),
                  ],
                ),
                TabBar(
                  controller: _controller,
                  tabs: const [
                    Tab(text: 'Episodes'),
                    Tab(text: "Info"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      Episodes(episodes: podcast!.episodes, bestImageUrl: null),
                      PodcastInfo(info: podcast!.description ?? ""),
                    ],
                  ),
                ),
                CurrentMedia(),
              ],
            ),
    );
  }
}
