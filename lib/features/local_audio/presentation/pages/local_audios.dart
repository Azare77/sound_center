import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/pages/category/category_page.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/create_playlist_dialog.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/tool_bar.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class LocalAudios extends StatefulWidget {
  const LocalAudios({super.key});

  @override
  State<LocalAudios> createState() => _LocalAudiosState();
}

class _LocalAudiosState extends State<LocalAudios>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _lastIndex = 0;
  String _query = '';
  List<AudioEntity> _audios = const [];
  List<AudioEntity> _favorites = const [];
  List<PlaylistEntity> _playlists = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: Category.values.length, vsync: this)
      ..addListener(_onTabChanged);
  }

  void _setQuery(String q) {
    if (q == _query) return;
    setState(() => _query = q);
  }

  void _onTabChanged() {
    final i = _tabController.index;
    if (i == _lastIndex) return;
    _lastIndex = i;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<LocalBloc>().add(GetLocalAudios());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalBloc, LocalState>(
      listener: (context, state) {
        final s = state.status;
        if (s is LocalAudioStatus) {
          setState(() => _audios = s.audios);
        } else if (s is LocalFavoriteStatus) {
          setState(() => _favorites = s.audios);
        } else if (s is LocalPlayListsStatus) {
          setState(() => _playlists = s.playlists);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            ListenableBuilder(
              listenable: _tabController,
              builder: (context, _) => ToolBar(
                onQueryChanged: _setQuery,
                index: _tabController.index,
                onOrderChange: (column, desc) {
                  List<AudioEntity> audios = AudioUtil.sort(
                    _audios,
                    column,
                    desc,
                  );
                  setState(() => _audios = audios);
                  audios = AudioUtil.sort(_favorites, column, desc);
                  setState(() => _favorites = audios);
                },
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
              indicator: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              splashBorderRadius: BorderRadius.circular(12),
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                for (final c in Category.values)
                  Tab(child: Text(c.title(context))),
              ],
            ),
            Expanded(
              child: _audios.isEmpty
                  ? Loading(label: S.of(context).scanning)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        for (final c in Category.values)
                          CategoryPage(
                            category: c,
                            items: switch (c) {
                              Category.favorites => _favorites,
                              _ => _audios,
                            },
                            playlists: c == Category.playlists
                                ? _playlists
                                : const [],
                            query: _query,
                          ),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: AnimatedScale(
            scale: _tabController.index == 2 ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CreatePlaylistDialog(),
                );
              },
              child: Icon(Icons.playlist_add_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
