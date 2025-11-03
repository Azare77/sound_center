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
import 'package:sound_center/shared/theme/themes.dart';

class CurrentMedia extends StatefulWidget {
  const CurrentMedia({super.key});

  @override
  State<CurrentMedia> createState() => _CurrentMediaState();
}

class _CurrentMediaState extends State<CurrentMedia> {
  final LocalPlayerRepositoryImp _localPlayer = LocalPlayerRepositoryImp();
  final PodcastPlayerRepositoryImp _podcastPlayer =
      PodcastPlayerRepositoryImp();

  Widget? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _updatePlayer();
  }

  void _updatePlayer() {
    final newPlayer = _buildMediaPlayer();
    if (newPlayer != null && !identical(_currentPlayer, newPlayer)) {
      setState(() => _currentPlayer = newPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocalBloc, LocalState>(
          listener: (_, _) => _updatePlayer(),
        ),
        BlocListener<PodcastBloc, PodcastState>(
          listener: (_, _) => _updatePlayer(),
        ),
      ],
      child: _currentPlayer ?? const SizedBox.shrink(),
    );
  }

  Widget? _buildMediaPlayer() {
    final AudioEntity? audioEntity = _localPlayer.getCurrentAudio;
    final Episode? episode = _podcastPlayer.getCurrentEpisode;

    final Widget? playerContent = _selectPlayerContent(audioEntity, episode);
    if (playerContent == null) return null;

    return _buildPlayerContainer(playerContent);
  }

  Widget? _selectPlayerContent(AudioEntity? audio, Episode? episode) {
    if (_localPlayer.hasSource() && audio != null) {
      return CurrentAudio(key: ValueKey(audio.id), audioEntity: audio);
    }
    if (_podcastPlayer.hasSource() && episode != null) {
      return CurrentPodcast(key: Key(episode.guid), episode: episode);
    }
    return null;
  }

  Widget _buildPlayerContainer(Widget child) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: DarkTheme.currentMedia,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );
  }
}
