import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class PlayerNavigation extends StatefulWidget {
  const PlayerNavigation({super.key});

  @override
  State<PlayerNavigation> createState() => _PlayerNavigationState();
}

class _PlayerNavigationState extends State<PlayerNavigation> {
  final LocalPlayerRepositoryImp imp = LocalPlayerRepositoryImp();

  late final LocalBloc _localBloc;

  int total = 1;
  int pass = 0;
  bool seeking = false;

  StreamSubscription<int>? _posSub;
  StreamSubscription<int>? _durSub;

  @override
  void initState() {
    super.initState();
    _localBloc = BlocProvider.of<LocalBloc>(context);
    _setupStreams();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    // Duration Stream
    _durSub = imp.durationStream.listen((ms) {
      total = ms;
      if (!seeking) _updateUi();
    });

    // Position Stream
    _posSub = imp.positionStream.listen((ms) {
      if (!seeking) {
        pass = ms;
        _updateUi();
      }
    });

    // Init values once
    Future.microtask(() async {
      total = await imp.getDuration();
      pass = imp.getCurrentPosition();
      _updateUi();
    });
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
              svg: imp.repeatMode == RepeatMode.noRepeat
                  ? "assets/icons/no-repeat.svg"
                  : imp.repeatMode == RepeatMode.repeatOne
                  ? "assets/icons/repeat-one.svg"
                  : "assets/icons/repeat-all.svg",
              onPressed: () {
                imp.changeRepeatState();
                _updateUi();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/previous.svg',
              onPressed: () async {
                _localBloc.add(PlayPreviousAudio());
                await _refreshAfterTrackChange();
              },
            ),

            PlayPauseButton(
              isPlaying: imp.isPlaying(),
              onPressed: () async {
                await imp.togglePlayState();
                _updateUi();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/next.svg',
              onPressed: () async {
                _localBloc.add(PlayNextAudio());
                await _refreshAfterTrackChange();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/shuffle.svg',
              color: imp.isShuffle()
                  ? Theme.of(context).sliderTheme.thumbColor
                  : Theme.of(context).iconTheme.color!.withValues(alpha: 0.5),
              onPressed: () {
                imp.changeShuffleState();
                _updateUi();
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshAfterTrackChange() async {
    pass = 0;
    total = await imp.getDuration();
    _updateUi();
  }

  Widget convertTime(int input) {
    return Text(AudioUtil.convertSeekBarTime(input));
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }
}
