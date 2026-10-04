import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/categories.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/pages/category/category_page.dart';
import 'package:sound_center/features/local_audio/presentation/util/multi_select_controller.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/create_playlist_dialog.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/tool_bar.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
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
  late LocalBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<LocalBloc>(context);
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
    MultiSelectController.disable();
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
    return ValueListenableBuilder<bool>(
      valueListenable: MultiSelectController.multiSelect,
      child: _buildScaffold(),
      builder: (context, multiSelectActive, child) => PopScope(
        canPop: !multiSelectActive,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) MultiSelectController.disable();
        },
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (MultiSelectController.isActive) {
                MultiSelectController.disable();
              }
            },
          },
          child: Focus(autofocus: true, child: child!),
        ),
      ),
    );
  }

  void _handleShare(Category category, Set<Object> items) async {
    List<AudioEntity> sharingAudios = [];
    switch (category) {
      case Category.favorites:
        final audios = items.cast<AudioEntity>();
        sharingAudios = audios.toList();
        break;
      case Category.allSongs:
        final audios = items.cast<AudioEntity>();
        sharingAudios = audios.toList();
        break;
      case Category.artists:
        final artists = items.cast<ArtistEntity>();
        for (ArtistEntity item in artists) {
          sharingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.albums:
        final albums = items.cast<AlbumEntity>();
        for (AlbumEntity item in albums) {
          sharingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.genres:
        final genres = items.cast<GenreEntity>();
        for (GenreEntity item in genres) {
          sharingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.folders:
        final folders = items.cast<FolderEntity>();
        for (FolderEntity item in folders) {
          sharingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      default:
        break;
    }
    if (!Platform.isLinux) {
      await SharePlus.instance.share(
        ShareParams(
          files: sharingAudios.map((audio) => XFile(audio.path)).toList(),
        ),
      );
    }
  }

  void _handleDelete(Category category, Set<Object> items) async {
    bool res =
        await showDialog(context: context, builder: (_) => ConfirmDialog()) ??
        false;
    if (!res) return;
    List<AudioEntity> removingAudios = [];
    switch (category) {
      case Category.favorites:
        final audios = items.cast<AudioEntity>();
        removingAudios = audios.toList();
        break;
      case Category.allSongs:
        final audios = items.cast<AudioEntity>();
        removingAudios = audios.toList();
        break;
      case Category.playlists:
        final playlists = items.cast<PlaylistEntity>();
        final playlistIds = playlists.map((playlist) => playlist.id).toList();
        bloc.add(DeletePlaylists(playlistIds: playlistIds));
        break;
      case Category.artists:
        final artists = items.cast<ArtistEntity>();
        for (ArtistEntity item in artists) {
          removingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.albums:
        final albums = items.cast<AlbumEntity>();
        for (AlbumEntity item in albums) {
          removingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.genres:
        final genres = items.cast<GenreEntity>();
        for (GenreEntity item in genres) {
          removingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
      case Category.folders:
        final folders = items.cast<FolderEntity>();
        for (FolderEntity item in folders) {
          removingAudios.addAll(
            AudioUtil.allAudios
                .where((audio) => audio.artist.trim() == item.name)
                .toList(),
          );
        }
        break;
    }

    bloc.add(DeleteAudios(removingAudios));
  }

  Widget _buildScaffold() {
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
                onShare: (items) {
                  _handleShare(Category.values[_tabController.index], items);
                  MultiSelectController.disable();
                },
                onDelete: (items) {
                  _handleDelete(Category.values[_tabController.index], items);
                  MultiSelectController.disable();
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
