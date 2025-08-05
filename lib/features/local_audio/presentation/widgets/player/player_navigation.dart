import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

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
            IconButton(
              onPressed: () {
                setState(() {
                  imp.changeRepeatState();
                });
              },
              icon: Icon(
                imp.repeatMode == RepeatMode.noRepeat
                    ? Icons.repeat
                    : imp.repeatMode == RepeatMode.repeatOne
                    ? Icons.repeat_one
                    : Icons.repeat_on_rounded,
              ),
            ),
            IconButton(
              onPressed: () async {
                _localBloc.add(PlayPreviousAudio());
                await _updateDuration();
              },
              icon: Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: () async {
                await imp.togglePlayState();
                setState(() {});
              },
              icon: Icon(imp.isPlaying() ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              onPressed: () async {
                _localBloc.add(PlayNextAudio());
                await _updateDuration();
              },
              icon: Icon(Icons.chevron_right),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  imp.changeShuffleState();
                });
              },
              icon: Icon(
                Icons.shuffle,
                color: imp.isShuffle() ? Colors.blue : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget convertTime(int input) {
    int duration = ((input) / 1000).floor();
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    String secondsStr = seconds.toString().padLeft(2, '0');
    return SizedBox(width: 40, child: Text("$minutes:$secondsStr"));
  }

  Future<void> _updateDuration() async {
    pass = 0;
    total = await imp.getDuration();
    pass = await imp.getCurrentPosition();
    setState(() {});
  }

  Future<void> _setUpTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      total = await imp.getDuration();
      pass = await imp.getCurrentPosition();
      if (!seeking) {
        setState(() {});
      }
    });
  }
}
