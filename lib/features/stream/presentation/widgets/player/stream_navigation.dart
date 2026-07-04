import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class StreamNavigation extends StatefulWidget {
  const StreamNavigation({super.key});

  @override
  State<StreamNavigation> createState() => _StreamNavigationState();
}

class _StreamNavigationState extends State<StreamNavigation> {
  final StreamPlayerRepositoryImp imp = StreamPlayerRepositoryImp();

  // late final StreamBloc _streamBloc;

  int total = 1;
  int pass = 0;
  bool seeking = false;

  StreamSubscription<int>? _posSub;
  StreamSubscription<int>? _durSub;

  @override
  void initState() {
    super.initState();
    // _streamBloc = BlocProvider.of<StreamBloc>(context);
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
            PlayPauseButton(
              isPlaying: imp.isPlaying(),
              onPressed: () async {
                await imp.togglePlayState();
                _updateUi();
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

  void _updateUi() {
    if (mounted) setState(() {});
  }
}
