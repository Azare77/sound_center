import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/episodes.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/podcast_info.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class PodcastDetail extends StatefulWidget {
  const PodcastDetail({super.key, required this.podcast});

  final Item podcast;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  Podcast? podcast;

  void getEpisodes() async {
    try {
      podcast = await Feed.loadFeed(url: widget.podcast.feedUrl!);
      if (podcast?.image == null) {}
    } on PodcastFailedException catch (e) {
      podcast = null;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (_) {
      podcast = null;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getEpisodes();
    _controller = TabController(length: 2, vsync: this);
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(podcast!.title ?? ""),
                    ElevatedButton(
                      onPressed: () {},
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
                      Episodes(
                        episodes: podcast!.episodes,
                        bestImageUrl: widget.podcast.bestArtworkUrl,
                      ),
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
