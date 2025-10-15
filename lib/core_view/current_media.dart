import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/current_audio.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/current_podcast.dart';

class CurrentMedia extends StatefulWidget {
  const CurrentMedia({super.key});

  @override
  State<CurrentMedia> createState() => _CurrentMediaState();
}

class _CurrentMediaState extends State<CurrentMedia> {
  final LocalPlayerRepositoryImp localPlayer = LocalPlayerRepositoryImp();

  final PodcastPlayerRepositoryImp podcastPlayer = PodcastPlayerRepositoryImp();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocalBloc, LocalState>(
          listener: (_, _) => setState(() {}),
        ),
        BlocListener<PodcastBloc, PodcastState>(
          listener: (_, _) => setState(() {}),
        ),
      ],
      child: media(),
    );
  }

  Widget media() {
    if (localPlayer.hasSource()) {
      AudioEntity audioEntity = localPlayer.getCurrentAudio!;
      return CurrentAudio(
        key: Key(audioEntity.id.toString()),
        audioEntity: audioEntity,
      );
    }
    if (podcastPlayer.hasSource()) {
      Episode episode = podcastPlayer.getCurrentEpisode!;
      return CurrentPodcast(key: Key(episode.guid), episode: episode);
    }
    return const SizedBox.shrink();
  }
}
