import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/pages/play_audio.dart'
    as audio_page;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/current_audio.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/play_podcast.dart'
    as podcast_page;
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/current_podcast.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/shared/theme/themes.dart';

class CurrentMedia extends StatefulWidget {
  const CurrentMedia({super.key, this.color});

  final Color? color;

  @override
  State<CurrentMedia> createState() => _CurrentMediaState();
}

class _CurrentMediaState extends State<CurrentMedia> {
  final LocalPlayerRepositoryImp _localPlayer = LocalPlayerRepositoryImp();
  final PodcastPlayerRepositoryImp _podcastPlayer =
      PodcastPlayerRepositoryImp();

  Widget? _currentPlayer;
  Widget? _playerPage;

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
    final EdgeInsets edgeInsets = EdgeInsets.fromViewPadding(
      WidgetsBinding.instance.platformDispatcher.views.first.padding,
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    );
    final paddingBottom = edgeInsets.bottom;
    final paddingTop = edgeInsets.top;

    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: GestureDetector(
        onTap: () {
          if (_playerPage == null) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            requestFocus: true,
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            builder: (_) => Padding(
              padding: EdgeInsets.only(top: paddingTop),
              child: _playerPage!,
            ),
          );
        },
        child: MultiBlocListener(
          listeners: [
            BlocListener<LocalBloc, LocalState>(
              listener: (_, _) => _updatePlayer(),
            ),
            BlocListener<PodcastBloc, PodcastState>(
              listener: (_, _) => _updatePlayer(),
            ),
            BlocListener<SettingBloc, SettingState>(
              listener: (_, _) => _updatePlayer(),
            ),
          ],
          child: _currentPlayer ?? const SizedBox.shrink(),
        ),
      ),
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
    _playerPage = null;
    if (_localPlayer.hasSource() && audio != null) {
      _playerPage = audio_page.PlayAudio();
      return CurrentAudio(key: ValueKey(audio.id), audioEntity: audio);
    }
    if (_podcastPlayer.hasSource() && episode != null) {
      _playerPage = podcast_page.PlayPodcast();
      return CurrentPodcast(key: Key(episode.guid), episode: episode);
    }
    return null;
  }

  Widget _buildPlayerContainer(Widget child) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.color ?? ThemeManager.current.mediaColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );
  }
}
