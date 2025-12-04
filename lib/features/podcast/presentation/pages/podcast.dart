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

  void handleDeepLink(BuildContext context, Map<String, String> params) async {
    try {
      search.Podcast podcast = await search.Feed.loadFeed(
        url: params['podcast'] ?? "",
      );
      final episode = podcast.episodes.firstWhere(
        (item) => item.guid == params['guid'],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PodcastDetail(feedUrl: params['podcast']!),
        ),
      );
      BlocProvider.of<PodcastBloc>(
        context,
      ).add(PlayPodcast(episodes: [episode], index: 0));
    } catch (_) {}
  }

  bool isInSubscribed(BuildContext context) {
    final bloc = BlocProvider.of<PodcastBloc>(context);
    final status = bloc.state.status;
    if (status is PodcastResultStatus) {
      bloc.add(ShowLoading());
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
              bool inSearch =
                  previous.status is PodcastResultStatus &&
                  current.status is SubscribedPodcasts;
              return notDownload && !inSearch;
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
              return Center(child: Text(S.of(context).noPodcast));
            },
          ),
        ),
      ],
    );
  }
}
