import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/pages/downloaded_episodes.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_list_template.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/subscribed/subscribed_podcast_list.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class Podcast extends StatefulWidget {
  const Podcast({super.key});

  @override
  State<Podcast> createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    BlocProvider.of<PodcastBloc>(context).add(GetSubscribedPodcasts());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFieldBox(
                controller: _controller,
                textInputAction: TextInputAction.search,
                hintText: 'what do you want?',
                onChanged: (text) {
                  if (text.trim().isEmpty) {
                    BlocProvider.of<PodcastBloc>(
                      context,
                    ).add(GetSubscribedPodcasts());
                  }
                },
                onSubmitted: (text) {
                  BlocProvider.of<PodcastBloc>(
                    context,
                  ).add(SearchPodcast(text.trim()));
                },
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DownloadedEpisodes()),
                );
              },
              icon: Icon(Icons.arrow_downward_rounded),
            ),
          ],
        ),
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
                return PodcastListTemplate(status.podcasts.podcasts);
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
