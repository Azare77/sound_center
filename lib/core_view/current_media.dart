import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/current_track.dart';
import 'package:sound_center/features/cloud/presentation/pages/play_track.dart'
    as cloud_page;
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/pages/play_audio.dart'
    as audio_page;
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/current_audio.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/pages/play_podcast.dart'
    as podcast_page;
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/current_podcast.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/pages/play_stream.dart'
    as stream_page;
import 'package:sound_center/features/stream/presentation/widgets/current_stream.dart';
import 'package:sound_center/shared/widgets/glass.dart';

class CurrentMedia extends StatefulWidget {
  const CurrentMedia({super.key, this.color, this.blur, this.opacity});

  final Color? color;
  final double? blur;
  final double? opacity;

  @override
  State<CurrentMedia> createState() => _CurrentMediaState();
}

class _CurrentMediaState extends State<CurrentMedia> {
  final LocalPlayerRepositoryImp _localPlayer = LocalPlayerRepositoryImp();
  final PodcastPlayerRepositoryImp _podcastPlayer =
      PodcastPlayerRepositoryImp();
  final StreamPlayerRepositoryImp _streamPlayer = StreamPlayerRepositoryImp();
  final CloudPlayerRepositoryImp _cloudPlayer = CloudPlayerRepositoryImp();

  Widget? _currentPlayer;
  Widget? _playerPage;

  late final List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _updatePlayer();
    _subs = [
      _localPlayer.audioChangedStream.listen((_) => _updatePlayer()),
      _podcastPlayer.episodeChangedStream.listen((_) => _updatePlayer()),
      _streamPlayer.streamChangedStream.listen((_) => _updatePlayer()),
      _cloudPlayer.trackChangedStream.listen((_) => _updatePlayer()),
    ];
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  void _updatePlayer() {
    final newPlayer = _buildMediaPlayer();
    _playerPage ??= audio_page.PlayAudio();
    setState(() => _currentPlayer = newPlayer);
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

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
              minHeight: MediaQuery.of(context).size.height,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            builder: (_) => _playerPage!,
          );
        },
        child: BlocListener<SettingBloc, SettingState>(
          listener: (_, _) => _updatePlayer(),
          child: _currentPlayer ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget? _buildMediaPlayer() {
    final AudioEntity? audioEntity = _localPlayer.getCurrentAudio;
    final Episode? episode = _podcastPlayer.getCurrentEpisode;
    final dynamic stream = _streamPlayer.getCurrentStream;
    final CloudTrack? cloud = _cloudPlayer.getCurrentTrack;

    final Widget? playerContent = _selectPlayerContent(
      audioEntity,
      episode,
      stream,
      cloud,
    );
    if (playerContent == null) return null;

    return _buildPlayerContainer(playerContent);
  }

  Widget? _selectPlayerContent(
    AudioEntity? audio,
    Episode? episode,
    dynamic stream,
    CloudTrack? cloud,
  ) {
    _playerPage = null;
    if (_localPlayer.hasSource() && audio != null) {
      _playerPage = audio_page.PlayAudio();
      return CurrentAudio(
        key: ValueKey((widget.key, audio.id)),
        audioEntity: audio,
      );
    }
    if (_podcastPlayer.hasSource() && episode != null) {
      _playerPage = podcast_page.PlayPodcast();

      return CurrentPodcast(
        key: ValueKey((widget.key, episode.guid)),
        episode: episode,
      );
    }
    if (_streamPlayer.hasSource() && stream != null) {
      final stream = _streamPlayer.getCurrentStream;
      late String url;
      late String title;
      if (stream is AudioModel) {
        url = stream.path;
        title = stream.title;
      } else if (stream is Source) {
        url = stream.listenUrl;
        title = stream.title ?? '';
      }
      _playerPage = stream_page.PlayStream();
      return CurrentStream(
        key: ValueKey((widget.key, "$url-$title")),
        streamEntity: stream,
      );
    }
    if (_cloudPlayer.hasSource() && cloud != null) {
      _playerPage = cloud_page.PlayTrack();
      return CurrentTrack(key: ValueKey((widget.key, cloud.id)), track: cloud);
    }
    return null;
  }

  Widget _buildPlayerContainer(Widget child) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: Glass(
        radius: 25.0,
        color: widget.color,
        blur: widget.blur,
        opacity: widget.opacity,
        child: Center(child: child),
      ),
    );
  }
}
