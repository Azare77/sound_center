import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
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
  final PodcastPlayerRepositoryImp imp = PodcastPlayerRepositoryImp();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentAudio = imp.getCurrentEpisode;
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        Episode episode = widget.episodes[index];
        episode.imageUrl ??= widget.bestImageUrl;
        final isCurrent = currentAudio?.guid == episode.guid;
        return Container(
          key: ValueKey(episode.guid),
          height: LIST_ITEM_HEIGHT,
          color: isCurrent ? Color(0x1D1BF1D8) : Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {});
              BlocProvider.of<PodcastBloc>(
                context,
              ).add(PlayPodcast(episodes: widget.episodes, index: index));
            },
            child: EpisodeTemplate(episode: episode),
          ),
        );
      }, childCount: widget.episodes.length),
    );
  }
}
