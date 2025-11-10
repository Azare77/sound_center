import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
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
  late final Timer _timer;
  late Episode episode;
  int total = 1;
  int pass = 0;
  bool seeking = false;
  late PodcastBloc _podcastBloc;

  @override
  void initState() {
    super.initState();
    setupPage();
  }

  void setupPage() async {
    _podcastBloc = BlocProvider.of<PodcastBloc>(context);
    await _updateDuration();
    await _setUpTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            convertTime(pass),
            Expanded(
              child: Slider(
                value: pass.toDouble(),
                inactiveColor: Colors.grey,
                max: total.toDouble() + 0.1,
                onChanged: (val) async {
                  pass = val.toInt();
                  setState(() {
                    pass = val.toInt();
                  });
                },
                onChangeStart: (_) {
                  seeking = true;
                },
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
                int dest = await imp.getCurrentPosition() - 10000;
                await imp.seek(Duration(milliseconds: dest));
                await _updateDuration();
              },
            ),
            MediaControllerButton(
              svg: 'assets/icons/previous.svg',
              onPressed: () async {
                _podcastBloc.add(PlayPreviousPodcast());
                await _updateDuration();
              },
            ),
            PlayPauseButton(
              isLoading: imp.isLoading(),
              isPlaying: imp.isPlaying(),
              onPressed: () async {
                await imp.togglePlayState();
                setState(() {});
              },
            ),
            MediaControllerButton(
              svg: 'assets/icons/next.svg',
              onPressed: () async {
                _podcastBloc.add(PlayNextPodcast());
                await _updateDuration();
              },
            ),
            MediaControllerButton(
              svg: 'assets/icons/30forward.svg',
              onPressed: () async {
                int dest = await imp.getCurrentPosition() + 30000;
                await imp.seek(Duration(milliseconds: dest));
                await _updateDuration();
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                PodcastPlayerRepositoryImp().setSpeed(1.8);
              },
              icon: Icon(Icons.arrow_upward_rounded),
            ),
            IconButton(
              onPressed: () {
                PodcastPlayerRepositoryImp().setSpeed(1);
              },
              icon: Icon(Icons.arrow_downward_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget convertTime(int input) {
    final duration = Duration(milliseconds: input);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final timeStr = hours > 0
        ? "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"
        : "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";

    return Text(timeStr);
  }

  Future<void> _updateDuration() async {
    pass = 0;
    total = await imp.getDuration();
    pass = await imp.getCurrentPosition();
    if (mounted) setState(() {});
  }

  Future<void> _setUpTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      total = await imp.getDuration();
      pass = await imp.getCurrentPosition();
      if (!seeking && mounted) {
        setState(() {});
      }
    });
  }
}
