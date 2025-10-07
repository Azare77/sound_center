import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode_template.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class Episodes extends StatefulWidget {
  const Episodes({super.key, required this.podcast});

  final Item podcast;

  @override
  State<Episodes> createState() => _EpisodesState();
}

class _EpisodesState extends State<Episodes> {
  Podcast? podcast;

  void getEpisodes() async {
    try {
      podcast = await Feed.loadFeed(url: widget.podcast.feedUrl!);
    } catch (e) {
      podcast = null;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    getEpisodes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.podcast.trackName ?? '')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PodcastBloc, PodcastState>(
              builder: (BuildContext context, PodcastState state) {
                if (state.status is PodcastResultStatus) {
                  // PodcastResultStatus status =
                  //     state.status as PodcastResultStatus;
                  return podcast == null
                      ? Loading()
                      : Column(
                          children: [
                            Wrap(children: [Text(podcast!.description ?? "")]),
                            Expanded(
                              child: ListView.builder(
                                itemCount: podcast!.episodes.length,
                                itemBuilder: (context, index) {
                                  Episode episode = podcast!.episodes[index];
                                  episode.imageUrl ??=
                                      widget.podcast.bestArtworkUrl;
                                  return InkWell(
                                    onTap: () {
                                      BlocProvider.of<PodcastBloc>(
                                        context,
                                      ).add(PlayPodcast(episode));
                                    },
                                    child: EpisodeTemplate(episode: episode),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                }
                return Loading();
              },
            ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }
}
