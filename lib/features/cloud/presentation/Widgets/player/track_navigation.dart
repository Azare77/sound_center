import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/play_pause_button.dart';

class TrackNavigation extends StatefulWidget {
  const TrackNavigation({super.key});

  @override
  State<TrackNavigation> createState() => _TrackNavigationState();
}

class _TrackNavigationState extends State<TrackNavigation> {
  final CloudPlayerRepositoryImp imp = CloudPlayerRepositoryImp();

  int total = 1;
  int pass = 0;
  bool seeking = false;
  bool loading = false;
  String svg10Back = "assets/icons/10backEn.svg";
  String svg30Forward = "assets/icons/30forwardEn.svg";

  late CloudBloc _cloudBloc;
  late SettingBloc _settingBloc;

  StreamSubscription<bool>? _loadingSub;
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
    _loadingSub?.cancel();
    super.dispose();
  }

  Future<void> _setupPage() async {
    _cloudBloc = BlocProvider.of<CloudBloc>(context);
    _settingBloc = BlocProvider.of<SettingBloc>(context);
    if (_settingBloc.state.locale == Locale("fa")) {
      svg10Back = "assets/icons/10back.svg";
      svg30Forward = "assets/icons/30forward.svg";
    }
    _loadingSub = imp.loadingStream.listen((loading) {
      this.loading = loading;
      _updateUi();
    });

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
      mainAxisSize: MainAxisSize.min,
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
              svg: 'assets/icons/previous.svg',
              onPressed: () async {
                _cloudBloc.add(PlayPreviousTrack());
                await _refreshAfterTrackChange();
              },
            ),

            PlayPauseButton(
              isLoading: loading,
              isPlaying: imp.isPlaying(),
              onPressed: () async {
                await imp.togglePlayState();
                _updateUi();
              },
            ),

            MediaControllerButton(
              svg: 'assets/icons/next.svg',
              onPressed: () async {
                _cloudBloc.add(PlayNextTrack());
                await _refreshAfterTrackChange();
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
