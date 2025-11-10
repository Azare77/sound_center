import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_list_template.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_tool_bar.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/subscribed/subscribed_podcast_list.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class Podcast extends StatefulWidget {
  const Podcast({super.key});

  @override
  State<Podcast> createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  late final PodcastToolBar podcastToolBar;

  @override
  void initState() {
    super.initState();
    podcastToolBar = PodcastToolBar();
    // BlocProvider.of<PodcastBloc>(context).add(GetSubscribedPodcasts());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        podcastToolBar,
        Expanded(
          child: BlocBuilder<PodcastBloc, PodcastState>(
            buildWhen: (previous, current) {
              return current.status is! DownloadedEpisodesStatus;
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
                return Loading(label: "waiting for your search input");
              }
              return Center(child: Text("NO PODCAST"));
            },
          ),
        ),
      ],
    );
  }
}
