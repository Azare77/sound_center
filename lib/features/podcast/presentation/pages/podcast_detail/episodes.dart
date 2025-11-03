import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episode_template.dart';

class Episodes extends StatefulWidget {
  const Episodes({super.key, required this.episodes, this.bestImageUrl});

  final List<Episode> episodes;
  final String? bestImageUrl;

  @override
  State<Episodes> createState() => _EpisodesState();
}

class _EpisodesState extends State<Episodes>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemExtent: LIST_ITEM_HEIGHT,
      cacheExtent: 700,
      itemCount: widget.episodes.length,
      itemBuilder: (context, index) {
        Episode episode = widget.episodes[index];
        episode.imageUrl ??= widget.bestImageUrl;
        return InkWell(
          onTap: () {
            BlocProvider.of<PodcastBloc>(
              context,
            ).add(PlayPodcast(episodes: widget.episodes, index: index));
          },
          child: EpisodeTemplate(episode: episode),
        );
      },
    );
  }
}
