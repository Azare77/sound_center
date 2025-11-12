import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/episodes.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_info.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episodes_tool_bar.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class PodcastDetail extends StatefulWidget {
  const PodcastDetail({
    super.key,
    required this.feedUrl,
    this.needToUpdate = false,
    this.defaultImg,
  });

  final String feedUrl;
  final bool needToUpdate;
  final String? defaultImg;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final PodcastRepositoryImp db = PodcastRepositoryImp(AppDatabase());
  bool subscribed = false;
  bool toolbarCollapsed = false;
  Podcast? podcast;
  List<Episode> episodes = [];
  final ScrollController _sliverScrollController = ScrollController();

  void _init({bool retry = true}) async {
    try {
      subscribed = await db.isSubscribed(widget.feedUrl);
      podcast = await Feed.loadFeed(url: widget.feedUrl);
      if (subscribed) {
        _update();
      }
      if (podcast != null) {
        episodes = podcast!.episodes;
      }
    } catch (_) {
      podcast = null;
    } finally {
      if (podcast == null) {
        if (retry) {
          _init(retry: false);
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
                  shadowColor: Color(0xFF601410),
                  backgroundColor: Color(0xff202138),
                  pinned: true,
                  floating: false,
                  title: AnimatedOpacity(
                    opacity: toolbarCollapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(podcast?.title ?? ""),
                  ),
                  expandedHeight: EXPANDED_HEIGHT,
                  flexibleSpace: PodcastInfo(
                    subscribe: _subscribe,
                    subscribed: subscribed,
                    podcast: podcast,
                    url: widget.defaultImg,
                  ),
                ),
                // if (podcast != null)
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
                      child: EpisodesToolBar(onChange: filter),
                    ),
                  ),
                ),
                podcast == null
                    ? SliverFillRemaining(child: Loading())
                    : Episodes(
                        episodes: episodes,
                        bestImageUrl: widget.defaultImg,
                      ),
              ],
            ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }

  void _subscribe() async {
    SubscriptionEntity sub = SubscriptionEntity.fromPodcast(
      widget.feedUrl,
      podcast!,
    );
    PodcastEvent event;
    if (subscribed) {
      event = UnsubscribeFromPodcast(sub.feedUrl);
    } else {
      event = SubscribeToPodcast(sub);
    }
    BlocProvider.of<PodcastBloc>(context).add(event);
    setState(() {
      subscribed = !subscribed;
    });
  }

  void _update() async {
    SubscriptionEntity sub = SubscriptionEntity.fromPodcast(
      widget.feedUrl,
      podcast!,
    );
    if (subscribed && widget.needToUpdate) {
      PodcastEvent event = UpdateSubscribedPodcast(sub);
      BlocProvider.of<PodcastBloc>(context).add(event);
    }
  }

  void filter(String name) {
    if (name.isEmpty) {
      episodes = podcast?.episodes ?? [];
    } else {
      episodes = podcast!.episodes
          .where((item) => item.title.contains(name))
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
