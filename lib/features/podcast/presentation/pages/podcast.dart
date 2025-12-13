// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart' as search;
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_list_template.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_tool_bar.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/subscribed/subscribed_podcast_list.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class PodcastSearchController {
  static final ValueNotifier<bool> show = ValueNotifier(true);
}

class Podcast extends StatelessWidget {
  const Podcast({super.key});

  bool haveNewEpisode(BuildContext context) {
    final status = BlocProvider.of<PodcastBloc>(context).state.status;
    if (status is SubscribedPodcasts) {
      return status.podcasts.any((p) => p.haveNewEpisode);
    }
    return false;
  }

  void handleDeepLink(BuildContext context, Map<String, String> params) async {
    try {
      PodcastBloc bloc = BlocProvider.of<PodcastBloc>(context);
      search.Podcast podcast = await search.Feed.loadFeed(
        url: params['podcast'] ?? "",
      );
      final episode = podcast.episodes.firstWhere(
        (item) => item.guid == params['guid'],
      );
      bloc.add(PlayPodcast(episodes: [episode], index: 0));
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PodcastDetail(feedUrl: params['podcast']!),
        ),
      );
      bloc.add(GetSubscribedPodcasts());
    } catch (_) {}
  }

  bool resetPodcastPage(BuildContext context) {
    final bloc = BlocProvider.of<PodcastBloc>(context);
    final status = bloc.state.status;
    if (status is PodcastResultStatus) {
      bloc.add(GetSubscribedPodcasts());
      PodcastSearchController.show.value = false;
      return false;
    }
    PodcastSearchController.show.value = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PodcastToolBar(),
        Expanded(
          child: BlocBuilder<PodcastBloc, PodcastState>(
            buildWhen: (previous, current) {
              bool notDownload = current.status is! DownloadedEpisodesStatus;
              return notDownload;
            },
            builder: (BuildContext context, PodcastState state) {
              if (state.status is SubscribedPodcasts) {
                SubscribedPodcasts status = state.status as SubscribedPodcasts;
                return SubscribedPodcastList(status.podcasts);
              }
              if (state.status is PodcastResultStatus) {
                PodcastResultStatus status =
                    state.status as PodcastResultStatus;
                return PodcastListTemplate(status.searchResult.podcasts);
              }
              if (state.status is LoadingPodcasts) {
                return Loading();
              }
              BlocProvider.of<PodcastBloc>(
                context,
              ).add(GetSubscribedPodcasts());
              return Center(child: Text(S.of(context).noPodcast));
            },
          ),
        ),
      ],
    );
  }
}
