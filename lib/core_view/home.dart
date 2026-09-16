// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/shared_preferences/player_state_storage.dart';
import 'package:sound_center/features/cloud/presentation/pages/cloud.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast.dart';
import 'package:sound_center/features/settings/presentation/settings.dart';
import 'package:sound_center/features/stream/presentation/pages/stream.dart';
import 'package:sound_center/generated/l10n.dart';

typedef NavItem = ({IconData icon, String title, bool badge});

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _menuDuration = Duration(milliseconds: 180);
  static const _blurSigma = 8.0;
  static const _scrimOpacity = 0.18;

  int index = 0;
  late final LocalPlayerRepositoryImp _localPlayer;
  late final PodcastPlayerRepositoryImp _podcastPlayer;
  late final LocalAudios _localAudios;
  late final Podcast _podcast;
  late final StreamPage _stream;
  late final CloudPage _cloud;
  late final AppLinks appLinks;
  late final StreamSubscription<Uri> _linkSubscription;

  late final AnimationController _menuCtrl;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _localAudios = LocalAudios();
    _podcast = Podcast();
    _stream = StreamPage();
    _cloud = CloudPage();
    appLinks = AppLinks();
    initDeepLinks();
    _localPlayer = LocalPlayerRepositoryImp();
    _podcastPlayer = PodcastPlayerRepositoryImp();
    _menuCtrl = AnimationController(vsync: this, duration: _menuDuration);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _menuCtrl.dispose();
    _linkSubscription.cancel();
    super.dispose();
  }

  String? _lastHandledLink;

  Future<void> initDeepLinks() async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
      final normalized = Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        queryParameters: uri.queryParameters,
      ).toString();

      if (_lastHandledLink == normalized) return;
      _lastHandledLink = normalized;
      _closeMenu();

      final params = uri.queryParameters;

      switch (uri.path) {
        case '/podcast':
          _podcast.handleDeepLink(context, params);
          break;

        case '/stream':
          _stream.handleDeepLink(context, params);
          break;
      }
      await Future.delayed(const Duration(seconds: 1));
      _lastHandledLink = null;
    });
  }

  List<NavItem> _navItems(BuildContext context) {
    final hasNewEpisode = _podcast.haveNewEpisode(context);
    return [
      (
        icon: Icons.music_note_rounded,
        title: S.of(context).local,
        badge: false,
      ),
      (
        icon: Icons.podcasts_rounded,
        title: S.of(context).podcast,
        badge: hasNewEpisode,
      ),
      (icon: Icons.radio_rounded, title: S.of(context).stream, badge: false),
      // TODO: کلید `cloud` را به l10n اضافه کن و این literal را با S.of(context).cloud عوض کن.
      (icon: Icons.cloud_rounded, title: 'Cloud', badge: false),
    ];
  }

  void _toggleMenu() {
    if (_menuOpen) {
      _closeMenu();
    } else {
      setState(() => _menuOpen = true);
      _menuCtrl.forward();
    }
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() => _menuOpen = false);
    _menuCtrl.reverse();
  }

  void _selectIndex(int i) {
    if (i != index) setState(() => index = i);
    _closeMenu();
  }

  void onSwipe(DragEndDetails details) {
    if (_menuOpen) {
      _closeMenu();
      return;
    }
    if (details.primaryVelocity == null) return;
    setState(() {
      if (details.primaryVelocity! < 0) {
        // swipe به چپ → بعدی
        index++;
      } else if (details.primaryVelocity! > 0) {
        // swipe به راست → قبلی
        index--;
      }
      if (index == 4) index = 0;
      if (index < 0) index = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0 && !_menuOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_menuOpen) {
          _closeMenu();
          return;
        }

        final canSwitchPage = _podcast.resetPodcastPage(context);
        final canSwitchStream = _stream.resetStreamPage(context);
        final canSwitchCloud = _cloud.resetCloudPage(context);
        if (index == 1 && canSwitchPage) setState(() => index = 0);
        if (index == 2 && canSwitchStream) setState(() => index = 0);
        if (index == 3 && canSwitchCloud) setState(() => index = 0);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GestureDetector(
              onHorizontalDragEnd: onSwipe,
              child: AppBar(
                title: const Text("Sound Center", textAlign: TextAlign.center),
                leading: IconButton(
                  onPressed: () {
                    _closeMenu();
                    showDialog(
                      context: context,
                      builder: (_) => const Settings(),
                    );
                  },
                  icon: const Icon(Icons.settings_rounded),
                ),
                actions: [_buildMenuButton(context)],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  IndexedStack(
                    index: index,
                    children: [_localAudios, _podcast, _stream, _cloud],
                  ),
                  _buildMenuLayer(context),
                ],
              ),
            ),
            const CurrentMedia(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        final items = _navItems(context);
        final showBadge = items.any((e) => e.badge) && index != 1;
        return IconButton(
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onPressed: _toggleMenu,
          icon: Badge(
            label: const SizedBox.shrink(),
            backgroundColor: Colors.red,
            isLabelVisible: showBadge,
            child: AnimatedRotation(
              turns: _menuOpen ? 0.125 : 0,
              duration: _menuDuration,
              child: Icon(items[index].icon),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuLayer(BuildContext context) {
    return AnimatedBuilder(
      animation: _menuCtrl,
      builder: (context, _) {
        if (_menuCtrl.isDismissed) return const SizedBox.shrink();
        final t = Curves.easeOut.transform(_menuCtrl.value);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMenu,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurSigma * t,
                      sigmaY: _blurSigma * t,
                    ),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: _scrimOpacity * t),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.9 + 0.1 * t,
                  alignment: Alignment.topRight,
                  child: _buildMenuCard(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 190, maxWidth: 260),
        child: BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            final items = _navItems(context);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  InkWell(
                    onTap: () => _selectIndex(i),
                    child: Container(
                      color: i == index
                          ? scheme.primary.withValues(alpha: 0.10)
                          : null,
                      padding: const EdgeInsetsDirectional.only(
                        start: 16,
                        end: 12,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Badge(
                            label: const SizedBox.shrink(),
                            backgroundColor: Colors.red,
                            isLabelVisible: items[i].badge,
                            child: Icon(
                              items[i].icon,
                              color: i == index ? scheme.primary : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              items[i].title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: i == index
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: i == index ? scheme.primary : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: i == index
                                ? scheme.primary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      Navigator.of(context).pushAndRemoveUntil(
        NoAnimationPageRoute(page: const Home()),
        (Route<dynamic> route) => false,
      );
      await saveLastPosition();
    }
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.inactive:
        saveLastPosition();
        break;
      default:
        break;
    }
  }

  Future<void> saveLastPosition() async {
    if (_localPlayer.hasSource()) {
      int duration = _localPlayer.getCurrentPosition();
      await PlayerStateStorage.saveLastPosition(duration);
    } else if (_podcastPlayer.hasSource()) {
      int duration = _podcastPlayer.getCurrentPosition();
      await PlayerStateStorage.saveLastPosition(duration);
    }
  }
}

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NoAnimationPageRoute({required this.page})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => page,
      );
}
