import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
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
  late final Timer _timer;
  late final LocalBloc _localBloc;
  late AudioEntity song;
  int total = 1;
  int pass = 0;
  bool seeking = false;

  @override
  void initState() {
    setupPage();
    _localBloc = BlocProvider.of<LocalBloc>(context);
    super.initState();
  }

  void setupPage() async {
    await _updateDuration();
    await _setUpTimer();
  }

  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (_) {}
    super.dispose();
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
                inactiveColor: Colors.grey,
                max: total.toDouble(),
                onChanged: (val) async {
                  _updateUi(fn: () => pass = val.clamp(0, total).toInt());
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
              svg: imp.repeatMode == RepeatMode.noRepeat
                  ? "assets/icons/no-repeat.svg"
                  : imp.repeatMode == RepeatMode.repeatOne
                  ? "assets/icons/repeat-one.svg"
                  : "assets/icons/repeat-all.svg",
              onPressed: () {
                _updateUi(fn: () => imp.changeRepeatState());
              },
            ),
            MediaControllerButton(
              svg: 'assets/icons/previous.svg',
              onPressed: () async {
                _localBloc.add(PlayPreviousAudio());
                await _updateDuration();
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
                await _updateDuration();
              },
            ),
            MediaControllerButton(
              svg: 'assets/icons/shuffle.svg',
              color: imp.isShuffle() ? Colors.blue : null,
              onPressed: () {
                _updateUi(fn: () => imp.changeShuffleState());
              },
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
    _updateUi();
  }

  Future<void> _setUpTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      total = await imp.getDuration();
      pass = await imp.getCurrentPosition();
      if (!seeking) {
        _updateUi();
      }
    });
  }

  void _updateUi({VoidCallback? fn}) {
    if (mounted) setState(fn ?? () {});
  }
}
