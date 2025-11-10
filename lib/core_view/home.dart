import 'package:flutter/material.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast.dart';
import 'package:sound_center/features/settings/presentation/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int index = 0;
  late final LocalPlayerRepositoryImp _localPlayer;

  late final PodcastPlayerRepositoryImp _podcastPlayer;

  @override
  void initState() {
    super.initState();
    _localPlayer = LocalPlayerRepositoryImp();
    _podcastPlayer = PodcastPlayerRepositoryImp();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onLongPress: () {
            showDialog(context: context, builder: (_) => Settings());
          },
          child: Text("Sound Center"),
        ),
        actions: [
          IconButton(
            tooltip: "local",
            onPressed: () {
              setState(() {
                index = 0;
              });
            },
            icon: Icon(Icons.music_note),
          ),
          IconButton(
            tooltip: "podcast",
            onPressed: () {
              setState(() {
                index = 1;
              });
            },
            icon: Icon(Icons.podcasts_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: index,
              children: [LocalAudios(), Podcast()],
            ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached || AppLifecycleState.inactive:
        if (_localPlayer.hasSource()) {
          int duration = await _localPlayer.getCurrentPosition();
          PlayerStateStorage.saveLastPosition(duration);
        } else if (_podcastPlayer.hasSource()) {
          int duration = await _podcastPlayer.getCurrentPosition();
          PlayerStateStorage.saveLastPosition(duration);
        }
        return;
      default:
        return;
    }
  }
}
