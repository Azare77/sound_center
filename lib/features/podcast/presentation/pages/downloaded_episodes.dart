import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episode_template.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class DownloadedEpisodes extends StatefulWidget {
  const DownloadedEpisodes({super.key});

  @override
  State<DownloadedEpisodes> createState() => _DownloadedEpisodesState();
}

class _DownloadedEpisodesState extends State<DownloadedEpisodes> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PodcastBloc>(context).add(GetDownloadedEpisodes());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloaded Episodes")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PodcastBloc, PodcastState>(
              builder: (BuildContext context, PodcastState state) {
                if (state.status is DownloadedEpisodesStatus) {
                  DownloadedEpisodesStatus status =
                      state.status as DownloadedEpisodesStatus;
                  return ListView.builder(
                    itemExtent: LIST_ITEM_HEIGHT,
                    cacheExtent: 700,
                    itemCount: status.episodes.length,
                    itemBuilder: (context, index) {
                      Episode episode = status.episodes[index];
                      return InkWell(
                        onTap: () {
                          BlocProvider.of<PodcastBloc>(context).add(
                            PlayPodcast(
                              episodes: status.episodes,
                              index: index,
                            ),
                          );
                        },
                        child: EpisodeTemplate(
                          episode: episode,
                          isDownloaded: true,
                        ),
                      );
                    },
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
