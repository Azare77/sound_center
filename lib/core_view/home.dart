// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast.dart';
import 'package:sound_center/features/settings/presentation/settings.dart';
import 'package:sound_center/generated/l10n.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int index = 0;
  late final LocalPlayerRepositoryImp _localPlayer;
  late final PodcastPlayerRepositoryImp _podcastPlayer;
  late final LocalAudios _localAudios;
  late final Podcast _podcast;
  late final AppLinks appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _localAudios = LocalAudios();
    _podcast = Podcast();
    appLinks = AppLinks();
    initDeepLinks();
    _localPlayer = LocalPlayerRepositoryImp();
    _podcastPlayer = PodcastPlayerRepositoryImp();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
      Map<String, String> params = uri.queryParameters;
      _podcast.handleDeepLink(context, params);
    });
  }

  void onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! < 0) {
      // swipe به چپ → بعدی
      setState(() => index = (index + 1) & 1);
    } else if (details.primaryVelocity! > 0) {
      // swipe به راست → قبلی
      setState(() => index = (index - 1) & 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (res, re) {
        if (!res) setState(() => index = 0);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GestureDetector(
              onHorizontalDragEnd: onSwipe,
              child: AppBar(
                title: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => const Settings(),
                    );
                  },
                  child: GestureDetector(
                    onHorizontalDragEnd: onSwipe,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 100),
                      child: Text("Sound Center", textAlign: TextAlign.center),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: index == 0
                        ? S.of(context).podcast
                        : S.of(context).local,
                    // use Bitwise Operations to change index between 0 and 1 (n)
                    onPressed: () => setState(() => index = (index + 1) & 1),
                    icon: Icon(
                      index == 0
                          ? Icons.podcasts_rounded
                          : Icons.music_note_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: index,
                children: [_localAudios, _podcast],
              ),
            ),
            const CurrentMedia(),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused ||
          AppLifecycleState.detached ||
          AppLifecycleState.inactive:
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
