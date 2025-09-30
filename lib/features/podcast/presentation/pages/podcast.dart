import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';
import 'package:sound_center/features/podcast/presentation/widgets/LocalAudio/podcast_list_template.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class Podcast extends StatefulWidget {
  const Podcast({super.key});

  @override
  State<Podcast> createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
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
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'what do you want?',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            BlocProvider.of<PodcastBloc>(
              context,
            ).add(SearchPodcast(text.trim()));
          },
        ),
        Expanded(
          child: BlocBuilder<PodcastBloc, PodcastState>(
            builder: (BuildContext context, PodcastState state) {
              if (state.status is PodcastResultStatus) {
                PodcastResultStatus status =
                    state.status as PodcastResultStatus;
                return Column(
                  children: [
                    Expanded(
                      child: PodcastListTemplate(status.podcasts.podcasts),
                    ),
                    // if (PodcastPlayerRepositoryImp().hasSource())
                    // CurrentAudio(audioEntity: status.currentAudio!),
                  ],
                );
              }
              return Loading(label: "waiting for your search input");
            },
          ),
        ),
      ],
    );
  }
}
