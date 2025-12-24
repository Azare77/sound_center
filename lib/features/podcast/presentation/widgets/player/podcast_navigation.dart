import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class PodcastNavigation extends StatefulWidget {
  const PodcastNavigation({super.key});

  @override
  State<PodcastNavigation> createState() => _PodcastNavigationState();
}

class _PodcastNavigationState extends State<PodcastNavigation> {
  final PodcastPlayerRepositoryImp imp = PodcastPlayerRepositoryImp();

  int total = 1;
  int pass = 0;
  bool seeking = false;

  late PodcastBloc _podcastBloc;

  StreamSubscription<int>? _posSub;
  StreamSubscription<int>? _durSub;

  @override
  void initState() {
    super.initState();
    _setupPage();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  Future<void> _setupPage() async {
    _podcastBloc = BlocProvider.of<PodcastBloc>(context);

    // Listen for duration updates
    _durSub = imp.durationStream.listen((ms) {
      total = ms;
      if (!seeking) _updateUi();
    });

    // Listen for position updates
    _posSub = imp.positionStream.listen((ms) {
      if (!seeking) {
        pass = ms;
        _updateUi();
      }
    });

    // Initial load
    total = await imp.getDuration();
    pass = imp.getCurrentPosition();
    _updateUi();
  }

  @override
  Widget build(BuildContext context) {
    pass = pass.clamp(0, total);

    return Column(
      children: [
        Row(
          children: [
            convertTime(pass),
            Expanded(
              child: Slider(
                value: pass.toDouble(),
                max: total.toDouble(),
                inactiveColor: Colors.grey,

                onChanged: (val) {
                  seeking = true;
                  pass = val.toInt();
                  _updateUi();
                },

                onChangeStart: (_) => seeking = true,

                onChangeEnd: (val) {
                  seeking = false;
                  imp.seek(Duration(milliseconds: val.floor()));
                },
              ),
            ),
            convertTime(total),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MediaControllerButton(
              svg: 'assets/icons/10back.svg',
              onPressed: () async {
                int dest = pass - 10000;
                if (dest < 0) dest = 0;
                await imp.seek(Duration(milliseconds: dest));
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/previous.svg',
              onPressed: () async {
                _podcastBloc.add(PlayPreviousPodcast());
                await _refreshAfterTrackChange();
              },
            ),

            PlayPauseButton(
              isLoading: imp.isLoading(),
              isPlaying: imp.isPlaying(),
              onPressed: () async {
                await imp.togglePlayState();
                _updateUi();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/next.svg',
              onPressed: () async {
                _podcastBloc.add(PlayNextPodcast());
                await _refreshAfterTrackChange();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/30forward.svg',
              onPressed: () async {
                int dest = pass + 30000;
                if (dest > total) dest = total;
                await imp.seek(Duration(milliseconds: dest));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget convertTime(int input) {
    return Text(AudioUtil.convertSeekBarTime(input));
  }

  Future<void> _refreshAfterTrackChange() async {
    pass = 0;
    total = await imp.getDuration();
    _updateUi();
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }
}
