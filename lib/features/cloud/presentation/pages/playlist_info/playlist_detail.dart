// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_repository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/pages/playlist_info/playlist_info.dart';
import 'package:sound_center/features/cloud/presentation/pages/playlist_info/track_tool_bar.dart';
import 'package:sound_center/features/cloud/presentation/pages/playlist_info/tracks.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({super.key, required this.playlist});

  final CloudPlaylist playlist;

  @override
  State<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  final CloudRepositoryImp repository = CloudRepositoryImp(AppDatabase());
  bool toolbarCollapsed = false;
  bool initialized = false;
  List<CloudTrack> allTracks = [];
  List<CloudTrack> tracks = [];
  String? image;
  final ScrollController _sliverScrollController = ScrollController();

  void _init({bool retry = true}) async {
    try {
      allTracks = await repository.loadPlaylistTracks(widget.playlist);
      image ??= widget.playlist.artworkUrl?.toString();
    } catch (_) {
      allTracks = [];
    } finally {
      if (allTracks == [] && mounted) {
        if (retry) {
          _init(retry: false);
        } else {
          if (mounted) Navigator.pop(context);
        }
      }
    }
    tracks = allTracks;
    initialized = true;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    image = widget.playlist.artworkUrl?.toString();
    double totalExpandableRange = EXPANDED_HEIGHT - kToolbarHeight;
    _sliverScrollController.addListener(() {
      bool hasClient = _sliverScrollController.hasClients;
      bool isOffsetBigger =
          _sliverScrollController.offset > totalExpandableRange;
      setState(() {
        if (!toolbarCollapsed && hasClient && isOffsetBigger) {
          toolbarCollapsed = true;
        } else if (toolbarCollapsed && hasClient && !isOffsetBigger) {
          toolbarCollapsed = false;
        }
      });
    });
    _init();
  }

  @override
  void dispose() {
    _sliverScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _sliverScrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight: kToolbarHeight,
                  elevation: 2,
                  shadowColor: themeData.appBarTheme.shadowColor,
                  backgroundColor: themeData.appBarTheme.backgroundColor,
                  pinned: true,
                  floating: false,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    color: toolbarCollapsed
                        ? themeData.iconTheme.color
                        : Colors.white,
                  ),
                  title: AnimatedOpacity(
                    opacity: toolbarCollapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(widget.playlist.title),
                  ),
                  expandedHeight: EXPANDED_HEIGHT,
                  flexibleSpace: PlaylistInfo(
                    url: image,
                    playlist: widget.playlist,
                  ),
                ),
                if (tracks.isNotEmpty)
                  SliverPinnedHeader(
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Focus(
                        onFocusChange: (f) async {
                          if (f) {
                            final offset = _sliverScrollController.offset;
                            for (int i = 0; i <= 500; i++) {
                              _sliverScrollController.jumpTo(offset);
                              await Future.delayed(Duration(milliseconds: 1));
                            }
                          }
                        },
                        child: TrackToolBar(onChange: filter),
                      ),
                    ),
                  ),
                tracks.isEmpty && !initialized
                    ? SliverFillRemaining(child: Loading())
                    : tracks.isNotEmpty && initialized
                    ? Tracks(tracks: tracks, bestImageUrl: image)
                    : SliverFillRemaining(
                        child: Center(child: Text("NO DRF FREE MUSIC")),
                      ),
              ],
            ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }

  void filter(String name) {
    name = name.trim().toLowerCase();
    if (name.isEmpty) {
      tracks = allTracks;
    } else {
      tracks = allTracks
          .where((item) => item.title.toLowerCase().contains(name))
          .toList();
    }
    setState(() {});
  }
}

class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({super.key, required Widget super.child});

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}

class RenderSliverPinnedHeader extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final paintedChildExtent = min(
      childExtent,
      constraints.remainingPaintExtent - constraints.overlap,
    );
    geometry = SliverGeometry(
      paintExtent: paintedChildExtent,
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: childExtent,
      paintOrigin: constraints.overlap,
      scrollExtent: childExtent,
      layoutExtent: max(0.0, paintedChildExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedChildExtent < childExtent,
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return 0;
  }
}
